program povunittest;
uses crt,RT_math,povunit;

var a,b,c,d,m:rt_vector;
    w:integer;
    ws:integer;
    i:integer;
begin
     clrscr;
     ws:=10;
     w:=0;
     i:=0;
     filename('c:\anwender\pov10\scn\test.pov');
     writeln(f,'#include "buh.inc"');
     m:=NULL;

     vinit(0,10,-100,a);
     camera(a,NULL);

     vinit(0,50,0,b);
     licht(b);

     Object_;
             union;
                   repeat
                    inc(i);
                    m.y:=10;
                    m.x:=50*cos(w*RAD);
                    m.z:=50*sin(w*RAD);
                    writevector(' M:=',m);
                    sphere(m,null,null,null,10);
                    tabw; writeln(f,'// kugel nummer ',i);
                    tabdone;
                    w:=w+ws;
                   until w>=360;
             TABDONE;
             texture('Mirror');
             TABDONE;

     done;
     fileend;
end.