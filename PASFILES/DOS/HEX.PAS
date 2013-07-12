{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X-}
(*===================================================================*)
(*                              HEX.PAS                              *)
(* enthÑlt die Konvertierungsfunktionen fÅr Dezimal nach Hexadezimal *)
(*     Alle Funktionen fÅllen den String auch vorne mit Nullen auf   *)
(*            Copyright (C) 1993 te-wi Verlag, MÅnchen               *)
(*===================================================================*)

UNIT Hex;

INTERFACE

FUNCTION Byte2Hex(b: BYTE):    STRING;
FUNCTION Word2Hex(w: WORD):    STRING;
FUNCTION Int2Hex(i:  INTEGER): STRING;
FUNCTION Long2Hex(L: LONGINT): STRING;
FUNCTION Ptr2Hex(p:  Pointer; Dollar: BOOLEAN): STRING;

IMPLEMENTATION

CONST
  HexChars: ARRAY[0..$F] OF CHAR = '0123456789ABCDEF';

FUNCTION Byte2Hex(b: BYTE): STRING;
BEGIN
  Byte2Hex[0] := #2;                               (* = ^B           *)
  Byte2Hex[1] := HexChars[b SHR  4];               (* Variante 1 zur *)
  Byte2Hex[2] := HexChars[b AND $F];               (* Umwandlung     *)
END;

FUNCTION Word2Hex(w: WORD): STRING;
BEGIN
   Word2Hex := HexChars[Hi(w) DIV $10] +           (* Variante 2 zur *)
               HexChars[Hi(w) MOD $10] +           (* Berechnung     *)
               HexChars[Lo(w) DIV $10] +
               HexChars[Lo(w) MOD $10];
END;

FUNCTION Int2Hex(i: INTEGER): STRING;
VAR
  j  : INTEGER;
  Hex: STRING;
BEGIN
   j := Abs(i);
   Hex := HexChars[Hi(j) DIV $10] +
          HexChars[Hi(j) MOD $10] +
          HexChars[Lo(j) DIV $10] +
          HexChars[Lo(j) MOD $10];
  IF i < 0 THEN Hex := '-' + Hex;
  Int2Hex := Hex;
END;

FUNCTION Long2Hex(L: LONGINT): STRING;
VAR
  s   : STRING;
  i, j: BYTE;
BEGIN
  s := '';                        (* oder s[0] := #0 oder s[0] := ^@ *)
  REPEAT                                (* Variante 3 zur Berechnung *)
    IF L MOD $10 < 10 THEN s := Chr(L MOD $10 + 48) + s
                      ELSE s := Chr(L MOD $10 + 55) + s;
    L := L DIV $10;
  UNTIL L = 0;
  j := BYTE(s[0]);
  IF j < 10 THEN FOR i := j TO 10 DO s := Concat('0', s);
  Long2Hex := s;
END;

FUNCTION Ptr2Hex(p: Pointer; Dollar: BOOLEAN): STRING;
VAR
  WordRec: ARRAY[1..2] OF WORD;
  r1, r2 : STRING;
BEGIN
  Move(p, WordRec, 4);
  r1 := Word2Hex(WordRec[2]);
  r2 := Word2Hex(WordRec[1]);
  IF Dollar THEN Ptr2Hex := '$' + r1 + ':$' + r2
            ELSE Ptr2Hex :=     + r1 + ':'  + r2;
  (*   In BP 7 gibt es den in der Unit Objects definierten Record    *)
  (*   ØWordRecÆ mit dem es wider Erwarten(?) nicht klappt!          *)
END;

END.

(*===================================================================*)
