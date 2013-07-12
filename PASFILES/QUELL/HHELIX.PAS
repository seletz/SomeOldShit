program hhelix;
uses crt,graph,vectorun,sgraph;
var sh,eh,sw,ew,sr1,er1,sr,er,ws:real;
    hs,rs,r1s:real;
    x,y,z:integer;
    h,w,r,r1:real;
    anzp:real;

    p:array [1..80] of vector;
    pa:array [1..80] of vector;

    alpha,beta,gamma:real;
    flpt:integer;
    fcount:integer;

    x1,y1,x2,y2:real;
    xmh,ymh:integer;
    i,j,k:integer;

    outf:text;
    outf2:text;
    outf3:text;
    fn:string;
    input:string;
procedure makefl(radius:real; punkte:integer);
var i:integer;
    ws,w:real;
begin
     ws:=(2*pi)/punkte;
     w:=0;
     for i:=1 to punkte do
         begin
              p[i].x:=cos(w)*radius;
              p[i].y:=0;
              p[i].z:=sin(w)*radius;
              w:=w+ws;
         end;
end;
procedure drehefl(winkel:real; punkte:integer);
var i:integer; wrad:real;
begin
     wrad:=rad(winkel);
     for i:=1 to punkte do
         begin
              p[i].x:=p[i].x*cos(wrad)+p[i].y*sin(wrad);
              p[i].y:=-p[i].x*sin(wrad)+p[i].y*cos(wrad);
         end;
end;
procedure transfl(x,y,z:real; punkte:integer);
var i:integer; v:vector;
begin
     v.x:=x;
     v.y:=y;
     v.z:=z;

     for i:=1 to punkte do
         begin
              vadd(p[i],v,p[i]);
         end;
end;
procedure writefl(punkte:integer);
var i:integer;
begin
     for i:=1 to punkte do
         begin
              writeln(outf,round(p[i].x),' ',round(p[i].y),' ',
                      round(p[i].z));
         end;
end;




begin
     clrscr;
     fn:='c:\temp\test.obt';
     assign(outf,'c:\temp\punkte');
     assign(outf2,'c:\temp\fl„chen');
     rewrite(outf2);
     rewrite(outf);

     writeln(outf,'HM_OBT');
     writeln(outf,'1.000000');
     flpt:=8;
     sr1:=40;
     sh:=10; eh:=350; sr:=150; er:=20; sw:=0; ew:=720; ws:=10;

     alpha:=0; beta:=0;

     anzp:=(ew-sw) / ws;
     hs:=(eh-sh) / anzp;
     rs:=(sr-er) / anzp;
     er1:=(sr1*er) / sr;
     r1s:=(sr1-er1) / anzp;

     writeln(outf,round(anzp*flpt));

     writeln('Punkte:',round(anzp*flpt));
     writeln('Fl„chen:',round((anzp-1)*flpt));
     writeln(outf2,round((anzp-1)*flpt));

     readln;

     h:=sh;
     r:=sr;
     w:=sw;
     r1:=sr1;

     grafikein;

     xmh:=getmaxx div 2;
     ymh:=getmaxy div 2;

     fcount:=0;
     repeat
           x:=round(cos(rad(w))*r);
           y:=round(sin(rad(w))*r);
           z:=round(h);

           alpha:=arctan(-sin(rad(w))*r);       { x' }
           beta:=arctan(cos(rad(w))*r);         { y' }


           gamma:=w;


           x1:=cos(rad(alpha+90))*r1;
           y1:=sin(rad(gamma))*r1;

           line(xmh+round(x+x1),768-round(z+y1),
                xmh+round(x-x1),768-round(z-y1));


           makefl(r1,flpt);
           drehefl(gamma,flpt);
           transfl(x,y,z,flpt);
           writefl(flpt);

           if fcount>0 then
              begin
                   for i:=fcount*flpt to fcount*flpt+flpt do
                       begin
                            writeln(outf2,i,' ',i-flpt,' ',
                                    (i+1) mod (fcount*flpt+flpt),' 0');
                            writeln(outf2,(i+1) mod (fcount*flpt+flpt),
                                    ' ',i-(flpt-1),' ',i-flpt,' 0');
                       end;
              end;


           w:=w+ws;
           h:=h+hs;
           r:=r-rs;
           r1:=r1-r1s;
           inc(fcount);
     until w>ew;

     readln;



     grafikaus;

     close(outf); close(outf2);

     assign(outf3,fn);
     assign(outf,'c:\temp\punkte');
     assign(outf2,'c:\temp\fl„chen');
     reset(outf); reset(outf2);
     rewrite(outf3);
     while not eof(outf) do
           begin
                readln(outf,input);
                writeln(outf3,input);
           end;
     close(outf);
     while not eof(outf2) do
           begin
                readln(outf2,input);
                writeln(outf3,input);
           end;
     close(outf2); close(outf3);
end.
