program cluster;
uses crt,graph,sgraph,vectorun;
const g=39;
      maxstars=20;
      r:real=500;
      zoom:real=10;
      epsilon=0.1;
      textm=false;
      graphic=true;
      trails=false;
      minx=10;
      maxx=1000;
      miny=10;
      maxy=750;
      fill:fillpatterntype=($FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF);
type  point = record x,y,z:real end;
      star = record a,v,pos:vector; m:real; c:integer; end;
var stars : array [1..maxstars] of star;
    null:vector;
    k:char;
    ende:boolean;


function inrange(i,u,o:real):boolean;
begin
     inrange:=((i>u) and(i<o));
end;
function scalex(x:real):real;
begin
     if inrange((maxx-minx)/2+x,minx,maxx) then
        scalex:=(maxx-minx)/2+x
     else begin
        scalex:=0
     end;
end;

function scalew(w:real):real;
begin
     if inrange(w,-2*pi,2*pi) then
        scalew:=w
     else begin
        if w>2*pi then w:=-2*pi;
        if w<(-2*pi) then w:=2*pi-w;
        scalew:=w
     end;
end;

function scaley(y:real):real;
begin
     if inrange((maxy-miny)/2+y,miny,maxy) then
        scaley:=(maxy-miny)/2+y
     else begin
        scaley:=0
     end;
end;
procedure clear;
begin  bar(0,0,getmaxx,getmaxy) end;

procedure clearstars;
var i:integer;
begin
     if graphic then begin
        for i:=1 to maxstars do begin
              putpixel(round(scalex(stars[i].pos.x/zoom)),
                      round(scaley(stars[i].pos.y/zoom)),0);
     	end;
     end;
end;

procedure drawstars;
var i,j:integer;
begin
     if textm=true then begin
     clrscr;
     for i:=1 to maxstars do begin
         writeln('Stern:',i);
         write('X:',stars[i].pos.x:3:3,'  ');
         write('Y:',stars[i].pos.y:3:3,'  ');
         writeln('Z:',stars[i].pos.z:3:3);
         write('VX:',stars[i].v.x:3:3,'  ');
         write('VY:',stars[i].v.y:3:3,'  ');
         writeln('VZ:',stars[i].v.z:3:3);

         writeln
     end;
     end else if graphic then begin
         for i:=1 to maxstars do begin
              putpixel(round(scalex(stars[i].pos.x/zoom)),
                      round(scaley(stars[i].pos.y/zoom)),stars[i].c);
         end;
     end;

end;

procedure init;
var i,j:integer;
    ws,w:real;
begin
     ws:=2*pi/maxstars;
     i:=0;
     null.x:=0;
     null.y:=0;
     null.z:=0;
     repeat
           inc(i);
           w:=w+ws;
           stars[i].a:=null;
           stars[i].pos:=null;
           stars[i].v:=null;
           stars[i].pos.z:=random(1000);
           stars[i].pos.x:=cos(w)*r;
           stars[i].pos.y:=sin(w)*r;
           stars[i].v.x:=cos(pi/2-(pi-w))*2;
           stars[i].v.y:=sin(pi/2-(pi-w))*2;
           stars[i].m:=random(300)/100;
           with stars[i] do begin
           	c:=1;
           	if m>0.6 then c:=2;
           	if m>0.8 then c:=3;
           	if m>1.2 then c:=4;
           end;
     until i=maxstars;
     if graphic=true then begin
        grafikein;
        setfillpattern(fill,0);
     end;
     setrgbpalette(1,255 , 0, 0);
     setrgbpalette(2,255 , 128, 80);
     setrgbpalette(3,255 , 255, 128);
     setrgbpalette(4,0 ,0 ,255 );
end;
procedure simstars;
var i,j,k:integer;
    q,d,b:real;
begin
     if trails=true then begin clearstars end;
     for i:=1 to maxstars do begin
         stars[i].a:=null;               (* beschleunigung null *)
         for j:=1 to maxstars do begin
             if (i<>j)  then begin
                q:=(sqr(stars[i].pos.x-stars[j].pos.x)+
                        sqr(stars[i].pos.y-stars[j].pos.y)+
                        sqr(stars[i].pos.z-stars[j].pos.z));

                d:=sqrt(q);
                if d<>0 then begin         (* kollision ?? *)
                   b:=stars[i].m*stars[j].m*G/q;
                   stars[i].a.x:=stars[i].a.x+b*(stars[j].pos.x-stars[i].pos.x)/d;
                   stars[i].a.y:=stars[i].a.y+b*(stars[j].pos.y-stars[i].pos.y)/d;
                   stars[i].a.z:=stars[i].a.z+b*(stars[j].pos.z-stars[i].pos.z)/d;
                end else begin
                    if textm then begin
                       writeln('Kollision !!!');
                       stars[i].a:=null
                    end else
                    if graphic then begin
                    end;
                end;
             end else begin

             end;
         end;
     end;
     for i:=1 to maxstars do begin
         vadd(stars[i].v,stars[i].a,stars[i].v);
     end;
     for i:=1 to maxstars do begin
         vadd(stars[i].pos,stars[i].v,stars[i].pos);
     end;
     drawstars;
end;
begin
     clrscr;
     init;
     ende:=false;
     repeat
     	repeat
           simstars;
     	until keypressed;
        k:=readkey;
        case k of
        	'+': begin
			zoom:=zoom*5;
                        clear;
                     end;
                '-': begin
			zoom:=zoom/5;
                        clear;
                     end;
                'q': ende:=true;
 {
                't': begin
			if trails=true then begin
				trails:=false;
			end else begin
				trails:=true
                        end
                     end}
        end;
     until ende;
     if graphic=true then grafikaus;
end.