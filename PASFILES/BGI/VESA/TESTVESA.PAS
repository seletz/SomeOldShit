Program testvesa;
Uses
  crt, DOS, vesa;
Var
  X, Y: Integer;
  r, g, b: Byte;
Begin
  ClrScr;
  If setmode (mode_800x600x64k) Then
  Begin
    For Y := 0 To vesarec. height - 1 Do
      For X := 0 To vesarec. width - 1 Do
      Begin
        r := Round ($ff * (0.5 + 0.5 * Sin ( X / vesarec. width * 2 * Pi) ) );
        b := Round ($ff * (0.5 + 0.5 * Cos ( Y / vesarec. height * 2 * Pi) ) );
        g := Round ($ff * (0.5 + 0.5 * Sin ( Y / vesarec. height * 2 * Pi) ) );
        setpix (X, Y, RGB ( r, g, b) );
      End;
    ReadLn;
    TextMode (co80);
  End
  Else
  Begin
    WriteLn ('setmode() returned false.');
  End;
End.