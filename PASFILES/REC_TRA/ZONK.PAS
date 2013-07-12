unit zonk;
INTERFACE
uses graph;
type point = record
             x,y:double;
             end;

     rectP = ^rect;
     rect = object
                  a,b,lo,ro,lu,ru:point;
                  constructor init(ia,ib:point);
                  function innerhalb(p:point):boolean;
            end;

     viewportp = ^viewport;
     viewport = object
                      bereich:rectp;
                      constructor init(ib:rectp);
                      procedure rahmen;
                      procedure plot(p:point; c:integer);
                      procedure line(a,b:point; c:integer);
                end;

IMPLEMENTATION

     constructor rect.init;
     begin
          a:=ia; b:=ib; lo:=a; ru:=b; ro.x:=b.x; ro.y:=a.y; lu.x:=a.x; lu.y:=b.y;
     end;
     function rect.innerhalb(p:point):boolean;
     begin
          if (p.x<a.x) and (p.y>a.y) and (p.x<b.x) and (p.y<b.y) then innerhalb:=true else innerhalb:=false
     end;

     constructor viewport.init; begin bereich:=ib end;
     procedure viewport.rahmen;
     begin
          with bereich^ do begin
               viewport.line(lo,ro,255);
               viewport.line(ro,ru,255);
               viewport.line(ru,lu,255);
               viewport.line(lu,lo,255);
          end;
     end;
     procedure viewport.plot;
     begin
          if bereich^.innerhalb(p) then
             putpixel(round(p.x),round(p.y),c);
     end;
     procedure viewport.line;
     begin
     end;

begin
end.