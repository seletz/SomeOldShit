program testmline;
uses graph,sgraph;
var p1,p2:point;
begin
     grafikein;
     p1.x:=200;
     p1.y:=100;
     p2.x:=getmaxx div 2;
     p2.y:=getmaxy div 2;
     mline(p1,p2);
     grafikaus;
end.