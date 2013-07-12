unit tga;
INTERFACE
uses crt,graph,sgraph,colors;
const grau=0;
      farbe=1;
type  TGAfile = Object
                     m,dx,dy:integer;
                     destructor done;
                     constructor init(mode:integer; breite,hoehe:integer);
                     procedure output(x,y:integer; r,g,b:byte);
               end;
IMPLEMENTATION
destructor TGAfile.done;
begin
     grafikaus;
end;
constructor TGAfile.init(mode:integer; breite,hoehe:integer);
var i:integer;
    h,s,v,r,g,b:real;
begin
     m:=mode;
     grafikein;
     dx:=getmaxx div (breite-1);
     dy:=getmaxy div (hoehe-1);

     case m of
          farbe: init_palette_farbe;
          grau:  init_palette_grau;
     end;
end;
procedure TGAfile.output(x,y:integer; r,g,b:byte);
VAR gr:integer;
begin
        case m of
             farbe: convert(r/255,g/255,b/255,gr);
             grau:  gr:=(r+g+b)div 3;
        end;

        setcolor(gr);
        setfillstyle(SolidFill,gr);
        bar(x*dx,y*dy,(x+1)*dx,(y+1)*dy);
end;

begin
end.