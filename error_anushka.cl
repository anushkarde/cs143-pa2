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
