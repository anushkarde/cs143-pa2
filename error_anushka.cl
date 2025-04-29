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

(* Improper formals *)
class A {
  foo(x: Int y: Bool): Bool { x + 1 };
}

