(*
PPRG1 - öBUNG 1 - ELETZHOFER STEFAN 05-04-1995

.....*
....***
...*****
..*******
.*********
***********
....***
....***

so solls aussehen; zeilen=6

Spitze:
        Punkte:={5,4,3,2,1,0} => Punkte(n):={z-1,z-2,...,z-n};
        n: aktuelle Zeile; z: Zeilen gesamt;
	Sterne:={1,3,5,7,9,11} => Sterne(n):={(n-1)*2+1};

dÅnner Teil:
        Spaces:=(2*zeilen-1) div 2 - 1;
        dann drei Sterne

*)
program spitze;
uses crt;
type
	zeilen_typ= 5..17;
var
   zeilen:zeilen_typ;     { wieviele Zeilen ? }
   i,j,k,n:integer;       { schleifenvar }
begin
     i:=0; j:=0; k:=0; n:=0; zeilen:=5;

     clrscr;
     write('Zeilen (5..17)');
     readln(zeilen);

     for i:=1 to zeilen do
     begin
          n:=zeilen-i; { anzahl der Punkte in dieser zeile }
          for j:= 1 to n do write('.');    { Punkte ausgeben }
          n:=(i-1)*2+1;{ anzahl der Sterne }
          for j:=1 to n do write('*');     { Sterne ausgeben }
          writeln; { Leerzeile }
     end;
     for i:= 1 to 2 do
     begin
          n:=(2*zeilen-1) div 2 - 1;
          for j:=1 to n do write('.');  { Punkte }
          writeln('***');               { Sterne und CRLF }
     end;

     writeln;
     writeln('Taste drÅcken.');
     readln;
end.