program liste;
uses crt,graph,sgraph;
const
        maxelem=1000;
        speed=0.5;
        minx=12;
        maxx=1000;
        miny=9;
        maxy=750;
type
        node = record
                     next:integer;
                     prev:integer;
                     spin:real;
                     velx:real;
                     vely:real;
                     posx:real;
                     posy:real;
                     col:integer;
        end;
var
        list : array [1..maxelem] of node;

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
procedure dputpixel(x,y,c:integer);
begin
     writeln(x,' ',y,' ',c);
end;

procedure init;
var i:integer;
begin

    for i:=1 to maxelem do
        with list[i] do begin
             posx:=scalex(512);
             posy:=scaley(380);
             velx:=(random(100))*speed;
             vely:=(random(100))*speed;
             spin:=random(360)*pi/180;
             if random(200)>100 then velx:=-velx;
             if random(200)>100 then vely:=-vely;

             col:=random(254)+1;
             if i<maxelem then begin
                next:=i+1;
                prev:=i-1;
                end
             else begin
                 next:=0;
                 prev:=i-1;
             end;
         end;


end;
procedure animate;
var i:integer;
begin
     for i:=1 to maxelem do begin
         with list[i] do begin
              putpixel(round(posx),round(posy),0);
              posx:=scalex(posx+velx);
              posy:=scaley(posy+vely);

              putpixel(round(posx),round(posy),col);
         end;
     end;

end;
begin
     init;
     grafikein;
     repeat
           animate;
     until keypressed;
     grafikaus;
end.