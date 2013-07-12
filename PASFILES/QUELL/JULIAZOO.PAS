program juiliazoom;
uses crt,graph;
type complex = RECORD
             a,b:real
             end;
var z,c,ecke:complex;
    n,i,j,k,max:integer;
    schritt,seite:real;
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
var b:real;
    v:integer;
begin
     n:=0;
     while (n<100) and (betrag(z)<2) do
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
     writeln('                          JuliaZOOM');
     writeln;
     writeln;
     writeln;
     ecke.a:=-1.8;
     ecke.b:=-0.9;
     seite:=1;
     writeln('Alte Werte:');
     gotoxy(15,5); write('a:',ecke.a);
     gotoxy(15,6); write('b:',ecke.b);
     gotoxy(15,8); write('Seite:',seite);

     writeln; readln;

     n:=0;

     max:=500;

     grafikein;

     schritt:=seite / max;
     c.a:=ecke.a-schritt;
     for j:=1 to max do
         begin
              z.a:=z.a+schritt;
              z.b:=ecke.b-schritt;
              for k:=1 to max do
                  begin
                       z.b:=z.b+schritt;

                       mandelgrund(z,c,n);

                       putpixel(j,k,n*3 mod 255);

                  end;
              if keypressed then j:=max;
         end;

     repeat until keypressed;

     grafikaus;
end.