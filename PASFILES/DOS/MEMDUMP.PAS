{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X-}
{$M 16384,0,$10000}
(*===================================================================*)
(*                           MEMDUMP.PAS                             *)
(*             Copyright (C) 1993 te-wi Verlag, Mnchen              *)
(*-------------------------------------------------------------------*)
(* Das Programm erzeugt einen Dump eines beliebigen Speicherbereichs *)
(*   Die Gr”áe der Dateien ist auf 64 kByte (ein Segment) begrenzt.  *)
(*    Das Programm darf nicht im Protected Mode compiliert werden!   *)
(*===================================================================*)

PROGRAM MemDump;

USES
  Hex;

VAR
  i      : INTEGER;
  p      : POINTER;
  Segment: WORD;
  f      : FILE;
  len    : WORD;
  s      : STRING;

PROCEDURE ErrorMsg;
BEGIN
  WriteLn(^M^J'MEMDUMP Version 1.0'^J);
  WriteLn('Fehler: Falscher oder fehlender Kommandozeilenparameter!');
  WriteLn('Aufruf: MEMDUMP Segmentadresse [L„nge]'^J);
  WriteLn(' Bei Eingabe von hexadezimalen Werten muá ein Dollarzeichen'
        + ' ($)');
  WriteLn(' vor die Zahl gestellt werden. Es wird immer ab dem Offset'
        + ' $0000');
  WriteLn(' gelesen. Wird keine L„nge oder die Zahl 0 angegeben, wird'
        + ' ein');
  WriteLn(' volles Segment (65535 Bytes) abgespeichert.');
END;

BEGIN
  len := 0;                           (* Dateil„nge mit 0 vorbelegen *)
  IF ParamCount = 0 THEN ErrorMsg    (* Keine Kommandozeile: Meldung *)
  ELSE
  BEGIN
    IF Pos('?', ParamStr(1)) > 0 THEN ErrorMsg
    ELSE
    BEGIN
      Val(ParamStr(1), Segment, i);
      IF i <> 0 THEN ErrorMsg                     (* Fehler: Meldung *)
      ELSE
      BEGIN
        IF ParamCount > 1 THEN Val(ParamStr(2), len, i);(*L„nge best.*)
        IF (i <> 0) OR (len = 0) THEN len := 65535;(* L„nge fixieren *)
        GetMem(p, len);                            (* Speicher holen *)
        Move(BYTE(Ptr(Segment, $0000)^), p^, len);(* in Puffer lesen *)
        s := Word2Hex(Segment);                           (* Hexwert *)
        IF Segment < $A000 THEN s := 'RAM-' + s
                           ELSE s := 'ROM-' + s;  (* Namen festlegen *)
        IF Length(s) > 8 THEN s[0] := #8;      (* Namensl„nge max. 8 *)
        s := s + '.BIN';                      (* Endung fixiert .BIN *)
        Assign(f, s);                      (* Dateivariable zuordnen *)
        ReWrite(f, 1);                           (* Record-L„nge = 1 *)
        BlockWrite(f, p^, len);         (* Puffer in Datei schreiben *)
        Close(f);                          (* Datei wieder schlieáen *)
        WriteLn(s, ' erzeugt');                  (* Meldung ausgeben *)
        FreeMem(p, len);                (* Speicher wieder freigeben *)
      END;                          (* ... und das war's auch schon! *)
    END;
  END;
END.

(*===================================================================*)
