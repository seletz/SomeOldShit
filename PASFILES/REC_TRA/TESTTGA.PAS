Program test_tgaunit;
Uses crt, tgaunit, graph;
Const
  breite = 150;
  hoehe = 150;
Var
  i, j : LongInt;
  r, g, b: Byte;
  tgaf: tgafile;
Begin
	textmode(c80 + font8x8);

  tgaf. init ( 'c:\temp\test.tga', breite, hoehe, nograph );
  tgaf. writeheader;
  For j := 1 To hoehe Do
  Begin
    For i := 1 To breite Do
    Begin

      If i = breite Then
      Begin
        r := 255;
        g := 255;
        b := 255;
      End
      Else
        If i = 0 Then
        Begin
          r := 255;
          g := 255;
          b := 255;
        End
        Else
          If j = hoehe Then
          Begin
            r := 255;
            g := 255;
            b := 255;
          End
          Else
            If j = 0 Then
            Begin
              r := 255;
              g := 255;
              b := 255;
            End
            Else
              If ( i mod 5)=0 Then
              Begin
                r := 128;
                g := 255;
                b := 255;
              End
              else
              If ( j mod 5)=0 Then
              Begin
                r := 128;
                g := 255;
                b := 255;
              End
              Else
              Begin
                r := 0;
                g := 0;
                b := 0;
              End;

      tgaf. Output ( i, j, r, g, b);

    End;
  End;
  tgaf. done;
End.