program ptrace;
{$a-,b-,d-,e+,f-,g+,i+,l-,n+,o-,r-,s-,v-,x-}
uses primout,crt;
const
      picsizewc = 10;
      pixrat = 1;
      infinity = 1e20; epsilon=1e-10;
      maxrekdep = 5;
      atteneps = 0.01;
      latpow = 5; latcnt = 1 shl latpow; latmask=latcnt-1;
type v3t = record x,y,z:single; end;
     ct = record r,g,b:single; end;
     rayt = record p,n:v3t; end;
     kugelt = record m:v3t; sqrr:single end;
     colproctyp = procedure(obnr:integer; p:v3t; var c:ct);
     nrmproctyp = procedure(p:v3t; var n:v3t);
     surft = record
                   od:ct; oe,n:single; refl,trans:boolean;
                   specc,transc:ct;
                   colproc:colproctyp; nrmproc:nrmproctyp;
             end;
     lattyp = array [0..latmask,0..latmask,0..latmask] of byte;
     coltabt=array[0..255] of ct;
     coltabsamplet = record nr:byte; c:ct; end;
     {$f+}
     procedure eqodproc  (obnr:integer; p:v3t; var c:ct); forward;
     procedure cloudproc (obnr:integer; p:v3t; var c:ct); forward;
     procedure marbleproc(obnr:integer; p:v3t; var c:ct); forward;
     procedure hellproc  (obnr:integer; p:v3t; var c:ct); forward;
     procedure eqnrmproc (p:v3t; var n:v3t);              forward;
     procedure waveproc  (p:v3t; var n:v3t);              forward;
     {$f-}

const k1:kugelt =(m:(x: 2.2; y:-1.5; z:1.0); sqrr:1.0*1.0);
      k2:kugelt =(m:(x:-0.2; y:-4.0; z:1.3); sqrr:1.3*1.3);
      eye:v3t   =(x: 2.0; y:-8.0; z: 1.6);
      lightv:v3t=(x:-2.0; y:-4.0; z: 2.0);
      lightc:ct =(r: 0.6; g: 0.6; b: 0.6);
      ambc:ct   =(r:0.1; g:0.1; b:0.1);

      sky:surft = (
                od:(r:0.5;g:0.5;b:0.5); oe:1; n:1; refl:false; trans:false;
                specc:(r:0.5;g:0.5;b:0.5); transc:(r:1.0;g:1.0;b:1.0);
                colproc:cloudproc; nrmproc:eqnrmproc
                  );

      hell:surft = (
                od:(r:0.5;g:0.5;b:0.5); oe:1; n:1; refl:false; trans:false;
                specc:(r:0.5;g:0.5;b:0.5); transc:(r:1.0;g:1.0;b:1.0);
                colproc:hellproc; nrmproc:eqnrmproc
                  );

      simple:surft = (
                od:(r:0.5;g:0.5;b:0.5); oe:10; n:1; refl:false; trans:false;
                specc:(r:0.5;g:0.5;b:0.5); transc:(r:1.0;g:1.0;b:1.0);
                colproc:eqodproc; nrmproc:eqnrmproc
                  );

      water:surft = (
                od:(r:0.3;g:0.3;b:0.3); oe:8; n:1.33; refl:true; trans:true;
                specc:(r:0.6;g:0.6;b:0.6); transc:(r:0.3;g:0.3;b:0.3);
                colproc:eqodproc; nrmproc:waveproc
                  );

      marble:surft = (
                od:(r:1.0;g:1.0;b:1.0); oe:8; n:1; refl:true; trans:false;
                specc:(r:0.3;g:0.3;b:0.3); transc:(r:1.0;g:1.0;b:1.0);
                colproc:marbleproc; nrmproc:eqnrmproc
                  );
      glas:surft = (
                od:(r:0.1;g:0.1;b:0.1); oe:20; n:1.5; refl:true; trans:true;
                specc:(r:0.5;g:0.5;b:0.5); transc:(r:0.5;g:0.5;b:0.5);
                colproc:eqodproc; nrmproc:eqnrmproc
                  );
      mirror:surft = (
                od:(r:0.1;g:0.1;b:0.1); oe:30; n:1; refl:true; trans:false;
                specc:(r:0.9;g:0.9;b:0.9); transc:(r:1.0;g:1.0;b:1.0);
                colproc:eqodproc; nrmproc:eqnrmproc
                  );
      brass:surft = (
                od:(r:0.3;g:0.3;b:0.1); oe:5; n:1; refl:true; trans:false;
                specc:(r:0.9;g:0.9;b:0.3); transc:(r:1.0;g:1.0;b:1.0);
                colproc:eqodproc; nrmproc:eqnrmproc
                  );
      marblecols:array [0..3] of coltabsamplet=
         ((nr:0; c:(r:0.2; g:1.0; b:1.0)) , (nr:70; c:(r:0.1; g:0.8; b:0.2)) ,
          (nr:140; c:(r:1.0; g:0.9; b:1.0)) , (nr:255; c:(r:0.4; g:0.9; b:0.1)));
      hellcols:array [0..3] of coltabsamplet=
         ((nr:0;c:(r:0.8;g:0.2;b:0.1)) , (nr:60; c:(r:0.8;g:0.9;b:0.2)) ,
          (nr:120; c:(r:1.0;g:0.9;b:1.0)) , (nr:255; c:(r:0.7;g:0.2;b:0.0)));

var mins:single;
    lattice : lattyp;
    obarr   : array[0..4] of surft;
    marbletab,helltab:coltabt;

procedure erreps(s:single);
begin
     if abs(s)<epsilon then
        begin
             writeln(#7,'FEHLER: Zahl=0 !'); halt(1);
        end;
end;

function lround(s:single) : longint;
begin
     if s>maxlongint then lround:=maxlongint else
     if s<-maxlongint then lround:=-maxlongint else lround:=round(s);
end;
function mul4b(b1,b2,b3,b4:byte):longint; assembler;
asm
     mov al,b1; mul b2; push ax; mov al,b3; mul b4; pop bx; mul bx;
end;
function norm(v:v3t) : single;
begin
     norm:=sqrt(sqr(v.x)+sqr(v.y)+sqr(v.z));
end;
procedure normalize(var v:v3t);
VAR N:single;
begin
     n:=norm(v); erreps(n); v.x:=v.x/n; v.y:=v.y/n; v.z:=v.z/n;
end;
procedure vsum(a,b:v3t; var s:v3t);
begin
     s.x:=a.x+b.x; s.y:=a.y+b.y; s.z:=a.z+b.z;
end;
procedure vdif(a,b:v3t; var s:v3t);
begin
     s.x:=a.x-b.x; s.y:=a.y-b.y; s.z:=a.z-b.z;
end;
procedure kmul(k:single; b:v3t; var s:v3t);
begin
     s.x:=k*b.x; s.y:=k*b.y; s.z:=k*b.z;
end;
function smul(a,b:v3t) : single;
begin
     smul:=a.x*b.x+a.y*b.y+a.z*b.z;
end;
procedure raytopoint(r:rayt; l:single; var p:v3t);
begin
     p.x:=r.p.x+l*r.n.x; p.y:=r.p.y+l*r.n.y; p.z:=r.p.z+l*r.n.z;
end;

procedure reflv(ve,n:v3t; var vr:v3t);
var w:single; v:v3t;
begin
     w:=2*smul(ve,n); kmul(w,n,v); vdif(v,ve,vr);
end;

function transv(ve,n:v3t; n1,n2:single; var vt:v3t) : boolean;
var p,q,c,d,hhh:single;
begin
     p:=n1/n2; c:=abs(smul(ve,n)); d:=1-sqr(p)*(1-sqr(c));
     if d < 0.0 then transv:=false else begin
        q:=p*c-sqrt(d); transv:=true; kmul(p,ve,ve);
        kmul(q,n,n); vsum(ve,n,vt);
     end;
end;

function pow(x,y:single) : single;
begin x:=ln(x)*y; if x<-10 then pow:=0 else pow:=exp(x); end;

procedure sqrsolve(p,q:single; var lam:single);
var d,h,l1,l2:single;
begin
     d:=sqr(p)*0.25-q;
     if d<0 then lam:=infinity else begin
        h:=-p*0.5; d:=sqrt(d); l1:=h+d; l2:=h-d;
        if (l1<l2) and (l2>epsilon) then lam:=l2 else
        if (l1>epsilon) then lam:=l1 else lam:=infinity;
     end;
end;

procedure intersect(var r:rayt; var obnr:integer; var lmin:single);
var p,q,pmmnrm,l:single; pmm:v3t;
begin
     normalize(r.n);
     if r.n.z>0 then begin if r.p.z>0 then obnr:=0 else obnr:=2; end
     else begin if r.p.z<0 then obnr:=1 else obnr:=2; end;
     if obnr=2 then begin
        lmin:=-r.p.z/r.n.z; if lmin<0 then lmin:=infinity;
     end else lmin:=infinity;
     vdif(r.p,k1.m,pmm); pmmnrm:=norm(pmm);
     p:=2*smul(pmm,r.n); q:=sqr(pmmnrm)-k1.sqrr;
     sqrsolve(p,q,l); if l<lmin then begin obnr:=3; lmin:=l; end;
     vdif(r.p,k2.m,pmm); pmmnrm:=norm(pmm);
     p:=2*smul(pmm,r.n); q:=sqr(pmmnrm)-k2.sqrr;
     sqrsolve(p,q,l); if l<lmin then begin obnr:=4; lmin:=l; end;
end;

function inshadow(p:v3t) : boolean;
var r:rayt; shdnr:integer; dummy:single;
begin
     r.p:=p; r.n:=lightv; raytopoint(r,0.001,r.p);
     intersect(r,shdnr,dummy); inshadow:=shdnr>1;
end;

function getnrm(obnr:integer; p,ve:v3t; var n:v3t) : boolean;
var nn:v3t;
begin
     if obnr=2 then begin n.x:=0; n.y:=0; n.z:=1; end else
     if obnr=3 then begin vdif(p,k1.m,n); normalize(n); end else
     if obnr=4 then begin vdif(p,k2.m,n); normalize(n); end;
     if smul(ve,n)<0 then kmul(-1,n,n); nn:=n;
     obarr[obnr].nrmproc(p,n); normalize(n);
     getnrm:=(smul(ve,n)>0) and (smul(nn,n)>0);
end;

procedure light(obnr:integer; p,n,ve,vr:v3t; var c:ct);
var w1,w2,spec:single; cd,cs:ct;
begin
     obarr[obnr].colproc(obnr,p,cd);
     w1:=smul(lightv,n);
     if (w1>0) and (not inshadow(p)) then begin
        c.r:=(lightc.r*w1+ambc.r)*cd.r;
        c.g:=(lightc.g*w1+ambc.g)*cd.g;
        c.b:=(lightc.b*w1+ambc.b)*cd.b;
        w2:=smul(vr,lightv);
        if w2>0 then begin
           spec:=pow(w2,obarr[obnr].oe); cs:=obarr[obnr].specc;
           c.r:=c.r+spec*cs.r;
           c.g:=c.g+spec*cs.g;
           c.b:=c.b+spec*cs.b;
        end;
     end else begin
         c.r:=ambc.r*cd.r;
         c.g:=ambc.g*cd.g;
         c.b:=ambc.b*cd.b;
     end;
end;

procedure trace(r:rayt; rekdep:integer; n1:single; atten:single; var c:ct);
var obnr:integer; lmin,n2,as,at:single; p,n,ve,vr,vt:v3t;
    ci,cs:ct; torefl,totrans:boolean;
begin
     if (rekdep>maxrekdep) or (atten<atteneps) then begin
        c.r:=0; c.g:=0; c.b:=0; exit;
     end;
     intersect(r,obnr,lmin);
     if obnr>1 then begin
        raytopoint(r,lmin,p);
        vdif(eye,p,ve); normalize(ve);
        torefl:=getnrm(obnr,p,ve,n);
        reflv(ve,n,vr); light(obnr,p,n,ve,vr,c);
        if obarr[obnr].refl and torefl then begin
           r.p:=p; r.n:=vr; raytopoint(r,0.001,r.p);
           cs:=obarr[obnr].specc;
           if (cs.r>cs.g) and (cs.r>cs.b) then as:=atten*cs.r else
           if cs.g>cs.b then as:=atten*cs.g else as:=atten*cs.b;
           trace(r,rekdep+1,1,as,ci);
           c.r:=c.r+ci.r*cs.r;
           c.g:=c.g+ci.g*cs.g;
           c.b:=c.b+ci.b*cs.b;
        end;
        if obarr[obnr].trans then begin
           if n1<>1 then totrans:=transv(ve,n,n1,1,vt)
           else totrans:=transv(ve,n,1,obarr[obnr].n,vt);
           if totrans then begin
              r.p:=p; r.n:=vt; raytopoint(r,0.001,r.p);
              if n1<>1 then n1:=1 else n1:=obarr[obnr].n;
              cs:=obarr[obnr].transc;
              if (cs.r>cs.g) and (cs.r>cs.b) then at:=atten*cs.r else
              if cs.g>cs.b then at:=atten*cs.g else at:=atten*cs.b;
              trace(r,rekdep+1,n1,at,ci);
              c.r:=c.r+ci.r*cs.r;
              c.g:=c.g+ci.g*cs.g;
              c.b:=c.b+ci.b*cs.b;
           end;
        end;
     end else obarr[obnr].colproc(obnr,r.n,c);
end;

(*------------------------- Noise dNoise und Turbulence -----------------*)

function noise(v:v3t) : single;
var b100,b010,b001,b101,b110,b111,b011,b000,x0,y0,z0,x1,y1,z1:byte;
    x,y,z,xs,ys,zs:longint;
const scal=128*latcnt; nscal=2/(255*128*128*128);
begin
     kmul(scal,v,v);
     x:=lround(v.x);     y:=lround(v.y);     z:=lround(v.z);
     xs:=x shr 7;        ys:=y shr 7;        zs:=z shr 7;
     x0:=xs and latmask; y0:=ys and latmask; z0:=zs and latmask;
     x1:=(xs+1) and latmask;
     y1:=(ys+1) and latmask;
     z1:=(zs+1) and latmask;

     b000:=lattice[x0,y0,z0];  b001:=lattice[x0,y0,z1];
     b010:=lattice[x0,y1,z0];  b011:=lattice[x0,y1,z1];
     b100:=lattice[x1,y0,z0];  b101:=lattice[x1,y0,z1];
     b110:=lattice[x1,y1,z0];  b111:=lattice[x1,y1,z1];

     x1:=x and $7f; y1:=y and $7f; z1:=z and $7f;
     x0:=$80-x1; y0:=$80-y1; z0:=$80-z1;
     noise:=(mul4b(b000,x0,y0,z0)+mul4b(b001,x0,y0,z1)+
             mul4b(b010,x0,y1,z0)+mul4b(b100,x1,y0,z0)+
             mul4b(b011,x0,y1,z1)+mul4b(b101,x1,y0,z1)+
             mul4b(b110,x1,y1,z0)+mul4b(b111,x1,y1,z1))*nscal-1;
end;
procedure dnoise(v:v3t; var n:v3t);
const scal=128*latcnt; nscal=1/(255*128*128*128)*2;
var x0,y0,z0,x1,y1,z1,k:byte; x,y,z,xs,ys,zs:longint; h:single;

function getdif(k,i:byte):byte;
const om:array[0..3,0..7,0..2] of byte =
      (((1,0,0),(1,0,1),(1,1,0),(1,1,1),(2,0,0),(2,0,1),(2,1,0),(2,1,1)),
       ((0,1,0),(0,1,1),(0,2,0),(0,2,1),(1,1,0),(1,1,1),(1,2,0),(1,2,1)),
       ((0,0,1),(0,0,2),(0,1,1),(0,1,2),(1,0,1),(1,0,2),(1,1,1),(1,1,2)),
       ((0,0,0),(0,0,1),(0,1,0),(0,1,1),(1,0,0),(1,0,1),(1,1,0),(1,1,1)));
begin
     getdif:=(lattice[(xs+om[k,i,0]) and latmask,
                      (ys+om[k,i,1]) and latmask,
                      (zs+om[k,i,2]) and latmask]
             -lattice[(xs+om[k,i,0]) and latmask,
                      (ys+om[k,i,1]) and latmask,
                      (zs+om[k,i,2]) and latmask]) and 255;
end;
begin
     kmul(scal,v,v);
     x:=lround(v.x);     y:=lround(v.y);     z:=lround(v.z);
     xs:=x shr 7;        ys:=y shr 7;        zs:=z shr 7;
     x1:=x and $7f; y1:=y and $7f; z1:=z and $7f;
     x0:=$80-x1; y0:=$80-y1; z0:=$80-z1;
     for k:=0 to 2 do begin
         h:=(mul4b(getdif(k,0),x0,y0,z0)+mul4b(getdif(k,1),x0,y0,z1)+
             mul4b(getdif(k,2),x0,y1,z0)+mul4b(getdif(k,3),x0,y1,z1)+
             mul4b(getdif(k,4),x1,y0,z0)+mul4b(getdif(k,5),x1,y0,z1)+
             mul4b(getdif(k,6),x1,y1,z0)+mul4b(getdif(k,7),x1,y1,z1))*nscal-1;
             if k=0 then n.x:=h else if k=1 then n.y:=h else n.z:=h;
     end;
end;

function turbulence(p:v3t):single;
var t,s:single;
begin
     t:=0; s:=1;
     while s>mins do begin
           t:=t+abs(noise(p)*s); s:=s*0.5; kmul(2,p,p);
     end;
     turbulence:=t;
end;

procedure gencoltab(samplecnt:integer; var samples; var coltab:coltabt);
var dr,dg,db:single; i,j,d:integer; c,c1:ct;
type sampt=array[0..100] of coltabsamplet;
begin
     fillchar(coltab,sizeof(coltab),0);
     for i:=0 to samplecnt-2 do begin
         d:=sampt(samples)[i+1].nr-sampt(samples)[i].nr-1;
         if d>0 then begin
            c:=sampt(samples)[i].c; c1:=sampt(samples)[i+1].c;
            dr:=(c1.r-c.r)/d; dg:=(c1.g-c.g)/d; db:=(c1.b-c.b)/d;
            for j:=sampt(samples)[i].nr to sampt(samples)[i+1].nr do begin
                coltab[j]:=c;
                c.r:=c.r+dr; if c.r<0 then c.r:=0 else if c.r>1 then c.r:=1;
                c.g:=c.g+dg; if c.g<0 then c.g:=0 else if c.g>1 then c.g:=1;
                c.r:=c.b+dr; if c.b<0 then c.b:=0 else if c.b>1 then c.b:=1;
            end;
         end;
     end;
end;

procedure eqodproc(obnr:integer; p:v3t; var c:ct);
begin c:=obarr[obnr].od; end;

procedure cloudproc(obnr:integer; p:v3t; var c:ct);
var t:single;
begin
     kmul(0.08,p,p); p.x:=p.x*0.3;
     t:=turbulence(p); c.r:=t; c.g:=t; c.b:=1;
end;

procedure marbleproc(obnr:integer; p:v3t; var c:ct);
var t:single; ci:byte;
begin
     kmul(0.08,p,p); t:=turbulence(p);
     if t>1 then ci:=255 else ci:=round(t*255); c:=marbletab[ci];
end;

procedure hellproc(obnr:integer; p:v3t; var c:ct);
var t:single; ci:byte;
begin
     kmul(0.08,p,p); p.y:=p.y*0.6; t:=turbulence(p);
     if t>1 then ci:=255 else ci:=round(t*255); c:=helltab[ci];
end;

procedure waveproc(p:v3t; var n:v3t);
var n1:v3t; r:single;
begin
     kmul(0.3,p,p); r:=sin(norm(p)*2*pi)*0.2; dnoise(p,n1);
     kmul(r,n1,n1); vsum(n1,n,n); normalize(n);
end;

procedure eqnrmproc(p:v3t; var n:v3t); begin end;

(*---------------------  User - Interface  --------------------------*)

procedure getprop(obnr,from,to_,default:byte; objstr,filler:string);
const c0=ord('0'); var c:char; nr:byte;
begin
     write('Nummer der OberflÑche fÅr ',objstr,'?',filler,'<ret>=',default,':');
     repeat c:=readkey until (ord(c)-c0 in [from..to_]) or (c=#13);
     if c=#13 then nr:=default else nr:=ord(c)-c0; writeln(nr);
     case nr of  0:obarr[obnr]:=sky;      1:obarr[obnr]:=hell;
                 2:obarr[obnr]:=simple;   3:obarr[obnr]:=marble;
                 4:obarr[obnr]:=water;    5:obarr[obnr]:=glas;
                 6:obarr[obnr]:=mirror;   7:obarr[obnr]:=brass;
     end;
end;

var x,y,i,j,k,xmax,ymax:integer; r:rayt; h,v:single; vr,vh,hv,nh:v3t; c:ct;

(*---------------------      M A I N       --------------------------*)

begin
     gencoltab(4,marblecols,marbletab); gencoltab(4,hellcols,helltab);
     clrscr;

     writeln('"Himmel und Hîlle" - PTRACE');
     writeln('Raytracer mit Solid-Texturen');
     writeln('(c) 92 j.p. & u.c. & Heinz Heise Verlag GmbH & Co KG');
     writeln('(a) by: Stefan Eletzhofer 26.1.93 - 30.1.93');
     writeln; writeln; writeln;
     write('Auflîsung eingeben (xmax,ymax):');
     readln(xmax,ymax);
     mins:=1/xmax;
     init(xmax,ymax); {primout init}
     writeln('OberflÑchen:');
     writeln('0:Wolken, 1:Hîlle, 2:Grau, 3:Marmor, 4:Wasser, '+
             '5:Glas, 6:Spiegel, 7:Messing'); writeln;
     getprop(0,0,3,0,'den Himmel','       ');
     getprop(1,0,3,1,'die Hîlle','        ');
     getprop(2,0,7,4,'den Boden','        ');
     getprop(3,0,7,5,'die kleine Kugel',' ');
     getprop(4,0,7,7,'die gro·e Kugel','  ');
     writeln;writeln;
     randomize;
     for i:=0 to latcnt-1 do
      for j:=0 to latcnt-1 do
       for k:=0 to latcnt-1 do lattice[i,j,k]:=random(256);
     r.p:=eye; erreps(eye.z); normalize(lightv);
     with eye do begin
          vh.x:=-x; vh.y:=-y; vh.z:=(sqr(x)+sqr(y)+sqr(z))/z;
          normalize(vh); if z<0 then kmul(-1,vh,vh);
          vr.x:=vh.y*z-vh.z*y;
          vr.y:=vh.z*x-vh.x*z;
          vr.z:=vh.x*y-vh.y*x;
          normalize(vr);
     end;
     grafikan;
     for y:=0 to ymax do begin
         h:=(-y/ymax+0.5)*Ymax/xmax*picsizewc*pixrat; kmul(h,vh,hv);
         gotoxy(1,wherey-1);writeln('                         ');
         gotoxy(1,wherey-1);writeln('Zeile ',y,' von ',ymax);
         for x:=0 to xmax do begin
             v:=(x/xmax-0.5)*picsizewc; kmul(v,vr,nh);
             vsum(hv,nh,nh); vdif(nh,eye,r.n); trace(r,0,1,1,c);
             if c.r>1 then c.r:=1;
             if c.b>1 then c.b:=1;
             if c.g>1 then c.g:=1;
             setzepixel(x,y,round(c.r*255),round(c.g*255),round(c.b*255));
         end;
     end;
     writeln('FERTIG!');
     grafikaus;
end.
