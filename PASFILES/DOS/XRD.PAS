{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X+,M 65384,0,0}
(*===================================================================*)
(*                         XRD.PAS Version 3.00                      *)
(*            Copyright (C) 1993 te-wi Verlag, MÅnchen               *)
(*          Compiler: Turbo/Borland Pascal Real-Mode-Target          *)
(*===================================================================*)
(*                                                                   *)
(*Beschreibung:                                                      *)
(*ƒƒƒƒƒƒƒƒƒƒƒƒƒ                                                      *)
(* Das Programm lîscht alle in einem Verzeichnis befindlichen        *)
(* Dateien und Unterverzeichnisse; es scheitert nicht an schreib-    *)
(* geschÅtzten und versteckten Dateien. Optional wird das Startver-  *)
(* zeichnis selbst ebenfalls gelîscht.                               *)
(*                                                                   *)
(* Ein Laufwerk kann vollstÑndig gelîscht werden, bei Festplatten ab *)
(* C: wird nochmals nachgefragt und wie bei FORMAT zur Sicherheit    *)
(* das Volume-Label abgefragt, wenn vollstÑndiges Lîschen verlangt   *)
(* wird. Bei vollstÑndigem Lîschen wird auch das Label entfernt.     *)
(*                                                                   *)
(* Es kann auch das aktuelle Verzeichnis mit gelîscht werden. Es     *)
(* wird dann eine entsprechende Meldung ausgegeben.                  *)
(*                                                                   *)
(*EinschrÑnkungen:                                                   *)
(*- Das Programm lÑuft nur unter DOS-Versionen ab 3.00 und bricht    *)
(*  bei Ñlteren DOS-Versionen ab.                                    *)
(*- 4DOS-'EXCEPT' ist auf XDEL nicht anwendbar!                      *)
(*- Das Programm ist nur nach Compilierung im Real-Mode lauffÑhig!   *)
(*-------------------------------------------------------------------*)
PROGRAM eXtendendRmDir;

{$IFNDEF DMPI}

USES
  Dos, DosUtil, Crt, ReadUnit, Cursor, Ansi, UPPER;

(*-------------------------------------------------------------------*)
(*                        globale Deklarationen                      *)
(*-------------------------------------------------------------------*)

CONST
  AllFiles : STRING[3]  = '*.*';                    (* Suchkriterium *)
  UBreak   : STRING[17] = '*** USERBREAK ***';
  PathNFnd : STRING[20] = 'Pfad nicht gefunden!';
  Copyrght : STRING[56] = 'eXtendend Remove-Directory '
                      + 'v.3.00, (C) 1993 te-wi-Verlag';

VAR
  result,                                                (* IOResult *)
  FCount,                                             (* DateizÑhler *)
  VCount   : WORD;                              (* VerzeichniszÑhler *)
  sr       : SearchRec;                            (* siehe Unit DOS *)
  WorkDir  : ARRAY[0..15] OF STRING;
                                            (* bis 15 Ebenen erlaubt *)
  Depth,                                         (* Verzeichnistiefe *)
  count    : BYTE;                                (* SchleifenzÑhler *)
  check    : STRING[1];                           (* ReadLn-Variable *)
  CON      : Text;                          (* Std-Ausgabe wegen CRT *)
  Drive    : STRING;                             (* Laufwerkskennung *)
  VolName  : STRING[12];                          (* Punkt beachten! *)
  InStr    : STRING[11];                     (* Label fÅr HD-Lîschen *)
  ActualDir: STRING;                       (*  RÅcksprungverzeichnis *)
  LeaveIt,                                  (* ja/nein fÅr Start-DIR *)
  LastFile,                                 (* zuletzt File oder DIR *)
  BreakRO  : BOOLEAN;                       (* Break wenn R/H/S-Attr *)
  TestCh   : INTEGER;                              (* fÅr ReadString *)
  AnsiInst : BOOLEAN;
  Buffer   : ARRAY[0..$200] OF BYTE;  (* Puffer fÅr Bootblock-Kontr. *)
  BootBlock: tBootBlock ABSOLUTE Buffer;         (* Bootsektor-Daten *)

(*-------------------------------------------------------------------*)
(*                   Funktionen und Prozeduren                       *)
(*-------------------------------------------------------------------*)

PROCEDURE NewLine;          (* Zeilensprung an Standardausgabe geben *)
BEGIN
  WriteLn(CON, '');
END;

(*-------------------------------------------------------------------*)

PROCEDURE Statistics;
(* Am Programmende Informationen Åber gelîschte Dateien und          *)
(* Verzeichnisse ausgeben                                            *)
BEGIN
  IF (FCount = 0) AND (VCount = 0) THEN
    WriteLn(CON, 'Keine Dateien/Verzeichnisse gelîscht.')
  ELSE
  BEGIN
    IF LastFile THEN NewLine;
    IF VCount > 0 THEN Write (CON, VCount) ELSE Write(CON, 'Keine');
    Write(CON, ' Verzeichnis');
    IF VCount <> 1 THEN Write(CON, 'se');
    WriteLn(CON, ' gelîscht');
    IF FCount > 0 THEN Write(CON, FCount) ELSE Write(CON, 'Keine');
    Write(CON, ' Datei');
    IF FCount <> 1 THEN Write(CON, 'en');
    WriteLn(CON, ' gelîscht');
  END;
END;

(*-------------------------------------------------------------------*)

PROCEDURE Home;
(* RÅcksprung zum Startverzeichnis wenn es noch vorhanden ist        *)
BEGIN
  ChDir(ActualDir);
  IF IOResult <> 0 THEN
  WriteLn(CON, 'Aktuelles Verzeichnis existiert nicht mehr!'^M^J);
END;

(*-------------------------------------------------------------------*)

PROCEDURE Errorhalt(s: STRING);
BEGIN
  AnsiWhite;
  IF s <> '' THEN WriteLn(CON, s);
  AnsiGray;
  Close(CON);
  Halt(1);
END;

(*-------------------------------------------------------------------*)

PROCEDURE UserBreakCheck;
VAR
  ch : CHAR;
BEGIN
  IF KeyPressed THEN
  BEGIN
    ch := ReadKey;
    IF ch IN [^C, ^S, ' '] THEN
    BEGIN
      IF ch = ^C THEN
      BEGIN
        Home;
        Statistics;
        Errorhalt(^M^J + UBreak)
      END
      ELSE
      BEGIN
        AnsiYellow;
        Write(CON, 'PAUSE --- Weiter mit beliebiger Taste ...');
        AnsiGray;
        REPEAT
          ch := ReadKey;
          IF ch = Chr(0) THEN IF KeyPressed THEN ch := ReadKey;
        UNTIL ch <> '';
        GotoXY(1, WhereY);
        ClrEoL;
      END;
    END;
  END;
END;

(*-------------------------------------------------------------------*)

PROCEDURE Break;
BEGIN
  Errorhalt('XRD wird nicht ausgefÅhrt.');
END;

(*-------------------------------------------------------------------*)

PROCEDURE Request(s: STRING);
VAR                        (* Ja/Nein-Abfrage, Umleitung ist mîglich *)
  kbd  : Text;
  chk  : CHAR;
BEGIN
  Assign(kbd, '');
  Reset(kbd);
  REPEAT
    Write(CON, s);
    Read(kbd, chk);                             (* GrÅ·e von Turbo-3 *)
  UNTIL UpCase(chk) IN ['J', 'N'];
  Close(kbd);
  check := chk;
END;

(*-------------------------------------------------------------------*)

PROCEDURE DeleteFiles;
VAR
  DelFile : FILE;
BEGIN
  FindFirst(AllFiles, Anyfile, sr);
  WHILE DosError <> 18 DO
  BEGIN
    IF sr.Attr IN [$0..$7, $20..$27] THEN
                                    (* alle Kombinationen fÅr Files, *)
                                    (* nicht: Directory, VolumeID    *)
    BEGIN
      IF BreakRO THEN IF NOT sr.Attr IN [0, Archive] THEN
      BEGIN
        Home;
        WriteLn(CON, 'Nicht-lîschbare Datei gefunden!');
        LastFile := TRUE;
        Statistics;
        Errorhalt('');
      END;
      UserBreakCheck;
      Assign(DelFile, sr.Name);
      WriteLn(CON, 'Lîsche Datei:', ' ': 8, FExpand(sr.Name));
      SetFAttr(DelFile, Archive);
      Erase(DelFile);
      Inc(FCount);
    END;
    FindNext(sr);
  END;
  LastFile := TRUE;
END;

(*-------------------------------------------------------------------*)

PROCEDURE ChangeDirectories;   (* Verzeichniswechsel solange es geht *)
BEGIN
  FindFirst(AllFiles, Directory, sr);          (* Verzeichnis suchen *)
  WHILE DosError <> 18 DO
  BEGIN
    IF (sr.Name[1] <> '.') AND (sr.Attr AND $10 = $10) THEN
    BEGIN                   (* PseudoeintrÑge '.' und '..' Åbergehen *)
      Inc(Depth);                                (* Dirtiefe erhîhen *)
      WorkDir[Depth] := sr.Name;                 (* Namen zuordnen   *)
      ChDir(sr.Name);                            (* DIR wechseln     *)
      FindFirst(AllFiles, Directory, sr);        (* weitersuchen     *)
    END;
    FindNext(sr);           (* bis im tiefsten Verzeichnis angelangt *)
  END;
END;

(*-------------------------------------------------------------------*)

PROCEDURE RemoveDirectory;  (* Verzeichnisse lîschen solange es geht *)
BEGIN
  IF (LeaveIt) AND (Depth = 1) THEN
  BEGIN
    Depth := 0;
    IF FExpand(WorkDir[Depth]) <> Drive + '\' THEN ChDir(Drive + '..');
    Exit
  END;
  UserBreakCheck;
  ChDir(Drive + '..');                          (* eine Ebene zurÅck *)
  WriteLn(CON, 'Lîsche Verzeichnis:', '  ',
          FExpand(WorkDir[Depth]),^M^J);
  RmDir(WorkDir[Depth]);                      (* Verzeichnis lîschen *)
  Inc(VCount);                            (* StatistikzÑhler erhîhen *)
  Dec(Depth);                                (* Dirtiefe erniedrigen *)
  LastFile := FALSE;
END;

(*-------------------------------------------------------------------*)

PROCEDURE TextOut;      (* ProgrammabhÑngiger Teil der Prozedur Help *)
BEGIN
  TextAttr := LightGray;                  (* 2. Fenster fÅr Schrift: *)
  Window(2, 2, 79, 24);
  TextAttr := Yellow;
  WriteLn(' ':12, Copyrght);
  TextAttr := LightGray;
  WriteLn(' ':6, 'Aufruf: XRD [d:][\]PFAD [/x] [/b],' +
          ' Parameter in [] sind optional.'^M^J^J);
  Write(' ':30);
  TextAttr := 112;
  WriteLn(' ':3, 'H I L F E', ' ':3, ^M^J);
  TextAttr := LightGray;

  WriteLn(' Das Programm lîscht in einem anzugebenden'
       + ' Verzeichnis alle Unterverzeichnis-'^M^J' se und Dateien.'
       + ^M^J' Wird der zusÑtzliche  Parameter /X angeben,'
       + ' wird  das angegebene Verzeichnis'^M^J' ebenfalls gelîscht.');
  WriteLn(' XRD  lîscht auch schreibgeschÅtzte und '
        + ' versteckte Dateien.  Soll dies nicht'^M^J
        + ' erfolgen, mu· der Kommandozeilenparameter'
        + ' /B angegeben werden. Ist /B  ange-'^M^J
        + ' geben,  so wird beim ersten Antreffen'
        + ' einer schreibgeschÅtzten und/oder ver-');
  WriteLn(' steckten Datei das Programm abgebrochen.'^M^J^J
        + ' XRD ist in der Lage, eine Diskette oder'
        + ' Platte  vollstÑndig zu lîschen. Wird'^M^J
        + ' als Ziellaufwerk ein Laufwerk ab C: '
        + ' angegeben und als Startverzeichnis  das');
  WriteLn(' Hauptverzeichnis (\), so verlangt XRD  zur'
        + ' Sicherheit die Eingabe der Daten-'^M^J
        + ' trÑgerkennung (Volume-Label). Die Eingabe'
        + ' kann frei  editiert werden, Klein-'^M^J
        + ' schreibung (auch Umlaute) wird umgewandelt.');
END;

(*-------------------------------------------------------------------*)

PROCEDURE Help;

VAR
  OldX, OldY, CrtMode, count: BYTE;
  ch                        : CHAR;
  ScrType                   : BYTE;
  ScrArray                  : ARRAY[0..3999] OF BYTE; (* BS-Speicher *)
  ScrSeg, Attrib, Cursor    : WORD;

  PROCEDURE SaveScreen;
 (* Bildschirminhalt in dem ARRAY ScrArray speichern, Cursorposition *)
 (* in OldX/OldY und altes Text-Attribut in attrib merken.           *)
 (* Da das Fenster aus dem DOS gestartet wird, wurde auf das Sichern *)
 (* der alten Fensterkoordinaten (WindMin/WindMax) verzichtet.       *)
  BEGIN
    OldX := WhereX;
    OldY := WhereY;
    Attrib := TextAttr;
    Move(Mem[ScrSeg:0], ScrArray, 4000);
   END;

(*-------------------------------------------------------------------*)

  PROCEDURE RestoreScreen;
 (* Bildschirminhalt aus dem ARRAY ScrArray restaurieren, Cursor auf *)
 (* OldX/OldY setzen und urspr. Text-Attribut aus attrib holen.      *)
  BEGIN
    Move(ScrArray, Mem[ScrSeg:0], 4000);
    TextAttr := Attrib;
    GotoXY(OldX, OldY);
  END;

(*-------------------------------------------------------------------*)

  PROCEDURE DrawLine;
  VAR
    count: BYTE;
  BEGIN
    FOR count := 2 TO 79 DO Write(Chr(205));
  END;

(*-------------------------------------------------------------------*)

BEGIN                                                (* Vorarbeiten: *)
  ScrType := BYTE(Ptr(Seg0040, $0049)^);             (* BS-Modus     *)
  IF ScrType = 7 THEN ScrSeg := SegB000 ELSE ScrSeg := SegB800;
  SaveScreen;
  IF ScrType IN [0..1, 4..6, 8..$50] THEN TextMode(CO80);
  Cursor := StartCursor;
  HideCursor;                                  (* Cursor ausschalten *)
  Window(1, 1, 80, 25);                        (*            Rahmen: *)
  TextAttr := LightGray;
  GotoXY(1, 1);
  TextAttr := Red;
  Write(Chr(201));
  DrawLine;
  Write(Chr(187));
  FOR count := 2 TO 24 DO Write(Chr(186), ' ':78, Chr(186));
  Write(Chr(200));
  DrawLine;
      (* Letztes Zeichen direkt schreiben um Scrolling zu vermeiden: *)
  MemW[ScrSeg:$F9E] := Red * $100 + 188;  (* HiByte = Farbe,         *)
                                          (* LoByte = Ord(Zeichen)   *)
                                          (* Hilfebildschirm:        *)
  TextOut;                                (* Text holen und ausgeben *)
  GotoXY(22, 23);
  TextAttr := Yellow;
  Write('ZurÅck zum DOS mit beliebiger Taste');
  REPEAT                         (* Auf Taste warten und Eingabe ver *)
    ch := ReadKey;               (* schlucken. Bei 'KeyPressed' wird *)
  UNTIL ch <> '';                (* das Zeichen nicht verschluckt!   *)
  IF ch = #0 THEN ch := ReadKey;
  Window(1, 1, 80, 25);                 (* Restaurierungen und Ende: *)
  IF ScrType IN [0, 1] THEN TextMode(ScrType);
                   (* nur 40-Zeichen-Modi, nicht Grafik restaurieren *)
  RestoreScreen;
  SetCursor(StartCursor);           (* Original-Cursor restaurieren: *)
  Halt(0);                          (*            Programm abbrechen *)
END;

(*-------------------------------------------------------------------*)
{                           Hauptprogramm                             }
(*-------------------------------------------------------------------*)

BEGIN
  Assign(CON, '');                          (* Bildschirmausgabe auf *)
  Append(CON);                             (* Standardausgabe setzen *)
                 (* ANSI-Sequenzen nur mit Append, nicht mit Rewrite *)
                                                (* Voreinstellungen: *)
  AnsiInst := AnsiSys;                                 (* ANSI-Check *)
  BreakRO  := FALSE;                          (* kein Break wenn R/O *)
  LastFile := TRUE;                             (* kein Zeilensprung *)
  LeaveIt  := TRUE;                     (* Verzeichnis nicht lîschen *)
  FCount   := 0;                                  (* DateizÑhler und *)
  VCount   := 0;                              (* VerzeichniszÑhler 0 *)
  VolName  := '';
  IF Lo(DosVersion) < 3 THEN Errorhalt('Falsche DOS-Version');
  IF (ParamCount < 1) OR (Pos('/?', ParamStr(1)) > 0) THEN Help;
  AnsiYellow;
  WriteLn(CON, 'XRD - Turbo ' + Copyrght);
  AnsiGray;
  IF (Length (ParamStr(1)) = 2) AND (Pos(':', ParamStr(1)) = 2) THEN
    Errorhalt(^M^J'Kein Verzeichnis angegeben!');

  IF ParamCount > 1 THEN FOR count := 2 TO ParamCount DO
  BEGIN
    IF (Pos('/x', ParamStr(count)) > 0)
    OR (Pos('/X', ParamStr(count)) > 0) THEN
    LeaveIt := FALSE;
    IF (Pos('/b', ParamStr(count)) > 0)
    OR (Pos('/B', ParamStr(count)) > 0) THEN
    BreakRO := TRUE;
    IF Pos('/?', ParamStr(count)) > 0 THEN Help;
  END;

  WriteLn(CON, ^M^J'SÑmtliche Unterverzeichnisse und'^M^J
               + 'Dateien  (auch schreibgeschÅtzte'^M^J
               + 'und versteckte) werden gelîscht!');
  Request('Wirklich fortfahren (J/N)? ');
  NewLine;
  IF check[1] IN ['J', 'j'] THEN
  BEGIN
    Depth := 1;
    WorkDir[1] := UpString(ParamStr(1));
    (* Turbo Pascal verlangt in der Kommandozeile zwischen den Para- *)
    (* metern Leerzeichen sonst wird alles an den ersten Parameter   *)
    (* angehÑngt. Hier erfolgt die Korrektur                         *)
    WHILE Pos('/', WorkDir[1]) > 0 DO
    BEGIN
      IF Pos('/X', UpString(WorkDir[1])) > 0 THEN LeaveIt := FALSE;
      IF Pos('/B', UpString(WorkDir[1])) > 0 THEN BreakRO := TRUE;
      WorkDir[1] := Copy(WorkDir[1], 1, Pos('/', WorkDir[1]) - 1);
    END;

    IF WorkDir[1][1] = '\' THEN
    BEGIN
      GetDir(0, Drive);
      WorkDir[1] := Drive[1] + ':' + WorkDir[1];
      Drive := '';
    END;
    IF Pos (':', WorkDir[1]) = 2 THEN Drive := Copy(WorkDir[1], 1, 2)
                                 ELSE Drive := '';
    IF ((Length(WorkDir[1]) = 3)) AND (Pos(':\', WorkDir[1]) = 2) THEN
    BEGIN
      IF WorkDir[1][1] > 'B' THEN               (* Plattenlaufwerk ! *)
      BEGIN
        ReadBootSector(BYTE(WorkDir[1][1]) - 64, Buffer);
        IF BootBlock.Data.MediaDescriptor = $F8 THEN BEGIN
          Write(CON, ^G'Es werden alle Verzeichnisse und'^M^J
              + 'Dateien der Platte ' + WorkDir[1][1], ': gelîscht. ');
          Request('Sind Sie absolut sicher (J/N)? ');
          IF UpCase(check[1]) = 'J' THEN
          BEGIN
            VolName := GetLabel(BYTE(WorkDir[1][1]) - 64);
            IF VolName = '' THEN FindFirst(WorkDir[1] + AllFiles,
                                         VolumeID + Archive, sr);
            IF Length(VolName) > 0 THEN
            BEGIN
              IF Pos('.', VolName) > 0 THEN
                Delete(VolName, Pos('.', VolName), 1);
              Write(CON, ^M^J'DatentrÑgerkennsatz von Platte '
                    + WorkDir[1][1] + ': eingeben: ');
              InStr := UpString(ReadString(12, TestCh));
              IF TestCh = 27 THEN
              BEGIN
                NewLine;
                Break;                                    (* Abbruch *)
              END;
              IF InStr <> VolName THEN
                Errorhalt(^M^J^J'Falscher DatentrÑgerkennsatz!');
            END;
          END ELSE Break;                                   (* Abbruch *)
        END;
      END;
    END;
  END ELSE Break;                                         (* Abbruch *)

  GetDir(0, ActualDir);
  ChDir(WorkDir[1]);
  IF IOResult <> 0 THEN
  BEGIN
    Home;
    Errorhalt(PathNFnd);
  END;
  CheckBreak := FALSE;

  REPEAT                                            (* Hauptschleife *)
    ChangeDirectories;
    DeleteFiles;
    IF (WorkDir[Depth] = Drive + '\') THEN
    BEGIN
      DeleteFiles;
      Statistics;
      IF GetLabel(BYTE(WorkDir[1][1]) - 64) <> '' THEN
      BEGIN
        WriteLn(CON, 'DatentrÑgerkennung gelîscht');
        SetLabel(BYTE(WorkDir[1][1]) - 64, '');
      END;
      Home;
      Errorhalt('');
    END;
    WHILE Pos('\', WorkDir[1]) > 0 DO
      Delete(WorkDir[1], 1, Pos('\', WorkDir[1]));
    RemoveDirectory;
  UNTIL Depth = 0;                         (* Ende der Hauptschleife *)
  Home;
  Statistics;
  Close(CON);
{$ELSE}
BEGIN
  WriteLn('Das Programm wurde fÑlschlicherweise im Protected Mode ',
          'compiliert!');
{$ENDIF}
END.

(*===================================================================*)
