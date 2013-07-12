{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X-,M 1024,0,0}
(*===================================================================*)
(*                               KS.PAS                              *)
(*             Copyright (C) 1993 te-wi Verlag, Mnchen              *)
(*-------------------------------------------------------------------*)
(* Programm zur Umschaltung der Tasten NumLock, CapsLock (ShiftLock) *)
(* und ScrollLock per Kommandozeile. Angabe von Groábuchstaben schal-*)
(* tet die entsprechende Taste ein, Die Angabe von Kleinbuchstaben   *)
(* schaltet die entsprechende Taste aus. Falls die Taste nicht ange- *)
(* geben wird, wird ihr derzeitiger Zustand beibehalten. KS.PAS      *)
(* verwendet die Unit KEYS.PAS, Prozedur SetKeyLock-                 *)
(*===================================================================*)

PROGRAM KeyBoardState; (* KS *)

USES
  Keys;

CONST
  cCap      : BOOLEAN = FALSE;
  sCap      : BOOLEAN = FALSE;
  nCap      : BOOLEAN = FALSE;
  cSmall    : BOOLEAN = FALSE;
  sSmall    : BOOLEAN = FALSE;
  nSmall    : BOOLEAN = FALSE;
  NumLock   : tLEDSet = ignore;
  CapsLock  : tLEDSet = ignore;
  ScrollLck : tLEDSet = ignore;

VAR
  i        : BYTE;
  Parameter: STRING;

PROCEDURE CmdLineHelp;
BEGIN
  WriteLn(#13#10'Steuertastenumschaltung v.1.0, ' +
          'Copyright (C) 1993 te-wi Verlag');
  WriteLn('Aufruf: KS [n|N][s|S][c|C]');
  WriteLn('  Wobei gilt: n := NumLock, s := ScrollLock, '
        + 'c := CapsLock');
  WriteLn('  Groábuchstabe schaltet ein, Kleinbuchstabe '
        + 'schaltet aus.');
  WriteLn('  Ist eine Taste nicht angegeben, wird ihr '
        + 'Status beibehalten.');
END;

BEGIN
  IF ParamCount = 0 THEN CmdLineHelp
  ELSE
  BEGIN
    Parameter := '';
    FOR i := 1 TO ParamCount DO
      Parameter := Parameter + ParamStr(i);

    IF (Pos('c', Parameter) = 0) AND (Pos('C', Parameter) = 0) AND
       (Pos('s', Parameter) = 0) AND (Pos('S', Parameter) = 0) AND
       (Pos('c', Parameter) = 0) AND (Pos('N', Parameter) = 0) THEN
      CmdLineHelp
    ELSE
    BEGIN
      cCap := Pos('C', Parameter) > 0;
      sCap := Pos('S', Parameter) > 0;
      nCap := Pos('N', Parameter) > 0;

      IF NOT cCap THEN cSmall := Pos('c', Parameter) > 0;
      IF NOT sCap THEN sSmall := Pos('s', Parameter) > 0;
      IF NOT nCap THEN nSmall := Pos('n', Parameter) > 0;

      IF cCap THEN CapsLock := ON ELSE IF cSmall THEN CapsLock := OFF;
      IF sCap THEN ScrollLck := ON ELSE IF sSmall THEN
        ScrollLck := OFF;
      IF nCap THEN NumLock  := ON ELSE IF nSmall THEN NumLock := OFF;

      SetLockKey(ScrollLck, NumLock, CapsLock);
    END;
  END;
END.

(*===================================================================*)
