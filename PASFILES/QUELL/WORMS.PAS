program worms;
uses crt,graph;
type worm = RECORD
          schwanz:integer;
          ri:integer;
          wc:integer;
          wc0:integer;
          koo : array [1..25,1..2] of integer;
          END;
var i,j,k,gmx,gmy:integer;
    w : array [1..10] of worm;
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
end;
procedure grafikaus;
begin
     closegraph
end;
procedure addmod(var i:integer; b:integer);
begin
     i:=i+1;
     if i>b then i:=1;
end;
procedure modulo(var i:integer; b:integer);
begin
     if i>b then i:=1;
     if i<1 then i:=b;
end;
procedure moveworm(var a:worm);
var i:real;
    j,x,y,xx,yy:integer;
begin
     with a do
          begin
               addmod(schwanz,25);
               setcolor(wc0);
               circle(koo[schwanz,1],koo[schwanz,2],3);

               i:=random;
               if i>0.5 then ri:=ri+10 else ri:=ri-10;

               j:=schwanz-1;
               if j<=0 then j:=25;
               x:=koo[j,1];
               y:=koo[j,2];

               xx:=x+round(8*cos((ri+1)*pi/180));
               yy:=y+round(8*sin((ri+1)*pi/180));
               if getpixel(x,y)<>0 then ri:=ri+120;


               koo[schwanz,1]:=(x+round(4*cos((ri+1)*pi/180)));
               modulo(koo[schwanz,1],gmx);
               koo[schwanz,2]:=(y+round(4*sin((ri+1)*pi/180)));
               modulo(koo[schwanz,2],gmy);

               setcolor(wc);
               circle(koo[schwanz,1],koo[schwanz,2],3);
          end;
end;
begin
     randomize;
     grafikein;
     gmx:=getmaxx; gmy:=getmaxy;
     for i:=1 to 10 do
         begin
              with w[i] do
                   begin
                        wc0:=0;
                        wc:=random(64);
                        schwanz:=1;
                        koo[1,1]:=random(gmx);
                        koo[1,2]:=random(gmy);
                   end;
         end;
     setcolor(100);
     i:=0;
     while not keypressed do
           begin
                addmod(i,10);
                moveworm(w[i]);
           end;
     grafikaus;
end.