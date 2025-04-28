asjdfjdkexjsld;   --extra tokens before class

class X {
      foo(): Int {
      ;
      };
};


class X {
      foo(): Int {
        {
            x * 3;
            let x: B in "str";
            x**3; --incorrect expression in block
            let y: A, b:: C, d:F in 1;          --bad let expression
            ERROR;
            y * 4;
        }
      };
};

class X {
      foo(): Int {
        {
            x *- 3;          -- error in first expr of block
            let x: B in "str";
            x**3; --incorrect expression in block
            let y: A, b:: C, d:F in 1;          --bad let expression
            ERROR;
            y * 4;
            badexprx5       -- error in last expr of block
        }
      };
};

(* error in feature, should allow us to go to the next feature *)
class A {
    riya(): Int {
        object <- 4
        error here 
    };
    anushka(): Double {
        here * 5
    };
};

(* error in last feature, should allow us to go to the next feature *)
class A {
    riya(): Int {
        object <- 4
    };
    anushka(): Double {
        here * 5
    };
    poop() Int {            -- no colon, so bad

    };
};

(* error in class, should allow us to go to the next class *)
class A {
    THIS IS AN ERROR
};

Class BB__ inherits A { }; 

class X {
      foo(): Int {
        {
            x * 3;
            let a:B, c:D, peep::::;      --let error should be ignored as bad block expression
            y * 4;
        }
      };
};

class X {ERRORRRRR};
