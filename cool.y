/*
 *  cool.y
 *              Parser definition for the COOL language.
 *
 */
%{
#include "cool-tree.h"
#include "stringtab.h"
#include "utilities.h"

/* Set the size of the parser stack to be sufficient large to accomodate
    our tests.  There seems to be some problem with Bison's dynamic
    reallocation of the parser stack, as it should resize to a max
    size of YYMAXDEPTH, which is by default 10000. */
#define YYINITDEPTH 3000

/* Locations */
#define YYLTYPE int              /* the type of locations */
#define cool_yylloc curr_lineno  /* use the curr_lineno from the lexer
                                    for the location of tokens */
extern int node_lineno;          /* set before constructing a tree node
                                    to whatever you want the line number
                                    for the tree node to be */

/* The default action for locations.  Use the location of the first
    terminal/non-terminal and set the node_lineno to that value. */
#define YYLLOC_DEFAULT(Current, Rhs, N)		  \
  Current = (Rhs)[1];                             \
  node_lineno = Current;

#define SET_NODELOC(Current)			\
  node_lineno = Current;

/* IMPORTANT NOTE ON LINE NUMBERS
*********************************
* The above definitions and macros cause every terminal in your grammar to
* have the line number supplied by the lexer. The only task you have to
* implement for line numbers to work correctly, is to use SET_NODELOC()
* before constructing any constructs from non-terminals in your grammar.
* Example: Consider you are matching on the following very restrictive
* (fictional) construct that matches a plus between two integer constants.
* (SUCH A RULE SHOULD NOT BE  PART OF YOUR PARSER):

plus_consts : INT_CONST '+' INT_CONST

* where INT_CONST is a terminal for an integer constant. Now, a correct
* action for this rule that attaches the correct line number to plus_const
* would look like the following:

plus_consts : INT_CONST '+' INT_CONST
{
// Set the line number of the current non-terminal:
// ***********************************************
// You can access the line numbers of the i'th item with @i, just
// like you acess the value of the i'th exporession with $i.
//
// Here, we choose the line number of the last INT_CONST (@3) as the
// line number of the resulting expression (@$). You are free to pick
// any reasonable line as the line number of non-terminals. If you
// omit the statement @$=..., bison has default rules for deciding which
// line number to use. Check the manual for details if you are interested.
@$ = @3;


// Observe that we call SET_NODELOC(@3); this will set the global variable
// node_lineno to @3. Since the constructor call "plus" uses the value of
// this global, the plus node will now have the correct line number.
SET_NODELOC(@3);

// construct the result node:
$$ = plus(int_const($1), int_const($3));
}

*/

extern char *curr_filename;

void yyerror(const char *s);  /*  defined below; called for each parse error */
extern int yylex();           /*  the entry point to the lexer  */
Program ast_root;	      /* the result of the parse  */
Classes parse_results;        /* for use in semantic analysis */
int omerrs = 0;               /* number of erros in lexing and parsing */
%}

/* A union of all the types that can be the result of parsing actions. */
%union {
  bool boolean;
  Symbol symbol;
  Program program;
  Class_ class_;
  Classes classes;
  Feature feature;
  Features features;
  Formal formal;
  Formals formals;
  Case case_;
  Cases cases;
  Expression expression;
  Expressions expressions;
  const char *error_msg;
}

/*
    Declare the terminals; a few have types for associated lexemes.
    The token ERROR is never used in the parser; thus, it is a parse
    error when the lexer returns it.

    The integer following token declaration is the numeric constant used
    to represent that token internally.  Typically, Bison generates these
    on its own, but we give explicit numbers to prevent version parity
    problems (bison 1.25 and earlier start at 258, later versions -- at
    257)

    NOTE: these numbers need to match what's in cool-parse.h !
  */
%token CLASS 258 ELSE 259 FI 260 IF 261 IN 262
%token INHERITS 263 LET 264 LOOP 265 POOL 266 THEN 267 WHILE 268
%token CASE 269 ESAC 270 OF 271 DARROW 272 NEW 273 ISVOID 274
%token <symbol>  STR_CONST 275 INT_CONST 276
%token <boolean> BOOL_CONST 277
%token <symbol>  TYPEID 278 OBJECTID 279
%token ASSIGN 280 NOT 281 LE 282 ERROR 283

/*  DON'T CHANGE ANYTHING ABOVE THIS LINE, OR YOUR PARSER WONT WORK       */
/**************************************************************************/

/* Complete the nonterminal list below, giving a type for the semantic
    value of each non terminal. (See section 3.6 in the bison 
    documentation for details). */

/* Declare types for the grammar's non-terminals . */
%type <program> program 
%type <classes> class_list 
%type <class_> class 
%type <features> optional_feature_list 
%type <features> feature_list
%type <feature> feature 
%type <formal> formal 
%type <formals> formals formal_list 
%type <expression> expr 
%type <expression> let_body 
%type <expressions> expr_list 
%type <expressions> expr_block_list
%type <case_> case
%type <cases> case_list

/* Precedence declarations go here. */
%nonassoc IN
%right ASSIGN
%left NOT
%nonassoc LE '<' '='
%left '+' '-'
%left '*' '/'
%left ISVOID
%left '~'
%left '@'
%left '.'

%%
// Save the root of the abstract syntax tree in a global variable.
program	: class_list	{ @$ = @1; ast_root = program($1); };

class_list
: class			/* single class */
{ $$ = single_Classes($1);
  parse_results = $$; }
| error ';' 
{ yyerrok; }
| class_list class	/* several classes */
{ $$ = append_Classes($1,single_Classes($2));
  parse_results = $$; }
|  class_list[a1] error ';'
{ $$ = $a1;
  yyerrok; }

/* If no parent is specified, the class inherits from the Object class. */
class	: CLASS TYPEID '{' optional_feature_list '}' ';'
{ $$ = class_($2,idtable.add_string("Object"),$4,
        stringtable.add_string(curr_filename)); }
| CLASS TYPEID INHERITS TYPEID '{' optional_feature_list '}' ';'
{ $$ = class_($2,$4,$6,stringtable.add_string(curr_filename)); }

/* Feature list may be empty, but no empty features in list. */
optional_feature_list:		/* empty */
{  $$ = nil_Features(); }
| feature_list 
{ $$ = $1; }

feature_list: feature ';'
{ $$ = single_Features($1); }
| error ';'
{ yyerrok; }
| feature_list feature ';'
{ $$ = append_Features($1, single_Features($2)); }
| feature_list[a1] error ';'
{ $$ = $a1;
  yyerrok; };
/* end of grammar */

feature[res]: OBJECTID[a1] formals[a2] ':' TYPEID[a3] '{' expr[a4] '}'
{ $res = method($a1, $a2, $a3, $a4); }
| OBJECTID[a1] ':' TYPEID[a2]
{ $res = attr($a1, $a2, no_expr()); }
| OBJECTID[a1] ':' TYPEID[a2] ASSIGN expr[a3]
{ $res = attr($a1, $a2, $a3); };

formals[res]: '(' ')'
{ $res = nil_Formals(); }
| '(' formal_list[a1] ')'
{ $res = $a1; }

formal_list[res]: formal[a1]
{ $res = single_Formals($a1); }
| formal_list[a2] ',' formal[a1]
{ $res = append_Formals($a2, single_Formals($a1)); };

formal[res]: OBJECTID[a1] ':' TYPEID[a2]
{ $res = formal($a1, $a2); };

expr[res]: OBJECTID[a1] ASSIGN expr[a2]
{ $res = assign($a1, $a2); }
| expr[a1]'.'OBJECTID[a2]'('')'
{ $res = dispatch($a1, $a2, nil_Expressions()); }
| expr[a1]'.'OBJECTID[a2]'(' expr_list[a3] ')'
{ $res = dispatch($a1, $a2, $a3); }
| expr[a1]'@'TYPEID[a2]'.'OBJECTID[a3]'('')'
{ $res = static_dispatch($a1, $a2, $a3, nil_Expressions()); }
| expr[a1]'@'TYPEID[a2]'.'OBJECTID[a3]'('expr_list[a4]')'
{ $res = static_dispatch($a1, $a2, $a3, $a4); }
| OBJECTID[a1]'('')'
{ $res = dispatch(object(idtable.add_string("self")), $a1, nil_Expressions()); }
| OBJECTID[a1]'('expr_list[a2]')'
{ $res = dispatch(object(idtable.add_string("self")), $a1, $a2); }
| IF expr[a1] THEN expr[a2] ELSE expr[a3] FI
{ $res = cond($a1, $a2, $a3); }
| WHILE expr[a1] LOOP expr[a2] POOL
{ $res = loop($a1, $a2); }
| '{' expr_block_list[a1] '}'
{ $res = block($a1); }
| LET let_body[a1]
{ $res = $a1; }
| CASE expr[a1] OF case_list[a2] ESAC
{ $res = typcase($a1, $a2); }
| NEW TYPEID[a1]
{ $res = new_($a1); }
| ISVOID expr[a1]
{ $res = isvoid($a1); }
| expr[a1] '+' expr[a2]
{ $res = plus($a1, $a2); }
| expr[a1] '-' expr[a2]
{ $res = sub($a1, $a2); }
| expr[a1] '*' expr[a2]
{ $res = mul($a1, $a2); }
| expr[a1] '/' expr[a2]
{ $res = divide($a1, $a2); }
| '~'expr[a1]
{ $res = neg($a1); }
| expr[a1] '<' expr[a2]
{ $res = lt($a1, $a2); }
| expr[a1] LE expr[a2]
{ $res = leq($a1, $a2); }
| expr[a1] '=' expr[a2]
{ $res = eq($a1, $a2); }
| NOT expr[a1]
{ $res = comp($a1); }
| '('expr[a1]')'
{ $res = $a1; }
| OBJECTID[a1]
{ $res = object($a1); }
| INT_CONST[a1]
{ $res = int_const($a1); }
| STR_CONST[a1]
{ $res = string_const($a1); }
| BOOL_CONST[a1]
{ $res = bool_const($a1); }

expr_list[res]: expr[a1]
{ $res = single_Expressions($a1); }
|  expr[a1] ',' expr_list[a2]
{ $res = append_Expressions(single_Expressions($a1), $a2); }

expr_block_list[res]: expr[a1]';'
{ $res = single_Expressions($a1); }
| error ';'
{ $res = nil_Expressions(); 
  yyerrok; }
| expr[a1] ';' expr_block_list[a2]
{ $res = append_Expressions(single_Expressions($a1), $a2); }
| error ';' expr_block_list[a1] 
{ $$ = $a1;
  yyerrok; }

case_list[res]: case[a1]
{ $res = single_Cases($a1); }
| case_list[a1] case[a2]
{ $res = append_Cases($a1, single_Cases($a2)); }

case[res]: OBJECTID[a1] ':' TYPEID[a2] DARROW expr[a3]';'
{ $res = branch($a1, $a2, $a3); }

let_body[res]: OBJECTID[a1] ':' TYPEID[a2] IN expr[a3]
{ $res = let($a1, $a2, no_expr(), $a3); }
| OBJECTID[a1] ':' TYPEID[a2] ASSIGN expr[a3] IN expr[a4]
{ $res = let($a1, $a2, $a3, $a4); }
| OBJECTID[a1] ':' TYPEID[a2] ',' let_body[a3]
{ $res = let($a1, $a2, no_expr(), $a3); }
| OBJECTID[a1] ':' TYPEID[a2] ASSIGN expr[a3] ',' let_body[a4]
{ $res = let($a1, $a2, $a3, $a4); }
| error ',' let_body[a1] 
{ $$ = $a1; 
  yyerrok; }

%%

/* This function is called automatically when Bison detects a parse error. */
void yyerror(const char *s)
{
  extern int curr_lineno;

  std::cerr << "\"" << curr_filename << "\", line " << curr_lineno << ": " \
    << s << " at or near ";
  print_cool_token(yychar);
  std::cerr << std::endl;
  omerrs++;
  if(omerrs>50) { std::cerr << "More than 50 errors" << std::endl; exit(1);}
}