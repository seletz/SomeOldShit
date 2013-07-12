unit rt_output;
INTERFACE
uses crt, vesa;
const no_graphic=0;
      grau=1;
      farbe=2;
type  output = Object
                     m,dx,dy:integer;
                     destructor done;
                     constructor init(mode:integer; breite,hoehe:integer);
                     procedure put(x,y:integer; r,g,b:double);
               end;
IMPLEMENTATION
destructor output.done;
begin
     textmode(c80 + font8x8);
end;
constructor output.init;
var i:integer;
    h,s,v,r,g,b:real;
begin
     m:=mode;
     if m<>no_graphic then begin
        setmode(mode_640x480x16m);
        dx:=round((vesarec. width-4) / (breite));
        dy:=round((vesarec. height-4) / ( hoehe));
     end;
end;
procedure output.put;
var
	rr,gg,bb:byte;
begin
	rr:= round($ff*r);
	gg:= round($ff*g);
	bb:= round($ff*b);
	setpix(x,y, rgb(rr,gg,bb) );
end;

begin
end.