{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X+,M 16384,0,655360}
(*===================================================================*)
(*                     HDSAVE.PAS Version 1.0                        *)
(*         Compiler: Turbo/Borland Pascal Real Mode Target           *)
(*                Copyright (C) 1993 te-wi Verlag                    *)
(*===================================================================*)
(* Beschreibung:                                                     *)
(*  Das Programm sichert die Partitionstabelle und die Bootsektoren  *)
(*  auf einer Festplatte in eine Datei. Diese Datei wird anschlies-  *)
(*  send versteckt.                                                  *)
(*===================================================================*)

PROGRAM HDSave;

USES
  Dos, DOSUtil;

VAR
  i, j  : INTEGER;
  f     : FILE;
  Buffer: POINTER;

BEGIN
  GetMem(Buffer, 512);
  ReadPartition(3, Buffer^);
  Assign(f, 'C:\SAVEFILE.BIN');
  ReWrite(f, 1);
  BlockWrite(f, Buffer^, 512);
  i := 3;
  WHILE j = 0 DO
  BEGIN
    j := ReadBootSector(i, Buffer^);
    Inc(i);
    IF j = 0 THEN BlockWrite(f, Buffer^, 512);
  END;
  Close(f);
  FreeMem(Buffer, 512);
  WriteLn(^M^J'HDSave Version 1.0');
  WriteLn('Die Partionstabelle und die Bootsektoren von C: bis ',
          Chr(BYTE(i) + 62), ': ');
  WriteLn('wurden in der Datei C:\SAVEFILE.BIN gespeichert.');
  SetFAttr(f, Hidden);
END.

(*===================================================================*)