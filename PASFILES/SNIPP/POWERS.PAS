{Ä Fido Pascal Conference ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ PASCAL Ä
Msg  : 391 of 473
From : Mike Patterson                      1:255/14.0           13 Apr 93  15:28
To   : Mark Ouellet
Subj : version numbers
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 MO> 7.10 is not out. JJ is just saying the NEXT version should include
 MO> a "**" operator (Power) as in 2**3 = 2 to the third power.

Mark, I know you aren't the guy that said there should be a power
operator, but... }

Function RaiseX (X,Y:Real) :Real;
Begin
 X:=LN(X);
 X:=(X*Y);
 X:=EXP(X);
 RAISEX:=X;
End;

{and}

Function XRt (X,Y:Real) :Real;
Begin
 X:=LN(X);
 X:=(X/Y);
 X:=EXP(X);
 XRT:=X;
End;

both work well for me... :)

Mike Patterson