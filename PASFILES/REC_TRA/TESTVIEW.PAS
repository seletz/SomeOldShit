program testview;
uses crt,ste,graph;
var vp1,vp2:viewporttype;
    i:integer;
begin
     grafikein;
     setviewport(100,100,500,500,ClipOn);
     for i:=1 to 10 do circle(300,300,i*50);
     setviewport(600,100,1000,500,ClipOn);
     for i:=1 to 10 do circle(200,200,i*50);
     waittast;
     grafikaus;
end.