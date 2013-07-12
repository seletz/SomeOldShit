program vehicles;
uses crt,neuroun,graph,sgraph;
const lx=200;
      ly=200;
      maxx=400;
      maxy=400;
type vbase = object (nbase)
                    aktcount:longint;
                    x,y,c:integer;
                    vx,vy,orient:real;
                    Constructor init(ix,iy:integer; ior:real; ic:integer);
                    procedure setxy(ix,iy:integer);
                    procedure setor(ior:real);
                    procedure setv(ivx,ivy:real);
                    procedure setc(ic:integer);
                    procedure draw;
                    procedure hide;
             end;
      red = object (vbase)
                   sicht:view;
                   lr,rr:receptor;
                   lm,rm:motor;
                   v1,v2:vlist;
                   constructor init(is:view);
                   procedure step;
            end;
{

                ***************** vbase **********************

}

Constructor vbase.init(ix,iy:integer; ior:real; ic:integer);
begin
     setxy(ix,iy);
     setv(0,0);
     setor(ior);
     setc(ic);
end;
procedure vbase.setxy(ix,iy:integer);
begin
     x:=ix; y:=iy;
end;
procedure vbase.setv(ivx,ivy:real);
begin
     vx:=ivx; vy:=ivy;
end;
procedure vbase.setor(ior:real);
begin
     orient:=ior;
end;
procedure vbase.setc(ic:integer);
begin
     c:=ic;
end;
procedure vbase.draw;
begin
{     writeln('Pos:  x:',x,' y:',y);}
      putpixel(x,y,4);
end;
procedure vbase.hide;
begin
end;
{

                ***************** Red Vehicle *******************

}
constructor red.init(is:view);
var i:integer;
begin
     sicht:=is;
     setxy(0,0);
     setv(0,0);
     setor(pi);
     lr.init(1,15,-5);
     rr.init(1,15,5);
     rm.init;
     lm.init;
     v1.init(@rm);
     v2.init(@lm);
     rr.setlist(@v1);
     lr.setlist(@v2);
end;
procedure red.step;
var d,el,er,alpha:real;
    xx,yy:integer;
    rd,ld:integer;
begin
     inc(aktcount);
     el:=sqrt(sqr(x+lr.x)+sqr(y+lr.y));
     er:=sqrt(sqr(x+rr.x)+sqr(y+rr.y));
     lr.click(el);
     rr.click(er);
     rd:=rm.gimmedreh;
     ld:=lm.gimmedreh;
     lm.cleardreh;
     rm.cleardreh;
     alpha:=arctan((rd-ld)/b);
     setor(orient+alpha);
     d:=(rd+ld);
     xx:=round(cos(orient)*d);
     yy:=round(sin(orient)*d);
     x:=sicht.scx(x+xx);
     y:=sicht.scy(y+yy);
{     writeln('X=',x,' Y=',y,' EL=',el:3,' ER=',er:3,' RD=',rd:3,' LD=',ld:3)}
end;
{

                ***************** Receptor *******************

}
var r:red;
    i:integer;
    vi:view;
begin
     vi.init(400,400,0,0);
     grafikein;
     setcolor (1);
     settextstyle(Triplexfont,horizdir,3);
     outtextxy(420,30,'Norovehicles!');
     r.init(vi);
     r.setxy(100,100);
     repeat
         r.step;
         r.draw;
     until keypressed;
     grafikaus;
end.