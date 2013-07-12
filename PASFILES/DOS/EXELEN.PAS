{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X-,M 16384,0,0}
(*===================================================================*)
(*                            EXELEN.PAS                             *)
(*            Copyright (C) 1993 te-wi Verlag, MÅnchen               *)
(* Demoprogramm fÅr die Funktionen GetFileLenFromHeader: LongInt und *)
(*          GetRealFileLength: LongInt der UNIT HuckePack            *)
(*===================================================================*)

PROGRAM EXE_Laengen_Test;

USES
  HuckePack, 
  Dos;

VAR
  prg    : PathStr;
  v1, v2 : LONGINT;
  count  : BYTE;
  ExePath: DirStr;
  ExeNam : NameStr;
  ExeExt : ExtStr;

BEGIN
  IF ParamCount < 1 THEN
    Write('EXELEN v 1.0, (C) 1990 J. Braun'
    + Chr(13) + Chr(10) + 
    'Aufruf: EXELEN EXENAME[.EXE]')
  ELSE
  BEGIN         (* weitere Fehler werden in 'Huckepack' abgefangen!  *)
    prg := ParamStr(1);
    FOR count := 1 TO Length(prg) DO
      prg[count] := UpCase(prg[count]);
    FSplit(prg, ExePath, ExeNam, ExeExt);
    IF ExeExt = '' THEN prg := prg + '.EXE';
    ExeName := prg;
    v1      := GetRealFileLength;
    v2      := GetFileLenFromHeader;
    WriteLn(Chr(13) + Chr(10) + 
            'Programmdatei                : ', ExeNam: 10, '.EXE');
    WriteLn('Effektive LÑnge der Datei    : ', v1 :8, ' Bytes');
    WriteLn('Im EXE-Header vermerkte LÑnge: ', v2 :8, ' Bytes');
  END;
END.
(*===================================================================*)
