(* If there is an error in a class definition but the 
   class is terminated properly and the next class is
   syntactically correct, the parser should be able to 
   restart at the next class definition. *)

(* missing { *)
class A 
    x: Int;
};

(* missing } *)
class B {
    x: Int;
;

(* missing ; after class *)
class A {
    x: Int:
} 
class B {
    y: Bool;
}

(* bad use of inherits*)
class C inherits {
    x: Int;
};

(* no inherits keyword *)
class C D {
    y: Bool:
};

(* garbage in middle of prog *)
class A {
    x: Int:
};
%somethingRandom
class B {
    y: Bool;
}

(* empty class *)
class B inherits C {

}

(* invalid featurelist *)
class A {
    5 + ;
};

(* empty feature that breaks*)
class A {
    ;
};

(* Multiple classes, first is broken *)
class Broken {
    5 + ;
}; 
class Recover {
    x : Int;
};

(* Multiple classes, second is broken *)
class AllGood {
    5 + ;
}; 
class NotGood {
    x : Int;
};


(* Similarly, the parser should recover from errors in features (going on to the next feature), a let binding
(going on to the next variable), and an expression inside a {...} block. *)

-- FEATURE LIST

(* Missing type in feature list *)
class A {
    x : Int;
    error_feature
    y : Bool;
};

(* Multiple errors to test recovery)
class B {
    bad
    not good 
    x : Int;
    no_comma
    y : Bool;
};

(* Empty feature list, should catch class error *)
class C inherits D {
    obj(): Int {
        ;
    };
};

(* Feature without ; *)
class E {
    obj(): Int {
        what's wrong?
    };
};

(* Bad list *)
class F {
  x : Int;
  y : Bool --
  foo(x: Int, y: Bool): Bool { x + 1 };
}

(* Embedded feature + : *)
class G {
    hello(foo(): Int:);
}

-- Attribute missing
class A {
  x : Int <- ;
};

-- Attribute missing but recover
class B {
  x : Int 5;
};

-- Missing colon before type
class A {
  foo(x: Int) Int { x };
};

-- FORMALS

-- Missing comma
class A {
  foo(x: Int y: Bool): Bool { x + 1 };
}

-- Trailing comma in formal list
class A {
  foo(x: Int, ) : Int { x };
};

-- Attribute missing TYPE
class A {
  x : { 5 };
};

-- Method missing parameter list parentheses
class A {
  foo x: Int { x };
};

-- Missing colon and no {} body

class A {
  foo(x: Int) Int x + 1;
};

-- Missing parens, colon, type
class A {
  foo x Int { x };
};

-- Missing colon, wrong assignment, 
class A {
  x Int <- 5;
};

-- Error in method body
class A {
  foo(x: Int): Int {
    error_here
};
};

-- Nested errors 
class A {
  foo(x: Int): Int {
    {
      5;
      error_block;
      6;
    }
  };
};

-- Attribute assignment
class A {
  x : Int <- 5
  y : Bool <- true
  z : String <- "hello";
};

-- EXPRS

-- Nested block
class A {
  foo(x: Int): Int {
    {
      5;
      error_block;
      6;
    }
  };
};

-- Missing semicolons
class A {
  x : Int <- 5
  y : Bool <- true
  z : String <- "hello";
};

-- Let binding missing in
class A {
  foo(x: Int): Int {
    let a : Int <- 5, b : Bool <- true 
    a + b;
  };
};

-- Trailing comma
class A {
  foo(x: Int): Int {
    let a : Int <- 5, in a;
  };
};

-- KEYWORDS
-- Missing then
class A {
  foo(x: Int): Int {
    if x < 5 x else 5 fi;
  };
};

-- Missing else
class A {
  foo(x: Int): Int {
    if x < 5 then 6 fi;
  };
};

-- Missing while
class A {
  foo(x: Int): Int {
    while x < 5 x;
  };
};

-- Missing pool
class A {
  foo(x: Int): Int {
    while x < 5 loop x + 1;
  };
};

-- Missing @TYPE
class A {
  foo(x: Int): Int {
    x@.foo();
  };
};

-- Missing parens
class A {
  foo(x: Int): Int {
    foo;
  };
};

-- Missing esac
class A {
  foo(x: Int): Int {
    case x of
      a : Int => 5;
      b : Bool => 6;
  };
};

-- Missing expr
class A {
  foo(x: Int): Int {
    case x of
      a : Int;
      b : Bool => 6;
    esac;
  };
};

-- No right hand side
class A {
  foo(x: Int): Int {
    x + ;
  };
};

-- Missing operand
class A {
  foo(x: Int): Int {
    ~ ;
  };
};

--Parenthesis mismatch
class A {
  foo(x: Int): Int {
    (x + 5;)
  };
};

-- Invalid expr in block
class A {
  foo(x: Int): Int {
    new ;
  };
};

-- Big error recovery
-- Bad features (errors inside feature list)
class Broken1 {
  x : Int <- 5
  y Int <- 10; -- missing colon between ID and TYPE

  foo(x: Int) Int { x + 1; }; -- missing colon before return type

  bar(x: Int, ) : Int { x; }; -- trailing comma in formals
};

-- Bad let binding inside a method
class Broken2 {
  foo(x: Int): Int {
    let a : Int <- 5, error_here, b : Bool <- true 
    a + b;
  };
};

-- Bad expression block inside a method
class Broken3 {
  foo(x: Int): Int {
    {
      5;
      ~ ;
      error_expr;
      6;
    }
  };
};

-- Bad case expression inside method
class Broken4 {
  foo(x: Int): Int {
    case x of
      a : Int => 5;
      b : Bool;
    esac;
  };
};

-- Bad class header (class started wrong but next class should be ok)
class Broken5 {
  x : Int <- 5; -- treating attributes at class level; wrong
class GoodClass {
  attr : Int <- 5;
  method(x: Int): Int { x + 1; };
};