program mice;
uses crt,graph;
const
      fak=5;
var q,p : array [1..100,1..2] of real;
    h:real;
    n,k,m,mg,gd,gm:integer;
procedure move(x,y:real);
var xx,yy:integer;
begin
     xx:=round(x*fak)+getmaxx div 2;
     yy:=round(y*fak)+getmaxy div 2;
     moveto(xx,yy);
end;
procedure draw(x,y:real);
var xx,yy:integer;
begin
     xx:=round(x*fak)+getmaxx div 2;
     yy:=round(y*fak)+getmaxy div 2;
     lineto(xx,yy);
end;
procedure menue;
var i,anz:integer;
    wstep,w:real;
begin
     repeat
          clrscr;
          writeln('Mice V1.0');
          writeln;
          write('Anzahl der ecken:');
          readln(anz);
     until (anz>0) and (anz<100);

     wstep:=2*pi/anz;

     writeln(wstep);

     while w>(2*pi) do
           begin
                i:=i+1;
                w:=w+wstep;
                p[i,1]:=cos(w)*10;
                p[i,2]:=sin(w)*10;
                writeln(i,' ',w);
           end;

     n:=anz;

end;
begin
     menue;

     gd:=IBM8514;
     gm:=ibm8514hi;
     initgraph(gd,gm,'c:\tp\bgi\');

     h:=0.05;

     for k:=0 to 100 do
         begin
              move(p[n,1],p[n,2]);
              for m:=1 to n do
                  draw(p[m,1],p[m,2]);
              for m:=1 to n do
                  begin
                       mg:=m mod n +1;
                       q[m,1]:=p[m,1]+h*(p[mg,1]-p[m,1]);
                       q[m,2]:=p[m,2]+h*(p[mg,2]-p[m,2]);
                  end;
              for m:=1 to n do
                  begin
                       p[m,1]:=q[m,1];
                       p[m,2]:=q[m,2];
                  end;
         end;

     repeat until keypressed;
     closegraph;
end.