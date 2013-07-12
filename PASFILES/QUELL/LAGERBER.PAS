program auflager;
uses crt,strings;
const maxf:integer=10;

type kraft = record
                   f,fx,fy:real;
                   lx,ly:real;
                   alpha:real;
             end;
var  f: array [0..10] of kraft;
     fa,fb:kraft;
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
     writeln('Bitte eine Taste drÅcken.');
     repeat until keypressed; readln
end;

procedure read1r(s:string; var x:real);
begin write(s); readln(x) end;

procedure init_debug;
begin
     {

        einfacher TrÑger fÅr testzwecke, '0' im MenÅ drÅcken

     }
     anzahl_f:=2;
     with fa do begin
          lx:=0;
          ly:=0;
          f:=0;
          alpha:=0;
          fx:=0;
          fy:=0;
     end;
     with fb do begin
          lx:=5;
          ly:=0;
          f:=0;
          alpha:=0;
          fx:=0;
          fy:=0;
     end;
     with f[1] do begin
          lx:=2.5;
          ly:=0;
          f:=1000*sqrt(2);
          alpha:=pi/4;
          fx:=-1000;
          fy:=-1000;
     end;
     with f[2] do begin
          lx:=10;
          ly:=0;
          f:=1000;
          alpha:=pi/2;
          fx:=0;
          fy:=-1000;
     end;
     daten_vorhanden:=true;
     maxmb_berechnet:=false;
     auflager_berechnet:=false;
     clrscr;
     writeln('Testdaten installiert');
     wartetaste;
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
     if daten_vorhanden then begin
        write('Bereits Daten eingegeben; diese lîschen(j/n) ?');
        repeat until keypressed;
        if readkey='j' then ok:=true;
     end else ok:=true;
     writeln;
     {

     A ..... Festlager
     B ..... Loslager

     Fa u. Fb immer in positiver Richtung


             A()---------------------------()B
              /\                           /\


     }
if ok then begin
     with fa do
          begin
               writeln('Position Festlager eingeben (Nullpunkt beliebig):');
               read1r('X-Koordinate:',lx);
               read1r('Y-Koordinate:',ly);
               f:=0;
               fx:=0;
               fy:=0;
          end;
     with fb do
          begin
               writeln;
               writeln('Position Loslager eingeben:');
               read1r('X-Koordinate:',lx);
               read1r('Y-Koordinate:',ly);
               f:=0;
               fx:=0;
               fy:=0;

          end;
     writeln;
     repeat
           writeln;
           read1r('Anzahl der angreifenden KrÑfte (1..10; 0 => Ende):',n);
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
                        f:=0;
                        fx:=0;
                        fy:=0;
                        alpha:=0;
                        writeln('Kraft nummer ',i);
                        writeln;
                        read1r('X-Koordinate:',lx);
                        read1r('Y-Koordinate:',ly);
                        {
                        read1r('Betrag in Newton',f);
                        read1r('Winkel zur positiven X-Achse in Grad:',alpha);
                        }
                        read1r('X-komponente in Newton:',fx);
                        read1r('Y-komponente in Newton:',fy);
                        {
                        if false then begin
                           fx:=cos(alpha)*f;
                           fy:=sin(alpha)*f;
                        end else begin
                        }
                            f := sqrt(sqr(fx)+sqr(fy));
                            if fx<>0 then
                               alpha := arctan(fy/fx)
                            else
                               alpha := pi*fy/abs(2*fy);

                        {end;}

                        writeln;
                   end;
         end;
end;
     daten_vorhanden:=true;
end;

procedure berechne_auflager;
var i:integer;
    lx,ly:real;
    em,efx,efy:real;
begin
     if daten_vorhanden then begin
     {
        zuerst E M(a)=0; => fb
     }

     clrscr;
     writeln;
     writeln;
     writeln('          Berechne...');

     EM:=0;
     Efx:=0;
     Efy:=0;

     for i:=1 to anzahl_F do
         begin
              with f[i] do
                   begin

                        EM := EM + fy*(lx-fa.lx) + fx*(ly-fa.ly);
                        EFx := EFx + fx;
                        EFy := EFy + fy;
                   end;
         end;

     with fb do
          begin
               if (lx-fa.lx)<>0 then fy:= - EM / (lx - fa.lx);
               fx := 0; { Loslager !! }

               f := abs(fy);
          end;

     {
        jetzt fa.x u. fa.y aus E Fx = 0; u. E Fy = 0;
     }

     with fa do
          begin
               fx:= - fb.fx - EFx;
               fy:= - fb.fy - EFy;
               f := sqrt(sqr(fx)+sqr(fy));
          end;
     auflager_berechnet:=true;
     write('Ok');
     wartetaste;
     end else begin
         clrscr;
         writeln('Zuerst Daten eingeben!');
         wartetaste;
     end;

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
        out_f('Festlager Fa:',fa);
        writeln;
        out_f('Loslager  Fb:',fb);
        writeln;
        writeln('Taste drÅcken'); repeat until keypressed; readln;
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
        if fa.lx<x then begin
           t:=t+fa.fx;
           q:=q+fa.fy;
           mfa:=fa.fy*(x-fa.lx);
        end else mfa:=0;

        if fb.lx<x then begin
           t:=t+fb.fx;
           q:=q+fb.fy;
           mfb:=fb.fy*(x-fb.lx);
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

             writeln('Mb an der stelle x=',x:3:3,'m betrÑgt ',mbx:3:3,'Nm');
             writeln('Q an der stelle x=',x:3:3,'m betrÑgt ',q:3:3,'N');
             writeln('T an der stelle x=',x:3:3,'m betrÑgt ',t:3:3,'N');

             write('Nochmal (j/n) ?');
             repeat until keypressed;
             if readkey='n' then ende:=true;
             writeln;
        until ende;
     end else begin
         writeln('Zuerst schritte 1 u. 2 ausfÅhren !');
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

     if fa.lx>fb.lx then l:=fa.lx else l:=fb.lx;

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
     writeln('maxMb an der stelle x=',x_mb:3:3,'m betrÑgt ',maxmb:3:3,'Nm');
     writeln('maxQ an der stelle x=',x_q:3:3,'m betrÑgt ',maxq:3:3,'N');
     writeln('maxT an der stelle x=',x_t:3:3,'m betrÑgt ',maxt:3:3,'N');


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
     writeln('                  TrÑber V1.0');
     writeln('                  ===========');
     writeln;
     writeln;
     writeln;
     writeln('          1......Dateneingabe');
     writeln('          2......Auflagerreaktionen berechnen');
     writeln('          3......Auflagerreaktionen anzeigen');
     writeln('          4......Biegemoment Mb u. Querkraft Q an einer beliebigen');
     writeln('                 Stelle x anzeigen');
     writeln('          5......max. Mb berechnen und anzeigen');
     writeln('          6......Durchbiegung an einer beliebigen Stelle x');
     writeln('                 berechnen und anzeigen');
     writeln('          7......maximale Durchbiegung anzeigen');
     writeln('          8......Dimensionierung');
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
          1: init;
          2: berechne_auflager;
          3: ausgabe_auflager;
          4: berechne_mbq_beliebig;
          5: berechne_maxmbq;
          6: berechne_f_beliebig;
          7: berechne_maxf;
          8: dimensioniere;
          9: ende:=true;
     end;
end;

begin
     ende:=false;
     maxmb_berechnet:=false;
     auflager_berechnet:=false;
     daten_vorhanden:=false;
     repeat
           menu;
     until ende;
end.