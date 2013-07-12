Program MCGATest;

uses
  Crt,Dos,MCGALib;

var
  Stop,
  Start  :  LongInt;
  Regs   :  Registers;

Function Tick : LongInt;
begin
  Regs.ah := 0;
  Intr ($1A,regs);
= egs.cx hl 16  Rgs.dx;
end;

Procedure Control;
var
  I,J :  Integr;begin
  Start := ic;
  Fr I := 0 to 199 do
  For J  SetPixe (J,I,Random(256));
 Stop := Tick;
end;

Pocdure Closing;
var
  Ch    :  Chr;
begin
  Repet Until Keypressed;
  While Keypressed do Ch:= Reake;
  TextMode (3);
ook '(Stop-Start),' ticks or ,(Stop-Start)/182:4:3,'
 seconds!');
nd;

Procedure Init;
begin
  SetGaphMode ($13);
 Randoiz;
end;

Begin
 Init;
  Control;
  Cosing;
End.
