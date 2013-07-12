program ball;
uses crt,graph,sgraph,vectorun;
const xmax:integer=160;
      ymax:integer=100;
      pixb=10;
      pixh=10;
      p:vector=(x:50; y:50; z:25);
      h:vector=(x:10; y:10; z:10);

type  view = object
             pp,hp:vector;
             dph:real;
             alpha,beta,gamma:winkel;
             constructor init(ip,ih:vector);
             destructor done;
             procedure setph(ip,ih:vector);
             procedure setabg(ia,ib,ig:winkel);
             function gimmealpha:winkel;
             function gimmebeta:winkel;
             function gimmegamma:winkel;
             procedure gimmepp(var op:vector);
             procedure gimmehp(var hp:vector);
             function gimmedph:real;
             end;


var x,y:integer;

begin
     x:=0; y:=0;
     repeat
         repeat
                  writeln('X:',x:3,' Y:',y:3);
                  x:=x+pixb;
         until x>xmax;
         x:=0;
         y:=y+pixh;
     until y>ymax;
end.