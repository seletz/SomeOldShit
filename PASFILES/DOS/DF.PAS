{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X-,M 65520,0,0}
                 (* rekursive Prozedur SearchDirectories -> MaxStack *)
(*===================================================================*)
(*                       DATEFIND.PAS Version 1.0                    *)
(*                    Copyright (C) 1993 te-wi Verlag                *)
(*           Compiler: Borland/Turbo Pascal Real Mode Target         *)
(*===================================================================*)

PROGRAM DateFind; (* Gibt alle Dateien dieses Tages aus *)

USES
  Crt, Dos, UPPER, Cursor, ANSI;

CONST
  allfiles   : STRING[3] = '*.*';
  copyrght   : STRING[49] = 'DateFind V. 1.00,' +
               ' Copyright (c) 1993 te-wi Verlag';
  MonName    : ARRAY[1..12] OF STRING[4] =
               ('Jan.','Feb.','MÑrz','Apr.','Mai ','Juni',
                'Juli','Aug.','Sep.','Okt.','Nov.','Dez.');

VAR
  count      : BYTE;
  CON        : Text;
  drive,
  parameter  : STRING;
  fcounter   : WORD;
  ansiinst   : BOOLEAN;
  Year,
  Month,
  Day,
  DayofWeek  : WORD;

(*-------------------------------------------------------------------*)
(*                       FUNKTIONEN und PROZEDUREN                   *)
(*-------------------------------------------------------------------*)

PROCEDURE CheckForKey;
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
        WriteLn(CON, ^M^J'*** USERBREAK ***');
        Close(CON);
        Halt(1);
      END
      ELSE
      IF (ch = ^S) OR (ch = ' ') THEN
      BEGIN
        AnsiYellow;
        Write(CON, 'PAUSE --- Weiter'
        + ' mit beliebiger Taste ...');
        AnsiGray;
        REPEAT
          ch := ReadKey;
          IF ch = Chr(0) THEN
            IF KeyPressed THEN ch := ReadKey;
        UNTIL ch <> '';
        GotoXY(1, WhereY);
        ClrEoL;
      END;
    END;
  END;
END;

(*-------------------------------------------------------------------*)

PROCEDURE TextOut;               (* ProgrammabhÑngiger Teil von Help *)
BEGIN
  TextAttr := LightGray;
  Window(2, 2, 79, 24);
  TextAttr := Yellow;
  WriteLn(' ':13, copyrght + ^J);
  TextAttr := LightGray;
  WriteLn(' ':31, 'Aufruf: DF d:'^M^J^J);
  Write(' ':30);
  TextAttr := 112;
  WriteLn(' ':3, 'H I L F E', ' ':3);
  TextAttr := LightGray;
  WriteLn(^J^J' DateFind zeigt alle Dateien mit heutigem ' +
          'Erstellungsdatum auf einem Laufwerk  an.  Es kann ein '+
          'anderes als das aktuelle  Laufwerk durchsucht werden,' +
          '  wenn  auf der Kommandozeile die entsprechende ' +
          'Laufwerkskennung angegeben wird.' + ^M^J);
  WriteLn(' Wenn DF ohne Parameter oder DF /?  aufgerufen'  +
          ' wird,  wird  dieser Hilfebild-'^M^J' schirm angezeigt.');
END;

PROCEDURE Help;
  
VAR
  oldx,
  oldy,
  count    : BYTE;
  ch       : CHAR;
  scrtype  : BYTE;
  scrarray : ARRAY[0..3999] OF BYTE;                  (* BS-Speicher *)
  scrseg   : WORD;
  attrib   : WORD;
  Cursor   : WORD;

  PROCEDURE SaveScreen;
 (* Bildschirminhalt in dem ARRAY ScrArray speichern, Cursorposition *)
 (* in OldX/OldY und altes Text-Attribut in attrib merken.           *)
 (* Da das Fenster aus dem DOS gestartet wird, wurde auf das Sichern *)
 (* der alten Fensterkoordinaten (WindMin/WindMax) verzichtet.       *)
  BEGIN
    oldx := WhereX;
    oldy := WhereY;
    attrib := TextAttr;
    Move(Mem[scrseg:0], scrarray, 4000);
   END;

(*-------------------------------------------------------------------*)

  PROCEDURE RestoreScreen;
 (* Bildschirminhalt aus dem ARRAY ScrArray restaurieren, Cursor auf *)
 (* OldX/OldY setzen und urspr. Text-Attribut aus attrib holen.      *)
  BEGIN
    Move(scrarray, Mem[scrseg:0], 4000);
    TextAttr := attrib;
    GotoXY(oldx, oldy);
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
  scrtype := BYTE(Ptr(Seg0040, $0049)^);             (* BS-Modus     *)
  IF scrtype = 7 THEN scrseg := SegB000
                 ELSE scrseg := SegB800;
  SaveScreen;
  IF scrtype IN [0..1, 4..6, 8..$50] THEN
    TextMode(CO80);
  Cursor := StartCursor;
  HideCursor;                                  (* Cursor ausschalten *)
  Window(1, 1, 80, 25);                        (* Rahmen:            *)
  TextAttr := LightGray;
  GotoXY(1, 1);
  TextAttr := Red;
  Write(Chr(201));
  DrawLine;
  Write(Chr(187));
  FOR count := 2 TO 24 DO
    Write(Chr(186), ' ':78, Chr(186));
  Write(Chr(200));
  DrawLine;
      (* Letztes Zeichen direkt schreiben um Scrolling zu vermeiden: *)
  MemW[scrseg:$F9E] := Red * $100 + 188;  (* HiByte = Farbe,         *)
                                          (* LoByte = Ord(Zeichen)   *)
                                          (* Hilfebildschirm:        *)
  TextOut;                                (* Text holen und ausgeben *)
  GotoXY(22, 23);
  TextAttr := Yellow;
  Write('ZurÅck zum DOS mit beliebiger Taste');
  REPEAT                        (* Auf Taste warten und Eingabe ver- *)
    ch := ReadKey;              (* schlucken. Bei 'KeyPressed' wird  *)
  UNTIL ch <> '';               (* das Zeichen nicht verschluckt!    *)
  IF ch = #0 THEN ch := ReadKey;
  Window(1, 1, 80, 25);         (* Restaurierungen und Ende:         *)
  IF scrtype IN [0, 1] THEN TextMode(scrtype);
                   (* nur 40-Zeichen-Modi, nicht Grafik restaurieren *)
  RestoreScreen;

  SetCursor(StartCursor);           (* Original-Cursor restaurieren: *)
  Halt(0);                          (* Programm abbrechen            *)
END;

(*-------------------------------------------------------------------*)

PROCEDURE ErrorHalt (s: STRING);
BEGIN
  AnsiWhite;
  WriteLn(CON, s);
  AnsiGray;
  Close(CON);
  Halt(1);
END;

(*-------------------------------------------------------------------*)

PROCEDURE ShowFiles (Showpath: STRING; sr: SearchRec; path: STRING);
VAR
  arcdisp : STRING[9];
  DateRec : DateTime;
  MinStr,
  MonStr   : STRING[2];
  YearStr  : STRING[4];
  lenStr,
  insertStr,
  fname,
  fext     : STRING;
  x        : INTEGER;
  len      : BYTE;
  OutPutStr: STRING;
BEGIN
  IF sr.Attr IN [$8..$F, $28..$2F] THEN BEGIN
    IF Pos('.', sr.Name) > 0 THEN
      Delete(sr.Name, Pos('.', sr.Name), 1);
  END;
  IF (Pos('.', sr.Name) > 0) AND (Length(sr.Name) > 0) THEN
  BEGIN
    fname := Copy(sr.Name, 1, Pos('.', sr.Name) - 1);
    fext  := sr.Name;
    Delete(fext, 1, Pos('.', fext));
  END
  ELSE
  BEGIN
    fname := sr.Name;
    fext := '  ';
  END;
  arcdisp := '    ';
  IF sr.Attr AND Archive  = Archive  THEN arcdisp[1] := 'A';
  IF sr.Attr AND ReadOnly = ReadOnly THEN arcdisp[2] := 'R';
  IF sr.Attr AND Hidden   = Hidden   THEN arcdisp[3] := 'H';
  IF sr.Attr AND SysFile  = SysFile  THEN arcdisp[4] := 'S';
  IF NOT (sr.Attr IN [$8..$F, $28..$2F]) THEN
  BEGIN
    Str(sr.Size, lenStr);
    IF Length(lenStr) > 3 THEN
    BEGIN
      insertStr := '.';
      len := Length(lenStr) - 2;
      Insert(insertStr, lenStr, len);
      IF Length(lenStr) > 7 THEN
      BEGIN
        len := Length(lenStr) - 6;
        Insert(insertStr, lenStr, len);
      END;
    END;
  END;
  IF NOT (sr.Attr IN [$8..$F, $28..$2F]) THEN BEGIN
    UnPackTime(sr.Time, DateRec);
    IF (DateRec.Day = Day) AND
       (DateRec.Year = Year) AND
       (DateRec.Month = Month) THEN BEGIN
      IF Showpath[Length(Showpath)] = '\' THEN
         Delete(Showpath, Length(Showpath), 1);
      OutPutStr := Showpath + '\' + fname + '.' +  fext;
      Write(CON, OutPutStr);
      IF Length(OutPutStr) < 42 THEN
        FOR x := Length(OutPutStr) TO 42 DO Write(CON, ' ');
      Write(CON, ' ',arcdisp);
      Write(CON, lenStr:10);
      Write(CON, Day: 3, '. ');
      Write(CON, MonName[DateRec.Month],' ');
      Str(DateRec.Year, YearStr);
      Write(CON, YearStr + '  ', DateRec.Hour:2, ':');
      Str(DateRec.Min, MinStr);
      IF Length(MinStr) < 2 THEN MinStr := '0' + MinStr;
      Write(CON, MinStr);
      WriteLn(CON, '');
      Inc(fcounter);
    END;
  END;
END;

(*-------------------------------------------------------------------*)

PROCEDURE SearchDirectories(path, fname: STRING);
VAR
  SRecord : SearchRec;
  fle     : FILE;
  Showpath: STRING;
BEGIN
  IF Length(path) > 0 THEN                    (* Suche nach Dateien: *)
    IF path[Length(path)] <> '\' THEN
      path := path + '\';
  SRecord.Name := '';
  FindFirst(path + fname, Anyfile MOD Directory, SRecord);
  Showpath := '        .   ';
  IF SRecord.Name <> '' THEN
  BEGIN
    IF Length(path)  > 3 THEN
      Showpath := Copy(path, 1, Length(path) - 1)
    ELSE Showpath := path;
  END;

  WHILE DosError = 0 DO
  BEGIN
    CheckForKey;
    IF SRecord.Attr IN [$0..$E, $20..$2E] THEN
      ShowFiles(Showpath, SRecord, path);
    FindNext(SRecord);
  END;
                                       (* Suche nach Verzeichnissen: *)
  FindFirst(path + allfiles, Directory, SRecord);
  WHILE DosError = 0 DO
  BEGIN
    CheckForKey;
    IF (SRecord.Attr AND Directory <> 0) AND
       (SRecord.Name[1] <> '.') THEN
      SearchDirectories(path + SRecord.Name, fname);
    FindNext(SRecord);
  END;
END;

(*-------------------------------------------------------------------*)
(*                           Hauptprogramm                           *)
(*-------------------------------------------------------------------*)
BEGIN
  CheckBreak := FALSE;

  IF (ParamCount = 0) OR (ParamStr(1) = '/?')
    THEN Help;

  Assign (CON, '');
  Append (CON);
  ansiinst := AnsiSys;

  IF Lo(DosVersion) < 3 THEN
    ErrorHalt('Falsche DOS-Version');

  fcounter := 0;
  drive := '';
  AnsiYellow;
  WriteLn(CON,'DF - Turbo '+ copyrght + ^J);
  AnsiGray;
  BEGIN
    parameter := ParamStr(1);
    parameter := UpString(parameter);
    IF NOT (parameter[1] IN ['A'..'Z']) THEN
    BEGIN
      GetDir(0, drive);
      drive := drive[1];
    END ELSE drive := parameter[1];
    drive := drive + ':';
    GetDate(Year, Month, Day, DayofWeek);
    SearchDirectories(drive + '\', '*.*');
  END;
  IF fcounter = 0 THEN
    ErrorHalt('Keine passenden Dateien fÅr '
            + drive + '\' + '*.*' + ' gefunden.')
  ELSE
  BEGIN
    Write(CON, ^M^J, fcounter, ' Datei');
    IF fcounter > 1 THEN Write(CON, 'en');
    WriteLn(CON, ' gefunden.');
  END;
  Close(CON);
END.
(*-------------------------------------------------------------------*)
