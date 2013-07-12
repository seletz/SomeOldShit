program mice;
uses crt,graph;
const n=5;
      fak=5;
var q,p : array [1..n,1..2] of real;
    h:real;
    k,m,mg,gd,gm:integer;
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
begin
     gd:=IBM8514;
     gm:=ibm8514hi;
     initgraph(gd,gm,'c:\tp\bgi\');

     p[1,1]:=-40;
     p[1,2]:=-45;

     p[2,1]:=40;
     p[2,2]:=-45;

     p[3,1]:=70;
     p[3,2]:=30;

     p[4,1]:=0;
     p[4,2]:=80;

     p[5,1]:=-70;
     p[5,2]:=30;

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