{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X-,Y-}
(*===================================================================*)
(*                            UPPER.PAS                              *)
(*            Copyright (C) 1993 te-wi Verlag, MÅnchen               *)
(*-------------------------------------------------------------------*)
(* Diese Unit demonstriert die Mîglichkeiten, wie Upcase/Upstring    *)
(* mehr oder minder erfolgreich und sinnvoll implementiert werden    *)
(* kînnen. Nach au·en tritt nur die letzte Mîglichkeit (Kombination) *)
(* in Erscheinung. Zwischenlîsungen sind nur intern realisiert.      *)
(*===================================================================*)

UNIT UPPER;

INTERFACE

FUNCTION GetCodePage: WORD;           (* liefert die aktive Codepage *)
FUNCTION SetCodePage(CP: WORD): INTEGER;(* setzt die aktive Codepage *)
    (* Die Funktion meldet bei erfolgreicher AusfÅhrung 0, sonst den *)
    (* DOS-Errorcode zurÅck. Das Funktionsergebnis sollte also aus-  *)
    (* gewertet werden, da nicht sicher ist, da· die Codepage-Um-    *)
    (* schaltung auch installiert ist.                               *)
FUNCTION UpCase(ch: CHAR): CHAR;       (* erweiterte Upcase-Funktion *)
FUNCTION UpString(s: STRING): STRING;  (* erweiterte UpString-Funkt. *)
FUNCTION StrUpper(s: pChar):  pChar;   (* UpString fÅr               *)
                                       (* nullterminierte Strings    *)
IMPLEMENTATION

USES
  Dos, DosUtil, Strings;

CONST
  Dos330 = $31E; (* Codepages gibt es erst ab der DOS-Version 3.30,  *)
                 (* dies ist der Code von DosVersion  = 3.30         *)
                 (* bezogen auf die neuimplemetierte Version         *)

  Dos331 = $31F;(* DOS 3.31, diese Nummer liefern alle DR-DOS-       *)
                (* Versionen, dann mu· man weiter im Environment     *)
                (* nach der DR-DOS-Version suchen (siehe DOSUTIL.PAS *)

FUNCTION DosVersion: WORD; ASSEMBLER;
(* Die Funktion ist - bis auf die umgekehrte also eigentlich sinn-   *)
(* volle Ausgabe der Versionsnummer identisch mit der Funktion der   *)
(* Unit DOS. Identisch wÑre: DosVersion := Swap(Dos.DosVersion);     *)
ASM
  MOV  AX, 3000h
  INT  21h
  XCHG AH, AL
END;

FUNCTION StdUpCase(ch: CHAR): CHAR;
(* Nachbildung der Standardfunktion UpCase wie sie auch in Borland   *)
(* Pascal funktioniert                                               *)
BEGIN
  IF ch IN ['a'..'z'] THEN StdUpCase := Chr(Ord(ch) - 32)
                      ELSE StdUpCase := ch;
END;

FUNCTION UpCase437(ch: CHAR): CHAR;
(* ein komplettes Upcase, das aber nur mit Codepage 437 funktioniert.*)
BEGIN
  CASE ch OF
    'a'..'z': UpCase437 := Chr(Ord(ch) - 32);
    'A'..'Z': UpCase437 := ch;
    'Ñ'     : UpCase437 := 'é';
    'î'     : UpCase437 := 'ô';
    'Å'     : UpCase437 := 'ö';
    'Ü'     : UpCase437 := 'è';
    'Ç'     : UpCase437 := 'ê';
    '§'     : UpCase437 := '•';
    'á'     : UpCase437 := 'Ä';
    'ë'     : UpCase437 := 'í'
   ELSE       UpCase437 := ch;
  END;
END;

FUNCTION UpCaseCP(ch: CHAR): CHAR;
(* Ausnutzung der landesspezifischen Informationen COUNTRY= fÅr die  *)
(* Umwandlung von Zeichen in Gro·buchstaben. Die Zeichen werden an-  *)
(* hand der DOS-Zeichensatztabelle konvertiert.                      *)
VAR
  Regs: Registers;
BEGIN
  IF DosVersion < Dos330 THEN UpCaseCP := UpCase(ch) ELSE
  BEGIN
    Regs.AX := $6520;
    Regs.DL := Ord(ch);
    MsDos(Regs);
    IF Regs.Flags AND FCarry <> 0 THEN
      UpCaseCP := UpCase(ch)
    ELSE UpCaseCP := Chr(Regs.DL);
  END;
END;

FUNCTION StdUpString(s: STRING): STRING;
VAR
  i: BYTE;
BEGIN
  IF Length(s) > 0 THEN
    FOR i := 1 TO Length(s) DO s[i] := StdUpCase(s[i]);
  StdUpString := s;
END;

FUNCTION UpString437 (s: STRING): STRING;
(* Umwandlung von Strings in Gro·buchstaben, nationale Sonderzeichen *)
(* sind nach der konsequenten Umwandlung in UpCase437 berÅcksichtigt.*)
(* Die Funktion arbeitet nur mit der Standard-Codepage 437 korrekt   *)
VAR
  i: BYTE;
BEGIN
  IF Length(s) > 0 THEN
    FOR i := 1 TO Length(s) DO s[i] := UpCase437(s[i]);
  UpString437 := s;
END;

FUNCTION UpStringCP(s: STRING): STRING;
(* Ausnutzung der landesspezifischen Informationen COUNTRY= fÅr die  *)
(* Umwandlung von Zeichenketten in Gro·buchstaben. Die Zeichen wer-  *)
(* den anhand der DOS-Zeichensatztabelle konvertiert. Diese Funktion *)
(* arbeitet mit allen Codepages, aber nur fÅr die jeweils lÑnder-    *)
(* spezifi-schen Sonderzeichen. Bei COUNTRY=049 (Deutschland) werden *)
(* deshalb nur die Umlaute umgewandelt, nicht aber frÑnzîsische,     *)
(* skandinavische, spanische und sonstige Sonderzeichen              *)
VAR
  Regs: Registers;
BEGIN
  IF DosVersion < Dos330 THEN UpStringCP := UpString(s) ELSE
  WITH Regs DO
  BEGIN
    AX := $6521;
    CX := Ord(s[0]);
    DS := Seg(s);
    DX := Succ(Ofs(s));
    MsDos(Regs);
    IF Odd(Flags) THEN UpStringCP := s
                  ELSE UpStringCP := UpString(s);
  END;                 
END;

FUNCTION StrUpper(s: pChar): pChar;
(* Ausnutzung der landesspezifischen Informationen COUNTRY= fÅr die  *)
(* Umwandlung von pChars in Gro·buchstaben. Die Zeichen werden an-   *)
(* hand der DOS-Zeichensatztabelle konvertiert.                      *)
VAR
  Regs: Registers;
  i   : BYTE;
  c   : STRING;
BEGIN
  IF DosVersion < Dos330 THEN StrUpper := Strings.StrUpper(s)
  ELSE
  WITH Regs DO
  BEGIN
    AX := $6522;
    DS := Seg(s^);
    DX := Ord(s^);
    MsDos(Regs);
    IF Odd(Flags) THEN StrUpper := s
                  ELSE StrUpper := Strings.StrUpper(s);
  END;
END;

FUNCTION SetCodePage(CP: WORD): INTEGER;
(* Setzt die aktive Codeseite. Diese mu· allerdings zuvor im DOS mit *)
(* DISPLAY.SYS, MODE CON CP PREP= .... und NLSFUNC definiert sein.   *)
(* Der Befehl entspricht dem DOS Befehl CHCP Codenummer. In Europa   *)
(* werden normalerweise die Hardware-Codepage 437 (Standard) und     *)
(* teilweise die internationale Codepage 850 eingesetzt und bei-     *)
(* spielsweise von OS/2 auch so default eingestellt. Normalerweise   *)
(* sind Codepages aber mehr ØBallaststoffÆ als sinnvolle Systemer-   *)
(* weiterung und machen nur dann Sinn, wenn nicht nur der Rechner    *)
(* sondern auch der Drucker die Codeseitenumschaltung unterstÅtzt    *)
(* (PRINTER.SYS und MODE PRN CP PREP= ....). Es sind aber fast nur   *)
(* IBM-Drucker, die damit zurechtkommen.                             *)
VAR
  Regs: Registers;
BEGIN
  WITH Regs DO BEGIN
    AX := $6602;            (* DOS-Funktion 66h: Get/Set Code Page  *)
    BX := CP;               (* UF 2: Codepage setzen (lesen = 1)    *)
    MsDos(Regs);            (* Nummer der Codepage in BX            *)
    IF Odd(Flags) THEN SetCodePage := Regs.AX
                  ELSE SetCodePage := 0;
  END;
END;

FUNCTION GetCodePage: WORD; ASSEMBLER; {Ermitteln der aktiven Codepage}
ASM   
  MOV AX, 6601h             (* DOS-Funktion 66h: Get/Set Code Page   *)
  INT 21h                   (* UF 1: Codepage ermitteln (setzen = 2) *)
  MOV AX, BX                            (* aktive Codepage von ØCONÆ *)
(* DX :=                           Hardware-Codepage bei Systemstart *)
END;

FUNCTION UpCase(ch: CHAR): CHAR;
(* So ist es jetzt (endlich) halbwegs sinnvoll: Es werden mîglichst  *)
(* viele Informationen ausgewertet und dann die bestmîgliche Umwand- *)
(* lung durchgefÅhrt. Kompromi·lîsung, die aber in den meisten FÑl-  *)
(* len gut einsetzbar ist. Wer die Funktion auch auf Codepage 850    *)
(* (Europa) erweitern will, kann sich Ñquivalent zu Upcase437 auch   *)
(* hier eine Tabelle aufbauen.                                       *)
BEGIN
  IF DosVersion < Dos330 THEN
     UpCase := StdUpCase(ch) ELSE
  BEGIN
    IF GetCodePage  = 437 THEN
      UpCase := UpCase437(ch)                       (* Standard      *)
    ELSE
      UpCase := UpCaseCP(ch);                       (* International *)
  END;
END;

FUNCTION UpString(s: STRING): STRING;      (* Kommentar siehe UpCase *)
BEGIN
  IF DosVersion < Dos330 THEN
     UpString := StdUpString(s) ELSE
  BEGIN
    IF GetCodePage  = 437 THEN
      UpString := UpString437(s)                    (* Standard      *)
    ELSE
      UpString := UpStringCP(s);                    (* International *)
  END;
END;

END.

(*===================================================================*)
