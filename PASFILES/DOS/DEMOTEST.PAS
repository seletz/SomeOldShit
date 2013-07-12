{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X-,Y-,M 1024,0,0}
(*===================================================================*)
(*                            DEMOTEST.PAS                           *)
(*                 Copyright (C) 1993 te-wi Verlag                   *)
(*-------------------------------------------------------------------*)
(*               Demonstration fÅr die Unit DEMOFILE                 *)
(*===================================================================*)

PROGRAM DemoForDemofileUnit;
{$DEFINE demo}                        { <-- bei Vollversion weglassen }
USES
  Crt {$IFDEF demo}, DemoFile {$ENDIF};

BEGIN
 {$IFDEF demo}
   Write ('Dies ist ein Test fÅr die UNIT ''DEMOFILE''');
 {$ELSE}
   Write('Dies ist die Vollversion von DEMOTEST ohne ProgrammzÑhler!');
 {$ENDIF}
END.

(*===================================================================*)
