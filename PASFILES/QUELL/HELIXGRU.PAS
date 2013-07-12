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
 *
 *)
uses crt,graph,vectorun,sgraph;
var sh,eh,sw,ew,sr,er,ws,srk,erk:integer;
    hs,rs,rks:integer;
    x,y,z:integer;
    h,w,r,rk:integer;
    anzp:integer;
    i,j,k:integer;
begin
     clrscr;

     sh:=10; eh:=100; sr:=250; er:=10; sw:=0; ew:=360; ws:=18;
     srk:=200;
     anzp:=(ew-sw) div ws;
     erk:=(srk*er) div sr;
     rks:=(srk-erk) div anzp;
     hs:=(eh-sh) div anzp;
     rs:=(sr-er) div anzp;

     writeln('Kugeln ges:',anzp,' Endh:',eh,' Wischr:',ws,' Startrad:',sr);
     readln;

     h:=sh;
     r:=sr;
     w:=sw;
     rk:=srk;

     i:=0;

     repeat
           inc(i);
           x:=round(cos(rad(w))*r);
           y:=round(sin(rad(w))*r);
           z:=h;

           writeln('Kugel nr ',i,' :  x=',x,' y=',y,' z=',z,' r=',rk);

           w:=w+ws;
           h:=h+hs;
           r:=r-rs;
           rk:=rk-rks;
     until w>ew;

     readln;
end.
