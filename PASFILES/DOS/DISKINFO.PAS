{$A+,B-,D-,E-,F-,G-,I-,N-,O-,P-,Q-,R-,S-,T-,V-,X-,M 4096,0,2048}
(*===================================================================*)
(*                     DISKINFO.PAS Version 2.00                     *)
(*                Copyright (C) 1993 te-wi Verlag, Mnchen           *)
(*-------------------------------------------------------------------*)
(* Das Programm gibt alle im Bootsektor eines Laufwerks befindlichen *)
(*              Informationen auf dem Bildschirm aus.                *)
(*===================================================================*)
{$IFNDEF DPMI}
PROGRAM DiskInformation;

USES
  Dos, UPPER, DOSUtil, Hex;

VAR
  Buffer    : ARRAY[0..$200] OF BYTE;
  BootBlock : tBootBlock ABSOLUTE Buffer;
  i         : WORD;
  Parameter : ComStr;
  DrvChar   : CHAR;
  result    : INTEGER;
  Size      : REAL;
  SizeStr   : STRING;
  FSizeStr  : STRING;

CONST
  Drive     : BYTE = 3;

BEGIN
  WriteLn(^M^J'Bootsektor-Information Version 2.00, ' +
        '(C) 1993 te-wi Verlag, Mnchen.');
  IF ParamCount > 0 THEN
  BEGIN
    Parameter := UpString(ParamStr(1));
    IF NOT (Parameter[1] IN ['A'..'Z', '?']) THEN
      Delete(Parameter, 1, 1);
    DrvChar := Parameter[1];
    IF DrvChar IN ['A'..'Z'] THEN Drive := BYTE(Ord(DrvChar) - 64)
    ELSE IF DrvChar = '?' THEN
    BEGIN
      WriteLn(^M^J'Aufruf:');
      WriteLn(' DISKINFO [-][Laufwerk|?]');
      WriteLn(' ''?'' zeigt diese Information an.');
      WriteLn(' Es reicht, wenn der Laufwerksbuchstabe angegeben');
      WriteLn(' wird. Ist kein Laufwerk angegeben, wird das erste');
      WriteLn(' Plattenlaufwerk angezeigt.'^M^J);
      Halt(0);
    END;
  END;

  result := ReadBootSector(Drive, Buffer);

  IF result <> 0 THEN
  BEGIN
    WriteLn('Fehler beim Lesen des Bootsektors von Laufwerk ',
      Chr(Drive + 64), ':');
      ExitCode := result;
  END
  ELSE
  BEGIN
    WriteLn(^J'Daten im Bootsektor von Laufwerk ',
            Chr(Drive + 64), ':');
    WriteLn('-----------------------------------');
    WITH BootBlock DO
    BEGIN
      Write('OEM-Kennung           : ');
      FOR i := 1 TO 8 DO
        IF OEM[i] >= ' ' THEN Write(OEM[i]);
      WriteLn;
      WriteLn('Bytes pro Sektor      : ', Data.BytesPerSector);
      WriteLn('Sektoren pro Cluster  : ', Data.SectorsPerCluster);
      WriteLn('Bytes pro Cluster     : ', WORD(Data.SectorsPerCluster) *
                                          WORD(Data.BytesPerSector));
      WriteLn('Reservierte Sektoren  : ', Data.ReservedSectors);
      WriteLn('Anzahl FATs           : ', Data.NumberOfFATs);
      WriteLn('Anzahl Rooteintr„ge   : ', Data.RootEntries);
      IF Data.TotalSectors <> 0 THEN BEGIN
        WriteLn('Sektoren (12 Bit-FAT) : ', Data.TotalSectors);
        Size := LONGINT(Data.TotalSectors) *
                LONGINT(Data.BytesPerSector) / 1024;
      END
      ELSE
      BEGIN
        WriteLn('Sektoren (16 Bit-FAT) : ', Data.BigTotalSectors);
        Size := LONGINT(Data.BigTotalSectors) *
                LONGINT(Data.BytesPerSector) / 1024 / 1024;
      END;
      Str(Size:5:2, SizeStr);
      IF Pos('.', SizeStr) > 0 THEN SizeStr[Pos('.', SizeStr)] := ',';
      IF Data.MediaDescriptor = $F8 THEN BEGIN
        WriteLn('Gesamtgr”áe in Mbytes : ', SizeStr);
        Str(DiskFree(Drive) / 1024 / 1024: 3: 2, FSizeStr);
        IF Pos('.', FSizeStr) > 0 THEN
            FSizeStr[Pos('.', FSizeStr)] := ',';
        WriteLn('Davon sind noch frei  : ', FSizeStr);
      END
      ELSE
      BEGIN
        WriteLn('Gesamtgr”áe in Kbytes : ', LONGINT(Data.TotalSectors)
                                        * LONGINT(Data.BytesPerSector)
                                        DIV 1024);
        WriteLn('Davon sind noch frei  : ', DiskFree(Drive) DIV 1024);

      END;
      WriteLn('Media-Descriptor-Byte : ',
                                  Byte2Hex(Data.MediaDescriptor), 'h');
      WriteLn('Sektoren pro FAT      : ', Data.SectorsPerFAT);
      WriteLn('Sektoren pro Spur     : ', Data.SectorsPerTrack);
      WriteLn('Schreib-/Lese-K”pfe   : ', Data.Heads);
      IF Data.MediaDescriptor = $F8 THEN
        WriteLn('Versteckte Sektoren   : ', Data.HiddenSectors)
      ELSE
        WriteLn('Versteckte Sektoren   : 0');
      Write(^M^J'Disk-Label (DOS4)     : ');
      FOR i := 1 TO 11 DO BEGIN
        IF DiskLabel[i] IN ['A'..'Z', '0'..'9'] THEN
          Write(DiskLabel[i]);
      END;
      WriteLn;
      Write('FAT-ID     (DOS4)     : ');
      FOR i := 1 TO 8 DO BEGIN
        IF FatTypeText[i] IN [' ', 'A'..'Z', '0'..'9'] THEN
          Write(FatTypeText[i]);
      END;
      IF Lo(DosVersion) < 4 THEN
        WriteLn('Hier kann bei Ihrem DOS auch etwas anderes stehen');
      WriteLn;
    END;
  END;
{$ELSE}
BEGIN
   WriteLn('Dieses Programm wurde f„lschlicherweise ' +
           'im DPMI-Mode compiliert!');
{$ENDIF}
END.

(*===================================================================*)
