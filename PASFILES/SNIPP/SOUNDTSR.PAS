{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 421 of 442
From : Raphael Vanney                      2:320/7.0            09 Apr 93  22:18
To   : Eric Ort
Subj : Tsrs
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Hi !

EO>I tried the Keep procedure for making a DOS Screen Saver....  well..
EO>there is
EO> so little docs on how to use it, could you give me an example ???

Sure.

----------------------------------------------------------- }
{ This is a very simple TSR, that should (I did not test it...)
produce some sound. And also some speed deprovement. }

{$m 2048,0,0}  { This is _important_ (tremendously :-)) }

Uses Crt,DOS ;

Procedure NewInt1c ; Interrupt ;
Begin
     Sound(100) ;
     Delay(5) ;
     NoSound ;
End ;

Begin
     SetIntVec($1c, @NewInt1c) ;   { Sets our Int $1c handler }
     Keep(0) ;
End.