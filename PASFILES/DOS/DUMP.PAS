{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X-,M $4000,0,0}
(*===================================================================*)
(*                            DUMP.PAS                               *)
(*             Copyright (C) 1993 te-wi Verlag, Mnchen              *)
(*    Das Programm erzeugt einen Hexdump einer beliebigen Datei      *)
(*===================================================================*)

PROGRAM HexDump;

USES
  Dos, Upper, Hex;

VAR
 sr                            : SearchRec;
 OrgName, HexFile              : PathStr;
 HexDir                        : DirStr;
 HexName                       : NameStr;
 HexExt                        : ExtStr;
 f                             : FILE OF BYTE;
 t                             : Text;
 l, len                        : Longint;
 i                             : INTEGER;
 b                             : BYTE;
 line, ls, dump, OutLine       : STRING;
 Year, Month, Day, DayofWeek,
 Hour, Minute, Second, Sec100  : WORD;
 dt                            : DateTime;

BEGIN
  IF ParamCount = 0 THEN
  BEGIN
    WriteLn(^M^J'DUMP v1');
    WriteLn(' Fehler beim Aufruf des Programms!');
    WriteLn(' Aufruf: ''DUMP QUELLDATEI''');
    WriteLn(' Die Zieldatei erh„lt den Namen der');
    WriteLn(' Quelldatei und die Endung .DMP');
  END
  ELSE
  BEGIN
    IF (Pos('?', ParamStr(1)) > 0) OR (Pos('*', ParamStr(1)) > 0) OR
      (Pos('/h', ParamStr(1)) > 0) OR (Pos('/H', ParamStr(1)) > 0) THEN
    BEGIN
      WriteLn(^M^J'DUMP Version 1.0'^J);
      WriteLn('Beliebige Bin„rdateien werden als Hexdump in eine');
      WriteLn('Datei geschrieben und gleichzeitig auf dem Bildschirm');
      WriteLn('angezeigt.'^J);
      WriteLn('Das Programm muá mit dem Namen der Quelle aufgerufen');
      WriteLn('werden. Der Name der Zieldatei ist gleich dem Namen');
      WriteLn('der Quelldatei. Die Zieldatei erh„lt die Endung .DMP.');
      WriteLn('Dateien mit der Endung .DMP k”nnen nicht bearbeitet');
      WriteLn('werden.');
      IF (Pos('?', ParamStr(1)) > 0) OR
         (Pos('*', ParamStr(1)) > 0) THEN
        WriteLn(^J'Wildcards in den Dateinamen sind nicht erlaubt.');
    END
    ELSE
    BEGIN
      OrgName := UpString(ParamStr(1));
      FSplit(OrgName, HexDir, HexName, HexExt);
      HexFile := HexDir + HexName + '.DMP';
      IF HexFile = OrgName THEN
      BEGIN
        WriteLn(^M^J'DUMP v1');
        WriteLn(' Fehler: Eingabedatei = Ausgabedatei!');
        WriteLn(' Dateien mit der Endung .DMP k”nnen');
        WriteLn(' nicht bearbeitet werden!');
      END
      ELSE
      BEGIN
        FileMode := 0;
        FindFirst(OrgName, AnyFile - Directory - VolumeID, sr);
        IF Length(sr.Name) = 0 THEN BEGIN
          WriteLn(^M^J'DUMP v1');
          WriteLn(' Fehler: Eingabedatei ', OrgName,
                  ' nicht vorhanden.')
        END
        ELSE
        BEGIN
          Assign(f, Orgname);
          Reset(f);
          Len := FileSize(f);
          IF IoResult <> 0 THEN Halt;
          Assign(t, HexFile); Rewrite(t);
          l := 0;
          line := '';
          dump := '';
          WriteLn;
          Write(t, 'Hexdump von ', HexName, HexExt);
          Write(   'Hexdump von ', HexName, HexExt);
          Write(t, ' (Originaldatei erzeugt am ');
          Write(   ' (Originaldatei erzeugt am ');
          UnpackTime(sr.Time, dt);
          WriteLn(t, dt.Day, '.', dt.Month, '.', dt.Day, ' um ', dt.Hour,
                     ':', dt.Min, ')');
          WriteLn(   dt.Day, '.', dt.Month, '.', dt.Day, ' um ',
                     dt.Hour, ':', dt.Min, ')');
          Getdate(Year, Month, Day, DayofWeek);
          GetTime(Hour, Minute, Second, Sec100);
          Writeln(t, HexName, '.DMP erzeugt am ', Day, '.', Month, '.',
                  Year, ' um ', Hour, ':', Minute, ^M^J^M^J);
          Writeln(HexName, '.DMP erzeugt am ', Day, '.', Month, '.',
                  Year, ' um ', Hour, ':', Minute, ^M^J^J);
          FOR l := 0 TO Len + $0F DO
          BEGIN
            IF l < Len THEN Read(f, b) ELSE b := 0;
            line := line + Byte2Hex(b) + ' ';
            IF b IN [32..126, 128..255] THEN
              dump := dump + Chr(b)
            ELSE
              dump := dump + '.';
            OutLine := line + dump;
            IF Length(OutLine) > 62 THEN BEGIN
              ls := Long2Hex(l - $F);
              Delete(ls, 1, 4);
              ls[1] := ' ';
              WriteLn(t, ls, ' | ', line, ' |  ', dump);
              WriteLn(   ls, ' | ', line, ' |  ', dump);
              line := '';
              dump := '';
           END;
          END;
          ls := Long2Hex(Len);
          WHILE ls[1] = '0' DO Delete(ls, 1, 1);
          WriteLn(t, ^M^J, 'Dateil„nge: ', Len, ' (', ls, 'h) Bytes');
          WriteLn(   ^M^J, 'Dateil„nge: ', Len, ' (', ls, 'h) Bytes');
          Close(f);
          Close(t);
        END;
      END;
    END;
  END;
END.

(*===================================================================*)
