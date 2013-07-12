{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 296 of 310
From : Norbert Igl                         2:2402/300.3         16 Apr 93  23:32
To   : Raphael Vanney                      2:320/7.0
Subj : Substed drives
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
 > Anyone has got an idea on how to know if a drive is a real one or the
 > result of a SUBST command ?
 > Any help... welcome :-)

  .... it's me again .... :->

  well, DOS ( esp. COMMAND.COM ) has a undocumented Command
  called TRUENAME, which takes wildcards also.

  The following is the reconstuction of this:

-------------------------8<---------------------------------}
Program TrueName;
uses DOS;

   function RealName(FakeName:String):String;
   Var
     Temp:String;
     Regs:Registers;
   begin
     FakeName := FakeName + #0; { ASCIIZ }
     With Regs do
     begin
       AH := $60;
       DS := Seg(FakeName); SI := Ofs(FakeName[1]);
       ES := Seg(Temp);     DI := OfS(Temp[1]);
       INTR($21,Regs);
       DOSERROR := AX * ((Flags And FCarry) shr 7);
       Temp[0] := #255;
       Temp[0] := CHAR(POS(#0,Temp)-1);
     end;
     If DosError <> 0 then Temp := '';
     RealName := Temp;
   end;

begin
  writeln( RealName( Paramstr(1) ));
end.