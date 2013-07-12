{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X-}
(*===================================================================*)
(*                            DEMOFILE.PAS                           *)
(*            Copyright (C) 1993 te-wi Verlag, MÅnchen               *)
(*               Initialisierungsunit fÅr Demoprogramme.             *)
(*-------------------------------------------------------------------*)
(* Funktion:                                                         *)
(* Die Unit funktioniert vollautomatisch:                            *)
(* Beim ersten Programmaufruf wird an das Programm ein 3 Bytes       *)
(* langer Schwanz angehÑngt, dessen 2. Byte als ZÑhler initialisiert *)
(* wird. Das Programm kann nun weitere 9 Mal aufgerufen werden. Beim *)
(* 11. Aufruf zerstîrt sich das Programm selbst, so da· kein weiterer*)
(* rer Aufruf mehr mîglich ist. Eine Meldung wird gegeben. Einziger  *)
(* Schutz des Anwenders ist ein gegenlaufendes Patchprogramm. Ein    *)
(* Schreibschutz wird vom internen ZÑhler Åberwunden. Alle weiteren  *)
(* Schutzma·nahmen fÅhren zum Programmabbruch.                       *)
(*-------------------------------------------------------------------*)
(* In Quellcode einbinden mit:                                       *)
(* USES DemoFile;                                                    *)
(*-------------------------------------------------------------------*)
(* Die UNIT ist NICHT overlayfÑhig!                                  *)
(*-------------------------------------------------------------------*)
(* Die Programme kînnen mit EXEPACK o. dgl. behandelt werden, da die *)
(* DateilÑnge zur Laufzeit ermittelt wird. Allerdings mu· ExePack    *)
(* vor dem ersten Aufruf des Programms angewandt werden.             *)
(*===================================================================*)

UNIT DemoFile;

INTERFACE

(*-------------------------------------------------------------------*)
(* Keine öbergabefunktionen, alles geschieht automatisch bei der     *)
(* Initialisierung des Programms.                                    *)
(*-------------------------------------------------------------------*)

IMPLEMENTATION

USES DosUtil, Crt, Dos;

CONST
  Calls = 10;                            { 10 Programmaufrufe maximal }

VAR
  f     : FILE;
  FTime : LONGINT;
  FAttr : WORD;
  dummy,
  Name  : STRING;

PROCEDURE DemoVersion;
VAR
  i, WRByte,
  CallCounter : BYTE;
  ExeFile     : FILE OF BYTE;
  ExeLength,
  FleLength   : LONGINT;

  FUNCTION GetRealFileLength: LONGINT;
  BEGIN
    Assign(f, ParamStr(0));
    Reset(f, 1);
    IF IOResult <> 0 THEN Halt;
    GetRealFileLength := FileSize(f);
    Close(f);
  END;

  PROCEDURE Message;
  BEGIN
    FSplit(ParamStr(0), dummy, Name, dummy);
    WriteLn(^M^J + Name + '-Demoversion:');
    WriteLn('Der interne ProgrammzÑhler ist abgelaufen,');
    WriteLn('besorgen Sie sich eine neue Kopie oder');
    WriteLn('lassen Sie sich registrieren!');
    (*---------------------------------------------------------------*)
    (* hier kînnen weitere Meldungen des Autors wie Verweise auf die *)
    (* Vollversion oder z.B. die Ausgabe eines Bestellformulars ein- *)
    (* gefÅgt werden.                                                *)
    (*---------------------------------------------------------------*)
  END;

BEGIN
  ExeLength := ExeFileLength(ParamStr(0));
  FleLength := GetRealFileLength;
  IF ExeLength = FleLength THEN
  BEGIN
    Assign(ExeFile, ParamStr(0));
    Reset(ExeFile);
    IF IOResult <> 0 THEN Halt;
    Seek(ExeFile, ExeLength);
    WRByte := 1;
    Write(ExeFile, WRByte);
    WRByte := 2;
    Write(ExeFile, WRByte);
    WRByte := 3;
    Write(ExeFile, WRByte);
    Close(ExeFile);
  END
  ELSE
  BEGIN
    Assign(ExeFile, ParamStr(0));
    Reset(ExeFile);
    IF IOResult <> 0 THEN Halt;
    Seek(ExeFile, ExeLength + 1);
    Read(ExeFile, CallCounter);
    IF CallCounter > Calls THEN
    BEGIN
      ClrScr;
      WRByte := 0;
      Seek(ExeFile, 0);
      FOR i := 0 TO 127 DO                   (* Programmkopf lîschen *)
        Write(ExeFile, WRByte);
      Seek(ExeFile, 0);
                              (* ØEXIT zum DOSÆ in Header schreiben: *)
      WRByte := $B4; (* MOV AH, *) Write(ExeFile, WRByte);
      WRByte := $4C; (* 4Ch     *) Write(ExeFile, WRByte);
      WRByte := $CD; (* INT     *) Write(ExeFile, WRByte);
      WRByte := $21; (* 21h     *) Write(ExeFile, WRByte);
      Message;
      Close(ExeFile);
      Assign(ExeFile, ParamStr(0));
      ReWrite(ExeFile);             (* Programm von Platte lîschen:  *)
      Close(ExeFile);               (* DateilÑnge aus FAT gestrichen *)
      (* Wiederherstellung beispielsweise mit den Norton Utilities   *)
      (* nur manuell mîglich (hilft aber nichts)                     *)
      Assign(ExeFile, ParamStr(0));
      Erase(ExeFile);              (* leeren Programmeintrag lîschen *)
      Halt;
    END
    ELSE
    BEGIN
      Seek(ExeFile, ExeLength + 1);
      Inc(CallCounter);
      Write(ExeFile, CallCounter);
      Close(ExeFile);
    END;
  END;
END;

BEGIN
  IF Lo(DosVersion) < 3 THEN         (* ParamStr(0) erst ab DOS 3.xx *)
  BEGIN
    WriteLn('Falsche DOS-Version');
    Halt;
  END;
  Assign(f, ParamStr(0));             (* Programmnamen zuordnen      *)
  GetFAttr(f, FAttr);                 (* Original-Dateiattr. holen   *)
  SetFAttr(f, Archive);               (* nur Archiv-Attribut setzen  *)
  IF DosError <> 0 THEN
  BEGIN
    FSplit(ParamStr(0), dummy, Name, dummy);
    WriteLn('Diskette ist schreibgeschÅtzt!'^M^J'Schreibschutz ' +
            'entfernen und'^M^J + Name + ' erneut aufrufen ...');
    Halt(1);
  END;
  Reset(f);
  GetFTime(f, FTime);
  Close(f);
  DemoVersion;                         (* ZÑhlerprozedur             *)
  Assign(f, ParamStr(0));              (* Datei neu zuordnen ...     *)
  Reset(f);                            (* und nochmals îffnen        *)
  SetFTime(f, FTime);                  (* Original-Datum setzen      *)
  Close(f);                            (* Datei schlie·en            *)
  Assign(f, ParamStr(0));              (* erneut zuordnen            *)
  SetFAttr(f, FAttr);                  (* Originalattribut setzen    *)
END.

(*===================================================================*)
