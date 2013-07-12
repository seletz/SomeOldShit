unit tga;
INTERFACE
uses crt,graph,sgraph,colors;
const grau=0;
      farbe=1;
type  TGAfile = Object
                     filename:string;
                     m,dx,dy:integer;
                     destructor done;
                     constructor init(fn:string; mode:integer; breite,hoehe:integer);
                     procedure output(x,y:integer; r,g,b:byte);
               end;
      TGAREC = record
                       indent_len,
                       cmap_type,
                       image_type:byte;
                       cmap_orgin,
                       cmap_len:integer;
                       centry_size:byte;
                       image_xorg,
                       image_yorg,
                       image_width,
                       image_height:integer;
                       pixel_size,
                       image_discr:byte;
                     data : array [0..1,0..1] of byte;
               end;
IMPLEMENTATION
destructor TGAfile.done;
begin
     grafikaus;
end;
constructor TGAfile.init(fn:string; mode:integer; breite,hoehe:integer);
var i:integer;
    h,s,v,r,g,b:real;
begin
     filename:=fn;
     m:=mode;
     grafikein;
     dx:=getmaxx div (breite);
     dy:=getmaxy div (hoehe);

     case m of
          farbe: init_palette_farbe;
          grau:  init_palette_grau;
     end;
        setfillstyle(SolidFill,64);
        bar(0,0,getmaxx,getmaxy);
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