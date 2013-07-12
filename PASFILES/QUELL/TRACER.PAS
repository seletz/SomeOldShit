program tracer;
uses crt;
{label}
const pi=1.1415932; pm2=pi*2; pd2=pi/2;
      ebene=0;
      dreieck=1;
      viereck=2;
      kreis=3;
      kreissektor=4;
      kreisring=5;
      kugel=10;
      zylinder=20;
      zylinderausschnitt=21;
      kegel=22;
      ellipsoid=24;

      anzahlk=2;
      maxstack=20;
      schwelle=0.0001;
type
    vector = RECORD
           x,y,z:real;
    end;
    color = record
          r,g,b:real;
    end;
    material = record
           c:color;
           schatthell:real;
           sp:real;
           trans:real;
    end;
    koerper = record
           typ:integer;
           mat:material;
           r1:vector;           { Ortsvektor }
           r2:vector;
           r3:vector;
           r4:vector;
           ri:real;             { innerer Radius }
           ra:real;             { ausserer Radius }
           sw:real;             { Startwinkel }
           ew:real;             { Endwinkel }
    end;
var
    k : array [1..anzahlk] of koerper;
    hilf : array [1..anzahlk,0..5] of real;
    xaoff,yaoff,xboff,yboff:real;
    boxw,boxh,xstart,xend,ystart,yend,xb,yb:integer;
    r,h,p,s,p1,n,q,sp:vector;
    la:real;
    hell,qh:color;
    hellf,spiegel:real;
    stack : array [0..maxstack] of color;
    stackptr,koerperdran:integer;
    original,schatten:boolean;

(**********************************************

        PROCEDUREN

***********************************************)

function sgn(x:real) :real;
begin
     if abs(x)<>x then
        sgn:=-1
     else
        sgn:=1;
end;
procedure swapi(var a,b:integer);
var c:integer;
begin
     c:=a;
     a:=b;
     b:=a;
end;
procedure swapr(var a,b:real);
var c:real;
begin
     c:=a;
     a:=b;
     b:=a;
end;

procedure vzero(var a:vector);
begin
     with a do begin x:=0; y:=0; z:=0; end;
end;

procedure vadd(var ad:vector; a,b:vector);
begin
     ad.x:=a.x+b.x;
     ad.y:=a.y+b.y;
     ad.z:=a.z+b.z;
end;
procedure vsub(var su:vector; a,b:vector);
begin
     su.x:=a.x-b.x;
     su.y:=a.y-b.y;
     su.z:=a.z-b.z;
end;

procedure vdiv(var di:vector; a,b:vector);
begin
     di.x:=a.x/b.x;
     di.y:=a.y/b.y;
     di.z:=a.z/b.z;
end;

procedure vmul(var mu:vector; a,b:vector);
begin
     mu.x:=a.x*b.x;
     mu.y:=a.y*b.y;
     mu.z:=a.z*b.z;
end;

procedure vcpy(a:vector; var b:vector);
begin
     b.x:=a.x;
     b.y:=a.y;
     b.z:=a.z;
end;
procedure cadd(var ad:color; a,b:color);
begin
     ad.r:=a.r+b.r;
     ad.g:=a.g+b.g;
     ad.b:=a.b+b.b;
end;
procedure csub(var su:color; a,b:color);
begin
     su.r:=a.r-b.r;
     su.g:=a.g-b.g;
     su.b:=a.b-b.b;
end;

procedure cdiv(var di:color; a,b:color);
begin
     di.r:=a.r/b.r;
     di.g:=a.g/b.g;
     di.b:=a.b/b.b;
end;

procedure cmul(var mu:color; a,b:color);
begin
     mu.r:=a.r*b.r;
     mu.g:=a.g*b.g;
     mu.b:=a.b*b.b;
end;

procedure ccpy(a:color; var b:color);
begin
     b.r:=a.r;
     b.g:=a.g;
     b.b:=a.b;
end;
function det(a11,a12,a13,a21,a22,a23,a31,a32,a33:real) : real;
var x1,x2,x3:real;
begin
     x1:=a11*(a22*a33-a23*a32);
     x2:=a12*(a21*a33-a23*a31);
     x3:=a13*(a21*a32-a22*a31);
     det:=x1-x2+x3;
end;
function betrag(a:vector) : real;
begin
     betrag:=sqrt(sqr(a.x)+sqr(a.y)+sqr(a.z));
end;
function dot(a,b:vector) : real;
begin
     dot:=a.x*b.x+a.y*b.y+a.z*b.z;
end;
function cosinwinkel(a,b:vector) : real;
begin
     cosinwinkel:=dot(a,b)/(betrag(a)*betrag(b));
end;
function xresc(x:integer) : integer;
begin
     xresc:=x;
end;
function yresc(y:integer) : integer;
begin
     yresc:=y;
end;
procedure writeto(x,y:integer; s:string);
begin
     gotoxy(x,y);
     writeln(s);
end;

procedure writevector(x,y:integer; s:string; a:vector);
begin
(*     gotoxy(x,y);*)
     writeln(s,'=( ',a.x:3:3,' / ',a.y:3:3,' / ',a.z:3:3,')');
end;

procedure winkelintervall(var ls:real; ns:integer; as,bs:real);
var d:real;
begin
     if as=0 then
        d:=pd2*sgn(bs)
     else
         begin
              d:=arctan(bs/as);
              if as<0 then
                 d:=d+pi;
         end;
     if d<0 then
        d:=d+pm2;

     if (d<k[ns].sw) or (d>k[ns].ew) then
        ls:=-1;
end;
procedure schnittebene(n:integer; ps,rs:vector; var l:real);
var d:real;
begin
     d:=rs.y*hilf[n,4]-rs.x*hilf[n,3]-rs.z*hilf[n,5];
     if d<>0 then
        l := ((ps.x-k[n].r1.x)*hilf[n,3]-(ps.y-k[n].r1.y)*hilf[n,4]+(ps.z-k[n].r1.z)*hilf[n,5])/d
     else
        l:=-1;
     if l<>-1 then begin writeln('Ebenenschnitt bei:',l:3:3); readln; end;
end;
procedure schnittdreieck(n:integer; ps,rs:vector; var l,a,b:real);
var d:real;
begin
     d:=r.y*hilf[n,4]-r.x*hilf[n,3]-r.z*hilf[n,5];
     if d<>0 then
        begin
             l := ((ps.x-k[n].r1.x)*hilf[n,3]-(ps.y-k[n].r1.y)*hilf[n,4]+(ps.z-k[n].r1.z)*hilf[n,5])/d;
             if l>0 then
                begin
                     a:=det(ps.x-k[n].r1.x,k[n].r3.x,-rs.x,ps.y-k[n].r1.y,k[n].r3.y,-rs.y,ps.z-k[n].r1.z,k[n].r3.z,-rs.z)/d;
                     b:=det(k[n].r2.x,ps.x-k[n].r1.x,-rs.x,k[n].r2.y,ps.y-k[n].r1.y,-rs.y,k[n].r2.z,ps.z-k[n].r1.z,-rs.z)/d;

                     if (a<0) or (b<0) or (a>1) or (b>1) or (a+b>1) then
                        l:=-1;
                end;
        end
     else
        l:=-1;
end;
procedure schnittviereck(n:integer; ps,rs:vector; var l,a,b:real);
var d:real;
begin
     d:=r.y*hilf[n,4]-r.x*hilf[n,3]-r.z*hilf[n,5];
     if d<>0 then
        begin
             l := ((ps.x-k[n].r1.x)*hilf[n,3]-(ps.y-k[n].r1.y)*hilf[n,4]+(ps.z-k[n].r1.z)*hilf[n,5])/d;
             if l>0 then
                begin
                     a:=det(ps.x-k[n].r1.x,k[n].r3.x,-rs.x,ps.y-k[n].r1.y,k[n].r3.y,-rs.y,ps.z-k[n].r1.z,k[n].r3.z,-rs.z)/d;
                     b:=det(k[n].r2.x,ps.x-k[n].r1.x,-rs.x,k[n].r2.y,ps.y-k[n].r1.y,-rs.y,k[n].r2.z,ps.z-k[n].r1.z,-rs.z)/d;

                     if (a<0) or (b<0) or (a>1) or (b>1) then
                        l:=-1;
                end;
        end
     else
        l:=-1;
end;
procedure schnittkreis(n:integer; ps,rs:vector; var l,a,b:real);
var d:real;
begin
     d:=r.y*hilf[n,4]-r.x*hilf[n,3]-r.z*hilf[n,5];
     if d<>0 then
        begin
             l := ((ps.x-k[n].r1.x)*hilf[n,3]-(ps.y-k[n].r1.y)*hilf[n,4]+(ps.z-k[n].r1.z)*hilf[n,5])/d;
             if l>0 then
                begin
                     a:=det(ps.x-k[n].r1.x,k[n].r3.x,-rs.x,ps.y-k[n].r1.y,k[n].r3.y,-rs.y,ps.z-k[n].r1.z,k[n].r3.z,-rs.z)/d;
                     b:=det(k[n].r2.x,ps.x-k[n].r1.x,-rs.x,k[n].r2.y,ps.y-k[n].r1.y,-rs.y,k[n].r2.z,ps.z-k[n].r1.z,-rs.z)/d;

                     if a*a+b*b>1 then
                        l:=-1;
                end;
        end
     else
        l:=-1;
end;
procedure schnittkreissektor(n:integer; ps,rs:vector; var l,a,b:real);
var d:real;
begin
     d:=r.y*hilf[n,4]-r.x*hilf[n,3]-r.z*hilf[n,5];
     if d<>0 then
        begin
             l := ((ps.x-k[n].r1.x)*hilf[n,3]-(ps.y-k[n].r1.y)*hilf[n,4]+(ps.z-k[n].r1.z)*hilf[n,5])/d;
             if l>0 then
                begin
                     a:=det(ps.x-k[n].r1.x,k[n].r3.x,-rs.x,ps.y-k[n].r1.y,k[n].r3.y,-rs.y,ps.z-k[n].r1.z,k[n].r3.z,-rs.z)/d;
                     b:=det(k[n].r2.x,ps.x-k[n].r1.x,-rs.x,k[n].r2.y,ps.y-k[n].r1.y,-rs.y,k[n].r2.z,ps.z-k[n].r1.z,-rs.z)/d;

                     if a*a+b*b<=1 then
                        winkelintervall(l,n,a,b)
                     else
                        l:=-1;
                end;
        end
     else
        l:=-1;
end;

procedure schnittkugel(n:integer; ps,rs:vector; var l:real);
var d,q,p,l0,l1:real;
begin
     d:=rs.x*rs.x+rs.y*rs.y+rs.z*rs.z;
     p:=(rs.x*(ps.x-k[n].r1.x)+r.y*(ps.y-k[n].r1.y)+r.z*(ps.z-k[n].r1.z))/d;
     q:=(sqr(ps.x-k[n].r1.x)+sqr(ps.y-k[n].r1.y)+sqr(ps.z-k[n].r1.z)-sqr(k[n].r2.x))/d;
     d:=sqr(p)-q;
     if d>0 then
        begin
             l0:=-p+sqrt(d);
             l1:=-p-sqrt(d);
             if (l0>l1) then
                l:=l1
             else
                l:=l0;
        end
     else
         l:=-1;
     if l<>-1 then begin writeln('Kugelschnitt bei:',l:3:3); readln; end;
end;
procedure welcherkoerper(kp:integer; ps,rs:vector; original,schatten:boolean);
var n:integer;
    ls,as,bs:real;
begin
     writevector(1,1,'ps',ps);
     la:=-1;
     koerperdran:=0;
     for n:=1 to anzahlk do
         begin
              case k[n].typ  of
                   ebene : schnittebene(n,ps,rs,ls);
                   dreieck : schnittdreieck(n,ps,rs,ls,as,bs);
                   viereck : schnittviereck(n,ps,rs,ls,as,bs);
                   kreis : schnittkreis(n,ps,rs,ls,as,bs);
                   kreissektor : schnittkreissektor(n,ps,rs,ls,as,bs);
                   kugel : schnittkugel(n,ps,rs,ls);
              end;
              if (ls>schwelle) and ((la<=0) or (ls < la)) and ((n<>kp) or (k[n].typ>=10)) then
                 la:=ls;
                 koerperdran:=n;
                 writeln('K”rper:',n);
                 if (k[n].typ>=20) and (kp=0) then
                    begin
                    end;
         end;
     if (koerperdran>0) and (kp=0) then
        begin
             s.x:=ps.x+la*rs.x;
             s.y:=ps.y+la*rs.y;
             s.z:=ps.z+la*rs.z;
             writevector(1,1,'s',s);
        end;
end;
procedure bestimmehell(ns:integer; ps:vector; spiegels:real; original:boolean);
var h:vector;
    dqe:real;
begin
     if k[ns].typ<=9 then
        begin
             n.x:=hilf[ns,0];
             n.y:=hilf[ns,1];
             n.z:=hilf[ns,2];

             if original <> true then
                begin
                     vsub(h,p,s);
                     if cosinwinkel(n,h)<0 then
                        begin
                             n.x:=-n.x;
                             n.y:=-n.y;
                             n.z:=-n.z;
                        end;
                end;

             vsub(h,q,s);
             vmul(h,h,n);
             dqe:=h.x+h.y+h.z;

             vsub(sp,s,q);
             sp.x:=sp.x+2*dqe*n.x;
             sp.y:=sp.y+2*dqe*n.y;
             sp.z:=sp.z+2*dqe*n.z;

             vsub(h,p,s);
             spiegel:=cosinwinkel(sp,h);
             if spiegel<0 then
                spiegel:=0;

             vsub(h,q,s);
             hellf:=cosinwinkel(n,h);
        end
     else
         begin
              if k[ns].typ=10 then
                 begin
                      vsub(n,s,k[ns].r1);
                 end;
         end;
     if k[ns].mat.sp>0 then
        spiegel:=1.5*exp(30*k[ns].mat.schatthell+ln(spiegel));
end;
procedure initminmax;
begin
end;
procedure initschattiere;
var i,j:integer;
    nx,ny,nz,nl:real;
    n:vector;
    d:vector;
begin
     for i:=1 to anzahlk do
         begin
              with k[i] do begin
                   if typ<10 then begin
                      N.x:=r2.y*r3.z-r2.z*r3.y;
                      N.y:=r2.z*r3.x-r2.x*r3.z;
                      N.z:=r2.x*r3.y-r2.y*r3.x;
                      vsub(d,p,r1);
                      if cosinwinkel(n,d)<0 then begin
                         n.x:=-n.x;
                         n.y:=-n.y;
                         n.z:=-n.z;
                      end;
                      nl:=sqrt(n.x*n.x+n.y*n.y+n.z*n.z);
                      hilf[i,0]:=n.x/nl;
                      hilf[i,1]:=n.y/nl;
                      hilf[i,2]:=n.z/nl;
                      hilf[i,3]:=r2.y*r3.z-r3.y*r2.z;
                      hilf[i,4]:=r2.x*r3.z-r2.z*r3.x;
                      hilf[i,5]:=r2.x*r3.y-r2.y*r3.x;
                   end;
              end;
         end;

     for i:=1 to maxstack do begin
         with stack[i] do begin
              r:=0;
              b:=0;
              g:=0;
         end;
     end;
     q.x:=100;
     q.y:=100;
     q.z:=100;

     qh.r:=1;
     qh.b:=1;
     qh.g:=1;

     hell.r:=0.3;
     hell.g:=0.3;
     hell.b:=0.3;

     h.x:=0;
     h.y:=0;
     h.z:=0;

     p.x:=10;
     p.y:=10;
     p.z:=40;

     k[1].typ:=ebene;
     k[1].r1.x:=0;
     k[1].r1.y:=0;
     k[1].r1.z:=0;
     k[1].r2.x:=10;
     k[1].r2.y:=0;
     k[1].r2.z:=0;
     k[1].r3.x:=0;
     k[1].r3.y:=10;
     k[1].r3.z:=0;
     k[1].mat.c.r:=0.4;
     k[1].mat.c.g:=0;
     k[1].mat.c.b:=1;
     k[1].mat.schatthell:=0.2;
     k[1].mat.sp:=0;
     k[1].mat.trans:=0;

     k[2].typ:=kugel;
     k[2].r1.x:=10;
     k[2].r1.y:=10;
     k[2].r1.z:=10;
     k[2].r2.x:=10;
     k[2].r2.y:=0;
     k[2].r2.z:=0;
     k[2].mat.c.g:=1;
     k[2].mat.c.r:=0;
     k[2].mat.c.b:=0;
     k[2].mat.schatthell:=0.2;
     k[2].mat.sp:=0;
     k[2].mat.trans:=0;


end;
procedure initminmaxlq;
begin
end;
procedure reprojektion(var a:vector; q:real; x,y:integer);
begin
     a.x:=x;
     a.y:=y;
     a.z:=p.z;
end;
procedure berechnepunkt;
var resthell : array [0..maxstack] of real;
    kp:integer;
    h:vector;
    dqe:real;
begin
     inc(stackptr);
     writevector(1,1,'BH: p',p);
     writevector(1,1,'BH: r',r);
     welcherkoerper(0,p,r,original,false);
     if koerperdran>0 then
        begin
             bestimmehell(koerperdran,p,spiegel,original);
             resthell[stackptr]:=k[koerperdran].mat.sp;

             if hellf<=0 then
                begin
                     hell.r:=k[koerperdran].mat.c.r*k[koerperdran].mat.schatthell;
                     hell.g:=k[koerperdran].mat.c.g*k[koerperdran].mat.schatthell;
                     hell.b:=k[koerperdran].mat.c.b*k[koerperdran].mat.schatthell;
                end
             else
                 begin
                      kp:=koerperdran;
                      vsub(h,q,s);
                      welcherkoerper(kp,s,h,false,true);
                      swapi(koerperdran,kp);
                      if (kp>0) and (la>1) then
                         begin
                              hell.r:=k[koerperdran].mat.c.r*k[koerperdran].mat.schatthell;
                              hell.g:=k[koerperdran].mat.c.g*k[koerperdran].mat.schatthell;
                              hell.b:=k[koerperdran].mat.c.b*k[koerperdran].mat.schatthell;
                         end
                      else
                          begin
                               hellf:=hellf*(1-resthell[stackptr]);
                               if hellf<k[koerperdran].mat.schatthell then
                                  hellf:=k[koerperdran].mat.schatthell;
                               hell.r:=k[koerperdran].mat.c.r+spiegel*resthell[stackptr];
                               hell.g:=k[koerperdran].mat.c.g+spiegel*resthell[stackptr];
                               hell.b:=k[koerperdran].mat.c.b+spiegel*resthell[stackptr];

                          end; {kp>0 la>1}
                 end; {hellf>=0}
             if (resthell[stackptr]>0) and (stackptr<maxstack) then
                begin
                     vsub(h,p,s);
                     vmul(h,n,h);
                     dqe:=h.x+h.y+h.z;

                     vsub(r,s,p);
                     r.x:=r.x+2*dqe*n.x;
                     r.y:=r.y+2*dqe*n.y;
                     r.z:=r.z+2*dqe*n.z;

                     ccpy(hell,stack[stackptr]);
                     vcpy(s,p);
                     original:=false;

                     berechnepunkt; { REKURSION!!!! }

                     cadd(hell,stack[stackptr],stack[stackptr+1]);

                     hell.r:=hell.r*resthell[stackptr];
                     hell.g:=hell.g*resthell[stackptr];
                     hell.b:=hell.b;

                end; {spiegelung}
        end
     else
         begin
              if stackptr=0 then
                 begin
                      hell.r:=-1;
                      hell.g:=-1;
                      hell.b:=-1;
                 end
              else
                  begin
                       hell.r:=0;
                       hell.g:=0;
                       hell.b:=0;
                  end;
         end; {if koerperdran>0}
     ccpy(hell,stack[stackptr]);
     resthell[stackptr]:=0;
     dec(stackptr);
end;

procedure ossetpoint(x0,y0,x1,y1:integer; farbe:color);
begin

     writeln(x0,',',y0,': r=',farbe.r:3,' g=',farbe.g:3,' b=',farbe.b:3);
end;
procedure trace;
begin
     clrscr;
     write('Initschattiere...');
     initschattiere;
     writeln('OK');
     xaoff:=(boxw and 1)/2;
     yaoff:=(boxh and 1)/2;

     if xaoff=0.5 then
        xboff:=0.5
     else
         xboff:=1;

     if yaoff=0.5 then
        yboff:=0.5
     else
         yboff:=1;

     clrscr;
     writeln('Schattieren...');

     koerperdran:=0;
     yb:=ystart+boxh div 2;
     while yb<(yend+boxh/2) do
           begin
                yb:=yb+boxh;
                xb:=xstart+boxw div 2;
                while xb<(xend+boxw/2) do
                      begin
                           xb:=xb+boxw;

                           reprojektion(r,0,xresc(xb),yresc(yb));

                           r.x:=r.x-p.x;
                           r.y:=r.y-p.y;
                           r.z:=r.z-p.z;

                           stackptr:=-1;

                           p1.x:=p.x;
                           p1.y:=p.y;
                           p1.z:=p.z;

                           original:=true;

                           writevector(1,1,'SH: p',p);
                           berechnepunkt;

                           p.x:=p1.x;
                           p.y:=p1.y;
                           p.z:=p1.z;

                           if stack[0].r>=0 then
                              begin
                                   hell.r:=stack[0].r*qh.r;
                                   hell.g:=stack[0].g*qh.g;
                                   hell.b:=stack[0].g*qh.g;

                                   OSSetpoint( xb - boxw div 2 + round(xaoff),
                                               yb - boxh div 2 + round(yaoff),
                                               xb + boxw div 2 + round(xboff),
                                               yb + boxh div 2 + round(yboff),
                                               hell);
                              end;

                      end; { xb }

           end; { yb }
     writeln('FERTIG!!!');
     repeat until keypressed;
end;
procedure drahtmodell;
begin
end;


procedure parameter;
begin
     clrscr;
     writeto(30,1,'Parameter:');
     writeto(30,2,'==========');

     writevector(10,5,'Licht Q',q);
     writevector(10,7,'Hauptpunkt H',h);
     writevector(10,9,'Proj. Punkt P',p);

     writeto(10,20,'TASTE DRšCKEN!');
     repeat until keypressed;

end;

procedure menue;
var wahl:integer;
    fini:boolean;
begin
     initschattiere;
     fini:=false;
     while not fini do
     begin
          while (wahl<0) or (wahl>3) do
          begin
               clrscr;
               writeln('****************************************************');
               writeln;
               writeln('               RAY-TRACER                           ');
               writeln;
               writeln('****************************************************');
               gotoxy(10,10);
               writeln('1.....Drahtmodell');
               gotoxy(10,11);
               writeln('2.....Schattieren');
               gotoxy(10,12);
               writeln('3.....Parameter Menue');
               gotoxy(10,14);
               writeln('0.....ENDE');
               gotoxy(13,16);
               write('Ihre wahl:'); readln(wahl);
          end;

          case wahl of
               0 : fini:=true;
               1 : drahtmodell;
               2 : trace;
               3 : parameter;
          end;
          wahl:=-1;
     end;
end;
(**********************************************

        HAUPTPROGRAMM

***********************************************)

begin
     vzero(r);
     vzero(h);
     vzero(p);
     vzero(s);
     vzero(p1);
     vzero(n);
     vzero(q);
     vzero(sp);

     boxw:=1;
     boxh:=1;
     ystart:=0;
     xstart:=0;
     xend:=10;
     yend:=10;

     menue;


end.

