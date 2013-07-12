program auflager;
uses crt,strings;
const maxf:integer=10;
      festlager=1;
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
     anzahl_F:integer;
     ende:boolean;
     maxmb,maxq,maxt:real;
     maxmb_berechnet,auflager_berechnet,daten_vorhanden:boolean;
     s:string;

procedure out_f(s:string; F:kraft);
begin
     writeln( s,'   Betrag: ',F.f:3:3,' N;',' Richtung:',F.alpha*180/pi:3:3,' Grad;');
     writeln(' Fx: ',f.fx:3:3,' N; Fy: ',F.fy:3:3,' N;');
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
procedure read1r(s:string; var x:real);
begin
     write(s); writeln(x:3:3);
     writeln;
     write('Wert „ndern');
     if frage then begin
        gotoxy(wherex,wherey-3);
        write(s); readln(x);
        gotoxy(wherex,wherey-1); writeln('                                                       ');
        gotoxy(wherex,wherey-1); write(s); writeln(x:3:3);
        gotoxy(wherex,wherey+1); writeln('                                                       ');
        gotoxy(wherex,wherey-2);
     end else begin
        gotoxy(wherex,wherey-1); writeln('                                                       ');
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
          x:=0.3;
          y:=0;
          alpha:=30*rad;
          typ:=loslager;
     end;
     with festl do begin
          x:=0;
          y:=0;
          alpha:=0;
          typ:=festlager;
     end;
     with f[1] do begin
          lx:=0.6;
          ly:=0.4;
          f:=350;
          alpha:=270*rad;
          fx:=0;
          fy:=0;
     end;
     daten_vorhanden:=true;
     maxmb_berechnet:=false;
     auflager_berechnet:=false;
end;
procedure init;
var i:integer;
    n:real;
    s:string;
    ok:boolean;
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
                        writeln('Kraft nummer ',i);
                        writeln;
                        read1r('X-Koordinate    : ',lx);
                        read1r('Y-Koordinate    : ',ly);
                        read1r('Betrag in Newton: ',f);
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
     writeln('i=',i);
     writeln('Summe der Fxi      : ',efx:3:3,'N');
     writeln('Summe der Fyi      : ',efy:3:3,'N');
     writeln('Summe der Momente X: Fxi * yi =',fx:3:3,'N * ',yi:3:3,'m = ',emx:3:3,'Nm');
     writeln('Summe der Momente Y: Fyi * xi =',fy:3:3,'N * ',xi:3:3,'m = ',emy:3:3,'Nm');
     end; end;

     em:=emx + emy;
     writeln('Summe der Momente ges.: ',em:3:3,'Nm');


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

     wartetaste;

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
     ende:=false;
     clrscr;
     if auflager_berechnet then begin
        repeat
             writeln;

             read1r('Schnitt-X-Koordinate bitte eingeben (in meter):',x);

             mb(x,mbx,q,t);

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
var mbx,q,t,x_q,x_t,x_mb,xu,xo,x,sx,l:real;
begin
     clrscr;
     x:=0;
     sx:=0;
     maxQ:=0;
     maxT:=0;
     maxMb:=0;
     mbx:=0;
     q:=0;
     t:=0;
     x_q:=0;
     x_t:=0;
     x_mb:=0;

     if festl.x>losl.x then l:=festl.x else l:=losl.x;

     read1r('untere Grenze:',xu);
     read1r('obere Grenze :',xo);
     read1r('Schrittweite bitte eingeben (in meter):',sx);

     writeln;
     x:=xu;

     while(x<(xo-sx)) do begin
           mb(x,mbx,q,t);
           if abs(mbx)>abs(maxMb) then begin
              maxMb:=mbx;
              x_mb:=x;
           end;
           if abs(t)>abs(maxt) then begin
              maxt:=t;
              x_t:=x;
           end;
           if abs(q)>abs(maxq) then begin
              maxq:=q;
              x_q:=x;
           end;
           x:=x+sx;
           writeln('x=',x:3:3);
           gotoxy(wherex,wherey-1);
     end;

     writeln;
     writeln;
     writeln('maxMb an der stelle x=',x_mb:3:3,'m betr„gt ',maxmb:3:3,'Nm');
     writeln('maxQ an der stelle x=',x_q:3:3,'m betr„gt ',maxq:3:3,'N');
     writeln('maxT an der stelle x=',x_t:3:3,'m betr„gt ',maxt:3:3,'N');


     wartetaste;

     maxmb_berechnet:=true;

end;
procedure berechne_f_beliebig;
begin
end;
procedure berechne_maxf;
begin
end;
procedure dimensioniere;
begin
end;
procedure menu;
var wahl,c:integer;
    s:string;
begin
     wahl:=-1;
     clrscr;
     writeln('                  Tr„ber V1.0');
     writeln('                  ===========');
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
     gotoxy(50,24); write('(C) 1994 by Stefan Eletzhofer');
     gotoxy(10,20);
     while (wahl<0) or (wahl>9) and (c<>0) do begin
           write('Ihre Wahl:');
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