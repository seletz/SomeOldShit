   {Circle.PAS}

{Beispielcode fÅr die Prozedur Circle }

uses Graph;

var
  Gd, Gm: Integer;
  Radius: Integer;
begin
  Gd := ibm8514;
  gm := ibm8514HI;
  InitGraph(gd, gm, 'c:\tp70\bgi\');
  if GraphResult <> grOk then begin
    writeln('Fehler:',graphresult);
    halt(1);
  end;
  for Radius := 1 to 5 do
    Circle(100, 100, Radius * 10);
  Readln;
  CloseGraph;
end.
