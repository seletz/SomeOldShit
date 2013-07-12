program chaos1;
uses crt,graph;
var x,r,step,k:real;
    i,j,xk,yk:integer;
procedure grafikein;
var gd,gm:integer;
begin
     gd:=ibm8514; gm:=ibm8514hi;
     initgraph(gd,gm,'c:\tp70\bgi\');
end;
procedure grafikaus;
begin
     closegraph
end;
begin
     grafikein;
     x:=0.3;
     r:=2.95;
     step:=(4-2.95)/getmaxx;
     k:=getmaxx/(4-2.95);
     writeln(step,' ',k);

     repeat
           r:=r+step;
           x:=0.3;
           for i:=1 to getmaxy do
               x:=r*x*(1-x);
           for i:=1 to getmaxy do
               begin
                    x:=r*x*(1-x);
                    xk:=round(k*(r-2.95));
                    yk:=round(getmaxy*x);
                    if not ((xk>getmaxx) or (yk>getmaxy)) then
                      putpixel(xk,yk,1);
               end;
           if keypressed then r:=100;
     until (r>4) ;

     repeat until keypressed;
     grafikaus;
end.