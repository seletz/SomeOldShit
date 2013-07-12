{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X-,M $1000,0,0}
(*===================================================================*)
(*                           KEYSDEMO.PAS                            *)
(*            Copyright (C) 1993 te-wi Verlag, Mnchen               *)
(*           Das Programm demonstriert den Einsatz der UNIT Keys     *)
(*===================================================================*)

PROGRAM KeysDemo;

USES
  Crt, Cursor, Hex, Keys;

VAR
 ch: CHAR;

CONST
  pressed: ARRAY[BOOLEAN] OF CHAR = ('-', '+');

BEGIN
  TextColor(Black);
  TextBackGround(Blue);
  ClrScr;
  TextColor(Red);
  TextBackground(7);
  GotoXY(1, 1);
  ClrEoL;
  GotoXY(14, 1);
  Write('Demonstration des Tastaturstatus, ' +
        'Ende mit <AltGr>');
  HideCursor;
  TextColor(0);
  TextBackground(7);
  GotoXY(1, 25);
  ClrEoL;
  GotoXY(30, 10); Write('ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
  GotoXY(30, 11); Write('³ ASCII-Zeichen: [ ] ³²');
  GotoXY(30, 12); Write('³ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ³²');
  GotoXY(30, 13); Write('³ Nummer:        000 ³²');
  GotoXY(30, 14); Write('³ Hexcode:       $00 ³²');
  GotoXY(30, 15); Write('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ²');
  GotoXY(31, 16);  Write('²²²²²²²²²²²²²²²²²²²²²²');
 REPEAT
  IF KeyPressed THEN BEGIN
    ch := ReadKey;
    IF ch = #0 THEN ch := ReadKey; { Sondertaste lesen! }
      GotoXY(48, 11);
      IF NOT (ch IN [^M,^G]) THEN Write(ch);
      GotoXY(47, 13);
      IF ch < #10 THEN Write ('0');
      IF ch < #100 THEN Write('0');
      Write(Ord(ch));
      GotoXY(48, 14);
      Write(Byte2Hex(Ord(ch)):2);
  END;
  GotoXY(2, 25);
  Write('Shift ', pressed[ShiftPressed]);
  Write(' Alt ',  pressed[AltPressed]);
  Write(' Ctrl ', pressed[CtrlPressed]);
  IF InsActive THEN Write(' Ins ') ELSE Write(' Ovr ');
  IF NumLockActive THEN Write (' Num ') ELSE Write (' Crs ');
  Write('ScrLock ', pressed[ScrollLockActive]);
  Write(' SysReq ', pressed[SysReqPressed]);
  Write(' ':25);
  IF LEDState(LEDScrollLock) THEN
  BEGIN
    TextColor(Red);
    Write('S');
    TextColor(Black);
  END
  ELSE
    Write (' ');
  Write(' ');
  IF LEDState(LEDNumLock) THEN
  BEGIN
    TextColor(Red);
    Write('N');
    TextColor(Black);
  END
  ELSE
    Write (' ');
  Write(' ');
  IF LEDState(LEDCapsLock) THEN
  BEGIN
    TextColor(Red);
    Write('C');
    TextColor(Black);
  END
  ELSE
    Write (' ');
 UNTIL AltRightPressed;
 SetCursor(StartCursor);
 TextAttr := 7;
 ClrScr;
END.

(*===================================================================*)
