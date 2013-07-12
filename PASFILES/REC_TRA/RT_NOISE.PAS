unit RT_noisef;
INTERFACE

uses crt,rt_types,rt_math,rt_objects,rt_textures;

const latpow = 5; latcnt = 1 shl latpow; latmask=latcnt-1;

type lattyp = array [0..latmask,0..latmask,0..latmask] of byte;
     coltabt=array[0..255] of rt_color;
     coltabsamplet = record nr:byte; c:rt_color; end;
const marblecols:array [0..3] of coltabsamplet=
         ((nr:0; c:(r:0.2; g:1.0; b:1.0)) , (nr:70; c:(r:0.5; g:0.2; b:0.8)) ,
          (nr:140; c:(r:1.0; g:0.9; b:1.0)) , (nr:255; c:(r:0.4; g:0.9; b:0.1)));
      hellcols:array [0..3] of coltabsamplet=
         ((nr:0;c:(r:0.8;g:0.2;b:0.1)) , (nr:60; c:(r:0.8;g:0.9;b:0.2)) ,
          (nr:120; c:(r:1.0;g:0.9;b:1.0)) , (nr:255; c:(r:0.7;g:0.2;b:0.0)));

var lattice:lattyp;
    mins:single;
    marbletab,helltab:coltabt;

function noise(v:v3t) : single;
procedure dnoise(v:v3t; var n:v3t);
function turbulence(p:v3t):single;
procedure gencoltab(samplecnt:integer; var samples; var coltab:coltabt);
procedure waveproc(p:v3t; var n:v3t);
procedure cloudproc(obnr:rt_object_pointer; p:v3t; var c:ct);
procedure schachproc(obnr:rt_object_pointer; p:v3t; var c:ct);
procedure marbleproc(obnr:rt_object_pointer; p:v3t; var c:ct);
procedure hellproc(obnr:rt_object_pointer; p:v3t; var c:ct);

IMPLEMENTATION
(*------------------------- Noise dNoise und Turbulence -----------------*)

function noise(v:v3t) : single;
var b100,b010,b001,b101,b110,b111,b011,b000,x0,y0,z0,x1,y1,z1:byte;
    x,y,z,xs,ys,zs:longint;
const scal=128*latcnt; nscal=2/(255*128*128*128);
begin
     vmul(scal,v,v);
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
     vmul(scal,v,v);
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
           t:=t+abs(noise(p)*s); s:=s*0.5; vmul(2,p,p);
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



procedure cloudproc;
var t:single;
begin
     vmul(0.08,p,p); p.x:=p.x*0.3;
     t:=turbulence(p); c.r:=t; c.g:=t; c.b:=1;
end;

procedure marbleproc;
var t:single; ci:byte;
begin
     vmul(0.08,p,p); t:=turbulence(p);
     if t>1 then ci:=255 else ci:=round(t*255); c:=marbletab[ci];
end;

procedure hellproc;
var t:single; ci:byte;
begin
     vmul(0.08,p,p); p.y:=p.y*6; t:=turbulence(p);
     if t>1 then ci:=255 else ci:=round(t*255); c:=helltab[ci];
end;

procedure schachproc;
begin
     if ((round(p.x) mod 2) > 1) and ((round(p.y) mod 2) > 1) then begin
        c:=BLACK;
        writeln('1');
     end else begin
         c:=GRAU90;
         writeln('0');
     end;
end;


procedure waveproc(p:v3t; var n:v3t);
var n1:v3t; r:single;
begin
     vmul(0.3,p,p); r:=sin(vabs(p)*2*pi)*0.2; dnoise(p,n1);
     vmul(r,n1,n1); vadd(n1,n,n); vnorm(n,n);
end;

procedure eqnrmproc(p:v3t; var n:v3t); begin end;

var i,j,k:integer;
begin
     gencoltab(4,marblecols,marbletab); gencoltab(4,hellcols,helltab);
     mins:=1/100;
     randomize;
     for i:=0 to latcnt-1 do
      for j:=0 to latcnt-1 do
       for k:=0 to latcnt-1 do lattice[i,j,k]:=random(256);
end.