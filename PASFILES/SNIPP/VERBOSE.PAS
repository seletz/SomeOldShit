{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 473 of 523
From : Justin Marquez                      1:106/100.0          27 Apr 93  10:40
To   : All
Subj : Fido .MSG header example
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Program VERBOSITY_INDEX;
{ Reads a FidoNet *.MSG file areas and logs info about authorship and
  "verbosity" found in the messages.

  Requires Turbo Pascal 7.xx or Borland Pascal 7.xx (for the STRINGS unit)

  OutPut is redirectable.  Can be quickly sorted with DOS's SORT.COM
  Here is a batch file you may find useful:

rem YAK.BAT
verbose %1 > zap.txt
sort < zap.txt > yak.txt /+37 /R
del zap.txt

   This program is written by Justin Marquez, FidoNet 106/100
   It is being donated to all as a PUBLIC DOMAIN program, which may be
   freely used, copied and modified as you please.

   "If you improve on it, I'd like a copy of the modifications for my
   own edification!"
}

Uses Strings,
     DOS;

TYPE
  FidoMessageHeader = Record
    FromUser  : Array[0..35] of Char ;
    ToUser    : Array[0..35] of Char ;
    Subject   : Array[0..71] of Char ;
    DateTime  : Array[0..19] of Char ;
    TimesRead : Word ;
    DestNode  : Word ;
    OrigNode  : Word ;
    Cost      : Word ;
    OrigNet   : Word ;
    DestNet   : Word ;
    Filler    : Array[0..7] of Byte ;
    Replyto   : Word ;
    Attribute : Word ;
    NextReply : Word ;
  End;

  Entry = record
    Author : string[36];
    Count  : integer;
    Bytes  : longint;
  End;

VAR
   MsgDir,
   fn       : string;
   SR       : SearchRec;
   tmp      : FidoMessageHeader;
   Who_From : string[36];
   n,
   i        : integer;
   HiNum    : integer;
   rec      : Array [1..512] of Entry;
   TotBytes : LongInt;

Procedure GetMsgInfo (fname:string; VAR Hdr:FidoMessageHeader);
Var
   HFile : file of FidoMessageHeader;
   MFile : Text;
Begin
  FillChar(Hdr,SizeOf(Hdr),#0);  { clear it out initially }
  { get msg hdr only }
  Assign(Hfile,fname);
   Reset(HFile);
   Seek(Hfile,0);
   Read(Hfile,Hdr);
  Close(Hfile);
End;

Procedure Pad_Path(Var s:string);
Begin
  if s[length(s)] = '\'
  then
  else
    s := s+'\';
End;

Procedure Process_Name;
Var
  k : integer;
  Found : Boolean;
Begin
  Found := FALSE;
  if n > 0
  then begin
       for k := 1 to n do begin
         if Who_From = rec[k].author then begin
           inc(rec[k].count);
           rec[k].Bytes := rec[k].Bytes + SR.Size;
           Found := TRUE;
         end;
       end;
  end
  else begin
       rec[1].author := Who_From;
       rec[1].count  := 1;
       rec[1].Bytes := rec[1].Bytes + SR.Size
  end;
  If NOT Found then begin
    inc(n);
    Rec[n].Author := Who_From;
    Rec[n].Count  := 1;
    rec[n].Bytes := rec[n].Bytes + SR.Size;
  end;
End;

Procedure Intro_And_Init;
Begin
  FillChar(rec,SizeOf(rec),#0);  { clear it out initially }
  HiNum    := 0;
  TotBytes := 0;
  n        := 0;
  If ParamCount > 0
  then
    MsgDir := ParamStr(1)
  else
    begin
      WriteLn(' VERBOSE <path> >');
      WriteLn('EXAMPLE:');
      WriteLn;
      WriteLn('VERBOSE C:\OPUS\HOUSYSOP\ ');
      WriteLn(' reads all msg files in the area and reports findings.');
      WriteLn;
      WriteLn(' Note: can be redirected to a file or device.');
      WriteLn;
      WriteLn('Public Domain from 106/100. Request as VERBOSE.ZIP.');
      Halt(2);
    end;
End;

Procedure Process_Files;
Begin
  Pad_Path(MsgDir);
  fn := MsgDir+'*.MSG';
  FindFirst(fn, AnyFile, SR);
  while DosError = 0 do
  begin
    fn        := MsgDir+SR.Name;
    GetMsgInfo (fn,tmp);
    Who_From  := '';
    Who_From  := StrPas( StrUpper(tmp.FromUser) );
    Inc(HiNum);
    TotBytes := TotBytes + SR.Size;
      Process_Name;
    FindNext(SR);
  end;
End;

Procedure Report_Results;
Begin
  for i := 1 to n do
    WriteLn(rec[i].Author:36,Rec[i].Count:4,(100*Rec[i].Count/HiNum):6:1,'% ',
            Rec[i].Bytes:6, ' bytes or',(100*Rec[i].Bytes/TotBytes):5:1,
            '% by size' );
  WriteLn(' Total messages found: ':36,HiNum:4);
  WriteLn(' Total bytes found   : ':36,TotBytes:18);
  WriteLn(n,' different writers found in ',MsgDir,'.');
End;

BEGIN
  Intro_And_Init;
  Process_Files;
  Report_Results;
END.