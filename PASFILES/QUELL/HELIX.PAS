program hhelix;
(*              Program written by: Stefan Eletzhofer;1992/1993
 *
 *              Helix-Spirale, 3-dimensional;
 *              punkte stellen kugeln mit dem radius rk dar;
 *              srk,erk : kugel-start-/endradius
 *              sh,eh   : start-/endh”he der spirale (z-koordinate)
 *              sr,er   : start-/endradius  -"-      (x/y-koordinate)
 *              sw,ew   : start-/endwinkel -"-
 *              ws      : winkelschrittweite
 *              anzp - 1: anzahl der berechneten punkte/kugelmittelpunkte
 *              h,w,r,rk: laufvariable in der berechnungsschleife
 *
 *              !!! sh < eh !!!
 *)
uses crt,graph,vectorun,sgraph;
var sh,eh,sw,ew,sr,er,ws,srk,erk:real;
    hs,rs,rks:real;
    x,y,z,xa,ya,za:real;
    h,w,r,rk,rk_max:real;
    anzp:real;
    i,j,k:integer;
    linear:boolean;
    key:char;
    pfad,fname:string;
    f:text;
procedure write3i(i1,i2,i3:integer);
begin
     writeln(f,i1,'.00 ',i2,'.00 ',i3,'.00');
end;
procedure write3r(i1,i2,i3:real);
begin
     writeln(f,i1:3:3,' ',i2:3:3,' ',i3:3:3);
end;
procedure writevec(i1,i2,i3:real);
begin
     write(f,'< ',i1:3:3,' ',i2:3:3,' ',i3:3:3,' >');
end;
procedure writekugel(nr:integer; x,y,z,r:real);
var rot:integer;
begin
     write(f,'          sphere { ');
     writevec(x,z,y);
     writeln(f,' ',r:3:3,' }      // Nr:',nr);
end;
procedure read1r(is:string; var ir:real);
begin
     write(is);
     readln(ir);
end;
begin
{
     sh:=0; eh:=100; sr:=50; er:=5; sw:=0; ew:=3*360; ws:=15;
     srk:=10;
}
     clrscr;
     writeln('+----------------------------------------+');
     writeln('|       Helix-Berechnung fr Pov 1.0     |');
     writeln('|              v1.0                      |');
     writeln('+----------------------------------------+');
     writeln;
     pfad:='c:\anwender\pov10\incl\';
     write('Filename eingeben: ',pfad);
     readln(fname);
     writeln;
     read1r('sh=',sh);
     read1r('eh=',eh);
     read1r('sr=',sr);
     read1r('er=',er);
     read1r('sw=',sw);
     read1r('ew=',ew);
     read1r('ws=',ws);
     read1r('srk=',srk);
     writeln;

     linear:=false;
     writeln('Kugelradien linear ?');
     key:=readkey;
     case key of
          'j': linear:=true;
          'J': linear:=true;
          'n': linear:=false;
          'N': linear:=false;
     end;
     write('Helix.....');
     assign(f,pfad+fname+'.inc');
     rewrite(f);

     anzp:=(ew-sw) / ws;
     erk:=(srk*er) / sr;
     rks:=(srk-erk) / anzp;
     hs:=(eh-sh) / anzp;
     rs:=(sr-er) / anzp;
     h:=sh;
     r:=sr;
     w:=sw;
     rk:=srk;

     i:=0;
     rk_max:=0;

     xa:=cos(rad(w-ws))*(r+rs);
     ya:=sin(rad(w-ws))*(r+rs);
     za:=h-hs;

     writeln(f,'        union {');

     repeat
           inc(i);
           x:=(cos(rad(w))*r);
           y:=(sin(rad(w))*r);
           z:=h;

           if not linear then
              rk:=abs(sqrt(x*x+y*y+z*z)-sqrt(za*za+xa*xa+ya*ya))/2;

           if rk>rk_max then rk_max:=rk;

           za:=z; xa:=x; ya:=y;

           writekugel(i,x,y,z,rk);

           w:=w+ws;
           h:=h+hs;
           r:=r-rs;
           if linear then rk:=rk-rks;
     until i=anzp+1;
     writeln(f,'   }');
     write(f,'   bounded_by { box {');
     if sr>er then begin
        writevec((-sr-rk_max-2)*sqrt(2),(-sr-rk_max-2)*sqrt(2),sh);
        writevec(( sr+rk_max+2)*sqrt(2),( sr+rk_max+2)*sqrt(2),eh);
     end else begin
        writevec((-er-rk_max-2)*sqrt(2),(-er-rk_max-2)*sqrt(2),sh);
        writevec(( er+rk_max+2)*sqrt(2),( er+rk_max+2)*sqrt(2),eh);
     end;
     writeln(f,' } }');
     close(f);
     writeln('Fertig');
     writeln(anzp:3:0,' Kugeln.');
     readln;
end.
