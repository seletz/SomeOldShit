program liste;
uses crt,graph,sgraph;
const
        debug=true;
        maxelem=30;
        maxstars=30;
        stickcol=2;
        starcol=3;
        shipcolor=5;
        enemycolor=6;
        maxenemy=4;
        enemyiq=30;
        speed=0.05;
        minx=12;
        maxx=1000;
        miny=9;
        maxy=750;
        shipscale=10;
        wischr=15*pi/180;
        schub=30*speed;
type
        sticknode = record
                     next:integer;
                     prev:integer;
                     spin:real;
                     alpha,velx:real;
                     vely:real;
                     posx:real;
                     posy:real;
                     length:real;
                     col:integer;
        end;
        starnode = record
                     next:integer;
                     prev:integer;
                     velx:real;
                     vely:real;
                     posx:real;
                     posy:real;
                     col:integer;
        end;
        shipnode = record
                     next:integer;
                     prev:integer;
                     col:integer;
                     alpha:real;
                     velx:real;
                     vely:real;
                     posx:real;
                     posy:real;
                     k: array [1..3,1..2] of real;
                     count:integer;
        end;




var
        starlist : array [1..maxstars] of starnode;
        list : array [1..maxelem] of sticknode;
        ship : shipnode;
        enemies : array [1..maxenemy] of shipnode;
        k:char;
        ende:boolean;







function inrange(i,u,o:real):boolean;
begin
     inrange:=((i>u) and(i<o));
end;
function scalex(x:real):real;
begin
     if inrange(x,minx,maxx) then
        scalex:=x
     else begin
        if x>maxx then x:=minx;
        if x<minx then x:=maxx-x;
        scalex:=x
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
     if inrange(y,miny,maxy) then
        scaley:=y
     else begin
        if y>maxy then y:=minx;
        if y<miny then y:=maxy-y;
        scaley:=y
     end;
end;

procedure dgrafikein; begin clrscr; end;
procedure dgrafikaus; begin writeln('ende'); end;
procedure dsetcolor(c:integer); begin end;
procedure dputpixel(x,y,c:integer);
begin
     writeln(x,' ',y,' ',c);
end;
procedure nputpixel(x,y,c:integer);
begin
end;
procedure dline(x,y,x2,y2:integer);
begin
     writeln(x,' ',y,' ',x2,' ',y2);
end;
procedure nline(x,y,x2,y2:integer);
begin
end;
procedure ncircle(x,y,r:integer);
begin
end;



procedure chkkey;
begin
     k:=readkey;
     if k in ['q',',','.',' ','c'] then begin
        case k of
         'q': ende:=true;
         '.': ship.alpha:=scalew(ship.alpha+wischr);
         ',': ship.alpha:=scalew(ship.alpha-wischr);
         ' ': begin
                   writeln('SCHUB');
                   ship.velx:=ship.velx+cos(ship.alpha)*schub;
                   ship.vely:=ship.vely+sin(ship.alpha)*schub;
                   WRITELN(ship.velx);
                   writeln(ship.vely);
              end;
         'c': begin sound(220); nosound; end;
        end;
     end else ende:=false;
end;

procedure init;
var i,j:integer;
    xy:array[1..3,1..2] of real;
begin

    for i:=1 to maxelem do
        with list[i] do begin
             posx:=scalex(512);
             posy:=scaley(380);
             velx:=(random(100))*speed;
             vely:=(random(100))*speed;
             spin:=random(1500)*pi/18000;
             length:=4;
            (* length:=(random(2200)+200)/100;*)
             alpha:=0;
             if random(200)>100 then velx:=-velx;
             if random(200)>100 then vely:=-vely;

             col:=stickcol;
             if i<maxelem then begin
                next:=i+1;
                prev:=i-1;
                end
             else begin
                 next:=0;
                 prev:=i-1;
             end;
         end;

         for i:=1 to maxstars do
             with starlist[i] do begin
                  posx:=scalex(random(1024));
                  posy:=scaley(random(768));
                  velx:=(random(200))*speed;
                  vely:=(random(200))*speed;
                  col:=starcol;
             end;

         xy[2,1]:=shipscale*cos(90*pi/180);
         xy[2,2]:=shipscale*sin(90*pi/180);
         xy[3,1]:=shipscale*cos(270*pi/180);
         xy[3,2]:=shipscale*sin(270*pi/180);
         xy[1,1]:=shipscale*cos(-45*pi/180);
         xy[1,2]:=shipscale*sin(-45*pi/180);
         for j:=1 to 3 do begin
             ship.k[j,1]:=xy[j,1];
             ship.k[j,2]:=xy[j,1];
         end;
         ship.col:=shipcolor;
         ship.posx:=scalex(0);
         ship.posy:=scaley(0);
         ship.velx:=3;
         ship.vely:=3;
         ship.alpha:=3/2*pi;
         for i:=1 to maxenemy do begin
             enemies[i].col:=enemycolor;
             enemies[i].posx:=scalex(random(500));
             enemies[i].posy:=scaley(random(300));
             enemies[i].velx:=2;
             enemies[i].vely:=2;
             enemies[i].alpha:=pi/2;
             enemies[i].count:=0;
             for j:=1 to 3 do begin
                 enemies[i].k[j,1]:=xy[j,1];
                 enemies[i].k[j,2]:=xy[j,1];
             end;
         end;
(*         writeln(enemies[1].k[1,1]);
         repeat until keypressed;*)
end;

procedure rline(x,y,x1,y1:real);
begin
     nline(round((x)),round((y)),
          round((x1)),round((y1)));
end;

procedure drawship(s:shipnode; black:boolean);
var sa,ca:real;
begin
     with s do begin
          sa:=sin(alpha); ca:=cos(alpha);
          if not black then setcolor(col) else setcolor(0);
          circle(round(posx),round(posy),shipscale);
          circle(round(posx+ca*shipscale),
                 round(posy+sa*shipscale),3);
{          rline(posx+k[2,1]*cos(alpha),posy+k[2,2]*sin(alpha),
               posx+k[1,1]*cos(alpha),posy+k[1,2]*sin(alpha));
          rline(posx+k[1,1]*cos(alpha),posy+k[1,2]*sin(alpha),
               posx+k[3,1]*cos(alpha),posy+k[3,2]*sin(alpha));
          rline(posx+k[3,1]*cos(alpha),posy+k[3,2]*sin(alpha),
               posx,posy);
          rline(posx,posy,
               posx+k[2,1]*cos(alpha),posy+k[2,2]*sin(alpha));}
     end;
end;
procedure animateship;
var i,j,k:integer;
begin
     drawship(ship,true);
     with ship do begin
          posx:=scalex(posx+velx);
          posy:=scaley(posy+vely);
     end;
     drawship(ship,false);
end;
procedure calcenemypos(var e,s:shipnode);
var a,b,c:real;
begin
{     if s.posx>e.posx then begin
        e.alpha:=scalew(e.alpha-0.3);
        e.velx:=e.velx+e.velx*cos(e.alpha);
        e.vely:=e.vely+e.vely*sin(e.alpha);
     end else begin
        e.alpha:=scalew(e.alpha+0.3);
        e.velx:=e.velx+e.velx*cos(e.alpha);
        e.vely:=e.vely+e.vely*sin(e.alpha);
     end;
     if s.posy>e.posy then begin
        e.alpha:=scalew(e.alpha-0.3);
        e.velx:=e.velx+e.velx*cos(e.alpha);
        e.vely:=e.vely+e.vely*sin(e.alpha);
     end else begin
        e.alpha:=scalew(e.alpha+0.3);
        e.velx:=e.velx+e.velx*cos(e.alpha);
        e.vely:=e.vely+e.vely*sin(e.alpha);
     end;
}
     a:=(e.posx-s.posx);
     b:=(e.posy-s.posy);
     e.alpha:=arctan(b/a);
     if s.posx<e.posx then e.alpha:=scalew(e.alpha-pi);
     e.velx:=2*cos(e.alpha);
     e.vely:=2*sin(e.alpha);
     e.posx:=scalex(e.posx+e.velx);
     e.posy:=scaley(e.posy+e.vely);
end;
procedure animateenemies;
var i,j,k:integer;
begin
     for i:=1 to maxenemy do begin
         drawship(enemies[i],true);
         if enemies[i].count=0 then begin
                  calcenemypos(enemies[i],ship);
                  enemies[i].count:=enemyiq;
         end else begin
                  dec(enemies[i].count);
                  enemies[i].posx:=scalex(enemies[i].posx+enemies[i].velx);
                  enemies[i].posy:=scaley(enemies[i].posy+enemies[i].vely);
         end;
         drawship(enemies[i],false);
     end;
end;
procedure animatebg;
var i:integer;
    pos1x,pos1y,pos2x,pos2y,ls,lc:real;
begin
     for i:=1 to maxelem do begin
         with list[i] do begin
              ls:=length*sin(alpha);
              lc:=length*cos(alpha);
              pos2x:=scalex(lc+posx);
              pos2y:=scaley(ls+posy);
              pos1x:=scalex(-lc+posx);
              pos1y:=scalex(-ls+posy);;
              setcolor(0);
              line(round(pos1x),round(pos1y),round(pos2x),round(pos2y));
              posx:=scalex(posx+velx);
              posy:=scaley(posy+vely);
              alpha:=alpha+spin;
              if alpha>=2*pi then alpha:=0;
              ls:=length*sin(alpha);
              lc:=length*cos(alpha);
              pos2x:=scalex(lc+posx);
              pos2y:=scaley(ls+posy);
              pos1x:=scalex(-lc+posx);
              pos1y:=scalex(-ls+posy);
              if (length*2)>(abs(sqrt(pos1x*pos1x+pos1y*pos1y)-sqrt(pos2x*pos2x+pos2y*pos2y))) then begin
                 setcolor(col);
                 line(round(pos1x),round(pos1y),round(pos2x),round(pos2y));
              end;
         end;
     end;
     for i:=1 to maxstars do  begin
         with starlist[i] do begin
              putpixel(round(posx),round(posy),0);
              posx:=scalex(posx+velx);
              posy:=scaley(posy+vely);
              putpixel(round(posx),round(posy),col);
         end;
     end;
     animateship;
     animateenemies;
end;
begin
     ende:=false;
     init;
     grafikein;
     repeat
           repeat
                 animatebg;
           until keypressed;
           chkkey;
     until ende;
     grafikaus;
end.