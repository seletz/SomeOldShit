{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X-,M 65520,0,0}
                 (* rekursive Prozedur SearchDirectories -> MaxStack *)
(*===================================================================*)
(*                           FF.PAS Version 1.0                      *)
(*                    Copyright (C) 1993 te-wi Verlag                *)
(*           Compiler: Borland/Turbo Pascal Real Mode Target         *)
(*===================================================================*)
(* Funktion:                                                         *)
(* vollstÑndige Dateisuche auf einem Laufwerk Åber die Verzeichnis-  *)
(* grenzen hinaus. Es kann nicht nach Directories gesucht werden.    *)
(*===================================================================*)

PROGRAM FileFinder;

USES
  Crt, Dos, DosUtil, Hex, ANSI, Cursor, UPPER;

CONST
  CtrlC      = Chr(3);
  LF         = Chr(10);
  CRLF       = Chr(13) + LF;
  CtrlS      = Chr(19);
  ESC        = Chr(27);
  invers     = 112;

  allfiles   : STRING[3] = '*.*';
  copyrght   : STRING[51] = 'FileFinder V. 1.00,' +
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

(*-------------------------------------------------------------------*)
(*                     FUNKTIONEN und PROZEDUREN                     *)
(*-------------------------------------------------------------------*)

PROCEDURE CheckForKey;
VAR
  ch : CHAR;
BEGIN
  IF KeyPressed THEN
  BEGIN
    ch := ReadKey;
    IF ch IN [CtrlC, CtrlS, ' '] THEN
    BEGIN
      IF ch = CtrlC THEN
      BEGIN
        WriteLn(CON, CRLF + '*** USERBREAK ***');
        Close(CON);
        Halt(1);
      END
      ELSE
      IF (ch = CtrlS) OR (ch = ' ') THEN
      BEGIN
        AnsiYellow;
        Write(CON, 'PAUSE --- Weiter mit beliebiger Taste ...');
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
  WriteLn(' ':13, copyrght);
  TextAttr := LightGray;
  WriteLn(' ':12, 'Aufruf: FF [d:]datei[.ext]' +
                  ' [[d:]datei[.ext] ... ] [/?]'+ CRLF);
  Write(' ':30);
  TextAttr := 112;
  WriteLn(' ':3, 'H I L F E', ' ':3);
  TextAttr := LightGray;
  WriteLn(LF +
          ' FileFind sucht alle passenden Dateien' +
          ' auf einem Laufwerk und  zeigt  sie an.' + CRLF +
          ' Es kann ein anderes als das  aktuelle' +
          ' Laufwerk  durchsucht  werden, wenn zum' + CRLF +
          ' Dateinamen die Laufwerkskennung angegeben wird.');
  WriteLn(' Im Gegensatz zu FileFile der Norton' +
          ' Utilities kînnen bei einem Aufruf unter-' + CRLF +
          ' schiedliche Dateien auch auf verschiedenen' +
          ' Laufwerken gesucht werden,  z. B.' + CRLF +
          ' FF A:*.sys C:*.sys A:*. Wird kein Laufwerk' +
          ' angegeben wird, wird auf  dem ak-');
  WriteLn(' tuellen bzw. dem vorigen Laufwerk gesucht.' +
          ' "FF A:*.exe *.com" sucht auch die' + CRLF +
          ' .COM-Dateien auf Laufwerk A:. Wenn Dateien auf' +
          ' verschiedenen Laufwerken  ge-');
  WriteLn(' sucht werden sollen, mu·, wenn zuerst auf einem' +
          ' anderen und dann auf dem ak-' + CRLF +
          ' tuellen Laufwerk gesucht werden soll, auch' +
          ' fÅr  das  aktuelle  Laufwerk  die' + CRLF +
          ' Laufwerkskennung angegeben werden.');
  WriteLn(' Wie beim DOS-DIR-Befehl wird, wenn  keine ' +
          ' Dateiendung  angegeben wird, ".*"' + CRLF +
          ' angehÑngt. Sollen Dateien ohne Endung gesucht '+
          ' werden, mu· an den Dateinamen');
  WriteLn(' ein Punkt angehÑngt werden, damit das Programm'+
          ' wei·,  da· das AnhÑngen einer' + CRLF +
          ' Endung nicht gewÅnscht wird.');
  WriteLn(' Wenn FF ohne Parameter oder FF /?  aufgerufen' +
          ' wird,  wird  dieser Hilfebild-'+ CRLF +
          ' schirm angezeigt.');
END;

(*-------------------------------------------------------------------*)

PROCEDURE Help;

VAR
  oldx,
  oldy,
  count    : BYTE;
  ch       : CHAR;
  scrtype  : BYTE;
  scrarray : ARRAY[0..3999] OF BYTE;                  (* BS-Speicher *)
  scrseg,
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
  ScrType := BYTE(Ptr(Seg0040, $0049)^);             (* BS-Modus     *)
  IF ScrType = 7 THEN ScrSeg := SegB000
                 ELSE ScrSeg := SegB800;

  SaveScreen;
  IF ScrType IN [0..1, 4..6, 8..$FF] THEN TextMode(CO80);
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
  MemW[ScrSeg:$F9E] := Red * $100 + 188;  (* HiByte = Farbe,         *)
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
  Window(1, 1, 80, 25);                 (* Restaurierungen und Ende: *)
  IF ScrType IN [0, 1] THEN TextMode(ScrType);
                   (* nur 40-Zeichen-Modi, nicht Grafik restaurieren *)
  RestoreScreen;

  SetCursor(StartCursor);           (* Original-Cursor restaurieren: *)
  Halt(0);                          (* Programm abbrechen            *)
END;

(*-------------------------------------------------------------------*)

PROCEDURE ErrorHalt(s: STRING);
BEGIN
  AnsiWhite;
  WriteLn(CON, s);
  AnsiGray;
  Close(CON);
  Halt(1);
END;

(*-------------------------------------------------------------------*)

PROCEDURE ShowFiles(sr: SearchRec; path: STRING);
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
  len      : BYTE;

BEGIN
  IF sr.Attr IN [$8..$F, $28..$2F] THEN
    IF Pos('.', sr.Name) > 0 THEN
      Delete(sr.Name, Pos('.', sr.Name), 1);
  IF Pos('.',sr.Name) > 0 THEN
  BEGIN
    fname := Copy(sr.Name, 1, Pos('.', sr.Name) - 1);
    fext  := sr.Name;
    Delete(fext, 1, Pos('.', fext));
  END
  ELSE
  BEGIN
    fname := sr.Name;
    fext := '';
  END;
  Write(CON,' ':5, fname, ' ':11 - Length(fname),
                    fext, ' ': 5 - Length(fext));

  arcdisp := '    ';
  IF sr.Attr AND Archive  = Archive  THEN arcdisp[1] := 'A';
  IF sr.Attr AND ReadOnly = ReadOnly THEN arcdisp[2] := 'R';
  IF sr.Attr AND Hidden   = Hidden   THEN arcdisp[3] := 'H';
  IF sr.Attr AND SysFile  = SysFile  THEN arcdisp[4] := 'S';
  Write(CON, ' ', arcdisp);
  IF sr.Attr AND VolumeID = VolumeID THEN
    Write(CON,' ':4,'Volume Label')
  ELSE
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
    Write (CON, lenStr:10, ' Bytes');
  END;
  WriteLn(CON, '');
  Inc(fcounter);
END;

(*-------------------------------------------------------------------*)

PROCEDURE SearchDirectories(path, fname: STRING);
VAR
  SRecord : SearchRec;
  fle     : FILE;
  ShowPath: STRING;
BEGIN
  IF Length(path) > 0 THEN                    (* Suche nach Dateien: *)
    IF path[Length(path)] <> '\' THEN
      path := path + '\';
  SRecord.Name := '';
  FindFirst(path + fname, Anyfile MOD Directory, SRecord);

  IF SRecord.Name <> '' THEN
  BEGIN
    IF Length(path)  > 3 THEN
      ShowPath := Copy(path, 1, Length(path) - 1)
    ELSE ShowPath := path;
    Write(CON, ShowPath);
    IF Length(ShowPath) = 3 THEN
      WriteLn(CON, '  ', ReadDiskIDNumber(ShowPath[1]), ' ':17,
                   'DatentrÑger-Nummer')
    ELSE
      WriteLn(CON, '');
  END;

  WHILE DosError = 0 DO
  BEGIN
    CheckForKey;
    IF SRecord.Attr IN [$0..$E, $20..$2E] THEN
      ShowFiles(SRecord, path);
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
(*                          Hauptprogramm                            *)
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
  WriteLn(CON,'FF - Turbo '+ copyrght + LF);
  AnsiGray;
  FOR count := 1 TO ParamCount DO
  (*  Abarbeiten aller in der Kommandozeile angegebenen Dateinamen:  *)
  BEGIN
    parameter := ParamStr(count);
    parameter := UpString(parameter);
    IF Pos('.', parameter) = Length(parameter) THEN
       Delete(parameter,Length(parameter),1)                 (* Ø*.Æ *)
    ELSE
    IF Pos('.', parameter) = 0 THEN                          (* Ø*Æ  *)
      parameter := parameter + '.*';

    IF Pos(':', parameter) > 0 THEN                          (* D:.. *)
    BEGIN
      drive := parameter[1] + ':';
      Delete(parameter, 1, 2);
    END;
    IF drive = '' THEN                     (* nur beim ersten Namen, *)
    BEGIN                                  (* sonst ist drive <> ''* *)
      GetDir(0, drive);
      Delete(drive, 3, Length(drive) - 2);
    END;
    WHILE Pos('\', parameter) > 0 DO                  (* User-Fehler *)
       Delete(parameter, 1, Pos('\', parameter));
    IF parameter = '' THEN parameter := '*.*';
    SearchDirectories(drive + '\', parameter);
  END;

  IF fcounter = 0 THEN
    ErrorHalt('Keine passenden Dateien fÅr ' + drive + '\' + parameter
            + ' gefunden.')
  ELSE
  BEGIN
    Write(CON, CRLF, fcounter, ' Datei');
    IF fcounter > 1 THEN Write(CON, 'en');
    WriteLn(CON, ' gefunden.');
  END;
  Close(CON);
END.
(*-------------------------------------------------------------------*)
