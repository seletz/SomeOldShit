{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X-,M 16384,0,0}

(*===================================================================*)
(*                            EXEGR.PAS                              *)
(*                 Copyright (C) 1993 te-wi Verlag                   *)
(*-------------------------------------------------------------------*)
(*  Demoprogramm, das seine effektive und die im Header angegebene   *)
(*                    L„nge ermittelt und ausgibt                    *)
(*===================================================================*)
(* Aufbau des EXE-Header (hierfr relevante Daten):                  *)
(* Byte_1 = "M"     = erstes Byte der Kennung                        *)
(* Byte_2 = "Z"     = zweites Byte der Kennung                       *)
(* Dateigr”áeinByte = ((Byte_6*256+Byte_5)-1)*512+(Byte_4*256+Byte_3)*)
(*-------------------------------------------------------------------*)
(* Die Daten im Exe-Header k”nnen dafr genutzt werden, um beim An-  *)
(* h„ngen zus„tzlicher Bin„rdateien (beispielsweise mit COPY/B) an   *)
(* das Programm selbst (OVL-Simulation) die Position dieser zus„tz-  *)
(* lich angeh„ngten Daten zu finden (Addition der EXE-Gr”áe).        *)
(* Die Funktion GetFileLenFromHeader bergibt immer die L„nge des    *)
(* vom Linker erstellten Programms zurck. Die L„nge der Datei, die  *)
(* durch Anh„ngen von anderen (Daten-Dateien) entstanden ist, kann   *)
(* einfach durch ™ffnen der Datei als untypisierte Datei mit einer   *)
(* Recordl„nge von 1 ermittelt werden.                               *)
(* Ausprobiert k”nnen die Demofunktionen im Programm dadurch, daá    *)
(* man an das Programm EXEGR.EXE eine beliebige andere Datei anh„ngt:*)
(* COPY/B EXEGR.EXE+TURBO.PCK TEST.EXE                               *)
(* Es wird einmal die ursprngliche L„nge von EXEGR.EXE ausgegeben   *)
(* und zus„tzlich noch die effektive Dateil„nge.                     *)
(* Trotz der L„ngen„nderung ist das Programm voll lauff„hig, da im   *)
(* Gegensatz zu .COM-Dateien die Codel„nge vom Linker festgelegt     *)
(* wird und nicht aus der Dateil„nge errecht ist. Sp„tere Žnderungen *)
(* werden deshalb ignoriert. Den selben Effekt machen sich auch      *)
(* Linkviren zunutze. šber diesen Effekt kann deshalb auch ein in    *)
(* ein Programm eingebauter Virentest arbeiten:                      *)
(* 1. Test der Dateil„nge ber GetFileLenFromHeader.                 *)
(* 2. Test der Dateil„nge ber FileSize bei Recordl„nge 1            *)
(* Bei nicht modifizierten Programmen mssen beide Werte gleich sein.*)
(*===================================================================*)

PROGRAM GetMyLength;

USES
  DosUtil;

VAR
  ExeFile: FILE;
  FSize,
  ExeLen : LONGINT;

BEGIN
  WriteLn('Programmdatei      :  ', ParamStr(0));
  ExeLen := ExeFileLength(ParamStr(0));
  IF ExeLen > 0 THEN
  BEGIN
    WriteLn('Programml„nge      : ', ExeLen:6, ' Bytes');
    Assign(ExeFile, ParamStr(0));
    Reset(ExeFile, 1);
    FSize := FileSize(ExeFile);
    WriteLn('Echte Dateil„nge   : ', FSize:6, ' Bytes');
    Close(ExeFile);
    WriteLn('Angeh„ngter Bereich: ', (FSize - FSize):6, ' Bytes');
  END
  ELSE
    WriteLn('Diese Datei ist kein gltiges Exe-Programm');
    (* --> Diese Meldung ist recht unwahrscheinlich, da das Programm *)
    (* nur dann startet, wenn es ein echtes Exe-File ist.            *)
END.

(*===================================================================*)
