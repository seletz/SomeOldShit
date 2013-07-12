program ste_test;
uses crt,ste,graph;
var v1,v2:view;
    x,y:real;
    w,xx,yy:integer;
begin
     clrscr;
     grafikein;

     v1.init(100,100,300,300);
     v2.init(500,100,300,300);

     for w:=0 to 360 do begin

         y:=150 + sin(w*pi/180)*100;
         x:=w/360*300;

         putpixel(v1.cx(x),v1.cy(y),3);
         putpixel(v2.cx(x),v2.cy(y),2);

     end;
     v1.rahmen;
     v2.rahmen;
     waittast;

     v1.convert(150,150,xx,yy);
     circle(xx,yy,100);

     v2.convert(150,150,xx,yy);
     circle(xx,yy,100);
     putpixel(xx,yy,1);
     xx:=getpixel(xx,yy);
     waittast;
     grafikaus;

     writeln(xx);
end.