module ASSIGNMENT-SYNTAX
    imports INT-SYNTAX
    imports BOOL-SYNTAX
    imports ID

    syntax Exp ::= IExp | BExp

    syntax IExp ::= Id | Int

    syntax IExp ::= "(" IExp ")" [bracket]
                  | IExp "+" IExp
                  | IExp "-" IExp
                  > IExp "*" IExp
                  | IExp "/" IExp
                  > IExp "^" IExp

    syntax BExp ::= Bool

    syntax BExp ::= "(" BExp ")" [bracket]
                  | IExp "<=" IExp
                  | IExp "<"  IExp
                  | IExp ">=" IExp
                  | IExp ">"  IExp
                  | IExp "==" IExp
                  | IExp "!=" IExp

    syntax BExp ::= BExp "&&" BExp
                  | BExp "||" BExp

    syntax Stmt ::= Id "=" IExp ";"
                  | Stmt Stmt [left]
endmodule

module ASSIGNMENT
    imports INT
    imports BOOL
    imports MAP
    imports ASSIGNMENT-SYNTAX

    configuration
      <k> $PGM:Stmt </k>
      <mem> .Map </mem>

    rule <k> IE:IExp => substI(IE, MEM) ... </k>
         <mem> MEM </mem>
      requires notBool isInt(IE)

    rule <k> BE:BExp => substB(BE, MEM) ... </k>
         <mem> MEM </mem>
      requires notBool isBool(BE)

    syntax Int ::= substI ( IExp , Map ) [function]
 // -----------------------------------------------
    rule substI(I1 + I2, SUBST) => substI(I1, SUBST) +Int substI(I2, SUBST)
    rule substI(I1 - I2, SUBST) => substI(I1, SUBST) -Int substI(I2, SUBST)
    rule substI(I1 * I2, SUBST) => substI(I1, SUBST) *Int substI(I2, SUBST)
    rule substI(I1 / I2, SUBST) => substI(I1, SUBST) /Int substI(I2, SUBST)
    rule substI(I1 ^ I2, SUBST) => substI(I1, SUBST) ^Int substI(I2, SUBST)

    rule substI(I:Id,   SUBST) => {SUBST [ I ]}:>Int
    rule substI(I:Int, _SUBST) => I

    syntax Bool ::= substB ( BExp , Map ) [function]
 // ------------------------------------------------
    rule substB(I1 <= I2, SUBST) => substI(I1, SUBST)  <=Int substI(I2, SUBST)
    rule substB(I1  < I2, SUBST) => substI(I1, SUBST)   <Int substI(I2, SUBST)
    rule substB(I1 >= I2, SUBST) => substI(I1, SUBST)  >=Int substI(I2, SUBST)
    rule substB(I1  > I2, SUBST) => substI(I1, SUBST)   >Int substI(I2, SUBST)
    rule substB(I1 == I2, SUBST) => substI(I1, SUBST)  ==Int substI(I2, SUBST)
    rule substB(I1 != I2, SUBST) => substI(I1, SUBST) =/=Int substI(I2, SUBST)

    rule substB(B1 && B2, SUBST) => substB(B1, SUBST) andBool substB(B2, SUBST)
    rule substB(B1 || B2, SUBST) => substB(B1, SUBST)  orBool substB(B2, SUBST)

    rule substB(true , _SUBST) => true
    rule substB(false, _SUBST) => false

    rule <k> S1:Stmt S2:Stmt => S1 ~> S2 ... </k>

    rule <k> ID = IE ; => . ... </k>
         <mem> MEM => MEM [ ID <- substI(IE, MEM) ] </mem>
endmodule
