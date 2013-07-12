{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X-,M 2048,0,0}
(*===================================================================*)
(*                             HTEST.PAS                             *)
(*             Copyright (C) 1993 te-wi Verlag, MÅnchen              *)
(*-------------------------------------------------------------------*)
(*               Demonstration fÅr die UNIT Huckepack                *)
(*===================================================================*)


PROGRAM Huckepacktest;

USES Huckepack;
          (* vergrî·ert das Programm beim ersten Aufruf um 130 Bytes *)
VAR
  test: ARRAY[1..2] OF BYTE;

BEGIN
  ReadVarFromExeFile(-2, test[1]);           (* Kennung 1. Buchstabe *)
  ReadVarFromExeFile(-1, test[2]);           (* Kennung 2. Buchstabe *)
 (* Anhand der Kennung kann festgestellt werden, ob es sich wirklich *)
 (* um einen Initialisierungsbereich oder um ein Overlay (o.dgl.)    *)
 (* handelt                                                          *)

  IF (Chr(test[1]) = 'J') AND (Chr(test[2]) = 'B') THEN
    Write('Kennung JB wurde gefunden')
  ELSE
    Write('Variablenbereichskennung nicht gefunden!');

  Halt(0); (* Alle Programme, in die die UNIT Huckepack eingebunden  *)
           (* ist, mÅssen mit HALT() beendet werden, da sonst Datum  *)
           (* und Attribut nicht zurÅckgesetzt werden                *)
END.

(*===================================================================*)