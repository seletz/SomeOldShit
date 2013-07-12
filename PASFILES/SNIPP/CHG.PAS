{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 429 of 473
From : Jon Jasiunas                        1:273/216.0          08 Apr 93  22:20
To   : Steve Mckain
Subj : SetFTime
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
SM> I'm trying to get the correct procedure down for moving a file using
  >BlockRead/Write and then changing the file date/time on the new file to
  >the old file. I can't seem to figure out how to use GetFTime and
  >SetFTime correctly. Any help would be greatly appreciated. }

program Chg;    { no error checking }

uses Crt, Dos;

var
  F    : File;
  Name : String;
  Time : LongInt;
  DT   : DateTime;

begin
  ClrScr;
  Write('File name? ');  ReadLn(Name);
  Assign(F, Name);
  Reset(F);
  GetFTime(F, Time);
  UnPackTime(Time, DT);
  With DT do begin
    WriteLn('File date: ', Month, '/', Day, '/', Year);
    WriteLn('File time: ', Hour, ':', Min, ':', Sec);
  end;
  Writeln;
  With DT do begin
    Write('New Month? ');  ReadLn(Month);
    Write('New Day? ');  ReadLn(Day);
    Write('New Year? ');  ReadLn(Year);
    Write('New Hour? ');  ReadLn(Hour);
    Write('New Minute? ');  ReadLn(Min);
    Write('New Seconds? ');  ReadLn(Sec);
  end;
  PackTime(DT, Time);
  SetFTime(F, Time);
  Close(F);
end.