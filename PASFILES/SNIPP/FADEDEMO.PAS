{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 592 of 708
From : Reynir Stefansson                   2:391/20.0           14 Apr 93  17:32
To   : All
Subj : Yafir...
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
     Here is yet another fade-in routine. This one does a proportional fade
of all colours. }

Program FadeDemo;

Uses Crt;

Const PelAddrRgR  = $3C7;
  PelAddrRgW  = $3C8;
  PelDataReg  = $3C9;
  
Type RGB = Record r, g, b : Byte; End;
  
Var i : Integer; CH : Char; col : Array [0..63] Of RGB;
  
Procedure GetCol (C : Byte; Var R, G, B : Byte);
Begin
  Port [PelAddrRgR] := C;
  R := Port [PelDataReg];
  G := Port [PelDataReg];
  B := Port [PelDataReg];
End;

Procedure SetCol (C, R, G, B : Byte);
Begin
  Port [PelAddrRgW] := C;
  Port [PelDataReg] := R;
  Port [PelDataReg] := G;
  Port [PelDataReg] := B;
End;

Procedure SetInten (b : Byte);
Var i : Integer; fr, fg, fb : Byte;
Begin
  For i := 0 To 63 Do
  Begin
    fr := col [i].r * b Div 63;
    fg := col [i].g * b Div 63;
    fb := col [i].b * b Div 63;
    SetCol (i, fr, fg, fb);
  End;
End;

Begin
  TextMode (LastMode);
  For i := 0 To 63 Do GetCol (i, col [i].r, col [i].g, col [i].b);
  For i := 1 To 15 Do
  Begin
    TextAttr := i;
    WriteLn ('Foreground colour = ', i: 2);
  End;
  CH := ReadKey;
  For i := 63 Downto 0 Do Begin SetInten (i); Delay (20); End;
  GotoXY (1, 1);
  For i := 15 Downto 1 Do
  Begin
    TextAttr := i;
    WriteLn ('Foreground colour = ', i: 2);
  End;
  For i := 0 To 63 Do Begin SetInten (i); Delay (20); End;
  CH := ReadKey;
  TextMode (LastMode);
End.