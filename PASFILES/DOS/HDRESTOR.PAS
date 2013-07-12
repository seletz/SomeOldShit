{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X+,M 16384,0,655360}
(*===================================================================*)
(*                    HDRESTORE.PAS Version 1.0                      *)
(*         Compiler: Turbo/Borland Pascal Real Mode Target           *)
(*                Copyright (C) 1993 te-wi Verlag                    *)
(*===================================================================*)
(* Beschreibung:                                                     *)
(*  Das Programm schreibt die HDSAVE.PAS gesicherten Daten der Fest- *)
(*  platte wieder zurÅck. Achtung: Das Programm lÑuft nicht unter    *)
(*  OS/2 2.0!                                                        *)
(*===================================================================*)

PROGRAM HDRestore;

USES
  Dos, DOSUtil;

TYPE
  Buffer = ARRAY[1..512] OF BYTE;
VAR
  Buf      : Buffer;
  i, j, r  : INTEGER;
  answer   : STRING;
  s, o     : WORD;
  f        : File OF Buffer;

BEGIN
  WriteLn(^M^J'HD-Restore Version 1.0');
  WriteLn('Das Programm liest die Partitionstabelle und die Bootsek' +
          'toren');
  WriteLn('aus der Datei C:\SAVEFILE.BIN und schreibt die Daten in '
        + 'die');
  WriteLn('entsprechenden Festplattenbereiche zurÅck!');
  WriteLn('Falls Sie zwischen dem Sichern der Daten und dem Aufruf '
        + 'von');
  WriteLn('HDRESTORE énderungen in der Plattenstruktur vorgenommen '
        +  'haben');
  WriteLn('oder ein neues Betriebssystem installiert haben, kann die');
  WriteLn('Plattenstruktur zerstîrt werden. Damit werden auch alle ' +
          'Daten');
  WriteLn('auf der Platte vernichtet!'^M^J);
  Write('Wollen Sie HDRESTORE wirklich ausfÅhren? (J/N) ');
  ReadLn(answer);
  IF (Pos('j', answer) > 0) OR (Pos('J', answer) > 0) THEN BEGIN
   WriteLn;
   Write('Sind Sie sich ganz sicher? (J/N) ');
   ReadLn(answer);
   IF (Pos('j', answer) > 0) OR (Pos('J', answer) > 0) THEN ELSE Halt
  END ELSE Halt(0);
  Assign(f, 'C:\SAVEFILE.BIN');
  SetFAttr(f, Archive);
  {$I-}
  Reset(f);
  {$I+}
  IF IoResult <> 0 THEN
  BEGIN
    WriteLn('Fehler beim Lesen der Datei SAVEFILE.BIN');
  END
  ELSE
  BEGIN
    j := FileSize(f);
    Read(f, Buf);
    WritePartition(3, Buf);
    Dec(j);
    FOR i := 1 TO j DO
    BEGIN
      Read(f, Buf);
      r := WriteBootSector(i + 2, Buf);
      IF r <> 0 THEN
      BEGIN
        WriteLn('Fehler beim Schreiben des Bootsektors von Laufwerk ',
                Chr(BYTE(i) + 62), ': ');
        Halt;
      END;
    END;
    Close(f);
    WriteLn('Die Partionstabelle und die Bootsektoren von C: bis ',
            Chr(BYTE(i) + 62), ': ');
    Writeln('wurden aus der Datei SAVEFILE.BIN zurÅckgeschrieben.');
    SetFAttr(f, Hidden);
  END;
END.

(*===================================================================*)