{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X-}
(*===================================================================*)
(*                            JOYTEST.PAS                            *)
(*     Demonstration und Test fÅr die Routinen in JOYSTICK.PAS       *)
(*                 Copyright (C) 1993 te-wi Verlag, MÅnchen          *)
(*===================================================================*)
PROGRAM JoystickTest;

USES
  Crt,
  Cursor,
  Joystick;

CONST
  pressed: ARRAY[FALSE..TRUE] OF STRING[3] = ('AUS', 'AN ');


VAR
  x,  y : INTEGER;
  f1, f2,
  f3, f4: BOOLEAN;
  oldx1, oldx2, oldy1, oldy2 : INTEGER;
BEGIN
  IF Joystick.IsInstalled THEN
  BEGIN
    oldx1 := 0; oldy1 := 0;
    oldx2 := 0; oldy2 := 0;
    ClrScr;
    HideCursor;
    TextAttr := Yellow;
    GotoXY(27, 1); Write('Joystick-Probe');
    GotoXY(21, 2); Write('Routinen fÅr ');
    IF ATFunctions THEN Write('AT Åber Int 15h')
                   ELSE Write('XT Åber Ports ');
    GotoXY( 5, 5); Write('Daten Joystick 1');
    GotoXY( 5, 6); Write('----------------');
    GotoXY(45, 5); Write('Daten Joystick 2');
    GotoXY(45, 6); Write('----------------');
    NormVideo;
    GotoXY(19, 24); Write('FÅr <Ende> beliebige Taste drÅcken');
    HighVideo;
    REPEAT
      Joystick.WhereXY1(x, y);
      x := x * 8 DIV 7 DIV 3;
      y := y * 8 DIV 7 DIV 3;
      GotoXY(5, 10); Write('X-Wert:', x: 6, '  ');
      IF oldx1 < x THEN Write(#26) ELSE
      IF oldx1 > x THEN Write(#27) ELSE Write(#196);
      GotoXY(5, 11); Write('Y-Wert:', y: 6, '  ');
      IF oldy1 < y THEN Write(#24) ELSE
      IF oldy1 > y THEN Write(#25) ELSE Write(#179);
      oldx1 := x; oldy1 := y;
      Joystick.WhereXY2(x, y);
      x := x * 8 DIV 7 DIV 3;
      y := y * 8 DIV 7 DIV 3;
      GotoXY(45, 10); Write('X-Wert:', x: 6, '  ');
      
      IF oldx2 < x THEN Write(#26) ELSE
      IF oldx2 > x THEN Write(#27) ELSE Write(#196);
      GotoXY(45, 11); Write('Y-Wert:', y: 6, '  ');
      IF oldy2 < y THEN Write(#24) ELSE
      IF oldy2 > y THEN Write(#25) ELSE Write(#179);
      oldx2 := x; oldy2 := y;
      FireButton(f1, f2, f3, f4);
      GotoXY( 5,13); Write('Button 1: ', pressed[f1]);
      GotoXY( 5,14); Write('Button 2: ', pressed[f2]);
      GotoXY(45,13); Write('Button 1: ', pressed[f3]);
      GotoXY(45,14); Write('Button 2: ', pressed[f4]);
    UNTIL KeyPressed;
    SetCursor(StartCursor);
    ClrScr;
  END
  ELSE
  BEGIN
    HighVideo;
    WriteLn('Kein Joystick am Rechner angeschlossen!');
  END;
  NormVideo;
  WriteLn(' ');
END.

(*===================================================================*)
