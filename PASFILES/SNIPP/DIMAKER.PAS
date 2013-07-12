{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 596 of 708
From : Reynir Stefansson                   2:391/20.0           14 Apr 93  17:33
To   : All
Subj : DOORINFO.DEF maker.
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
     Some time ago I looked at the Waffle BBS v1.63. I wrote this proglet
to create a DOORINFO file for certain aftermarket utilities. Here you are:}

PROGRAM DIMaker; {Writes DOORINFO.DEF/DORINFOn.DEF for Waffle BBS. }

VAR tf : TEXT; Graphic : INTEGER; Port : CHAR; SysName, SysOpFirst, SysOpLast,
    Baud, Terminal, First, Last, CallLoc, TimeLeft, SecLev, FossilOn,
    SysDir, FileName : STRING;

{ Command line for Waffle: }

{ dimaker ~%b ~%t ~%O ~%a ~%F ~%A@~%n ~%L -1 [-|n] }

PROCEDURE WriteDorInfo;
BEGIN
   Assign(tf, SysDir+FileName+'.DEF');
   Rewrite(tf);
   WriteLn(tf, SysName);                { BBS name }
   WriteLn(tf, SysOpFirst);             { SysOp's first name }
   WriteLn(tf, SysOpLast);              { SysOp's last name }
   WriteLn(tf, 'COM', Port);            { COMport in use }
   WriteLn(tf, Baud, ' BAUD,8,N,1');    { Speed and char format }
   WriteLn(tf, '0');                    { ? }
   WriteLn(tf, First);                  { User's first name }
   WriteLn(tf, Last);                   { User's last name }
   WriteLn(tf, CallLoc);                { User's location }
   WriteLn(tf, Graphic);                { 1 if ANSI, 0 if not. }
   WriteLn(tf, SecLev);                 { Security level }
   WriteLn(tf, TimeLeft);               { Time until kick-out }
   WriteLn(tf, FossilOn);               { -1 if using FOSSIL, 0 if not }
   Close(tf);
END;

{ Don't let my reusing of variables disturb you. }
PROCEDURE GatherInfo;
BEGIN
   FileName[1] := '-';
   SysName := ParamStr(0);
   Graphic := Length(SysName);
   REPEAT Dec(Graphic) UNTIL SysName[Graphic]='\';
   SysDir := Copy(SysName, 1, Graphic);
   Assign(tf, Copy(SysName, 1, Length(SysName)-4)+'.CFG');
   Reset(tf);
   ReadLn(tf, SysName);
   ReadLn(tf, SysOpFirst);
   ReadLn(tf, SysOpLast);
   Close(tf);
   Baud     := ParamStr(1);
   Terminal := ParamStr(2);
   TimeLeft := ParamStr(3);
   SecLev   := ParamStr(4);
   First    := ParamStr(5);
   Last     := ParamStr(6);
   CallLoc  := ParamStr(7);
   FossilOn := ParamStr(8);
   FileName := ParamStr(9);
   Port := FileName[1];
   IF Port='-' THEN FileName := 'DOORINFO' ELSE FileName := 'DORINFO'+Port;
   IF Terminal='vt100' THEN Graphic := 1 ELSE Graphic := 0;
   Port := '2';
   IF Baud='LOCAL' THEN BEGIN Baud := '0'; Port := '0'; END;
END;

BEGIN;
   GatherInfo;
   WriteDorInfo;
END.