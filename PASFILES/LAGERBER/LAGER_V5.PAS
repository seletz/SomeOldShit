program auflager;
uses crt,strings;
const festlager=1;
      loslager=2;
      eingespannt=3;
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
     traeger = record
                     l:real;
                     xo,xu:real;
                     iy:real;
                     a,b:lager;
                     fa,fb:kraft;
                     maxmb,maxq,maxt,maxf,x_maxf,x_maxq,x_maxt,x_maxmb:real;
                     minW,minI,zulMb:real;
               end;

var  f: array [0..10] of kraft;
     e:real;
     anzahl_F:integer;
     ende:boolean;
     tr:traeger;
     maxf_berechnet,maxmb_berechnet,auflager_berechnet,daten_vorhanden:boolean;
     pfad,s:string;

function pow(x,y:real):real;
begin if x>0 then pow:=exp(y*ln(x)) else pow:=0; end;
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
procedure read1r(s:string; var x:real; xu,xo:real);
var xx:real;
begin
     write(s); writeln(x:3:3);
     writeln;
     write('Wert „ndern');
     if frage then begin
              xx:=x;
              gotoxy(wherex,wherey-2);
        repeat
              gotoxy(wherex,wherey-1);
              write(s); readln(xx);
              x:=xx;
        until (xx>=xu) and (xx<=xo);
              gotoxy(wherex,wherey-1); clreol; writeln;
              gotoxy(wherex,wherey-1); write(s); writeln(x:3:3);
              gotoxy(wherex,wherey+1); clreol; writeln;
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
     with tr.b do begin
          x:=10;
          y:=0;
          alpha:=0*rad;
          typ:=loslager;
     end;
     with tr.a do begin
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
     tr.iy:=50000;
     tr.xu:=0;
     tr.xo:=10;
     tr.l:=10;
     pfad:='c:\tp\lagerber\';
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
     with tr.a do
          begin
               writeln('Position Festlager eingeben (Nullpunkt beliebig):');
               read1r('X-Koordinate:',x,-1e37,1e37);
               read1r('Y-Koordinate:',y,-1e37,1e37);
          end;
     with tr.b do
          begin
               writeln;
               writeln('Position Loslager eingeben:');
               read1r('X-Koordinate:',x,-1e37,1e37);
               read1r('Y-Koordinate:',y,-1e37,1e37);
               alpha:=alpha/rad;
               read1r('Winkel zur positiven X-Achse:',alpha,0,360);
               alpha:=alpha*rad;
          end;
     writeln;
     repeat
           writeln;
           n:=anzahl_f;
           read1r('Anzahl der angreifenden Kr„fte (1..10; 0 => Ende):',n,1,10);
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
                        read1r('X-Koordinate    : ',lx,-1e37,1e37);
                        read1r('Y-Koordinate    : ',ly,-1e37,1e37);
                        read1r('Betrag in Newton: ',f,1,1e37);
                        alpha:=alpha/rad;
                        read1r('Winkel zur positiven X-Achse in Grad: ',alpha,0,360);
                        alpha:=alpha*rad;
                        read1r('X-komponente in Newton: ',fx,1,1e37);
                        read1r('Y-komponente in Newton: ',fy,1,1e37);
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

         quadrant:=berechne_quadrant(lx,ly,tr.a.x,tr.a.y);

         fx:=cos(alpha)*f;
         fy:=sin(alpha)*f;

         efx:=efx + fx;
         efy:=efy + fy;

         yi:=abs(ly-tr.a.y);
         xi:=abs(lx-tr.a.y);

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

     yi:=abs(tr.b.y-tr.a.y);
     xi:=abs(tr.b.x-tr.a.x);
     tr.fb.alpha:=tr.b.alpha+pi/2;

     quadrant:=berechne_quadrant(tr.b.x,tr.b.y,tr.a.x,tr.a.y);
     case quadrant of
          1: begin
                  tr.fb.f:=(-em)/(+sin(tr.fb.alpha)*xi-cos(tr.fb.alpha)*yi);
             end;
          2: begin
                  tr.fb.f:=(-em)/(-sin(tr.fb.alpha)*xi-cos(tr.fb.alpha)*yi);
             end;
          3: begin
                  tr.fb.f:=(-em)/(-sin(tr.fb.alpha)*xi+cos(tr.fb.alpha)*yi);
             end;
          4: begin
                  tr.fb.f:=(-em)/(+sin(tr.fb.alpha)*xi+cos(tr.fb.alpha)*yi);
             end;
     end;

     tr.fb.fx:=cos(tr.fb.alpha)*tr.fb.f;
     tr.fb.fy:=sin(tr.fb.alpha)*tr.fb.f;

     tr.fa.fx:=-(efx+tr.fb.fx);
     tr.fa.fy:=-(efy+tr.fb.fy);
     tr.fa.f:=sqrt(sqr(tr.fa.fx)+sqr(tr.fa.fy));
     tr.fa.alpha:=arctan(abs(tr.fa.fy)/abs(tr.fa.fx));

     quadrant:=berechne_quadrant(tr.fa.fx,tr.fa.fy,0,0);

     case quadrant of
          1: begin
                  tr.fa.alpha:=tr.fa.alpha;
             end;
          2: begin
                  tr.fa.alpha:=pi  - tr.fa.alpha;
             end;
          3: begin
                  tr.fa.alpha:=pi  + tr.fa.alpha;
             end;
          4: begin
                  tr.fa.alpha:=2*pi- tr.fa.alpha;
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
        out_f('Festlager :',tr.fa);
        writeln;
        out_f('Loslager  :',tr.fb);
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
        if tr.a.x<x then begin
           t:=t+tr.fa.fx;
           q:=q+tr.fa.fy;
           mfa:=tr.fa.fy*(x-tr.a.x);
        end else mfa:=0;

        if tr.b.x<x then begin
           t:=t+tr.fb.fx;
           q:=q+tr.fb.fy;
           mfb:=tr.fb.fy*(x-tr.b.x);
        end else mfb:=0;

        mbx:=mfa + mfb + mbx;

end;
procedure berechne_mbq_beliebig;
var x,q,t,mbx:real;
    i:integer;
    ende:boolean;
begin
     x:=(tr.b.x-tr.a.x)/2;
     q:=0;
     t:=0;
     i:=0;
     ende:=false;
     clrscr;
     if auflager_berechnet then begin
        repeat
             clrscr;
             read1r('Schnitt-X-Koordinate bitte eingeben (in meter):',x,-1e37,1e37);

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
     xu:=tr.xu;
     xo:=tr.xo;
     sx:=0.001*(xo-xu);
     tr.maxQ:=0;
     tr.maxT:=0;
     tr.maxMb:=0;
     mbx:=0;
     q:=0;
     t:=0;

     if tr.a.x>tr.b.x then l:=tr.a.x else l:=tr.b.x;

     read1r('untere Grenze:',xu,-1e37,1e37);
     read1r('obere Grenze :',xo,-1e37,1e37);
     read1r('Schrittweite bitte eingeben (in meter):',sx,-1e37,1e37);
     if sx=0 then exit;
     writeln;
     x:=xu;

     while(x<(xo-sx)) do begin
           mb(x,mbx,q,t);
           if abs(mbx)>abs(tr.maxMb) then begin
              tr.maxMb:=mbx;
              tr.x_maxmb:=x;
           end;
           if abs(t)>abs(tr.maxt) then begin
              tr.maxt:=t;
              tr.x_maxt:=x;
           end;
           if abs(q)>abs(tr.maxq) then begin
              tr.maxq:=q;
              tr.x_maxq:=x;
           end;
           x:=x+sx;
           writeln('x=',x:3:3);
           gotoxy(wherex,wherey-1);
     end;

     writeln;
     writeln;
     textcolor(lightgreen);
     writeln('maxMb an der stelle x=',tr.x_maxmb:3:3,'m betr„gt ',tr.maxmb:3:3,'Nm');
     writeln('maxQ an der stelle x=',tr.x_maxq:3:3,'m betr„gt ',tr.maxq:3:3,'N');
     writeln('maxT an der stelle x=',tr.x_maxt:3:3,'m betr„gt ',tr.maxt:3:3,'N');
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
begin if tr.a.x<x then get_fa:=tr.fa.fy else get_fa:=0; end;

function get_fb(x:real):real;
begin if tr.b.x<x then get_fb:=tr.fb.fy else get_fb:=0; end;

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
var a,b,l:real;
    t,tf:real;
    i:integer;
begin
     {

                        F„lle siehe Dubbel C20


     }
     t:=0;

     for i:=1 to anzahl_f do
         begin
              tf:=f[i].fy;
              if f[i].lx<>tr.a.x then
                 if f[i].lx<tr.a.x then begin
                    { Fall 11 umgekehrt }
                 end else
                 if (f[i].lx>tr.a.x) and (f[i].lx<tr.b.x) then begin
                    { Fall 2}

                    writeln('Kraft ',i,': Fall 2');

                    a:=f[i].lx-tr.a.x;
                    b:=(tr.b.x-tr.a.x)-a;
                    l:=a+b;
                    write1r('a=',a,'m');
                    write1r('b=',b,'m');
                    if a=b then      t:= t + (tf*pow(l,3))/(48*e*iy)*(3*x/l-4*pow(x/l,3))
                    else
                        if x<=a then t:= t + (tf*a*b*b)/(6*e*iy)*((1+l/b)*    x/l - pow( x ,3)/(a*b*l))
                        else         t:= t + (tf*a*a*b)/(6*e*iy)*((1+l/a)*(l-x)/l - pow(l-x,3)/(b*a*l));

                 end else
                 if f[i].lx<tr.b.x then begin
                    { Fall 11 }

                    writeln('Kraft ',i,': Fall 11');

                    a:=f[i].lx-tr.b.x;
                    b:=x-tr.b.x;
                    l:=tr.b.x-tr.a.x;

                    if x<=l then t:= t - (tf*a*l*l/(6*e*iy)*(x/l-pow(x/l,3)));
                    if x>l  then t:= t + (tf*pow(a,3)/(6*e*iy)*(2*l*b/(a*a)+3*pow(b/l,2)-pow(b/l,3)));

                 end;
         end;

     ber_f:=100*t;
end;
procedure berechne_f_beliebig;
var x,fx:real;
begin
     {
        f(x):=-1/E*I * 1/2*Mb(x)*x^2
     }
     clrscr;
     x:=(tr.b.x-tr.a.x)/2;
     fx:=0;
     repeat
           clrscr;
           gotoxy(1,1);
           read1r('Konstante E (N/mm^2) :',e,1,1e37);
           read1r('Iy          ( cm^3 ) :',tr.iy,0.01,1e37);
           writeln;
           read1r('x           (  m   ) :',x,-1e37,1e37);

           fx:=ber_f(x,e,tr.iy);
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
     f:=0; tr.maxf:=0;
     xu:=tr.xu;
     xo:=tr.xo;
     dx:=(xo-xu)/1000;
     clrscr;
     read1r('Konstante E (N/mm^2) :',e,1,1e37);
     read1r('Iy          ( cm^3 ) :',tr.iy,0.01,1e37);
     writeln;
     read1r('Xu ( m ) :',xu,-1e37,1e37);
     read1r('Xo ( m ) :',xo,-1e37,1e37);
     read1r('dX ( m ) :',dx,-1e37,1e37);

     x:=xu;
     repeat
           gotoxy(1,8); clreol;
           write1r('x=',x,' m');
           f:=ber_f(x,e,tr.iy);
           if abs(f)>abs(tr.maxf) then begin tr.maxf:=f; tr.x_maxf:=x end;
           x:=x+dx;
     until x>(xo-dx);

     tr.maxf:=1000*tr.maxf;

     writeln;
     writeln;

     textcolor(lightgreen);
     write1r('maxf = ',tr.maxf,' mm');
     write1r('an der Stelle x=',tr.x_maxf,' m');
     textcolor(white);

     writeln;

     wartetaste;

     maxf_berechnet:=true;
end;
procedure dimensioniere;
var minW:real;
    sigma_zul:Real;
    fzul:real;
    d:real;
    i,j:integer;
begin
     clrscr;
     writeln('Dimensionierung OHNE Beachtung der zul.Durchbiegung:');
     writeln('====================================================');
     writeln;
     writeln;
     sigma_zul:=140;
     read1r('max. zul. Spannung (N/mm^2) :',sigma_zul,0.01,1e37);

     minW:=tr.maxMb/sigma_zul;
     tr.minw:=minw;
     writeln;
     textcolor(lightgreen);
     writeln('min. erford. Widerstandsmoment = ',minW:3:3,'cm^3');
     textcolor(white);
     writeln;
  if maxf_berechnet then begin
     writeln('Dimensionierung M I T Beachtung der zul.Durchbiegung:');
     writeln('====================================================');
     writeln;

     fzul:=tr.l/500 * 1000;

     read1r('max. zul. Durchbiegung eingeben (in mm):',fzul,-1e37,1e37);
     writeln;

     tr.minI:=abs(tr.iy*(tr.maxf/fzul));

     writeln;
     textcolor(lightgreen);
     writeln('min. erford. Fl„chentr„gheitsmoment = ',tr.minI:3:3,'cm^4');
     textcolor(yellow);
     writeln;
     writeln('vorhandenes  Fl„chentr„gheitsmoment = ',tr.iy:3:3,'cm^4');
     writeln;
     if tr.mini<tr.iy then begin
        textcolor(green+blink);
        writeln('Iy vorh > Iy erf. => OK !');
        writeln;
        write1r('Sicherheit :',tr.iy/tr.minI,'');
     end else begin
        textcolor(red+blink);
        writeln('Iy vorh < Iy erf. => UNTERDIMENSIONIERT !');
        writeln;
        write1r('Sicherheit :',tr.iy/tr.minI,'');
     end;

     textcolor(white);
     writeln;

  end;
     wartetaste;
end;
procedure optimize; begin end;
procedure disk_menu;
var wahl,c,i:integer;
    s:string;
    fi:text;
begin
     wahl:=-1;
     clrscr;
     writeln('                  Disk Menu');
     writeln('                  =========');
     writeln;
     writeln;
     writeln;
     writeln('          1......Laden');
     writeln('          2......Speichern');
     writeln;
     writeln('          0......Ende');
     gotoxy(5,15);
     while (wahl<0) or (wahl>2) and (c<>0)  or ende do begin
           textcolor(lightgreen);
           write('Ihre Wahl:');
           textcolor(white);
           readln(s);
           val(s,wahl,c);
     end;
     case wahl of
          0: ;
          1: begin
                  gotoxy(5,17);
                  write('Name bitte (OHNE .tbr)'); readln(s);
                  s:=pfad+s+'.tbr';
                  assign(fi,s);
                  reset(fi);
                  readln(fi,s);
                  if s<>'Tr„ber-datei' then begin
                     fehler('Keine Tr„ber-Datei !');
                  end else begin
                      readln(fi,anzahl_f);
                      with tr do begin
                           readln(fi,iy);
                           readln(fi,a.x);
                           readln(fi,a.y);
                           readln(fi,a.alpha); a.alpha:=a.alpha*rad;
                           readln(fi,a.typ);
                           readln(fi,b.x);
                           readln(fi,b.y);
                           readln(fi,b.alpha); b.alpha:=b.alpha*rad;
                           readln(fi,b.typ);
                      end;
                      for i:=1 to anzahl_f do begin
                          with f[i] do begin
                               readln(fi,lx);
                               readln(fi,ly);
                               readln(fi,f);
                               readln(fi,alpha); alpha:=alpha*rad;
                          end;
                      end;
                      close(fi)
                  end;
             end;

          2: begin
                  gotoxy(5,17);
                  write('Name bitte (OHNE .tbr)'); readln(s);
                  s:=pfad+s+'.tbr';
                  assign(fi,s);
                  rewrite(fi);
                  writeln(fi,'Tr„ber-datei');
                      writeln(fi,anzahl_f);
                      with tr do begin
                           writeln(fi,iy:3:3);
                           writeln(fi,a.x:3:3);
                           writeln(fi,a.y:3:3);
                           writeln(fi,a.alpha/rad:3:3);
                           writeln(fi,a.typ);
                           writeln(fi,b.x:3:3);
                           writeln(fi,b.y:3:3);
                           writeln(fi,b.alpha/rad:3:3);
                           writeln(fi,b.typ);
                      end;
                      for i:=1 to anzahl_f do begin
                          with f[i] do begin
                               writeln(fi,lx:3:3);
                               writeln(fi,ly:3:3);
                               writeln(fi,f:3:3);
                               writeln(fi,alpha/rad:3:3);
                          end;
                      end;
                  close(fi);
             end;
     end;
end;
procedure tabelle; begin end;
procedure init_hand; begin end;
procedure config; begin end;

procedure menu;
var wahl,c:integer;
    s:string;
begin
     wahl:=-1;
     clrscr;
     writeln('                  Tr„ber V1.25 b');
     writeln('                  ===============');
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
     if maxmb_berechnet then textcolor(white) else textcolor(yellow);
     writeln('          9......Optimierung');
     textcolor(white);
     writeln('          10.....Daten von Hand eingeben');
     writeln('          11.....Konfiguration');
     writeln('          12.....Tabelle');
     writeln;
     writeln('          13.....Disk-opreationen');
     writeln;
     writeln('          0.....Programmende');
     textcolor(red);
     gotoxy(50,24); write('(C) 1994 by Stefan Eletzhofer');
     gotoxy(10,25);
     while (wahl<0) or (wahl>9) and (c<>0)  or ende do begin
           textcolor(lightgreen);
           write('Ihre Wahl:');
           textcolor(white);
           readln(s);
           val(s,wahl,c);
     end;
     case wahl of
          0: ende:=true;
          1: if auflager_berechnet then begin init; auflager_berechnet:=false end else init;
          2: if daten_vorhanden then berechne_auflager else fehler('Zuerst Daten eingeben!');
          3: if auflager_berechnet then ausgabe_auflager else fehler('Zuerst Auflager berechnen!');
          4: if auflager_berechnet then berechne_mbq_beliebig else fehler('Zuerst Auflager berechnen!');
          5: if auflager_berechnet then berechne_maxmbq else fehler('Zuerst Auflager berechnen!');
          6: if auflager_berechnet then berechne_f_beliebig else fehler('Zuerst Auflager berechnen!');
          7: if auflager_berechnet then berechne_maxf else fehler('Zuerst Auflager berechnen!');
          8: if maxmb_berechnet then dimensioniere else fehler('Zuerst maximales Biegemoment berechnen!');
          9: optimize;
          10: init_hand;
          12: Tabelle;
          11: Config;
          13: Disk_menu;
     end;
end;

begin
     highvideo;
     textbackground(black);
     textcolor(white);
     ende:=false;
     maxmb_berechnet:=false;
     auflager_berechnet:=false;
     maxf_berechnet:=false;
     init_debug;
     repeat
           menu;
     until ende;
end.