Uses tgaunit;
Const
  breite__ = 100;
  hoehe__  = 100;
Var
  t: tgafile;
  fb: File Of Byte;
  i, j: Integer;
  r, g, b: Byte;
Procedure testbild (X, Y: Integer; Var rot, gruen, blau: Byte);
Begin
  rot := Trunc ($ff * Sin (X / breite__) );
  blau := Trunc ($ff * Cos (Y / hoehe__ ) );
  gruen := $0f;
  If X = 1 Then
  Begin
    rot := $ff;
    gruen := $ff;
    blau := $ff;
  End
  Else If X = breite__ Then
  Begin
    rot := $ff;
    gruen := $ff;
    blau := $ff;
  End
  Else If Y = 1 Then
  Begin
    rot := $ff;
    gruen := $ff;
    blau := $ff;
  End
  Else If Y = hoehe__ Then
  Begin
    rot := $ff;
    gruen := $ff;
    blau := $ff;
  End
  Else If (X Mod 5) = 0 Then
  Begin
    rot := $ff;
    gruen := $ff;
    blau := $00;
  End
  Else If (Y Mod 5) = 0 Then
  Begin
    rot := $ff;
    gruen := $00;
    blau := $ff;
  End;
End;
Begin
  t. init ('c:\temp\test.tga', breite__, hoehe__, nograph);
  t. writeheader;
  For j := hoehe__ Downto 1 Do
  Begin
    WriteLn ('Zeile ', hoehe__ - (j - 1), ' / ', hoehe__);
    For i := 1 To breite__ Do
    Begin
      testbild (i, j, r, g, b);
      t. Output (i, j, r, g, b);
    End
  End;
  t. done;
End.