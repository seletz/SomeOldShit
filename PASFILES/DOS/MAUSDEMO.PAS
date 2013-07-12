{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X-,M 16384,0,655360}
(*===================================================================*)
(*                           MAUSDEMO.PAS                            *)
(*         Demonstration der Routinen der Unit MOUSE.PAS             *)
(*            Copyright (C) 1993 te-wi Verlag, MÅnchen               *)
(*===================================================================*)

PROGRAM MouseDemonstration;

USES
  Dos, Graph, Crt, Mouse;

VAR
  gd,  gm : INTEGER;
  s1,  s2 : STRING;
  x, y    : INTEGER;

BEGIN
  DetectGraph(gd, gm);
  InitGraph(gd, gm, GetEnv('BGIPATH'));
  IF GraphResult <> grOk THEN Halt(1);
  Rectangle(49, 49, GetMaxX - 49, GetMaxY - 49);
  SetMouseWindow(50, 50, GetMaxX - 50, GetMaxY - 50);
  DisplayCursor;
  GraphCursor(0, 0, ArrowCursor);
  SetTextJustify(CenterText, CenterText);
  OutTextXY(GetMaxX DIV 2, GetMaxY - 30,
     'Punkte setzen mit linker Maustaste');
  OutTextXY(GetMaxX DIV 2, GetMaxY - 15, 'Ende mit rechter Maustaste');
  SetTextJustify(LeftText, TopText);
  REPEAT
   LeftXY(x, y);
   PutPixel(x, y, LightCyan);
   SetColor(White);
   Str(Mouse.WhereX, s1);
   OutTextXY(10, 10, s1);
   Str(Mouse.WhereY, s2);
   OutTextXY(100, 10, s2);
   SetColor(Black);
   OutTextXY(10, 10, s1);
   OutTextXY(100, 10, s2);
  UNTIL Pressed = Right;
  HideCursor;
  CloseGraph;
END.

(*===================================================================*)
