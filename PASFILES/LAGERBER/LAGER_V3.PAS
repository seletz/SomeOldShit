program auflager;
uses crt,strings;
const festlager=1;
      loslager=2;
      rad:real=pi/180;
type kraft = record
                   f,fx,fy:real;
                   alpha:real;
                   lx,ly:real
             end;
     lager = record
                   typ:integer;
                   x,y:real;
                   alpha:real;
             end;
var  f: array [0..10] of kraft;
     losl,festl:lager;
     Fl,Ff:kraft;
     e,iy:real;
     anzahl_F:integer;
     ende:boolean;
     maxmb,maxq,maxt,maxf,x_maxf,x_maxq,x_maxt,x_maxmb:real;
     maxmb_berechnet,auflager_berechnet,daten_vorhanden:boolean;
     s:string;

procedure out_f(s:string; F:kraft);
begin
     textcolor(lightgreen);
     writeln( s,'   Betrag: ',F.f:3:3,' N;',' Richtung:',F.alpha*180/pi:3:3,' Grad;');
     writeln(' Fx: ',f.fx:3:3,' N; Fy: ',F.fy:3:3,' N;');
     textcolor(white);
end;

procedure wartetaste;
begin
     writeln;
     writeln('Bitte eine Taste drcken.');
     repeat until keypressed; readln
end;

procedure fehler(s:string);
begin
     clrscr;
     textcolor(lightred+blink);
     gotoxy(30,12); writeln(s);
     delay(2000);
     textbackground(black);
     textcolor(white);
end;
{
procedure readzahl(var x:real);
const zeichen : set of char = ['1','2','3','4','5','6','7','8','9','0','-','+','.'];
var c:char;
    temp:string;
    charok,ende:boolean;
    f:integer;
begin
     ende:=false;
     repeat
           repeat
                 c:=readkey;
                 charok:=c in zeichen;
           until charok or (ord(c)=13);

           write(c);

           temp:=temp+c;

     until not charok;

     val(temp,x,f);
     writeln;
end;
}
function frage:boolean;
var c:char;
begin
     write (' (j/n) ? ');
     c:=readkey;
     if c='j' then frage:=true else frage:=false;
     writeln (c);
end;
procedure write1r(s:string; x:real; s2:string);
begin
     writeln(s,x:3:3,' ',s2);
end;
procedure read1r(s:string; var x:real);
begin
     write(s); writeln(x:3:3);
     writeln;
     write('Wert „ndern');
     if frage then begin
        gotoxy(wherex,wherey-3);
        write(s); readln(x);
        gotoxy(wherex,wherey-1); clreol; writeln;
        gotoxy(wherex,wherey-1); write(s); writeln(x:3:3);
        gotoxy(wherex,wherey+1); writeln('                                                       ');
        gotoxy(wherex,wherey-2);
     end else begin
        gotoxy(wherex,wherey-1); clreol; writeln;
        gotoxy(wherex,wherey-2);
     end;
end;

procedure init_debug;
begin
     {

        einfacher Tr„ger fr testzwecke, '0' im Men drcken

        buch seite 57

     }
     anzahl_f:=1;
     with losl do begin
          x:=10;
          y:=0;
          alpha:=0*rad;
          typ:=loslager;
     end;
     with festl do begin
          x:=0;
          y:=0;
          alpha:=0;
          typ:=festlager;
     end;
     with f[1] do begin
          lx:=5;
          ly:=0;
          f:=100000;
          alpha:=270*rad;
          fx:=0;
          fy:=0;
     end;
     e:=210000;
     iy:=1000;
     daten_vorhanden:=true;
     maxmb_berechnet:=false;
     auflager_berechnet:=false;
end;
procedure init;
var i:integer;
    n:real;
    s:string;
    ok:boolean;
procedure clear_teil(sz,ez:integer);
var i:integer;
begin
     for i:=sz to ez do begin
         gotoxy(1,i);
         clreol;
     end;
end;
begin
     clrscr;
     ok:=false;
     maxmb_berechnet:=false;
     auflager_berechnet:=false;
     {

     A ..... Festlager
     B ..... Loslager

     Fa u. Fb immer in positiver Richtung


             A()---------------------------()B
              /\                           /\


     }
     with festl do
          begin
               writeln('Position Festlager eingeben (Nullpunkt beliebig):');
               read1r('X-Koordinate:',x);
               read1r('Y-Koordinate:',y);
          end;
     with losl do
          begin
               writeln;
               writeln('Position Loslager eingeben:');
               read1r('X-Koordinate:',x);
               read1r('Y-Koordinate:',y);
               alpha:=alpha/rad;
               read1r('Winkel zur positiven X-Achse:',alpha);
               alpha:=alpha*rad;
          end;
     writeln;
     repeat
           writeln;
           n:=anzahl_f;
           read1r('Anzahl der angreifenden Kr„fte (1..10; 0 => Ende):',n);
           gotoxy(wherex,wherey-2);
     until n<=10;

     writeln;
     writeln;

     if n=0 then halt;

     anzahl_f:=round(n);

     for i:=1 to anzahl_f do
         begin
              with f[i] do
                   begin
                        clear_teil(13,24);
                        gotoxy(1,12);
                        write('Kraft nummer ');
                        textcolor(yellow);
                        writeln(i);
                        textcolor(white);
                        writeln;
                        read1r('X-Koordinate    : ',lx);
                        read1r('Y-Koordinate    : ',ly);
                        read1r('Betrag in Newton: ',f);
                        alpha:=alpha/rad;
                        read1r('Winkel zur positiven X-Achse in Grad: ',alpha);
                        alpha:=alpha*rad;
                        read1r('X-komponente in Newton: ',fx);
                        read1r('Y-komponente in Newton: ',fy);
                        if f=0 then begin
                           f := sqrt(sqr(fx)+sqr(fy));
                           if fx<>0 then
                              alpha := arctan(fy/fx)
                           else
                              alpha := pi*fy/abs(2*fy);
                        end;
                        writeln;
                   end;
         end;

     daten_vorhanden:=true;
end;

function berechne_quadrant(xi,yi,xf,yf:real):integer;
begin
     {
        in welchem Quadrant liegt (xi,yi) ,  wenn (xf,yf) den
        Nullpunkt eines rechtwinkligen Koordinatensystems bildet?
     }
     if (xi>=xf) and(yi>=yf) then berechne_quadrant:=1;
     if (xi< xf) and(yi>=yf) then berechne_quadrant:=2;
     if (xi< xf) and(yi< yf) then berechne_quadrant:=3;
     if (xi>=xf) and(yi< yf) then berechne_quadrant:=4;
end;

procedure berechne_auflager;
var i:integer;
    em,emx,emy,efx,efy:real;
    xi,yi:real;
    quadrant:integer;
begin
     clrscr;
     em:=0;
     emx:=0;
     emy:=0;
     efx:=0;
     efy:=0;

     {
        E M(festl)
     }

     for i:=1 to anzahl_f do begin with f[i] do begin

         quadrant:=berechne_quadrant(lx,ly,festl.x,festl.y);

         fx:=cos(alpha)*f;
         fy:=sin(alpha)*f;

         efx:=efx + fx;
         efy:=efy + fy;

         yi:=abs(ly-festl.y);
         xi:=abs(lx-festl.y);

         case quadrant of
          1: begin
                  emx:=emx + (-fx*yi);
                  emy:=emy + (+fy*xi);
             end;
          2: begin
                  emx:=emx + (-fx*yi);
                  emy:=emy + (-fy*xi);
             end;
          3: begin
                  emx:=emx + (+fx*yi);
                  emy:=emy + (-fy*xi);
             end;
          4: begin
                  emx:=emx + (+fx*yi);
                  emy:=emy + (+fy*xi);
             end;
         end;
     end; end;

     em:=emx + emy;

     yi:=abs(losl.y-festl.y);
     xi:=abs(losl.x-festl.x);
     fl.alpha:=losl.alpha+pi/2;

     quadrant:=berechne_quadrant(losl.x,losl.y,festl.x,festl.y);
     case quadrant of
          1: begin
                  fl.f:=(-em)/(+sin(fl.alpha)*xi-cos(fl.alpha)*yi);
             end;
          2: begin
                  fl.f:=(-em)/(-sin(fl.alpha)*xi-cos(fl.alpha)*yi);
             end;
          3: begin
                  fl.f:=(-em)/(-sin(fl.alpha)*xi+cos(fl.alpha)*yi);
             end;
          4: begin
                  fl.f:=(-em)/(+sin(fl.alpha)*xi+cos(fl.alpha)*yi);
             end;
     end;

     fl.fx:=cos(fl.alpha)*fl.f;
     fl.fy:=sin(fl.alpha)*fl.f;

     ff.fx:=-(efx+fl.fx);
     ff.fy:=-(efy+fl.fy);
     ff.f:=sqrt(sqr(ff.fx)+sqr(ff.fy));
     ff.alpha:=arctan(abs(ff.fy)/abs(ff.fx));

     quadrant:=berechne_quadrant(ff.fx,ff.fy,0,0);

     case quadrant of
          1: begin
                  ff.alpha:=ff.alpha;
             end;
          2: begin
                  ff.alpha:=pi  - ff.alpha;
             end;
          3: begin
                  ff.alpha:=pi  + ff.alpha;
             end;
          4: begin
                  ff.alpha:=2*pi- ff.alpha;
             end;
     end;

     auflager_berechnet:=true;

end;

procedure ausgabe_auflager;
var s:string;
begin
     if auflager_berechnet then begin
        clrscr;
        writeln('Auflagerreaktionen');
        writeln('==================');
        writeln;
        writeln;
        out_f('Festlager :',ff);
        writeln;
        out_f('Loslager  :',fl);
        writeln;
        writeln('Taste drcken'); repeat until keypressed; readln;
     end else begin
         clrscr;
         writeln('Auflager noch nicht berechnet!');
         wartetaste;
     end;
end;
procedure mb(x:real; var mbx,q,t:real);
var mfa,mfb:real;
    i:integer;
begin
     mbx:=0;
     q:=0;
     t:=0;
        mfa:=0;
        mfb:=0;
        i:=1;
        repeat
              if f[i].lx<x then begin
                 with f[i] do begin
                      t:=t+fx;
                      q:=q+fy;
                      mbx:=mbx+fy*(x-lx);
                 end;
              end;
              inc(i);
        until i>anzahl_f;
        if festl.x<x then begin
           t:=t+ff.fx;
           q:=q+ff.fy;
           mfa:=ff.fy*(x-festl.x);
        end else mfa:=0;

        if losl.x<x then begin
           t:=t+fl.fx;
           q:=q+fl.fy;
           mfb:=fl.fy*(x-losl.x);
        end else mfb:=0;

        mbx:=mfa + mfb + mbx;

end;
procedure berechne_mbq_beliebig;
var x,q,t,mbx:real;
    i:integer;
    ende:boolean;
begin
     x:=(losl.x-festl.x)/2;
     q:=0;
     t:=0;
     i:=0;
     ende:=false;
     clrscr;
     if auflager_berechnet then begin
        repeat
             clrscr;
             read1r('Schnitt-X-Koordinate bitte eingeben (in meter):',x);

             mb(x,mbx,q,t);

             writeln;

             writeln('Mb an der stelle x=',x:3:3,'m betr„gt ',mbx:3:3,'Nm');
             writeln('Q an der stelle x=',x:3:3,'m betr„gt ',q:3:3,'N');
             writeln('T an der stelle x=',x:3:3,'m betr„gt ',t:3:3,'N');

             write('Nochmal (j/n) ?');
             repeat until keypressed;
             if readkey='n' then ende:=true;
             writeln;
        until ende;
     end else begin
         writeln('Zuerst schritte 1 u. 2 ausfhren !');
         wartetaste;
     end;
end;
procedure berechne_maxmbq;
var mbx,q,t,xu,xo,x,sx,l:real;
begin
     clrscr;
     x:=0;
     xu:=festl.x;
     xo:=losl.x;
     sx:=0.001*(xo-xu);
     maxQ:=0;
     maxT:=0;
     maxMb:=0;
     mbx:=0;
     q:=0;
     t:=0;

     if festl.x>losl.x then l:=festl.x else l:=losl.x;

     read1r('untere Grenze:',xu);
     read1r('obere Grenze :',xo);
     read1r('Schrittweite bitte eingeben (in meter):',sx);
     if sx=0 then exit;
     writeln;
     x:=xu;

     while(x<(xo-sx)) do begin
           mb(x,mbx,q,t);
           if abs(mbx)>abs(maxMb) then begin
              maxMb:=mbx;
              x_maxmb:=x;
           end;
           if abs(t)>abs(maxt) then begin
              maxt:=t;
              x_maxt:=x;
           end;
           if abs(q)>abs(maxq) then begin
              maxq:=q;
              x_maxq:=x;
           end;
           x:=x+sx;
           writeln('x=',x:3:3);
           gotoxy(wherex,wherey-1);
     end;

     writeln;
     writeln;
     textcolor(lightgreen);
     writeln('maxMb an der stelle x=',x_maxmb:3:3,'m betr„gt ',maxmb:3:3,'Nm');
     writeln('maxQ an der stelle x=',x_maxq:3:3,'m betr„gt ',maxq:3:3,'N');
     writeln('maxT an der stelle x=',x_maxt:3:3,'m betr„gt ',maxt:3:3,'N');
     textcolor(white);

     wartetaste;

     maxmb_berechnet:=true;

end;
function efy(x:real):real;
var i:integer;
    s:real;
begin
     s:=0;
     for i:=1 to anzahl_f do begin
         if f[i].lx<x then begin
            s:=s + f[i].fy;
         end;
     end;
     efy:=s;
end;

function get_fa(x:real):real;
begin if festl.x<x then get_fa:=ff.fy else get_fa:=0; end;

function get_fb(x:real):real;
begin if losl.x<x then get_fb:=fl.fy else get_fb:=0; end;

function ber_q(x:real):real;
var q:real;
begin
     {
        Q := - E Fyi|lxi<x + Fay|xa<x + Fby|xb<x;
     }
     if not auflager_berechnet then begin fehler ('ber_q: Auflager nicht berechnet??'); halt; end;
     q:=0;
     q:= - efy(x) + get_fa(x) + get_fb(x);
     ber_q:=q;
end;
function ber_f(x,e,iy:real):real;
var c0,c1,c2,k,t,q:real;
begin
     {
        c0,c1,c2 ... integrationskonstanten; c1 nicht bestimmbar
     }
     k:=0;
     c1:= 0;
     c0:= festl.x     *     (efy(festl.x) - get_fb(festl.x));
     c2:= festl.x*festl.x * ( - c0 );
     q:=ber_q(x);
     k:=1/(6*e*iy);
     t:=k*(q*x*x*x + c0*x*x + c1*x + c2);

     ber_f:=t;
end;
procedure berechne_f_beliebig;
var x,fx:real;
begin
     {
        f(x):=-1/E*I * 1/2*Mb(x)*x^2
     }
     clrscr;
     x:=(losl.x-festl.x)/2;
     fx:=0;
     repeat
           clrscr;
           gotoxy(1,1);
           read1r('Konstante E (N/mm^2) :',e);
           read1r('Iy          ( cm^3 ) :',iy);
           writeln;
           read1r('x           (  m   ) :',x);

           fx:=ber_f(x,e,iy);
           writeln;
           textcolor(lightgreen);
           writeln('f(x) = ',fx:3:3,'m = ',fx*1000:3:3,'mm');
           textcolor(white);
           writeln;
           write('Nochmal');
     until not frage;
end;
procedure berechne_maxf;
var f,x,xu,xo,dx:real;
begin
     x:=0;
     f:=0; maxf:=0;
     xu:=festl.x;
     xo:=losl.x;
     dx:=(1/1000)*abs(losl.x-festl.x);

     clrscr;
     read1r('Konstante E (N/mm^2) :',e);
     read1r('Iy          ( cm^3 ) :',iy);
     writeln;
     read1r('Xu ( m ) :',xu);
     read1r('Xo ( m ) :',xo);
     read1r('dX ( m ) :',dx);

     x:=xu;
     repeat
           gotoxy(1,8); clreol;
           write1r('x=',x,' m');
           f:=ber_f(x,e,iy);
           if abs(f)>abs(maxf) then begin maxf:=f; x_maxf:=x end;
           x:=x+dx;
     until x>(xo-dx);

     writeln;
     writeln;

     textcolor(lightgreen);
     write1r('maxf = ',maxf*1000,' mm');
     write1r('an der Stelle x=',x_maxf,' m');
     textcolor(white);

     writeln;

     wartetaste;
end;
procedure dimensioniere;
var minW:real;
    sigma_zul:Real;
begin
     clrscr;
     writeln('Dimensionierung OHNE Beachtung der zul.Durchbiegung:');
     writeln('====================================================');
     writeln;
     writeln;
     sigma_zul:=140;
     read1r('max. zul. Spannung (N/mm^2) :',sigma_zul);

     minW:=maxMb/sigma_zul;
     writeln;
     textcolor(lightgreen);
     writeln('min. erford. Widerstandsmoment = ',minW:3:3,'cm^3');
     textcolor(white);
     writeln;
     wartetaste;
end;
procedure menu;
var wahl,c:integer;
    s:string;
begin
     wahl:=-1;
     clrscr;
     writeln('                  Tr„ber V1.15 b');
     writeln('                  ==============');
     writeln;
     writeln;
     writeln;
     writeln('          1......Dateneingabe');
     if daten_vorhanden then textcolor(white) else textcolor(yellow);
     writeln('          2......Auflagerreaktionen berechnen');
     if auflager_berechnet then textcolor(white) else textcolor(yellow);
     writeln('          3......Auflagerreaktionen anzeigen');
     if auflager_berechnet then textcolor(white) else textcolor(yellow);
     writeln('          4......Biegemoment Mb u. Querkraft Q an einer beliebigen');
     writeln('                 Stelle x anzeigen');
     if auflager_berechnet then textcolor(white) else textcolor(yellow);
     writeln('          5......max. Mb berechnen und anzeigen');
     if auflager_berechnet then textcolor(white) else textcolor(yellow);
     writeln('          6......Durchbiegung an einer beliebigen Stelle x');
     writeln('                 berechnen und anzeigen');
     if auflager_berechnet then textcolor(white) else textcolor(yellow);
     writeln('          7......maximale Durchbiegung anzeigen');
     if maxmb_berechnet then textcolor(white) else textcolor(yellow);
     writeln('          8......Dimensionierung');
     textcolor(white);
     writeln;
     writeln('          9......Programmende');
     textcolor(red);
     gotoxy(50,24); write('(C) 1994 by Stefan Eletzhofer');
     gotoxy(10,20);
     while (wahl<0) or (wahl>9) and (c<>0) do begin
           textcolor(lightgreen);
           write('Ihre Wahl:');
           textcolor(white);
           readln(s);
           val(s,wahl,c);
     end;
     case wahl of
          0: init_debug;
          1: if auflager_berechnet then begin init; auflager_berechnet:=false end else init;
          2: if daten_vorhanden then berechne_auflager else fehler('Zuerst Daten eingeben!');
          3: if auflager_berechnet then ausgabe_auflager else fehler('Zuerst Auflager berechnen!');
          4: if auflager_berechnet then berechne_mbq_beliebig else fehler('Zuerst Auflager berechnen!');
          5: if auflager_berechnet then berechne_maxmbq else fehler('Zuerst Auflager berechnen!');
          6: if auflager_berechnet then berechne_f_beliebig else fehler('Zuerst Auflager berechnen!');
          7: if auflager_berechnet then berechne_maxf else fehler('Zuerst Auflager berechnen!');
          8: if maxmb_berechnet then dimensioniere else fehler('Zuerst maximales Biegemoment berechnen!');
          9: ende:=true;
     end;
end;

begin
     highvideo;
     textbackground(black);
     textcolor(white);
     ende:=false;
     maxmb_berechnet:=false;
     auflager_berechnet:=false;
     init_debug;
     daten_vorhanden:=false;
     repeat
           menu;
     until ende;
end.