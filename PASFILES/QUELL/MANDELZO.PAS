program mandelzoom;
uses crt,graph;

const interations=255;

type complex = RECORD
             a,b:real
             end;
var z,c,eckelo,eckeru:complex;
    n,i,j,k,maxx,maxy:integer;
    nr,schritta,schrittb,seitea,seiteb:real;
function betrag(c:complex) : real;
begin
     betrag:=sqrt(sqr(c.a)+sqr(c.b));
end;
procedure csqr(c:complex; var cq:complex);
begin
     cq.b:=2*c.a*c.b;
     cq.a:=sqr(c.a)-sqr(c.b);
end;
procedure cadd(a,b:complex; var ca:complex);
begin
     ca.a:=a.a+b.a;
     ca.b:=a.b+b.b;
end;
procedure csub(a,b:complex; var cs:complex);
begin
     cs.a:=a.a-b.a;
     cs.b:=a.b-b.b;
end;
procedure mandelgrund(z,c:complex; var n:integer);
var nr,b:real;

    v:integer;
begin
     n:=0;

     while (n<interations) and (betrag(z)<2000) do
           begin
                csqr(z,z);
                cadd(z,c,z);
                inc(n);
                if betrag(z)>=2 then inc(v);
                b:=betrag(z);
           end;

end;
procedure grafikein;
var gd,gm,i:integer;
begin
     gd:=ibm8514; gm:=ibm8514hi;
     initgraph(gd,gm,'c:\tp\bgi\');
     for i:=0 to 63 do
         setrgbpalette(i,i*4,0,0);
     for i:=64 to 127 do
         setrgbpalette(i,128,(i-64)*4,128);
     for i:=128 to 191 do
         setrgbpalette(i,0,128,(i-128)*4);
     for i:=192 to 255 do
         setrgbpalette(i,255-(i-192)*4,255-(i-192)*4,255-(i-192)*4);
     for i:=0 to 255 do
         begin
              setcolor(i);
              line(i,getmaxy-50,i,getmaxy);
         end;
end;
procedure grafikaus;
begin
     closegraph
end;
begin
     clrscr;
     writeln('                          MANDELZOOM');
     writeln;
     writeln;
     writeln;
     eckelo.a:=-1.25;
     eckelo.b:=1.5;
     eckeru.a:=1.25;
     eckeru.b:=-1.8;

     maxx:=getmaxx div 3;
     maxy:=getmaxy div 3;

     seitea:=eckeru.a - eckelo.a;
     seiteb:=eckeru.b - eckelo.b;
     schrittb:=seiteb/maxx;
     schritta:=seitea/maxy;

     n:=0;

     grafikein;


     c.a:=eckelo.a;
     for j:=1 to maxx do
         begin
              c.a:=c.a+schritta;
              c.b:=eckelo.b;
              for k:=1 to maxy do
                  begin
                       c.b:=c.b+schrittb;
                       z.a:=0; z.b:=0;
                       mandelgrund(z,c,n);

                       putpixel(j,k,n mod 255);

                  end;
              if keypressed then j:=maxx;
         end;

     repeat until keypressed;

     grafikaus;
end.