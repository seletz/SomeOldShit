Program testvesa;
Uses
  crt, DOS, vesa;
Var
  X, Y: Integer;
  r, g, b: Byte;
Begin
  ClrScr;
  If setmode (mode_640X480X16m) Then
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
    Y := 0;
    Repeat
      wrline (0, Y, vesarec. width - 1, Y, RGB ($ff, $ff, $ff) );
      Inc (Y, 25);
    Until Y > vesarec. height - 1;
    X := 0;
    Repeat
      wrline (X, 0, X, vesarec. height - 1, RGB ($ff, $ff, $ff) );
      Inc (x, 25);
    Until x > vesarec. width - 1;
    ReadLn;
    TextMode (co80);
  End
  Else
  Begin
    WriteLn ('setmode() returned false.');
  End;
End.