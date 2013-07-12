{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 663 of 702
From : MIKE COPELAND                       1:114/151.0          21 Apr 93  22:13
To   : JON RUPERT
Subj : SECONDS TO H:M:S
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
 JR> I'm looking for some FAST routines to change seconds into a
 JR> readable format, (ie. H:M:S).

 JR> For instance, 8071 seconds = 2:14:31

   Here's the code I use, and it's fast enough for me: }

function FORMAT_TIME (V : integer) : STR8; { format time as hh:mm:ss }
var X,Z   : integer;
    PTIME : STR8;
begin                            { note: incoming time is in seconds }
  Z := ord('0'); PTIME := '  :  :  ';                   { initialize }
  X := V div 3600; V := V mod 3600;                  { process hours }
  if (X > 0) and (X <= 9) then PTIME[2] := chr(X+Z)
  else if X = 0 then PTIME[3] := ' '                 { zero-suppress }
       else          PTIME[2] := '*';                  { overflow... }
  X := V div 60; V := V mod 60;                    { process minutes }
  PTIME[4] := chr((X div 10)+Z); PTIME[5] := chr((X mod 10)+Z);
  PTIME[7] := chr((V div 10)+Z);                   { process seconds }
  PTIME[8] := chr((V mod 10)+Z); FORMAT_TIME := PTIME
end;  { FORMAT_TIME }