program colors;
uses crt,graph,sgraph;
const coffset=5;
type color = record r,g,b:real; end;
procedure putcolor(r,g,b:real; x,y:integer);
begin
     putpixel(x,y,round(b*5)*36+round(g*5)*6+round(r*5)+coffset);
end;
procedure setc(r,g,b:real);
begin
     setcolor(round(b*5)*36+round(g*5)*6+round(r*5)+coffset);
end;
var c:color;
    ic,ir,ig,ib:integer;
    r,g,b:real;
    i,j:real;
begin
     grafikein;
     clrscr;
     i:=0; j:=1/5;
     ic:=0+coffset;
     for ib:=0 to 5 do begin
         for ig:=0 to 5 do begin
             for ir:=0 to 5 do begin
                 setrgbpalette(ic, round(255*ir*j),
                                   round(255*ig*j),
                                   round(255*ib*j));
             end;
         end;
     end;
     for ib:=0 to 5 do begin
         for ig:=0 to 5 do begin
                 setc(ir*j,ig*j,0);
                 bar(ir*10,ig*10,ir*10+10,ig*10+10);
         end;
     end;
     readln;
     grafikaus;
end.