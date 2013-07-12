{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X-}
(*===================================================================*)
(*                    HUCKEPACK.PAS Version 1.0                      *)
(*                  Copyright (C) 1993 te-wi Verlag                  *)
(*===================================================================*)
(*                                                                   *)
(*  Funktion: Ersetzen von Konfigurationsdateien, indem              *)
(*            Konfigurationsdaten an das EXE-Programm                *)
(*            (ParamStr(0)) angehÑngt werden.                        *)
(*                                                                   *)
(*  Vorbemerkung:                                                    *)
(*   Turbo Pascal ab Version 5.5 erlaubt es, Overlays mit            *)
(*      COPY/B programm+overlay prg                                  *)
(*   an das EXE-File anzuhÑngen. Solche Programme dÅrfen             *)
(*   HuckePack auf keinen Fall verwenden, da hier die Daten          *)
(*   in das Overlay geschrieben wÅrden!                              *)
(*-------------------------------------------------------------------*)
(*  INTERFACE-Variablen:                                             *)
(*                                                                   *)
(*  MaxVars: BYTE (Voreinstellung 20 Bytes = VerlÑngerung um         *)
(*           23 Bytes)                                               *)
(*  ExeName: STRING (Voreinstellung: ParamStr(0) = Name des          *)
(*           Programmes)                                             *)
(*-------------------------------------------------------------------*)
(*  INTERFACE-Prozeduren:                                            *)
(*                                                                   *)
(*  PROCEDURE WriteVarToExeFile(VarAdr: LongInt;                     *)
(*                              Variable: BYTE);                     *)
(*   Schreibt die Byte-Variable 'Variable' an die Stelle             *)
(*   VarAdr des öberhang-Bereiches. Ist der Variablenbereich         *)
(*   noch nicht vorhanden, wird er automatisch initialisiert.        *)
(*                                                                   *)
(*  PROCEDURE ReadVarFromExeFile(VarAdr: LongInt;                    *)
(*                               VAR Variable: BYTE);                *)
(*   Liest aus dem Variablenbereich die Variable 'Variable'.         *)
(*   Ist noch kein Variablenbereich initialisiert wird der neu       *)
(*   gebildet und mit Nullen aufgefÅllt.                             *)
(*                                                                   *)
(*  Aufbau des Variablenbereiches:                                   *)
(*  Benutzt werden kann der Bereich von Byte 0 bis Byte              *)
(*  MaxVars. Vor dem Bereich werden noch zwei Zeichen (JB)           *)
(*  angehÑngt, die mit                                               *)
(*    ReadVarFromExeFile(-2, t1);                                    *)
(*    ReadVarFromExeFile(-1, t2);                                    *)
(*    IF (t1 <> 74) AND (t2 <> 66) THEN { Fehler! }                  *)
(*  getestet werden.                                                 *)
(*                                                                   *)
(*  Die Unit liest und schreibt in der EXE-Datei auch dann,          *)
(*  wenn diese schreibgeschÅtzt ist. Vor jedem Lese- und             *)
(*  Schreibvorgang werden die Dateiattribute und das Datei-          *)
(*  Erstellungsdatum gelesen und anschlie·end wieder restauriert.    *)
(*  Sind Virus-Checker installiert, die die Dateien auf              *)
(*  LÑngenÑnderungen prÅfen oder die es verhindern, da·              *)
(*  Datei-Attribute geÑndert werden, kann es mit Programmen          *)
(*  Probleme geben, die die UNIT Huckepack verwenden. Unter          *)
(*  normalen UmstÑnden ist es fÅr den Benutzer aber nicht            *)
(*  feststellbar, da· die Programme manipuliert werden.              *)
(*  Das EXE-Programm selbst merkt nicht, da· es verlÑngert           *)
(*  wird, da die ProgrammlÑnge ausschlie·lich aus der im             *)
(*  Header vermerken LÑnge geholt wird und hier keine                *)
(*  Manipulationen stattfinden.                                      *)
(*-------------------------------------------------------------------*)
(*  INTERFACE-Funktionen:                                            *)
(*                                                                   *)
(*  FUNCTION GetRealFileLength: LongInt;                             *)
(*   Die Funktion ermittelt die effektive LÑnge einer Datei.         *)
(*                                                                   *)
(*  FUNCTION GetFileLenFromHeader: LongInt;                          *)
(*   Die Funktion ermittelt die im EXE-Header angegebene             *)
(*   ProgrammlÑnge  eines EXE-Files. Wird die Funktion auf           *)
(*   ein Programm oder eine Datei angewandt, die nicht im            *)
(*   EXE-Format vorliegt, gibt die Funktion 0 zurÅck.                *)
(*                                                                   *)
(*   Sollen die beiden Funktionen auf ein anderes Programm           *)
(*   als ParamStr(0) angewandt werden, mu· die in Huckepack          *)
(*   definierte Variable ExeFile im aufrufenden Programm             *)
(*   entsprechend Åberschrieben werden, z.B:                         *)
(*                                                                   *)
(*   ExeName := ParamStr(1);                                         *)
(*   IF GetFileLenFromHeader = 0 THEN { Fehler }                     *)
(*   ELSE                                                            *)
(*   BEGIN                                                           *)
(*     IF GetRealFileLength <> GetFileLenFromHeader THEN ...         *)
(*                                                                   *)
(*  Intern werden die Funktionen verwendet, um zu prÅfen, ob         *)
(*  das Programm bereits einen VariablenÅberhang enthÑlt.            *)
(*                                                                   *)
(*===================================================================*)

UNIT Huckepack;

INTERFACE

CONST                (* LÑnge des Variablenbereiches, ggf. anpassen! *)
  MaxVars : BYTE = 20;
VAR
  ExeName : STRING;

PROCEDURE WriteVarToEXEFile(VarAdr: LONGINT;  Variable: BYTE);
PROCEDURE ReadVarFromEXEFile(VarAdr: LONGINT; VAR Variable: BYTE);
FUNCTION  GetRealFileLength: LONGINT;
FUNCTION  GetFileLenFromHeader: LONGINT;

IMPLEMENTATION

USES
  Dos;

VAR
  ExePath : DirStr;
  ExeExt  : ExtStr;
  Name    : NameStr;
  IOError : INTEGER;

CONST
  FTime : LONGINT = 0;
  FAttr : WORD    = Archive;

(*-------------------------------------------------------------------*)

PROCEDURE Error(err: INTEGER);
VAR
  Msg: STRING;
  Regs: Registers;
BEGIN
  CASE err OF
    $02: Msg := 'Datei nicht gefunden';
    $03: Msg := 'Pfad nicht gefunden';
    $04: Msg := 'Zugriff verweigert';
    $06: Msg := 'Fehlerhafter Zugriff';
    $12: Msg := 'Zu viele Dateien';
    $FE: Msg := 'Falsche DOS-Version';
    ELSE Msg := 'unerwarteter Fehler';
  END;{CASE}
  WriteLn('Es ist ein Fehler aufgetreten!');
  WriteLn('Fehlernummer: ', err);
  WriteLn('ErlÑuterung : ', Msg + Chr(13) + Chr(10));
  Write('Das Programm wird abgebrochen!');
  IF Mem[$0040:$0049] = 7 THEN {HercMono}
    Regs.CX := $0709
  ELSE
    Regs.CX := $0607; {CGA/EGA}
  Regs.AH := $01; {Cursor setzen}
  Intr($10, Regs);
  Halt(BYTE(err));
END;{Error}

(*-------------------------------------------------------------------*)
(* Die Prozeduren PrepareFile u. RestoreSettings MöSSEN immer und    *)
(* grundsÑtzlich alternierend aufgerufen werden. Eine Verschachtelung*)
(* fÅhrt zu falschen Resultaten !!!!!!                               *)
(*-------------------------------------------------------------------*)

PROCEDURE PrepareFile(FileName: PathStr);
VAR
  f: FILE;
BEGIN
  Assign(f, FileName);
  GetFAttr(f, FAttr);
  IOError := DosError;
  IF IOError <> 0 THEN Error(IOError);
  SetFAttr(f, Archive);
  IOError := DosError;
  IF IOError <> 0 THEN Error(IOError);
  Assign(f, FileName);
  Reset(f);
  IOError := IOResult;
  IF IOError <> 0 THEN Error(IOError);
  GetFTime(f, FTime);
  Close(f);
END;

(*-------------------------------------------------------------------*)

PROCEDURE RestoreSettings(FileName: PathStr);
VAR
  f: FILE;
BEGIN
  Assign(f, FileName);
  Reset(f);
  IOError := IOResult;
  IF IOError <> 0 THEN Error(IOError);
  SetFTime(f, FTime);
  Close(f);
  Assign(f, FileName);
  SetFAttr(f, FAttr);
  IOError := DosError;
  IF IOError <> 0 THEN Error(IOError);
END;

(*-------------------------------------------------------------------*)

FUNCTION GetFileLenFromHeader: LONGINT;
VAR
  ExeFile: FILE OF BYTE;
  IDByte : ARRAY[1..2] OF BYTE;
  g      : ARRAY[1..4] OF BYTE;
BEGIN
  PrepareFile(ExeName);
  Assign(ExeFile, ExeName);
  Reset(ExeFile);
  IOError := IOResult;
  IF IOError <> 0 THEN Error(IOError);
  Read(ExeFile, IDByte[1]);
  Read(ExeFile, IDByte[2]);
  IF (Chr(IDByte[1]) = 'M') AND (Chr(IDByte[2]) = 'Z') THEN
                     BEGIN                            (* EXE-Kennung *)
    Read(ExeFile, g[1]);
    Read(ExeFile, g[2]);
    Read(ExeFile, g[3]);
    Read(ExeFile, g[4]);
    Close(ExeFile);
    IF (g[1] = 0) AND (g[2] = 0) THEN
      GetFileLenFromHeader :=
          LONGINT(g[4]) * 256 + LONGINT(g[3])
    ELSE
      GetFileLenFromHeader :=
        ((LONGINT(g[4]) * 256 +
          LONGINT(g[3])) - 1) * 512 +
         (LONGINT(g[2]) * 256 +
          LONGINT(g[1]));
  END
  ELSE
  GetFileLenFromHeader := 0;
  RestoreSettings(ExeName);
END;

(*-------------------------------------------------------------------*)

FUNCTION GetRealFileLength: LONGINT;
VAR
  fle : FILE;
BEGIN
  PrepareFile(ExeName);
  Assign(fle, ExeName);
  Reset(fle, 1);
  IOError := IOResult;
  IF IOError <> 0 THEN Error(IOError);
  GetRealFileLength := FileSize(fle);
  Close(fle);
  RestoreSettings(ExeName);
END;

(*-------------------------------------------------------------------*)

PROCEDURE WriteVarToEXEFile(VarAdr: LONGINT;
                            Variable: BYTE);
VAR
  i, Init    : BYTE;
  f          : FILE;
  ExeFile    : FILE OF BYTE;
  FleLength,
  ExeLength  : LONGINT;
BEGIN
  ExeLength := GetFileLenFromHeader;
  FleLength := GetRealFileLength;
  PrepareFile(ExeName);
  IF FleLength = ExeLength THEN
  BEGIN
    Init := 0;                    (* Variablenbereich initialisieren *)
    Assign(ExeFile, ExeName);
    Reset(ExeFile);
    Seek(ExeFile, ExeLength);
    Init := BYTE(Ord('J'));                  (* Kennung 1. Buchstabe *)
    Write(ExeFile, Init);
    Init := BYTE(Ord('B'));                  (* Kennung 2. Buchstabe *)
    Write(ExeFile, Init);
    Init := 0;
    FOR i := 0 TO MaxVars DO
      Write(ExeFile, Init);
    Close(ExeFile);
  END;
  Assign(ExeFile, ExeName);
  Reset(ExeFile);
  Seek(ExeFile, ExeLength + VarAdr + 2);
  Write(ExeFile, Variable);
  Close(ExeFile);
  RestoreSettings(ExeName);
END;

(*-------------------------------------------------------------------*)

PROCEDURE ReadVarFromEXEFile(VarAdr: LONGINT;
                         VAR Variable: BYTE);
VAR
  ExeLength,
  FleLength : LONGINT;
  ExeFile   : FILE OF BYTE;
BEGIN
  ExeLength := GetFileLenFromHeader;
  FleLength := GetRealFileLength;
  IF FleLength = ExeLength THEN
  BEGIN
    IF Lo(DosVersion) < 3 THEN Error($FE);
    WriteVarToEXEFile(0, 0);
    Variable := 0;
  END
  ELSE
  BEGIN
    PrepareFile(ExeName);
    Assign(ExeFile, ExeName);
    Reset(ExeFile);
    IOError := IOResult;
    IF IOError <> 0 THEN Error(IOError);
    Seek(ExeFile, ExeLength + VarAdr + 2);
                           (* LÑnge des Programms + Adresse + Header *)
    Read(ExeFile, Variable);
    Close(ExeFile);
    RestoreSettings(ExeName);
  END;
END;

(*-------------------------------------------------------------------*)

BEGIN
  ExeName := ParamStr(0);
(* darf von anderen Units oder vom Hauptprogramm Åberschrieben       *)
(* werden.                                                           *)
END.

(*===================================================================*)
