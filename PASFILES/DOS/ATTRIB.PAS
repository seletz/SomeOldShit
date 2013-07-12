{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X+,M 65520,0,0}
(*===================================================================*)
(*                     ATTRIB.PAS Version 2.0                        *)
(*         Compiler: Turbo/Borland Pascal Real Mode Target           *)
(*                Copyright (C) 1993 te-wi Verlag                    *)
(*===================================================================*)
(* Beschreibung:                                                     *)
(*  Das Programm ersetzt das DOS-Programm ATTRIB fÅr DOS-Versionen   *)
(*  kleiner als 5.0. Es kînnen alle Dateiattribute geÑndert werden,  *)
(*  der Aufruf ist identisch wie beim DOS-ATTRIB-Befehl (au·er den   *)
(*  zusÑtzlichen Parametern.                                         *)
(*  Verzeichnisse werden nicht angezeigt, aber im Hauptverzeichnis   *)
(*  das Volume-Label (Attribut V)                                    *)
(*===================================================================*)

PROGRAM FileAttribute;

USES
  Crt, Dos, Cursor, ANSI, UPPER;

CONST
  allfiles   : STRING[3] = '*.*';
  sysfcount  = 9;
  SystemFile : ARRAY[1..sysfcount] OF STRING[11] =
              ('IO.SYS',     'MSDOS.SYS',             (* MS-DOS      *)
               'IBMBIO.COM', 'IBMDOS.COM',            (* PC-DOS      *)
               'OS2BOOT',    'OS2KRNL',   'OS2LDR',   (* OS/2 2.0    *)
               'DRBIOS.SYS', 'DRBDOS.SYS');           (* DR-DOS 3.41 *)
  copyrght   : STRING[52] = 'ATTRIB Version 2.00,' +
               ' Copyright (c) 1993 te-wi Verlag';
VAR
  newattr, count, parlen     : BYTE;
  drive                      : STRING[2];
  CON                        : Text;
  Parameter                  : ARRAY [1..20] OF STRING;
  fcounter                   : WORD;
  startpath, srcfile         : STRING;
  deletea, deleter, deletes,
  deleteh, seta, setr, sets,
  seth, works, subs, sysmod,
  ansiinst                   : BOOLEAN;

(*-------------------------------------------------------------------*)
(*                   FUNKTIONEN und PROZEDUREN                       *)
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
  TextAttr := LightGray;                  (* 2. Fenster fÅr Schrift: *)
  Window(2, 2, 79, 24);
  TextAttr := Yellow;
  WriteLn(' ':13, copyrght);
  TextAttr := LightGray;
  WriteLn(' ':8, 'Aufruf: ATTRIB [+/-AHRS] [d:]'+
        '[\][DIR\]Dateien [/S] [/SYS] [/?]'+ ^M^J);
  Write(' ':30);
  TextAttr := 112;
  WriteLn(' ':3, 'H I L F E', ' ':3);

  TextAttr := LightGray;
  WriteLn(^M^J' ATTRIB ersetzt den DOS-ATTRIB-Befehl. Das '+
          ' Programm  ist flexibler  als  das'^M^J +
          ' Original-Programm.  Es sind beim Aufruf ver'+
          'schiedene Parameter zu verwenden:'^M^J +
          ' AHRS (in beliebiger Folge: éndern des' +
          ' A(rchiv),  H(idden),  R(eadOnly)  oder');
  WriteLn(' S(ystemfile)-Attributes. Die Reihenfolge ist' +
          ' beliebig.  Die  Attibute kînnen'^M^J +
          ' einzeln oder in Gruppen geÑndert werden. Wenn' +
          ' vor das Attribut ein  "-"  ge-'^M^J +
          ' stellt wird, wird das Attribut gelîscht, wird' +
          ' ein "+" vorgestellt, wird  das');
  WriteLn(' Attribut gesetzt. Es kann gleichzeitig ein' +
          ' Attribut gesetzt  und ein anderes'^M^J +
          ' gelîscht werden, wenn sie getrennt angegeben' +
          ' werden. Der Parameter "/S" gibt'^M^J +
          ' dem Programm an, da· der  Attributwechsel ' +
          ' auch in allen Unterverzeichnissen');
  WriteLn(' gefÅhrt werden soll. Die Parameter mÅssen' +
          ' durch  Leerzeichen  getrennt sein.'^M^J +
          ' ATTRIB ist nur auf Dateien,  nicht  auf ' +
          ' VerzeichniseintrÑge  anwendbar, die');
  WriteLn(' Platzhalter (*, ?) sind fÅr Dateien,'+
          ' nicht aber fÅr Directories erlaubt.'^M^J +
          ' ATTRIB/? oder ATTRIB ohne Parameter gibt' +
          ' diesen Hilfebildschirm aus.'^M^J^J +
          ' Hinweis: Die DOS-Dateien ' + SystemFile[1] +
          '/' + SystemFile[2] + ' bzw. ' + SystemFile[3] +
          '/' + SystemFile[4] + '  werden');
  WriteLn(' aus SicherheitsgrÅnden von ATTRIB nur'+
          ' geÑndert, wenn /SYS angegeben wird.');
END;

PROCEDURE Help;

VAR
  ScrSeg: WORD;
  oldx,
  oldy,
  count    : BYTE;
  ch       : CHAR;
  scrtype  : BYTE; 
  scrarray : ARRAY[0..3999] OF BYTE;                  (* BS-Speicher *)
  attrib   : WORD;
  Cursor   : WORD;
  PROCEDURE SaveScreen;
  VAR
    scrofs : WORD;
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
  VAR
    scrofs : WORD;
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
  scrtype := BYTE(Ptr(Seg0040, $0049)^);             (*   BS-Modus   *)
  IF scrtype = 7 THEN ScrSeg := SegB000
                 ELSE ScrSeg := SegB800;
  SaveScreen;
  IF scrtype IN [0..1, 4..6, 8..$50] THEN TextMode(CO80);
  Cursor := StartCursor;
  HideCursor;                                  (* Cursor ausschalten *)
  Window(1, 1, 80, 25);                        (* Rahmen:            *)
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
  MemW[ScrSeg:$F9E] := Red * $100 + 188;  (* HiByte := Farbe,        *)
                                          (* LoByte := Ord(Zeichen)  *)
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

PROCEDURE ErrorHalt (s: STRING);
BEGIN
  AnsiWhite;
  WriteLn(CON, s);
  AnsiGray;
  Close(CON);
  Halt(1);
END;

(*-------------------------------------------------------------------*)

PROCEDURE Parse(Input: STRING; VAR drive, startpath, srcfile:  STRING);
VAR
  len,
  count,
  position : BYTE;
  actualdir,
  dr       : STRING;
BEGIN
  dr := '';
  drive := '';
  startpath := '';
  srcfile := '';

  IF Pos('\', Input) = 1 THEN
  BEGIN
    GetDir(0, dr);
    drive := dr[1] + ':';
    Input := drive + Input;
    drive := '';
  END;

  IF Length(Input) = 2 THEN
    IF Input[2] = ':' THEN
    BEGIN
       drive := Input;
       GetDir(Ord(Input[1]) - 64, startpath);
       Delete(startpath, 1, 2);
       srcfile := allfiles;
       Exit;
    END;

  IF Length(Input) = 3 THEN
    IF Input[2] = ':' THEN
      IF Input[3] = '\' THEN
      BEGIN
        drive := Input[1] + ':';
        startpath := '\';
        srcfile := allfiles;
        Exit
      END;

  IF (Length(Input) > 1) AND (Pos('\', Input) > 1) AND
     (Pos(':', Input) = 0) THEN
  BEGIN
    GetDir(0, startpath);
    drive := startpath[1] + ':';
    Delete(startpath, 1, 2);
    position := 0;
    FOR count := 1 TO Length(Input) DO
      IF Input[count] = '\' THEN position := count;
    srcfile := Input;
    Delete(srcfile, 1, position);
    len := Length(startpath);
    startpath := startpath + '\' + Input;
    Delete(startpath, len + position  + 1,
         Length(startpath) - position + 1);
    Exit;
  END;

  IF (Pos('\', Input) = 0) AND (Pos(':', Input) = 0) THEN
  BEGIN
    GetDir(0, startpath);
    drive := startpath[1] + ':';
    Delete(startpath, 1, 2);
    srcfile := Input;
    Exit;
  END;

  IF (Input[2] = ':') AND
     (Input[3] = '\') THEN
  BEGIN
    drive := Input[1] + ':';
    startpath := Input;
    IF startpath[Length(startpath)] = '\' THEN
    BEGIN
      Delete(startpath, 1, 2);
      Delete(startpath, Length(startpath), 1);
      srcfile := allfiles;
      Exit;
    END;
    Delete(startpath, 1, 2);
    IF Pos('\', startpath) > 0 THEN
    BEGIN
      position := 0;
      FOR count := 1 TO Length(startpath) DO
        IF startpath[count] = '\' THEN position := count;
      IF position = Length(startpath) THEN
      BEGIN
         Delete(startpath, 2, Length(startpath) - 2);
         Delete(startpath, Length(startpath) - 1, 1);
         srcfile := allfiles;
      END
      ELSE
      IF Pos('\', startpath) <> position THEN
      BEGIN
        srcfile := Copy(startpath, position + 1,
                    Length(startpath) - position);
        len := Length(startpath);
        Delete(startpath, position, len - position + 1);
      END
      ELSE
      BEGIN
        srcfile := startpath;
        startpath := '\';
        srcfile := Copy(srcfile, 2, Length(srcfile) - 1);
      END;
    END;
    Exit;
  END;
  IF (Input[2] = ':') AND (Input[3] <> '\') THEN
  BEGIN
    GetDir(Ord(UpCase(Input[1])) - 64, startpath);
    drive := Input[1] + ':';
    Delete(startpath, 1, 2);
    srcfile := Copy(Input, 3, Length(Input) - 2);
    Exit;
  END;

  GetDir(0, startpath);
  drive := startpath[1] + ':';

  Delete(startpath, 1, 2);
  srcfile := Input;

  IF srcfile = startpath THEN srcfile := allfiles;
  IF Pos(UpString(srcfile), startpath) > 0 THEN
    Delete(srcfile, Pos(srcfile, startpath), Length(srcfile));
END;

(*-------------------------------------------------------------------*)

PROCEDURE CheckParameters(VAR chg, subs: BOOLEAN);
VAR
  count: BYTE;
BEGIN
  chg     := FALSE; subs    := FALSE; deletea := FALSE;
  deleter := FALSE; deletes := FALSE; deleteh := FALSE;
  seta    := FALSE; setr    := FALSE; sets    := FALSE;
  seth    := FALSE; srcfile := '';    sysmod  := FALSE;

  FOR count := 1 TO ParamCount DO
  BEGIN
    IF Pos('/?', Parameter[count]) > 0 THEN Help;
    IF NOT (Parameter[count][1] IN ['-', '+', '/']) THEN
    BEGIN
      Parse(Parameter[count], drive, startpath, srcfile);
      IF startpath[Length(startpath)] <> '\' THEN
        startpath := startpath + '\';
      startpath := drive + startpath;
    END
    ELSE
    IF Parameter[count][1] IN ['-', '+'] THEN
    BEGIN
      IF Parameter[count][1] = '-' THEN
      BEGIN
        IF Pos('A', Parameter[count]) > 1 THEN deletea := TRUE;
        IF Pos('H', Parameter[count]) > 1 THEN deleteh := TRUE;
        IF Pos('R', Parameter[count]) > 1 THEN deleter := TRUE;
        IF Pos('S', Parameter[count]) > 1 THEN deletes := TRUE;
      END
      ELSE
      BEGIN
        IF Pos('A', Parameter[count]) > 1 THEN seta := TRUE;
        IF Pos('H', Parameter[count]) > 1 THEN seth := TRUE;
        IF Pos('R', Parameter[count]) > 1 THEN setr := TRUE;
        IF Pos('S', Parameter[count]) > 1 THEN sets := TRUE;
      END;
      chg := TRUE;
    END
    ELSE IF Parameter[count][1] = '/' THEN
    BEGIN
      IF Parameter[count] = '/S' THEN subs := TRUE;
      IF Parameter[count] = '/SYS' THEN sysmod := TRUE;
    END;
  END;
END;

(*-------------------------------------------------------------------*)

PROCEDURE ShowAttributes(FRecord: SearchRec; path: STRING);
VAR
  fname   : STRING[12];
  arcdisp : STRING[9];
  i       : BYTE;
BEGIN
  IF (NOT sysmod) AND works THEN FOR i := 1 TO sysfcount DO
    IF (FRecord.Name = SystemFile[i]) THEN Exit;
  IF ((NOT sysmod) AND works) THEN
    IF FRecord.Attr IN [$8..$F, $28..$2F] THEN Exit;
  arcdisp := '         ';
  IF FRecord.Attr AND VolumeID = VolumeID THEN arcdisp[1] := 'V';
  IF FRecord.Attr AND Archive  = Archive  THEN arcdisp[3] := 'A';
  IF FRecord.Attr AND ReadOnly = ReadOnly THEN arcdisp[5] := 'R';
  IF FRecord.Attr AND Hidden   = Hidden   THEN arcdisp[7] := 'H';
  IF FRecord.Attr AND SysFile  = SysFile  THEN arcdisp[9] := 'S';
  fname := FRecord.Name;
  IF FRecord.Attr AND VolumeID = VolumeID THEN
    IF Pos('.', fname) > 0 THEN Delete(fname, Pos('.', fname), 1);
  IF works THEN
  BEGIN
    IF deletea THEN Write('-A') ELSE IF seta THEN Write('+A')
               ELSE Write(' ':2);
    IF deleter THEN Write('-R') ELSE IF setr THEN Write('+R')
               ELSE Write(' ':2);
    IF deleteh THEN Write('-H') ELSE IF seth THEN Write('+H')
               ELSE Write(' ':2);
    IF deletes THEN Write('-S') ELSE IF sets THEN Write('+S')
    ELSE Write(' ':2);
    WriteLn(' --> ' + path + fname);
  END
  ELSE
  BEGIN
    IF FRecord.Attr AND VolumeID = VolumeID THEN
      WriteLn(CON, arcdisp, ' ':4, fname) (*fÅr Volume Pfad weglassen*)
    ELSE
      WriteLn(CON, arcdisp, ' ':4, path, fname);
    Inc(fcounter);
  END;
END;

(*-------------------------------------------------------------------*)

PROCEDURE ChangeAttributes(sr: SearchRec; path: STRING);
VAR
  f : FILE;
  i : INTEGER;
BEGIN
  FOR i := 1 TO sysfcount DO
  BEGIN
    IF (sr.Name = SystemFile[i]) AND (sysmod = FALSE) THEN Exit;
  END;
  newattr := sr.Attr;
  IF sr.Attr AND $20 = 0   THEN IF seta    THEN Inc(newattr, $20);
  IF sr.Attr AND $20 = $20 THEN IF deletea THEN Dec(newattr, $20);
  IF sr.Attr AND $01 = 0   THEN IF setr    THEN Inc(newattr, $01);
  IF sr.Attr AND $01 = $01 THEN IF deleter THEN Dec(newattr, $01);
  IF sr.Attr AND $02 = 0   THEN IF seth    THEN Inc(newattr, $02);
  IF sr.Attr AND $02 = $02 THEN IF deleteh THEN Dec(newattr, $02);
  IF sr.Attr AND $04 = 0   THEN IF sets    THEN Inc(newattr, $04);
  IF sr.Attr AND $04 = $04 THEN IF deletes THEN Dec(newattr, $04);
  Assign(f, path + sr.Name);
  SetFAttr(f, newattr);
  Inc(fcounter);
END;

(*-------------------------------------------------------------------*)

PROCEDURE SearchDirectories(path, fname: STRING);
VAR
  sr : SearchRec;
BEGIN
  IF Length(path) > 0 THEN             (* Suche nach DateieintrÑgen: *)
    IF path[Length(path)] <> '\' THEN path := path + '\';
  sr.Name := '';
  FindFirst(path + fname, Anyfile MOD Directory, sr);
  IF sr.Name <> '' THEN WriteLn(CON, '');
  WHILE DosError = 0 DO
  BEGIN
    CheckForKey;
    IF sr.Attr AND Directory = 0 THEN
    BEGIN
      IF works THEN ChangeAttributes(sr, path);
      ShowAttributes(sr, path)
    END;
    FindNext(sr);
  END;
                                       (* Suche nach Verzeichnissen: *)
  FindFirst(path + allfiles, Directory, sr);
  WHILE DosError = 0 DO
  BEGIN
    CheckForKey;
    IF (sr.Attr AND Directory = Directory) AND (sr.Name[1] <> '.') THEN
      SearchDirectories(path + sr.Name, fname);
    FindNext(sr);
  END;
END;

(*-------------------------------------------------------------------*)

PROCEDURE OnlyOneDirectory (path, srcfile: STRING);
VAR
  sr : SearchRec;
BEGIN
  FindFirst(path + srcfile, $3F, sr);
  WHILE DosError = 0 DO
  BEGIN
    IF sr.Attr IN [$0..$E, $20..$2E] THEN
    BEGIN
      CheckForKey;
      IF works THEN ChangeAttributes(sr, path);
      ShowAttributes(sr, path);
    END;
    FindNext(sr)
  END;
END;

(*-------------------------------------------------------------------*)
(*                            Hauptprogramm                          *)
(*-------------------------------------------------------------------*)

BEGIN
  CheckBreak := FALSE;
  Assign(CON, '');
  Append(CON);
  ansiinst := ANSISYS;
  IF ParamCount = 0 THEN Help;         (* Hilfe wenn kein Parameter: *)
  FOR count := 1 TO 20 DO
    Parameter[count] := '';                          (* MÅll lîschen *)
  FOR count := 1 TO ParamCount DO
    Parameter[count] := UpString(ParamStr(count));
  IF Lo(DosVersion) < 3 THEN ErrorHalt('Falsche DOS-Version');
  fcounter := 0;
  CheckParameters(works, subs);
  IF srcfile = '' THEN ErrorHalt('Keine Datei(en) angegeben');
  IF (srcfile = SystemFile[1]) OR (srcfile = SystemFile[2]) OR
     (srcfile = SystemFile[3]) OR (srcfile = SystemFile[4]) THEN
    IF NOT sysmod THEN
      ErrorHalt(^M^J'Systemdateien werden nicht geÑndert !'^M^J +
                'Wenn Sie Systemdateien Ñndern wollen,'^M^J +
                'mÅssen Sie zusÑtzlich die Option /SYS'^M^J +
                'angeben.');
  AnsiYellow;
  WriteLn(CON, 'Turbo ' + copyrght + ^J);
  AnsiGray;
  IF subs THEN SearchDirectories(startpath, srcfile)
          ELSE OnlyOneDirectory(startpath, srcfile);
  IF fcounter = 0 THEN
    ErrorHalt('Datei '+ srcfile + ' nicht gefunden.')
  ELSE
  BEGIN
    Write(CON, ^M^J, fcounter, ' Datei');
    IF fcounter > 1 THEN Write (CON, 'en');
    IF works THEN WriteLn(CON, ' bearbeitet.')
             ELSE WriteLn(CON, ' angezeigt.');
  END;
  Close(CON);
END.

(*===================================================================*)
