program controlit;
uses crt,graph,vectorun,sgraph,objsgraph;
const anzpy=5;
var p: array [1..anzpy] of pyramid;
    a,b,c,v:vector;
    i,j,k:integer;
    u,w:real;
begin
     vzero(a); vzero(b); vzero(c); vzero(v);
     a.x:=10;
     a.y:=0;
     b.x:=0;
     b.y:=10;
     c.z:=10;
     while (u<2*pi) and (i<5) do
           begin
                inc(i);
                u:=u+(2*pi/anzpy);
                v.x:=cos(u)*25;
                v.y:=sin(u)*25;
                p[i].init(v,a,b,c);
           end;

end.