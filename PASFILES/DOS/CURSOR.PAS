{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X-}
(*===================================================================*)
(*                           CURSOR.PAS                              *)
(*               Copyright (C) 1993 te-wi Verlag, MÅnchen            *)
(*                   Cursorroutinen fÅr Borland Pascal               *)
(*===================================================================*)

UNIT Cursor;

INTERFACE

CONST
  StartCursor: WORD = $0607;

VAR
  BIOSCursor: WORD;

PROCEDURE SetCursor(CursorShape: WORD);
PROCEDURE HideCursor;
PROCEDURE BlockCursor;

IMPLEMENTATION

(*-------------------------------------------------------------------*)

PROCEDURE SetCursor(CursorShape: WORD); ASSEMBLER;
{ Setzen des Cursors mit Int 10h }
ASM
  MOV CX, CursorShape
  MOV AH, 01h
  INT 10h
END;

(*-------------------------------------------------------------------*)

PROCEDURE HideCursor;{ Abschalten des Cursors Åber zu hohen Startwert }
BEGIN
  SetCursor($1500);
END;

(*-------------------------------------------------------------------*)

PROCEDURE BlockCursor;{ Setzen eines Cursors von Zeile 0 bis Zeile 15 }
BEGIN
  SetCursor($0015);
END;

VAR
  OldExitProc: POINTER;

{$F+}
PROCEDURE CursorExitProc;    (* Neue Exit-Procedur, die den Cursor   *)
BEGIN                        (* wieder auf den Startwert zurÅcksetzt *)
  SetCursor(StartCursor);
  ExitProc := OldExitProc;
END;

BEGIN
  OldExitProc := ExitProc;
  ExitProc    := @CursorExitProc;
  BIOSCursor  := WORD(Ptr(Seg0040, $0060)^);   (* Cursordaten im     *)
  StartCursor := BIOSCursor;                   (*  BIOS-Datensegment *)
END.

(*===================================================================*)
