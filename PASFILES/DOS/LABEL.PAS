{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X-,M 16384,0,655360}
(*===================================================================*)
(*                              LABEL.PAS                            *)
(*                    (C) 1993 te-wi Verlag, Mnchen                 *)
(*  Demonstration fr die Funktionen GetLabel und SetLabel der Unit  *)
(*                             DOSUTIL.PAS                           *)
(*===================================================================*)

PROGRAM DosLabel;

USES
  Dos, Upper, Dosutil;

VAR
  Drive      : BYTE;
  Parameter,
  OldVol,
  Dir        : STRING;
  result, i  : INTEGER;

BEGIN
  GetDir(0, Dir);
  Drive := Ord(Dir[1]) - 64;
  IF ParamCount = 0 THEN
  BEGIN
    WriteLn('Bitte das neue Label auf der Kommandozeile angeben!');
    Halt;
  END;
  Parameter := '';
  IF ParamCount > 0 THEN
  BEGIN
    FOR i := 1 TO ParamCount DO
      Parameter := Parameter + ParamStr(i) + ' ';
  END;
  Parameter := UpString(Parameter);
  Parameter[0] := Pred(Parameter[0]);
  Dir := Parameter;
  IF Pos(':', Dir) > 0 THEN
  BEGIN
    Drive := Ord(Dir[1]) - 64;
    Delete(Dir, 1, 2);
  END;
  IF Dir[1] = '\' THEN Delete(Dir, 1, 1);
  OldVol := GetLabel(Drive);
  IF DosError = 18 (* ¯No more files® ist kein Fehler *) THEN
    DosError := 0;
  IF DosError <> 0 THEN WriteLn('Fehler Nummer: ', DosError);
  IF OldVol <> '' THEN
    WriteLn('Volumelabel in Laufwerk ', Chr(Drive + 64) ,
            ' ist ' , OldVol)
  ELSE
    WriteLn('Datentr„ger in ', Chr(Drive + 64) ,
            ' hat keinen Namen');
  IF Dir <> '' THEN
  BEGIN
    result := SetLabel(Drive, Dir);
    IF result = 0 THEN
      WriteLn('Volumelabel in Laufwerk ', Chr(Drive + 64) ,
              ' auf ' , GetLabel(Drive), ' ge„ndert.')
    ELSE
     WriteLn('Falsche Eingabe!');
   END
   ELSE
   BEGIN
     IF SetLabel(Drive, '') = 0 THEN
        Write('Datentr„gernamen gel”scht')
     ELSE
       Write('Fehler beim L”schen des Volume-Namens');
   END;
END.

(*===================================================================*)
