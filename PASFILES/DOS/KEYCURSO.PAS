{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X-}
{$M 16384,0,0}
(*===================================================================*)
(*                           KEYCURSOR.PAS                           *)
(*           Copyright (C) 1993 te-wi Verlag, MÅnchen                *)
(*-------------------------------------------------------------------*)
(*   Das Programm demonstriert die Mîglichkeiten der Sondertasten-   *)
(*            abfrage mit Funktionen der Unit ØKeysÆ                 )
(*===================================================================*)
PROGRAM KeyCursor;

USES
  Crt, Keys, Cursor;

VAR
 x1, x2, y1, y2: INTEGER;

BEGIN
  HideCursor;
  ClrScr;
  x1 := 39;
  x2 := 39;
  y1 := 12;
  y2 := 12;
  TextAttr := 112;
  GotoXY(1, 1);
  ClrEol;
  GotoXY(25, 1);
  Write('Demonstration fÅr die Unit Keys');
  GotoXY(1, 25);
  ClrEol;
  GotoXY(2, 25);
  Write(#2' bewegen: <Alt>, <AltGr>, <Shift-Left>, <Shift-Right> ' +
        #186'      Beenden: <Ctrl>');
  TextAttr := 14;
  REPEAT
    IF ShiftRightPressed THEN
    BEGIN
      Inc(x1);
      IF x1 >= 80 THEN x1 := 80;
    END;
    IF ShiftLeftPressed THEN
    BEGIN
      Dec(x1);
      IF x1 <= 1 THEN x1 := 1;
    END;
    IF AltRightPressed THEN
    BEGIN
      Inc(y1);
      IF y1 >= 24 THEN y1 := 24;
      Delay(5);
    END;
    IF AltLeftPressed THEN
    BEGIN
      Dec(y1);
      IF y1 <= 2 THEN y1 := 2;
      Delay(5);
    END;
    IF NOT ScrollLockActive THEN
      IF (x2 <> x1) OR (y1 <> y2) THEN
      BEGIN
        GotoXY(x2, y2);
        Write(' ');
      END;
    GotoXY(x1, y1);
    Write(#2);
    y2 := y1;
    x2 := x1;
    Delay(10);
  UNTIL CtrlPressed;
  SetCursor(StartCursor);
  TextAttr := 7;
  ClrScr;
END.

(*===================================================================*)
