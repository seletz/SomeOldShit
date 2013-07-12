{$A+,B-,D-,E-,F+,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X-}
(*===================================================================*)
(*                            DOSUTIL.PAS                            *)
(*                    (C) 1993 te-wi Verlag, MÅnchen                 *)
(*-------------------------------------------------------------------*)
(*  Implementation von in der Unit DOS ØvergessenenÆ DOS- und BIOS-  *)
(*                 Funktionen sowie Erweiterungen                    *)
(*===================================================================*)

UNIT DOSUtil;

INTERFACE

CONST
  USA          = 01; Netherlands  = 31; Belgium      = 32;
  France       = 33; Spain        = 34; Italy        = 39;
  Switzerland  = 41; Austria      = 43; Britain      = 44;
  Denmark      = 45; Sweden       = 46; Norway       = 47;
  Germany      = 49;                              (* LÑnderkennungen *)

TYPE
  tBPB       = RECORD
    BytesPerSector    : WORD;      (* Bytes pro Sektor               *)
    SectorsPerCluster : BYTE;      (* Anzahl der Sektoren je Cluster *)
    ReservedSectors   : WORD;      (* reservierte Sektoren           *)
    NumberOfFATs      : BYTE;      (* Anzahl der Fileallocat.-Tables *)
    RootEntries       : WORD;      (* Anzahl der RooteintrÑge        *)
    TotalSectors      : WORD;      (* der Sektoren auf dem Laufwerk  *)
    MediaDescriptor   : BYTE;      (* Media-Identifizierungs-Byte    *)
    SectorsPerFAT     : WORD;      (* Anzahl der Sektoren pro FAT    *)
    SectorsPerTrack   : WORD;      (* Anzahl der Sektoren pro Spur   *)
    Heads             : WORD;      (* Anzahl der Schreib-/Lese-Kîpfe *)
    HiddenSectors     : LONGINT;   (* Anzahl versteckter Sektoren    *)
    BigTotalSectors   : LONGINT;   (* Anzahl der Sektoren bei BIGDOS *)
    reserved          : ARRAY[0..6] OF BYTE; (* reservierter Bereich *)
  END;

  tBootBlock = RECORD
    Jump              : ARRAY[1..3] OF BYTE;   (* JMP zur Bootrout.  *)
    OEM               : ARRAY[1..8] OF CHAR;   (* OEM-Kennung        *)
    Data              : tBPB;                  (* Parameter-Tabelle  *)
        (* Ab hier kein Standard mehr. Kompatible und Ñltere Systeme *)
        (* kînnen einen hiervon abweichenden Aufbau besitzen:        *)
    DiskLabel         : ARRAY[1..11] OF CHAR;  (* DOS>=4-spezifisch  *)
    FATTypeText       : ARRAY[1..8] OF CHAR;   (* DOS>=4-spezifisch  *)
    DosLoader         : ARRAY[0..351] OF BYTE; (* DOS-Laderoutine    *)
    Messages          : ARRAY[0.. 64] OF CHAR; (* Lader-Meldungen    *)
    FileLoader        : ARRAY[0.. 30] OF CHAR; (* Dateilader         *)
        (* Ab hier wieder Standard:                                  *)
    EndMarker         : ARRAY[0..1] OF CHAR;   (* Sektor-Ende-Marke  *)
  END;

(*-------------------------------------------------------------------*)
(* Die Funktion GetCountry liefert den in der CONFIG.SYS angegebenen *)
(* Landescode nach der obigen Konstantentabelle                      *)
FUNCTION GetCountry: BYTE;

(*-------------------------------------------------------------------*)
(* Funktion zur Ermittlung der LÑnge eines Exe-Programms aus dem     *)
(* Exe-Header                                                        *)
FUNCTION ExeFileLength(fName: STRING) : LONGINT;

(*-------------------------------------------------------------------*)
(* DOS-Funktionen ab DOS 4: Es wird die nicht-dokumentierte DOS-     *)
(* Funktion 69h mit den Unterfunktionen 00h und 01h verwendet. Die   *)
(* Funktion gibt es zwar auch unter OS/2 2.0X. Dort werden die Lese- *)
(* und Schreiboperationen aber vom Betriebssystem-Kernel abgeblockt. *)

(* Lesen der DatentrÑger-Kennnummer der DOS-Versionen 4 bis 6        *)
FUNCTION ReadDiskIDNumber(Drive: CHAR): STRING;

(* Schreiben der DatentrÑger-Kennnummer der DOS-Versionen 4 bis 6    *)
FUNCTION WriteDiskIDNumber(Drive: CHAR; IdNumber: STRING): INTEGER;

(* Lesen des Disketten-/Plattenlabels Åber FindFirst. Dos-Versions-  *)
(* unabhÑngig.                                                       *)
FUNCTION GetLabel(Drive: BYTE): STRING;

(* Setzen des Disketten-/Plattenlabels Åber FCB-Funktionen           *)
FUNCTION SetLabel(Drive: BYTE; DriveLabel: STRING): INTEGER;

(* Lesen des Disketten-/Plattenlabels im Bootsektor der DOS-Versio-  *)
(* nen 4 bis 6. Nicht zu verwechseln mit dem Eintragen der Volume-   *)
(* Label-Verzeichniseintrags!                                        *)
FUNCTION ReadDos4Label(Drive: CHAR): STRING;

(* Schreiben des Disketten-/Plattenlabels im Bootsektor der DOS-     *)
(* Versionen 4 bis 6. Nicht zu verwechseln mit dem Eintrag ØVolumeÆ  *)
(* im Hauptverzeichnis einer Diskette oder Platte.                   *)
FUNCTION WriteDos4Label(Drive: CHAR; VolLabel: STRING): INTEGER;

(*-------------------------------------------------------------------*)
(*     DOS und BIOS-Funktionen Direct-Write und Direct-Read.         *)

FUNCTION BIOSWrite(Drive: BYTE; Head, Cyl, First, Num: WORD;
                   VAR Buffer): INTEGER;
FUNCTION BIOSRead(Drive: BYTE; Head, Cyl, First, Num: WORD;
                  VAR Buffer): INTEGER;

FUNCTION DiskWrite(Drive: BYTE; Head, Cyl, First, Num: WORD;
                   VAR Buffer): INTEGER;
FUNCTION DiskRead(Drive: BYTE; Head, Cyl, First, Num: WORD;
                  VAR Buffer): INTEGER;

FUNCTION ReadBootSector (Drive: BYTE; VAR Buffer): INTEGER;
FUNCTION WriteBootSector(Drive: BYTE; VAR Buffer): INTEGER;

FUNCTION ReadPartition (Drive: BYTE; VAR Buffer): INTEGER;
FUNCTION WritePartition(Drive: BYTE; VAR Buffer): INTEGER;

(*-------------------------------------------------------------------*)
(*               Auslîsen von Kaltstart und Warmstart!               *)
PROCEDURE ColdBoot;
PROCEDURE WarmBoot;

(* Falls DR-DOS installiert ist, RÅckgabe der Versionsnummer, sonst  *)
(* (also bei MS-DOS) wird der Wert $0000 zurÅckgegeben               *)
FUNCTION DRDOSVersion: WORD;

IMPLEMENTATION
{$F+}

USES Dos, Hex;

TYPE
  tInfoRec     = RECORD
    reserved,
    labellow,
    labelhigh  : WORD;
    vlabel,
    fattype    : ARRAY[0..10] OF CHAR;
  END;

CONST
  InfoRec     : tInfoRec =
    (reserved : 0000;
     labellow : 0000;
     labelhigh: 0000;
     vlabel   : #0#0#0#0#0#0#0#0#0#0#0;
     fattype  : 'FAT 16'#0#0#0#0#0);

  MaxBufSize              = 511;
  GetParameters : BYTE    = $60;
  SetParameters : BYTE    = $40;
  WriteTrack    : BYTE    = $41;
  ReadTrack     : BYTE    = $61;
  FormatTrack   : BYTE    = $42;
  VerifyTrack   : BYTE    = $62;
  SetAccessFlag : BYTE    = $47;
  GetAccessFlag : BYTE    = $67;
  Dos330                  = $31E;

TYPE
  tSectBuffer = ARRAY[0..MaxBufSize] OF BYTE; (* Puffer fÅr 1 Sektor *)

  pLayoutList = ^tLayoutList;
  tLayoutList = RECORD
    SectorNumber : WORD;
    SectorSize   : WORD;
    Next         : pLayoutList;
  END;

  tTrackLayout = RECORD
    SectorCount : WORD;
    Sectors     : pLayoutList;
  END;

  tDeviceParams = RECORD
    SpecialFunctions : BYTE;
    DeviceType       : BYTE;
    DeviceAttributes : WORD;
    Cylinders        : WORD;
    MediaType        : BYTE;
    DeviceBPB        : tBPB;
    TrackLayOut      : tTrackLayout;
  END;

  tR_W_Block = RECORD
    SpecialFunctions : BYTE;
    Head             : WORD;
    Cylinder         : WORD;
    FirstSector      : WORD;
    NumberOfSectors  : WORD;
    TransferAddress  : POINTER;
  END;

FUNCTION GetExtendedError: INTEGER; ASSEMBLER;
(*-------------------------------------------------------------------*)
(* Liste aller mîglichen DOS-Fehler:                                 *)
(* Standard-Fehlercodes:                                             *)
(*  0       kein Fehler                                              *)
(*  1       Subfunktion nicht unterstÅtzt                            *)
(*  2       Datei nicht gefunden                                     *)
(*  3       Suchweg nicht gefunden                                   *)
(*  4       Keine weiteren freien Handles                            *)
(*  5       Zugriff verweigert                                       *)
(*  6       Handle nicht definiert                                   *)
(*  7       Speicherkontrollblock zerstîrt                           *)
(*  8       Nicht genug Speicherplatz                                *)
(*  9       Keine Block-Segmentadresse (MCB)                         *)
(* 10       Fehler im Environment                                    *)
(* 11       UngÅltiges Format                                        *)
(* 12       UngÅltiger Zugriffscode                                  *)
(* 13       UngÅltige Daten                                          *)
(* 14       reserviert (unbenutzt)                                   *)
(* 15       Laufwerk existiert nicht                                 *)
(* 16       Aktuelles Laufwerk lÑ·t sich nicht entfernen             *)
(* 17       Rename kann nicht kopieren                               *)
(* 18       Keine weiteren EintrÑge                                  *)
(* Kritische Fehler:                                                 *)
(* 19       Medium ist schreibgeschÅtzt                              *)
(* 20       GerÑt nicht definiert                                    *)
(* 21       GerÑt nicht bereit                                       *)
(* 22       Unbekannter Befehl                                       *)
(* 23       PrÅfsummenfehler (CRC) auf dem Medium                    *)
(* 24       Falsche SektorlÑnge                                      *)
(* 25       Spur nicht gefunden                                      *)
(* 26       Unbekanntes Media-ID                                     *)
(* 27       Sektor nicht gefunden                                    *)
(* 28       Kein Papier im Drucker                                   *)
(* 29       genereller Schreibfehler                                 *)
(* 30       Lesefehler                                               *)
(* 31       Genereller Fehler                                        *)
(* Kritische Fehler ab DOS 3.0:                                      *)
(* 32       Datei ist gesperrt                                       *)
(* 33       Datensatz ist gesperrt                                   *)
(* 34       Unerlaubter Diskettenwechsel                             *)
(* 35       Kein FCB verfÅgbar                                       *)
(* 36       Alle LOCK-Records besetzt                                *)
(* Standard-Fehlercodes ab DOS 3.0:                                  *)
(* 50       Operation nicht unterstÅtzt                              *)
(* 65       Codeseiten-Umschaltung nicht mîglich                     *)
(* 68       Generische IOCTL-Aufrufe nicht unterstÅtzt               *)
(* 80       Datei existiert bereits                                  *)
(* 81       FCB existiert doppelt                                    *)
(* 82       Verzeichnis existiert bereits                            *)
(* 83       Abbruch nach Critical Error                              *)
(* 84       DOS-interne Tabellen vollstÑndig belegt                  *)
(* 85       Laufwerk bereits zugeordnet                              *)
(* 86       Pa·wort ungÅltig (LAN)                                   *)
(* 87       UngÅltiger Parameter                                     *)
(* 88       Schreibfehler im Netzwerk                                *)
(*-------------------------------------------------------------------*)
ASM                              (* DOS-Funktion 59h: Extended Error *)
  MOV AH, 59h                    (* Die Funktion liefert den letzten *)
  XOR BX, BX                     (* bei einer DOS-Operation aufge-   *)
  INT 21h                        (* tretenen Fehlercode in AX zurÅck *)
END;

FUNCTION ReadDiskIDNumber(Drive: CHAR): STRING;
VAR
  drv : BYTE;
  Regs: Registers;
  s   : STRING;
BEGIN
  drv := Ord(UpCase(Drive)) - 64;
  IF Lo(DosVersion) IN [4..9] THEN WITH Regs DO
  BEGIN
    BL := drv;
    DS := Seg(InfoRec);
    DX := Ofs(InfoRec);
    AX := $6900;                 (* undokumentierte DOS-Funktion 69h *)
    MsDos(Regs);                 (* Unterfunktion 00 ab MS-DOS 4.0   *)
    IF Odd(Flags) THEN           (* (Flags AND FCarry) = FCarry      *)
    BEGIN
      CASE AX OF
        5, 11:  s := 'XXXX:XXXX';
       15, 30:  s := '    :    ';
       ELSE     s := Word2Hex(InfoRec.labelhigh) + ':' +
                     Word2Hex(InfoRec.labellow);
      END
    END
    ELSE
      s := Word2Hex(InfoRec.labelhigh) + ':' +
           Word2Hex(InfoRec.labellow);
  END
  ELSE s := '0000:0000';               (* Funktion nicht unterstÅtzt *)
  ReadDiskIDNumber := s;
END;

FUNCTION WriteDiskIDNumber(Drive: CHAR; IdNumber: STRING): INTEGER;
VAR
  Regs  : Registers;
  drv   : BYTE;
  test  : INTEGER;
  s1, s2: STRING;
BEGIN
  IF Length(IdNumber) <> 9 THEN
  BEGIN
    WriteDiskIDNumber := 50;
    Exit;
  END;
  WriteDiskIDNumber := 0;
  drv := Ord(UpCase(Drive)) - 64;
  IF Lo(DosVersion) IN [4..9] THEN WITH Regs DO
  BEGIN
    BL := drv;
    DS := Seg(InfoRec);
    DX := Ofs(InfoRec);
    AX := $6900;                 (* undokumentierte DOS-Funktion 69h *)
    MsDos(Regs);                 (* Unterfunktion 00 ab MS-DOS 4.0   *)
    IF Odd(Flags) THEN           (* (Flags AND FCarry) = FCarry      *)
    BEGIN
   (* es ist ein Fehler aufgetreten, der Zeiger konnte nicht gesetzt *)
   (* werden. Deshalb wird die DatentrÑger-Nummer nicht geschrieben. *)
      WriteDiskIDNumber := INTEGER(AX);
      Exit;
    END
    ELSE
    BEGIN
      s1 := Copy(IdNumber, 1, 4);
      Delete(IdNumber, 1, 5);
      s2 :=IdNumber;
      Val(s1, InfoRec.labellow, test);
      IF test <> 0 THEN BEGIN WriteDiskIDNumber := test; Exit; END;
      Val(s2, InfoRec.labelhigh, test);
      IF test <> 0 THEN BEGIN WriteDiskIDNumber := test; Exit; END;
      BL := drv;
      DS := Seg(InfoRec);
      DX := Ofs(InfoRec);        (* undokumentierte DOS-Funktion 69h *)
      AX := $6901;               (* Unterfunktion 01 ab MS-DOS 4.0   *)
      MsDos(Regs);
      IF Odd(Flags) THEN WriteDiskIDNumber := AX;
    END;
  END;
END;

FUNCTION ReadDos4Label(Drive: CHAR): STRING;
VAR
  drv  : BYTE;
  Regs : Registers;

BEGIN
  drv := Ord(UpCase(Drive)) - 64;
  IF Lo(DosVersion) IN [4..9] THEN WITH Regs DO
  BEGIN
    BL := drv;
    DS := Seg(InfoRec);
    DX := Ofs(InfoRec);
    AX := $6900;                 (* undokumentierte DOS-Funktion 69h *)
    MsDos(Regs);                 (* Unterfunktion 00 ab MS-DOS 4.0   *)
    IF Odd(Flags) THEN
    BEGIN
      ReadDos4Label := #0#0#0#0#0#0#0#0#0#0#0;
      Exit;
    END
    ELSE ReadDos4Label := InfoRec.vlabel;
  END
  ELSE ReadDos4Label := #0#0#0#0#0#0#0#0#0#0
                                       (* Funktion nicht unterstÅtzt *)
END;

FUNCTION WriteDos4Label(Drive: CHAR; VolLabel: STRING): INTEGER;
VAR
  Regs: Registers;
  i,
  drv : BYTE;
BEGIN
  WriteDos4Label := 0;
  drv := Ord(UpCase(Drive)) - 64;
  IF Lo(DosVersion) IN [4..9] THEN WITH Regs DO
  BEGIN
    BL := drv;
    DS := Seg(InfoRec);
    DX := Ofs(InfoRec);
    AX := $6900;                 (* undokumentierte DOS-Funktion 69h *)
    MsDos(Regs);                 (* Unterfunktion 00 ab MS-DOS 4.0   *)
    IF Odd(Flags) THEN BEGIN     (* FCarry ist gesetzt               *)
   (* es ist ein Fehler aufgetreten, der Zeiger konnte nicht gesetzt *)
   (* werden. Deshalb wird die DatentrÑger-Nummer nicht geschrieben. *)
      WriteDos4Label := AX;
      Exit;
    END
    ELSE
    BEGIN
      FOR i := 0 TO Pred(Length(VolLabel)) DO
        InfoRec.vlabel[i] := VolLabel[Succ(i)];
      IF Length(VolLabel) < 11 THEN
        FOR i := Length(VolLabel) TO 11 DO
         InfoRec.vlabel[Pred(i)] := #0;
      BL := drv;
      DS := Seg(InfoRec);
      DX := Ofs(InfoRec);        (* undokumentierte DOS-Funktion 69h *)
      AX := $6901;               (* Unterfunktion 01 ab MS-DOS 4.0   *)
      MsDos(Regs);
      IF Odd(Flags) THEN WriteDos4Label := AX;
    END;
  END;
END;

FUNCTION ExeFileLength(fName: STRING): LONGINT;
VAR
  ExeFile: FILE OF BYTE;
  ExeID1,
  ExeID2,
  b1, b2,
  b3, b4 : BYTE;
  sr     : SearchRec;
BEGIN
  FindFirst(fName, Anyfile - Directory - VolumeID, sr);
  IF Length(fName) < Length(sr.Name) THEN BEGIN
    IF Pos(fName, sr.Name) = 0 THEN
    BEGIN
      ExeFileLength := -1;
      Exit;
    END
  END ELSE BEGIN
    IF Pos(sr.Name, fName) = 0 THEN
    BEGIN
      ExeFileLength := -1;
      Exit;
    END;
  END;
  Assign(ExeFile, fName);
  Reset(ExeFile);
  Read(ExeFile, ExeID1);
  Read(ExeFile, ExeID2);
  IF (Chr(ExeID1) <> 'M') OR (Chr(ExeID2) <> 'Z') THEN
  BEGIN
    ExeFileLength := -1;                (* Keine Exe-Programm-Datei! *)
    Exit;
  END;
  Read(ExeFile, b1);
  Read(ExeFile, b2);
  Read(ExeFile, b3);
  Read(ExeFile, b4);
  Close(ExeFile);
  IF (b2 = 0) AND (b1 = 0) THEN
    ExeFileLength:= b4 * $100 + b3
  ELSE
    ExeFileLength := ((b4 * $100 + b3) - 1) * $200
                    + (b2 * $100 + b1)
END;

FUNCTION GetCountry: BYTE; 
(* Die Daten aus dem LandesPuffer werden nicht ausgewertet, wer Lust *)
(* hat, kann sich das selbst implementieren.                         *)
TYPE
  tCountryBuffer = RECORD       (* DOS-Puffer mit Landes-Information *)
    DateFormat: WORD;           (* Aufbau nur gÅltig ab DOS 3.0!     *)
    Currency  : ARRAY[0..4] OF CHAR;           (* WÑhrungsformat     *)
    thousand  : CHAR;                          (* Tausender-Trennung *)
    dummy1    : BYTE;                          (* ein Null-Byte      *)
    dezimal   : CHAR;                          (* Dezimal-Zeichen    *)
    dummy2    : BYTE;                          (* ein Null-Byte      *)
    date      : CHAR;                          (* Datum-Trennzeichen *)
    dummy3    : BYTE;                          (* ein Null-Byte      *)
    Time      : CHAR;                          (* Zeit-Trennzeichen  *)
    dummy4    : BYTE;                          (* ein Null-Byte      *)
    Curr_Form : BYTE; (* BITSET *)             (* WÑhrungsformat     *)
    exact     : BYTE;            (* Stellen hinter dem WÑhrungskomma *)
    Time_Form : BYTE; (* BITSET *)             (* Zeitformat         *)
    Rout_Offs : WORD;            (* Offset DOS-Zeichensatztabelle    *)
    Rout_Seg  : WORD;            (* Segment DOS-Zeichensatztabelle   *)
    reserved  : ARRAY[0..11] OF BYTE;            (* reserv. Bereich  *)
  END;
VAR
  vCountry: tCountryBuffer;
  s, o    : WORD;
  return  : BYTE;
BEGIN
  s := Seg(vCountry);
  o := Ofs(GetCountry);
  ASM
     MOV AH, 38h
     MOV BX, s
     MOV DS, BX
     MOV DX, o
     XOR AL, AL
     INT 21h
     MOV return, BL
  END;
  GetCountry := return;
END;
FUNCTION IO_Generic(Drive: BYTE; What: BYTE; VAR Struct): INTEGER;
VAR
  Regs : Registers;
BEGIN
  WITH Regs DO BEGIN
    AH := $44;
    AL := $0D;
    BL := Drive;
    CH := $08;                              (* Kategorie (immer $08) *)
    CL := What;
    DS := Seg(Struct);
    DX := Ofs(Struct);
    Intr($21, Regs);
    IF Odd(Flags) THEN IO_Generic := AX ELSE IO_Generic := 0;
  END;
END;

FUNCTION DiskRead(Drive: BYTE; Head, Cyl, First, Num: WORD;
                  VAR Buffer): INTEGER;
VAR
  RW : tR_W_Block;
BEGIN
  RW.SpecialFunctions := 0;
  RW.Head             := Head;
  RW.Cylinder         := Cyl;
  RW.FirstSector      := First - 1;
  RW.NumberOfSectors  := Num;
  RW.TransferAddress  := @Buffer;
  DiskRead := IO_Generic(Drive, ReadTrack, RW);
END;

FUNCTION DiskWrite(Drive: BYTE; Head, Cyl, First, Num : WORD;
                   VAR Buffer): INTEGER;
VAR
  RW : tR_W_Block;
BEGIN
  RW.SpecialFunctions := 0;
  RW.Head             := Head;
  RW.Cylinder         := Cyl;
  RW.FirstSector      := First - 1;
  RW.NumberOfSectors  := Num;
  RW.TransferAddress  := @Buffer;
  DiskWrite := IO_Generic(Drive, WriteTrack, RW);
END;

FUNCTION BIOSRead(Drive: BYTE; Head, Cyl, First, Num : WORD;
                  VAR Buffer): INTEGER;
VAR
  Regs: Registers;
BEGIN
  WITH Regs DO
  BEGIN
    AH := 2;
    AL := Num;
    CH := Cyl;
    CL := First;
    DH := Head;
    IF Drive < 3 THEN
      DL := Drive
    ELSE
      DL := Drive + $80 - 3;
    ES := Seg(Buffer);
    BX := Ofs(Buffer);
    Intr($13, Regs);
    IF AH = $FF THEN BIOSRead := GetExtendedError
                ELSE BIOSRead := 0;
  END;
END;

FUNCTION BIOSWrite(Drive: BYTE; Head, Cyl, First, Num: WORD;
                   VAR Buffer): INTEGER;
VAR
  Regs: Registers;
BEGIN
  WITH Regs DO
  BEGIN
    AH := 3;
    AL := Num;
    CH := Cyl;
    CL := First;
    DH := Head;
    IF Drive < 3 THEN
      DL := Drive
    ELSE
      DL := Drive + $80 - 3;
    ES := Seg(Buffer);
    BX := Ofs(Buffer);
    Intr($13, Regs);
    IF AH = $FF THEN BIOSWrite := GetExtendedError
                ELSE BIOSWrite := 0;

  END;
END;

FUNCTION ReadBootSector(Drive: BYTE; VAR Buffer): INTEGER;
VAR
  r: INTEGER;
BEGIN
  IF Drive < 3 THEN
  BEGIN
    IF Swap(Dos.DosVersion) < Dos330 THEN
      r := BIOSRead(Drive, 0, 0, 1, 1, Buffer)
    ELSE
      r := DiskRead(Drive, 0, 0, 1, 1, Buffer);
  END
  ELSE
  BEGIN
    IF Swap(Dos.DosVersion) < Dos330 THEN
      r := BIOSRead(Drive, 1, 0, 1, 1, Buffer)
    ELSE
      r := DiskRead(Drive, 1, 0, 1, 1, Buffer)
  END;
  ReadBootSector := r;
END;

FUNCTION WriteBootSector(Drive: BYTE; VAR Buffer): INTEGER;
VAR
  r: INTEGER;
BEGIN
  IF Drive < 3 THEN
  BEGIN
    IF Swap(Dos.DosVersion) < Dos330 THEN
      r := BIOSWrite(Drive, 0, 0, 1, 1, Buffer)
    ELSE
      r := DiskWrite(Drive, 0, 0, 1, 1, Buffer);
  END
  ELSE
  BEGIN
    IF Swap(Dos.DosVersion) < Dos330 THEN
      r := BIOSWrite(Drive, 1, 0, 1, 1, Buffer)
    ELSE
      r := DiskWrite(Drive, 1, 0, 1, 1, Buffer);
  END;
  WriteBootSector := r;
END;

FUNCTION ReadPartition(Drive: BYTE; VAR Buffer): INTEGER;
VAR
  r: INTEGER;
BEGIN
  IF Swap(Dos.DosVersion) < Dos330 THEN
    r := BIOSRead(Drive, 0, 0, 1, 1, Buffer)
  ELSE
    r := DiskRead(Drive, 0, 0, 1, 1, Buffer);
  ReadPartition := r;
END;

FUNCTION WritePartition(Drive: BYTE; VAR Buffer): INTEGER;
VAR
  r: INTEGER;
BEGIN
  IF Swap(Dos.DosVersion) < Dos330 THEN
    r := BIOSWrite(Drive, 0, 0, 1, 1, Buffer)
  ELSE
    r := DiskWrite(Drive, 0, 0, 1, 1, Buffer);
  WritePartition := r;
END;

PROCEDURE RebootSystem; ASSEMBLER;
(* Lîst einen Warmstart aus, das WarmstartIDWort wird nicht geÑndert *)
ASM
  PUSH AX                      (* vorsichtshalber alle verwendeten   *)
  PUSH BX                      (* Register sichern (kann nie schaden *)
  PUSH DX
  PUSH DS
  PUSH ES
  MOV  BX, 0F000H              (* Segment: $F000; Offset:  $FFFE     *)
  MOV  DS, BX                  (* = vorletztes adressierbares Byte   *)
  MOV  BX, 0FFFEH              (* vor 1 Mbyte (absolute Adr. $FFFFE) *)
  MOV  AL, DS:[BX]
  CMP  AL, 0FCH                (* Maschinen-ID: $FC = AT             *)
  JNE  @NoAT
  MOV  AL, 0FEH                (* Identisch mit: Inline($B0/$FE      *)
  MOV  DX, 0064H               (*                      /$BA/$64/$00  *)
  OUT  DX, AL                  (*                      /$EE);        *)
                               (* --> Simulation von Alt+Ctrl+Del    *)
@NoAT:                         (* Nicht geklappt: Brachialmethode    *)
  MOV  BX, 0FFFFH              (* Ñquivalent zu JMP FAR $FFFF:0000   *)
  MOV  BX, ES                  (* --> Inline($EA/$00/$00/$FF/$FF);   *)
  XOR  BX, BX                  (* IBM, Phoenix, XTs, ... . Reset     *)
  CALL WORD Ptr ES:[BX]        (* Im TASM/BASM nur als CALL Åber Reg *)
  POP  ES                      (* Sprung auf die BIOS-Reset-Routine  *)
  POP  DS                      (* Falls es wider Erwarten nicht ge-  *)
  POP  DX                      (* klappt hat, alle Register wieder   *)
  POP  BX                      (* restaurieren                       *)
  POP  AX
END;

PROCEDURE ColdBoot; ASSEMBLER;
(* Die Prozedur lîst einen Reset des Rechners mit Systemcheck aus.   *)
ASM
  PUSH AX                      (* Register auf den Stack (das        *)
  PUSH BX                      (* schadet bekanntlich nie)           *)
  PUSH DS
  MOV  BX, 0040H               (* Segmentadresse auf 0040h Åber      *)
  MOV  DS, BX                  (* DS := BX setzen und Offset auf 72h *)
  MOV  BX, 0072H               (* so da· DS:[BX] = 40h:72h ist.      *)
  XOR  AX, AX                  (* AX := 0;                           *)
  MOV  DS:[BX], AX             (* und nach 40h:72h := 0000 schreiben *)
  CALL RebootSystem            (* ... und Neustart!                  *)
  POP  DS                      (* Register wieder vom Stack holen    *)
  POP  BX
  POP  AX
END;

PROCEDURE WarmBoot; ASSEMBLER;
ASM
  PUSH AX                      (* Register auf den Stack (das        *)
  PUSH BX                      (* schadet bekanntlich nie)           *)
  PUSH DS
  MOV  BX, 0040H               (* Segmentadresse auf 0040h Åber      *)
  MOV  DS, BX                  (* DS := BX setzen und Offset auf 72h *)
  MOV  BX, 0072H               (* so da· DS:[BX] = 40h:72h ist.      *)
  MOV  AX, 1234H               (* AX := 1234 = Warmstartkennung      *)
  MOV  DS:[BX], AX             (* und nach 40h:72h := 0000 schreiben *)
  CALL RebootSystem            (* ... und Neustart                   *)
  POP  DS                      (* Register wieder vom Stack holen    *)
  POP  BX
  POP  AX
END;

FUNCTION DRDOSVersion: WORD;
(* Die Funktion ermittelt auf einfache Weise die DR-DOS-Version. Da- *)
(* bei wird davon ausgegangen, da· DR-DOS im Environment die Variab- *)
(* len OS=DRDOS und VERSION=Nummer implementiert. Diese kînnen al-   *)
(* lerdings durch den Benutzer gelîscht werden. Es gibt eine weitere *)
(* Mîglichkeit, die DR-DOS Version Åber Bugs in diesen Betriebssy-   *)
(* stemen zu ermitteln (SCHéPERS 1991, S. 359 ff, dies ist aber im   *)
(* Normalfall nicht notwendig. Au·erdem kann DR-DOS auch damit er-   *)
(* mittelt werden, da· das Betriebssystem einige spezifische Erwei-  *)
(* terungen, wie die Pa·wortabfrage, enthÑlt.                        *)
VAR
  os     : STRING;
  version: STRING;
BEGIN
  IF Swap(Dos.DosVersion) <> $31F THEN DRDOSVersion := $0000 ELSE
  BEGIN
    os := GetEnv('OS');
    IF os <> 'DRDOS' THEN
    BEGIN
      DRDOSVersion := $0000;
      Exit;
    END;
    version := GetEnv('VERSION');
    CASE version[1] OF
      '3': DRDOSVersion := 341;
      '5': DRDOSVersion := 500;
      '6': DRDOSVersion := 600;
      ELSE DRDOSVersion :=   0;
    END;
  END;
END;

FUNCTION GetLabel(Drive: BYTE): STRING; (* Label des Laufwerks lesen *)
VAR
  sr         : SearchRec;
  SearchDrive: PathStr;
  DriveLabel : STRING[12];
BEGIN
  IF Drive = 0 THEN GetDir(0, SearchDrive)
               ELSE SearchDrive := Chr(Drive + 64);
  SearchDrive := SearchDrive[1];
  FindFirst(SearchDrive + ':\*.*', VolumeID, sr);
  IF DosError = 0 THEN          (* bei DosError 18 --> nicht gesetzt *)
  BEGIN
    DriveLabel := sr.Name;                    (* aus SearchRec holen *)
    IF Pos('.', DriveLabel) > 0 THEN
      Delete(DriveLabel, Pos('.', DriveLabel), 1);  (* Punkt lîschen *)
  END
  ELSE
    DriveLabel := '';                               (* nicht gesetzt *)
  GetLabel := DriveLabel;
END;

FUNCTION SetLabel(Drive: BYTE; DriveLabel: STRING): INTEGER;
(* Setzen des Volume-Labels Åber die DOS FCB-Funktionen. Es werden   *)
(* die DOS-Konventionen berÅcksichtigt, also nur erlaubte Zeichen    *)
(* geschrieben. FÅr Drive: 0 = aktuell, 1 = A:, 2 = B:, 3 = C ...    *)
VAR
  FCB     : ARRAY[0..45] OF BYTE;  (* File-Control-Block vereinfacht *)
  Regs    : Registers;
  OldLabel: STRING[11];             (* ursprÅngliches Diskettenlabel *)
  i       : INTEGER;
BEGIN
  IF Length(DriveLabel) > 11 THEN DriveLabel[0] := Chr(11);
  FCB[0] := $FF;                     (* Kennung erw. FCB setzen      *)
  FOR i := 1 TO 45 DO FCB[i] := $00; (* ... des Rest ausnullen       *)
  FCB[6] := VolumeID;                (* was bearbeitet werden soll   *)
  FCB[7] := Drive;                   (* Laufwerk an Position 7       *)
  OldLabel := GetLabel(drive);       (* das bleibt uns nicht erspart *)
  IF DosError = 18 THEN DosError := 0;(* ØNo more filesÆ kein Fehler *)
  IF DosError <> 0 THEN              (* DOS-Fehler aufgetaucht       *)
  BEGIN
    SetLabel := DosError;            (* Funktionsergebnis = Fehler   *)
    Exit;                            (* ... und raus                 *)
  END;

  IF DriveLabel = '' THEN            (* --> Funktion Label lîschen   *)
  BEGIN
    IF OldLabel <> '' THEN           (* war eines da                 *)
    BEGIN
      FOR i := Length(OldLabel) TO 11 DO
        OldLabel := OldLabel +  ' '; (* Ausnullen mit Leerzeichen    *)
      FOR i := 1 TO 11 DO FCB[i + 7] := Ord(OldLabel[i]);
      WITH Regs DO                   (* in FCB Åbertragen            *)
      BEGIN
        AH := $13;                   (* Funktion 13h: Label lîschen  *)
        DS := Seg(FCB);
        DX := Ofs(FCB);
        MsDos(Regs);
        IF Regs.AH = $FF THEN SetLabel := GetExtendedError
                         ELSE SetLabel := 0;  (* FehlerprÅfung       *)
        Exit;                                 (* ... und raus        *)
      END
    END
    ELSE
    BEGIN             (* wo nichts ist, kannn nichts gelîscht werden *)
      SetLabel := 0;  (* Lîschen was nicht war ist kein Fehler       *)
      Exit;           (* und raus aus der Funktion                   *)
    END;
  END;

  FOR i := Length(DriveLabel) TO 11 DO (* ... und jetzt Label setzen *)
    DriveLabel := DriveLabel +  ' ';
  FOR i := 1 TO 11 DO
  BEGIN                                  (* unerlaubtes Zeichen ???? *)
    IF DriveLabel[i] IN [Chr(0)..Chr(31), '.', '&', '?', '"', '*' ,
                         '+', '<', '>', Chr(166)..Chr(255)] THEN
      DriveLabel[i] := '_';            (* durch Unterstrich ersetzen *)
    IF DriveLabel[i] IN ['/', '|', '/'] THEN DriveLabel[i] := '!'
  END;                              (* oder durch ein Ausrufezeichen *)

  IF Length(OldLabel) > 0 THEN
  BEGIN
    FOR i := Length(OldLabel) TO 11 DO OldLabel := OldLabel +  ' ';
    FOR i := 1 TO 11 DO           (* ausnullen und Åbertragen in FCB *)
    BEGIN
      FCB[i +  7] := Ord(OldLabel[i]); (* Laufwerksnummer nach Pos 7 *)
      FCB[i + 23] := Ord(DriveLabel[i]);
    END;
    WITH Regs DO
    BEGIN
      AH := $17;                   (* Funktion 17h: Label umbenennen *)
      DS := Seg(FCB);
      DX := Ofs(FCB);
      MsDos(Regs);
      IF Regs.AH = $FF THEN SetLabel := GetExtendedError
                       ELSE SetLabel := 0           (* Fehlerabfrage *)
    END;
  END
  ELSE
  BEGIN
    FOR i := 1 TO 11 DO FCB[i + 7] := Ord(DriveLabel[i]);
    WITH Regs DO
    BEGIN
      AH := $16;                        (* Funktion 16h: Neu anlegen *)
      DS := Seg(FCB);                   (* des Labels                *)
      DX := Ofs(FCB);
      MsDos(Regs);
      IF Regs.AH = $FF THEN SetLabel := GetExtendedError
                       ELSE SetLabel := 0
    END;
  END;
END;

END.
(*===================================================================*)
