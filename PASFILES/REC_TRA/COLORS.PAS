unit colors;
INTERFACE
uses graph;
procedure convert(r,g,b:real; var c:integer);
procedure rgb_to_hsv(r,g,b:real; var h,s,v:real);
procedure hsv_to_rgb(h,s,v:real; var r,g,b:real);
procedure init_palette_farbe;
procedure init_palette_grau;
IMPLEMENTATION
const UNDEFINED:real=0;
function maximum(a,b,c:real):real;
begin
     if a<=b then begin
        if b<=c then maximum:=c else maximum:=b;
     end else begin
         if a<=c then maximum:=c else maximum:=a;
     end;
end;
function minimum(a,b,c:real):real;
begin
     if a>=b then begin
        if b>=c then minimum:=c else minimum:=b;
     end else begin
         if a>=c then minimum:=c else minimum:=a;
     end;
end;
procedure init_palette_grau;
var i:integer;
begin
     for i:=0 to 255 do setrgbpalette(i,i,i,i);
end;
procedure init_palette_farbe;
var i:integer;
    h,s,v,r,g,b:real;
begin
     setrgbpalette(0,0,0,0);
     setrgbpalette(64,255,255,255);
     setrgbpalette(128,153,153,153);
     setrgbpalette(192,76,76,76);

     for i:=1 to 63 do
         begin
              s:=0.5;
              v:=0.5;
              h:=360*i/64;

              hsv_to_rgb(h,s,v,r,g,b);
              setrgbpalette(i,round(r*255),round(g*255),round(b*255));

              s:=1;
              v:=0.5;

              hsv_to_rgb(h,s,v,r,g,b);
              setrgbpalette(i+64,round(r*255),round(g*255),round(b*255));

              s:=0.5;
              v:=1;

              hsv_to_rgb(h,s,v,r,g,b);
              setrgbpalette(i+128,round(r*255),round(g*255),round(b*255));

              s:=1;
              v:=1;

              hsv_to_rgb(h,s,v,r,g,b);
              setrgbpalette(i+192,round(r*255),round(g*255),round(b*255));
         end;
end;

procedure rgb_to_hsv;
var delta,max,min:real;
begin
     max:=maximum(r,g,b);
     min:=minimum(r,g,b);
     v:=max;

     if max<>0 then
        s:=(max-min)/max
     else s:=0;

     if s=0 then
        h:=UNDEFINED
     else begin
          delta:=max-min;

          if r=max then
             h:=(g-b)/delta
          else if g=max then
             h:=2+(b-r)/delta
          else if b=max then
             h:=4+(r-g)/delta;

          h:=h*60;
          if h<0 then h:=h+360;
     end;
end;
procedure hsv_to_rgb;
var i,f,p,q,t:real;
begin
     if s=0 then
        if h=UNDEFINED then
           begin
                r:=v;
                h:=v;
                b:=v;
           end
        else begin writeln('hsv_to_rgb: s=0 und h<>0 !'); halt(255) end
     else
         begin
              if h=360 then h:=0;

              h:=h/60;
              i:=int(h);
              f:=frac(h);
              p:=v*(1-s);
              q:=v*(1-(s*f));
              t:=v*(1-(s*(1-f)));
              case round(i) of
                   0: begin r:=v; g:=t; b:=p end;
                   1: begin r:=q; g:=v; b:=p end;
                   2: begin r:=p; g:=v; b:=t end;
                   3: begin r:=p; g:=q; b:=v end;
                   4: begin r:=t; g:=p; b:=v end;
                   5: begin r:=v; g:=p; b:=q end;
              end;
         end;
end;

procedure convert;
var h,s,v:real;
begin
     rgb_to_hsv(r,g,b,h,s,v);
     if v<0.2 then
        if v<0.25 then
           c:=0
        else if v>0.8 then
             c:=64
        else if v>0.5 then
             c:=192
        else c:=128
     else begin
          c:=round(64*h/360);
          if c=0 then c:=1;
          if c>63 then c:=63;

          if v>0.5 then c:=c or $80;
          if s>0.5 then c:=c or $40;
     end;
end;

begin
end.