{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X-,M 16384,0,0}
(*===================================================================*)
(*                     SHOWVECT.PAS Version 1.0                      *)
(*                 Copyright (C) 1993 te-wi Verlag                   *)
(*-------------------------------------------------------------------*)
(* Das Programm zeigt die Liste der Interruptvektoren mit Kommentar  *)
(* auf dem Bildschirm an. Die Liste kann zusÑtzlich auch in eine     *)
(* Datei ØSHOWVECT.OUTÆ geschrieben und ausgedruckt werden (LPT1).   *)
(*-------------------------------------------------------------------*)
(* Achtung:                                                          *)
(* Wenn das Programm aus der IDE von Turbo/Borland Pascal aufgerufen *)
(* wird, werden nicht die Originalvektoren, sondern die vom Compiler *)
(* umgebogenen Vektoren angezeigt!                                   *)
(* Das Programm kann sowohl im Protected- als auch im Real-Mode com- *)
(* piliert und gestartet werden, im DMPI werden allerdings nicht die *)
(* Interruptvektoren sondern die Descriptoren angezeigt.             *)
(*===================================================================*)

PROGRAM ShowVectors;

USES
  Crt, Dos, Hex, Cursor, Printer;

VAR
  VecTab : ARRAY[0..$FF] OF STRING[77];

CONST
  UpperLine: STRING[77] = #32#32#32#218#196'[Adresse]'#196#194'[I]'   +
             #194#196#196#196#196#196'[Bezeichnung]'#196#196#196#196  +
             #196#194#196#196#196#196#196#196#196#196#196'[Beschreib' +
             'ung]'#196#196#196#196#196#196#196#196#196#191;
  Lowerline: STRING[77] = #32#32#32#192#196#196#196#196#196#196#196   +
             #196#196#196#196#193#196#196#196#193#196#196#196#196#196 +
             #196#196#196#196#196#196#196#196#196#196#196#196#196#196 +
             #196#196#196#196#193#196#196#196#196#196#196#196#196#196 +
             #196#196#196#196#196#196#196#196#196#196#196#196#196#196 +
             #196#196#196#196#196#196#196#196#196#217;
  InfoLine   : STRING[61] = '                 Ø Show Vectors v1.01 ' +
             '(C) 1993 te-wi Verlag Æ';
  StatusLine : STRING[78] = '['#24#25'][PgUp][PgDn][End][Home]' +
             ' [$]XX [S]peichern [D]rucken  [F1]=Hilfe [ESC]=Ende';
  HelpLine   : STRING[39] = 'ZurÅck zur Tabelle mit beliebiger Taste';

PROCEDURE Init;
VAR
  Vectors: ARRAY[0..$FF] OF POINTER;  { Zeiger auf alle Intr-Vektoren }
  i      : BYTE;                                     { ZÑhlervariable }
BEGIN
  (* Alle Interruptvektoren in einem Array vom Typ LogRec holen:     *)
  SwapVectors;                          (* nicht die programmeigenen *)
  FOR i := 0 TO $FF DO GetIntVec(i, Vectors[i]);   (* Vektoren holen *)
  SwapVectors;                              (* Vektoren restaurieren *)
  (* Die Tabelle mit den Bezeichnungen und ErklÑrungen aufbauen:     *)
  VecTab[$00] := 'DIVIDE ERROR           '
               + #179'Division durch Null             ';
  VecTab[$01] := 'SINGLE STEP            '
               + #179'Debugger-Einzelschritt-Mode     ';
  VecTab[$02] := 'NON MASKABLE INTERRUPT '
               + #179'Nicht maskierbarer Interrupt NMI';
  VecTab[$03] := 'ONE-BYTE-INTERR.       '
               + #179'Breakpoint                      ';
  VecTab[$04] := 'OVERFLOW               '
               + #179'öberlauf der internen Hardware  ';
  VecTab[$05] := 'PRINT SCREEN KEY       '
               + #179'Start bei Druck auf [PrtScr]    ';
  VecTab[$06] := 'UNDEFINED OPCODE       '
               + #179'ab 80286                        ';
  VecTab[$07] := 'NO MATH UNIT AVAILABLE '
               + #179'ab 80286 fÅr die NPX-Emulation  ';
  VecTab[$08] := 'IRQ0 TIMER INTERRUPT   '
               + #179'Zeitgenerator-Hardware-Interrupt';
  VecTab[$09] := 'IRQ1 KEYBOARD INTERRUPT'
               + #179'Tastatur-Hardware-Interrupt     ';
  VecTab[$0A] := 'IRQ2 EGA VERT. RETRACE '
               + #179'Vertical-Retrace-Signal bei EGA ';
  VecTab[$0B] := 'IRQ3 COM2              '
               + #179'Serielle Schnittstelle 2        ';
  VecTab[$0C] := 'IRQ4 COM1              '
               + #179'Serielle Schnittstelle 1        ';
  VecTab[$0D] := 'IRQ5 FIXED DISK        '
               + #179'Festplatte bei XT, bei AT LPT2  ';
  VecTab[$0E] := 'IRQ6 DISKETTE          '
               + #179'Disketten-Hardware-Interrupt    ';
  VecTab[$0F] := 'IRQ7 PRINTER           '
               + #179'Drucker-Hardware-Interrupt LPT1 ';
  VecTab[$10] := 'VIDEO                  '
               + #179'BIOS-Bildschirminterrupt        ';
  VecTab[$11] := 'EQUIPMENT DETERMINATION'
               + #179'Ermittlung der PC-Konfiguration ';
  VecTab[$12] := 'MEMORY SIZE            '
               + #179'Grî·e des Arbeitsspeichers      ';
  VecTab[$13] := 'DISK                   '
               + #179'Disketten-/Festplatten-Interrupt';
  VecTab[$14] := 'SERIAL I/O             '
               + #179'Serielle Ein-/Ausgabe Åber BIOS ';
  VecTab[$15] := 'CASSETTE/AT-FUNCTIONS  '
               + #179'Kassetten-Interr./AT-Funktionen ';
  VecTab[$16] := 'KEYBOARD               '
               + #179'BIOS-Tastatur-Interrupt         ';
  VecTab[$17] := 'PRINTER                '
               + #179'Drucker-BIOS-Interrupt          ';
  VecTab[$18] := 'TRANSFER TO ROM BASIC  '
               + #179'Sprung ins BASICA (IBM)         ';
  VecTab[$19] := 'DISK BOOT              '
               + #179'System-Start (IBM)              ';
  VecTab[$1A] := 'CLOCK                  '
               + #179'BIOS-Timer-Interrupt            ';
  VecTab[$1B] := 'CTRL BREAK KEY         '
               + #179'BIOS [Ctrl]+[Break]-Routine     ';
  VecTab[$1C] := 'CLOCK TICK             '
               + #179'Timer-Zusatzroutine (IBM)       ';
  VecTab[$1D] := '6845 VIDEO INIT TABLE  '
               + #179'Video-Tabelle                   ';
  VecTab[$1E] := 'DISKETTE PARAMS TABLE  '
               + #179'Disketten-Parameter-Tabelle     ';
  VecTab[$1F] := 'GRAPHICS SET 2         '
               + #179'BIOS-Grafikzeichensatz-Tabelle  ';
  VecTab[$20] := 'PROGAM TERMINATION     '
               + #179'Programmende (bei COM-Programm) ';
  VecTab[$21] := 'DOS INTERRUPT          '
               + #179'DOS-Standard-Interrupt          ';
  VecTab[$22] := 'TERMINATE ADDRESS      '
               + #179'Abbruch, nie direkt verwenden!  ';
  VecTab[$23] := 'CONTROL C EXIT ADDRESS '
               + #179'[CTRL]+[C]-Abbruchadresse       ';
  VecTab[$24] := 'FATAL ERROR HANDLER    '
               + #179'Behandlung kritischer DOS-Fehler';
  VecTab[$25] := 'ABSOLUTE DISK READ     '
               + #179'Direktes Lesen von DatentrÑger  ';
  VecTab[$26] := 'ABSOLUTE DISK WRITE    '
               + #179'Direktes Schreiben von Datentr. ';
  VecTab[$27] := 'TSR                    '
               + #179'Beenden und im Speicher halten  ';
  VecTab[$28] := 'KEYBOARD BUSY LOOP     '
               + #179'DOS-internes Flag               ';
  VecTab[$29] := 'FAST PUTCHAR           '
               + #179'DOS-interne Routine             ';
  VecTab[$2A] := 'MICROSOFT NETWORKS     '
               + #179'Microsoft-Netzwerk-Routinen     ';
  FOR i := $2B TO $2D DO
    VecTab[i] := 'INTERNAL               '
               + #179'DOS-interne Routine             ';
  VecTab[$2E] := 'EXECUTE - INTERNAL     '
               + #179'DOS-interne Routine             ';
  VecTab[$2F] := 'MULTIPLEX              '
               + #179'DOS-Multiplexer-Interrupt       ';
{$IFDEF DPMI}
  VecTab[$30] := 'BORLAND DPMI-INTERFACE '
               + #179'CP/M-Funkt. / auch Borland DPMI ';
{$ELSE}
  VecTab[$30] := 'FAR JUMP TO CP/M CALL  '
               + #179'CP/M-Funkt. / auch Borland DPMI ';
{$ENDIF}
  VecTab[$31] := 'FAR JUMP TO CP/M CALL  '
               + #179'Zeiger auf CP/M-kompat. Aufruf  ';
  VecTab[$32] := 'RESERVED               '
               + #179'FÅr DOS reserviert              ';
  VecTab[$33] := 'MS MOUSE               '
               + #179'Microsoft-Mausinterface         ';
  FOR i := $34 TO $3E DO
    VecTab[i] := 'FLOATING POINT EMULATN.'
               + #179'Flie·komma-Emulations-Routine   ';
  VecTab[$3F] := 'MICROSOFT DLL MANAGER  '
               + #179'Microsoft DLL-Manager           ';
  VecTab[$40] := 'HARD DISK              '
               + #179'relozierter BIOS-Floppy-Handler ';
  VecTab[$41] := 'FIXED DISK PARAMETERS  '
               + #179'reloz. BIOS-Festplattenparameter';
  VecTab[$42] := 'RELOCATED VIDEO HANDLER'
               + #179'Umgebogener BIOS-Video-Handler  ';
  VecTab[$43] := 'USER FONT TABLE        '
               + #179'EGA/VGA-Fonttabellen            ';
  VecTab[$44] := 'NOVELL NETWARE         '
               + #179'High-Level-Sprachen API         ';
  FOR i := $45 TO $60 DO
    VecTab[i] := 'RESERVED               '
               + #179'reserviert                      ';
  VecTab[$46] := '2 FIXED DISK PARAMETERS'
               + #179'siehe INT 41h                   ';
  VecTab[$4A] := 'AT USER ALARM          '
               + #179'RTC Alarmschnittstelle zum BIOS ';
  FOR i := $61 TO $66 DO
    VecTab[i] := 'RESERVED FOR USER INTR.'
               + #179'fÅr Applikationen reserviert    ';
  VecTab[$67] := 'EMM                    '
               + #179'EMS-Manager                     ';
  FOR i := $68 TO $6C DO
    VecTab[i] := 'UNUSED                 '
               + #179'normalerweise unbenutzt         ';
  VecTab[$6D] := 'VGA INTERNAL           '
               + #179'von versch. VGA-Karten verwendet';
  VecTab[$6E] := 'UNUSED                 '
               + #179'unbenutzt                       ';
  VecTab[$6F] := 'NOVELL NETBIOS         '
               + #179'Novell-Netzwerk                 ';
  VecTab[$70] := 'IRQ8 REAL TIME CLOCK   '
               + #179'AT Echtzeit-Uhr                 ';
  VecTab[$71] := 'IRQ9 LAN ADAPTER 1     '
               + #179'Netzwerk-Adapter 1              ';
  VecTab[$72] := 'IRQ10 RESERVED         '
               + #179'reserviert                      ';
  VecTab[$73] := 'IRQ11 RESERVED         '
               + #179'reserviert                      ';
  VecTab[$74] := 'IRQ12 MOUSE INTERRUPT  '
               + #179'Maus-Interrupt bei IBM PS/2     ';
  VecTab[$75] := 'IRQ13 80287 ERROR      '
               + #179'80x87-Fehler                    ';
  VecTab[$76] := 'IRQ14 FIXED DISK       '
               + #179'Festplatte                      ';
  VecTab[$77] := 'IRQ15 RESERVED         '
               + #179'reserviert                      ';
  FOR i := $78 TO $7E DO
    VecTab[i] := 'UNUSED                 '
               + #179'normalerweise unbenutzt         ';
  VecTab[$7A] := 'NOVELL NETWARE LL API  '
               + #179'Low-Level API von Novell        ';
  VecTab[$7F] := 'HDILOAD                '
               + #179'IBM 8514/A-Interface            ';
  FOR i := $80 TO $F0 DO
    VecTab[i] := 'RESERVED FOR BASIC IPR '
               + #179'fÅr GW-Basic/Basica reserviert  ';
  FOR i := $F1 TO $FD DO
    VecTab[i] := 'RESERVED FOR USER INTR.'
               + #179'fÅr Applikationen reserviert    ';
  FOR i := $FE TO $FF DO
    VecTab[i] := 'PROTECTED MODE RESERV. '
               + #179'fÅr Protected Mode reserviert   ';
  FOR i := $00 TO $FF DO                { die Zeichenketten aufbauen: }
    VecTab[i] := '   '#179 + Ptr2Hex(Vectors[i], TRUE)
                    + #179'$' + Byte2Hex(i)
                    + #179 + VecTab[i] + #179;
END;

PROCEDURE Run;

  PROCEDURE SetBackGround;
  BEGIN
    IF BYTE(Ptr(Seg0040, $0049)^) IN [0, 2, 7] THEN    { SW/Monochrom }
      TextAttr := LightGray                                { Standard }  
    ELSE                                                     { Farbe: } 
    BEGIN
      TextColor(Yellow); TextBackground(Blue);                 { Bunt }
    END;
  END;

  PROCEDURE WriteALine(l: INTEGER; s: STRING);
  BEGIN
    TextAttr := 112;                              { Farbe: invertiert }
    GotoXY(1, l);                              { Zeilenanfang von ØlÆ }
    ClrEoL;                                    { Bis zum Ende lîschen }
    GotoXY(2, l);                              { 2. Zeichen der Zeile }
    Write(s);                                          { ØsÆ ausgeben }
    SetBackGround;                                 { Std-Farbe setzen }
  END;

  PROCEDURE WriteDown(s: STRING; i: INTEGER);
  VAR                                  { Zeichen nach unten schreiben }
    y: INTEGER;
  BEGIN
    IF s[0] > ^@ THEN                            { auch das ist #0 !! }
      FOR y := 1 TO BYTE(s[0]) DO            { identisch zu Length(s) }
      BEGIN                                { wÅstes schnelles Typcast }
        GotoXY(79, y + i); Write(s[y]);        { ein Zeichen ausgeben }
      END;
  END;

  PROCEDURE Help;
  VAR
    i: INTEGER;
    ch: CHAR;
  BEGIN
    WriteALine(25, HelpLine);
    TextAttr := 111;                  { wei·e Schrift auf rotem Grund }
    FOR i := 2 TO 24 DO
    BEGIN
      GotoXY(1, i); ClrEoL;           { Bildschirm au·er Statuszeilen }
    END;                              { lîschen                       }  
    GotoXY(5, 3); Write(#218); FOR i := 6 TO 74 DO Write(#196);
    Write(#191);                      { Rahmen um den Hilfebildschirm }
    FOR i := 4 TO 21 DO               { mit Grafikzeichen (einfache)  }  
    BEGIN                             { Linien) zeichnen              }
      GotoXY(5, i); Write(#179, #179:70);
    END; 
    GotoXY(5, 22); Write(#192); FOR i := 6 TO 74 DO Write(#196);
    Write(#217);
    ch := #0;                         { Hilfetext ausgeben            }
    GotoXY(36,  4); Write('Hilfe');  GotoXY(5, 5); Write(#195);
    FOR i := 6 TO 74 DO Write(#196); Write(#180);
    GotoXY( 6,  7); Write('Mit den Cursortasten wird durch die Liste '
                        + 'gescrollt.');
    GotoXY( 6,  9); Write('Direktes Anspringen erfolgt durch Eingabe '
                        + 'der Hex-Nummer des entspre-');
    GotoXY( 6, 10); Write('chenden Interrupts. Die Eingabe mu· immer '
                        + 'mit Ø$Æ und zwei Hexzahlen');
    GotoXY( 6, 11); Write('erfolgen, bei Interrupts kleiner als 10h m'
                        + 'it fÅhrender Null, also ');
    GotoXY( 6, 12); Write('beispielweise $03 fÅr Int 3h.');
    GotoXY( 6, 14); Write('Mit Ø[S]peichernÆ wird die Tabelle auf den'
                        + ' DatentrÑger in die Datei');
    GotoXY( 6, 15); Write('SHOWVECT.OUT ins aktuelle Verzeichnis gesi'
                        + 'chert.  Eine bereits vor-');
    GotoXY( 6, 16); Write('handene Ñltere Datei wird dabei Åberschrie'
                        + 'ben. Mit Ø[D]ruckenÆ wird');
    GotoXY( 6, 17); Write('die komplette Liste aller Interrupts auf d'
                        + 'em Drucker ausgegeben.');
    GotoXY( 6, 18); Write('Achtung: Das dauert, da es sich um 256 Zei'
                        + 'len handelt, etwas lÑnger.');
    GotoXY( 6, 20); Write('Das Programm wird mit einem Druck auf <ESC'
                        + '> ohne Nachfrage beendet.');
    REPEAT
      ch := ReadKey;             { Tastendruck abfragen, bei F-Tasten }
    UNTIL ch <> #0;                     { das erste Zeichen schlucken }  
    WriteALine(25, StatusLine);              { Infozeile restaurieren }
    FOR i := 2 TO 24 DO                     { roten Bildschirm wieder }
    BEGIN                                   { lîschen (blau)          }
      GotoXY(1, i);
      ClrEoL;
    END;
    GotoXY(1,  2); Write(UpperLine);            { alten Rahmen wieder }
    GotoXY(1, 24); Write(Lowerline);                   { restaurieren }
  END;

VAR
   First, Second,                               { fÅr direkte Eingabe }
   key           : CHAR;                            { Tastaturabfrage }
   i, j, c       : BYTE;                              { ZÑhlvariablen }
   t             : Text;                              { Dateivariable }
   test          : INTEGER;                               { fÅr Val() }
BEGIN
  HideCursor;                                            { Cursor aus }
  SetBackGround;                            { Hintergrundfarbe setzen }
  ClrScr;                                        { ... und BS lîschen }
  WriteALine(1, InfoLine);                   { erste und letzte Zeile }
  WriteALine(25, StatusLine);                          { ... anzeigen }
  GotoXY(1, 2);                                       { Rahmen ziehen }
  WriteLn(UpperLine);
  FOR j := 0 TO 20 DO WriteLn(VecTab[j]);    { Vektoren ab 0 anzeigen }
  WriteLn(Lowerline);                            { untere Rahmenzeile }
  i := 0; j := 0;                            { Variablen auf 0 setzen }
  REPEAT
    key := UpCase(ReadKey);    { Die Tastaturabfrage fÅr die Schleife }
    IF (key = 'S') THEN                           { Taste ØSpeichernÆ }
    BEGIN
      WriteDown('SPEICHERN IN DATEI', 2);             { Info ausgeben }
      Assign(t, 'SHOWVECT.OUT');                     { Datei zuordnen }
      ReWrite(t);                                   { ... neu anlegen }
      WriteLn(t, UpperLine);                        { Rahmen oben ... }
      FOR i := 0 TO $FF DO WriteLn(t, VecTab[i]);      { Vektoren ... }
      WriteLn(t, UpperLine);           { und unteren Rahmen schreiben }
      Close(t);                                     { Datei schlie·en }
      WriteDown('                  ', 2);          { Infotext lîschen }
      i := $00;                                      { Vektorenanfang }
    END
    ELSE IF key = 'D' THEN                          { Taste ØDruckenÆ } 
    BEGIN
      WriteDown('VEKTOREN DRUCKEN', 2);               { Info ausgeben }
      WriteLn(Lst, UpperLine);                      { Rahmen oben ... }
      FOR i := 0 TO $FF DO WriteLn(Lst, VecTab[i]);    { Vektoren ... }
      WriteLn(Lst, Lowerline);           { und unteren Rahmen drucken }
      WriteDown('                 ', 2);           { Infotext lîschen }
      i := $00;                                      { Vektorenanfang }
    END
    ELSE IF key = '$' THEN BEGIN                  { direkt anspringen }
      REPEAT
        First  := ReadKey;                { Zehnerzahl (hex) abfragen }
      UNTIL First IN ['0'..'9', 'A'..'F', 'a'..'f'];
      REPEAT
       Second := ReadKey;                  { Einerzahl (hex) abfragen }
      UNTIL Second IN ['0'..'9', 'A'..'F', 'a'..'f'];
      Val('$' + First + Second, c, test);  { String in Zahl umwandeln }
      IF test = 0 THEN                 { kein Fehler, also ausfÅhren: }
      BEGIN               
        IF c IN [$00..$FF - 20] THEN i := c        ELSE
        IF c IN [$FF - 20..$FF] THEN i := $FF - 20 ELSE i := 0;
        GotoXY(1, 3);                             { Cursor zum Anfang }
        FOR j := i TO i + 20 DO WriteLn(VecTab[j]);        { ausgeben }
      END;
    END
    ELSE IF key = #0 THEN               { Cursor- oder Funktionstaste }
    BEGIN
      key := ReadKey;                            { zweiten Code lesen }
      IF (key = 'H') AND (i > 0) THEN Dec(i);             { Cursor Up }
      IF (key = 'P') AND (i < $FF - 20) THEN Inc(i);    { Cursor Down }
      IF (key = 'G') AND (i <> 0) THEN i := 0;                 { Home }
      IF (key = 'O') AND (i < $FF - 21) THEN i := $FF - 20;     { End }
      IF (key = 'Q') THEN                                      { PgUp }
        IF (i <= $FF - 20 * 2) THEN Inc(i, 21) ELSE i := $FF - 20;
      IF (key = 'I') THEN                                      { PgDn }
        IF (i >= 21 * 2) THEN Dec(i, 21) ELSE i := 0;
      IF key = ';' THEN Help;                                    { F1 }
      GotoXY(1, 3);
      FOR j := i TO i + 20 DO WriteLn(VecTab[j]);    { Werte anzeigen }
    END;
  UNTIL key = #27;                               { Bis <ESC> gedrÅckt }
END;

PROCEDURE Done;
BEGIN
  SetCursor(StartCursor);                         { Cursor anschalten }
  TextAttr := LightGray;                      { Standard-Textattribut }
  WriteLn(' ');        { nur so wird das Text-Attribut zurÅckgesetzt! }
  ClrScr;                                    { und Bildschirm lîschen }
END;

BEGIN
  Init;                                  { Initialisieren der Tabelle }
  Run;                                         { Anzeigen der Tabelle }
  Done;                                      { Restaurieren der Werte }
END.                  

(*===================================================================*)
