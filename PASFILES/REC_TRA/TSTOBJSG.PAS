program testobjsgraph;
uses crt,graph,vectorun,sgraph,objsgraph;
var a,b,c,v,d,a2,b2,c2,v2:vector;
    wuerfel:pyramid;
    i:integer;
procedure kreuz;
var z,i,j,k:vector;
begin
     vzero(z); vzero(i); vzero(j); vzero(k);
     i.x:=15;
     j.y:=15;
     k.z:=15;
     setcolor(3);
     line3d(z,i);
     setcolor(4);
     line3d(z,j);
     setcolor(5);
     line3d(z,k);
end;
begin

     vzero(a);
     vzero(b);
     vzero(c);
     vzero(v);
     vzero(d);
     vzero(a2);
     vzero(b2);
     vzero(c2);
     a.x:=10;
     b.y:=10;
     c.z:=10;
     v2.x:=10;
     v2.y:=10;
     v2.z:=10;
     grafikein;
     setrgbpalette(1,255,255,255);
     init3d(10,10,10,0,0,0,1000,10,10,0);
     kreuz;
     wuerfel.init(v,a,b,c);
     wuerfel.show(1);
     readln;
     wuerfel.hide;
     for i:=1 to 360 do
         begin
              kreuz;
              wuerfel.drehe(i,0,0);
              wuerfel.show(1);
              wuerfel.hide;
         end;
     wuerfel.drehe(0,180,45);
     wuerfel.reset;
     wuerfel.show(1);
     readln;
     wuerfel.hide;
     for i:=1 to 360 do
         begin
              kreuz;
              wuerfel.reset;
              d.x:=cos(rad(i))*15;
              d.z:=sin(rad(i))*15;

              wuerfel.trans(d);
              wuerfel.show(1);
              wuerfel.hide;

         end;
     vzero(d);
     for i:=1 to 360 do
         begin
              kreuz;
              wuerfel.reset;
              d.x:=cos(rad(i))*15;
              d.y:=sin(rad(i))*15;
              wuerfel.trans(d);
              wuerfel.show(1);
              wuerfel.hide;
         end;
     vzero(d);
     for i:=1 to 360 do
         begin
              kreuz;
              wuerfel.reset;
              d.z:=cos(rad(i))*15;
              d.y:=sin(rad(i))*15;

              wuerfel.trans(d);
              wuerfel.show(1);
              wuerfel.hide;
         end;
     wuerfel.show(1);
     readln;
     wuerfel.hide;
     for i:=1 to 360 do
         begin
              init3d(10,10,10,0,0,0,1000,i,0,0);
              kreuz;
              wuerfel.show(1);
              wuerfel.hide;
         end;
     grafikaus;
end.