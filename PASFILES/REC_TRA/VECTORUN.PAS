unit vectorun;
INTERFACE
type vector = RECORD x,y,z:real; END;
type point = record x,y,z:real; end;

procedure vzero(var a:vector);
procedure vinit(ix,iy,iz:real; var a:vector);
procedure pinit(ix,iy,iz:real; var p:point);
procedure p2v(a,b:point; var v:vector);
procedure vnorm(v:vector; var n:vector);
function vcosw(v,w:vector):real;
function vdot(v,w:vector):real;
procedure vadd(a,b:vector; var c:vector);
procedure vsub(a,b:vector; var c:vector);
{
procedure vdot(a,b:vector; var c:vector);
procedure vcross(a,b:vector; var c:vector);
}
procedure vdiv(k:real; a:vector; var c:vector);
procedure vmul(k:real; a:vector; var c:vector);
procedure writevector(s:string; a:vector);
procedure writewinkel(s:string; r:real);
procedure drehx(a:real; var v:vector);
procedure drehy(a:real; var v:vector);
procedure drehz(a:real; var v:vector);

function det2(a11,a12,
              a21,a22:real):real;
function det3(a11,a12,a13,
              a21,a22,a23,
              a31,a32,a33:real):real;

IMPLEMENTATION

procedure p2v(a,b:point; var v:vector);
begin
     vinit(b.x-a.x,b.y-a.y,b.z-a.z,v);
end;
procedure vnorm(v:vector; var n:vector);
begin
     writevector('v=',v);
     vdiv(sqrt(sqr(v.x)+sqr(v.y)+sqr(v.z)),v,n);
end;
function vcosw(v,w:vector):real;
begin
     vcosw:=vdot(v,w)/(vdot(v,v)*vdot(w,w));
end;
procedure drehx(a:real; var v:vector);
var p:vector;
    sa,ca:real;
begin
     p:=v;
     sa:=sin(a);
     ca:=cos(a);
     v.z:=ca*p.z+sa*p.y;
     v.y:=ca*p.y-sa*p.z;
end;
procedure drehy(a:real; var v:vector);
var p:vector;
    sa,ca:real;
begin
     p:=v;
     sa:=sin(a);
     ca:=cos(a);
     v.x:=ca*p.x+sa*p.z;
     v.z:=ca*p.z-sa*p.x;
end;

procedure drehz(a:real; var v:vector);
var p:vector;
    sa,ca:real;
begin
     p:=v;
     sa:=sin(a);
     ca:=cos(a);
     v.x:=ca*p.x+sa*p.y;
     v.y:=ca*p.y-sa*p.x;
end;
procedure writewinkel(s:string; r:real);
begin
     writeln(s,r*180/pi:3:3);
end;
function det2(a11,a12,
              a21,a22:real):real;
begin
     det2:=a11*a22-a12*a21;
end;
function det3(a11,a12,a13,
              a21,a22,a23,
              a31,a32,a33:real):real;
begin
     det3:= a11*a22*a33+a12*a23*a31+a13*a21*a32
           -a13*a22*a31-a11*a23*a32-a12*a21*a33;
end;

procedure writevector(s:string; a:vector);
begin
     writeln(s,'( ',a.x:3:3,' / ',a.y:3:3,' / ',a.z:3:3,' )');
end;
procedure vzero(var a:vector);
begin
     a.x:=0;
     a.y:=0;
     a.z:=0;
end;
procedure vinit(ix,iy,iz:real; var a:vector);
begin
     with a do begin
          x:=ix; y:=iy; z:=iz;
     end;
end;
procedure pinit(ix,iy,iz:real; var p:point);
begin
         p.x:=ix; p.y:=iy; p.z:=iz;
end;
procedure vadd(a,b:vector; var c:vector);
begin
     c.x:=a.x+b.x;
     c.y:=a.y+b.y;
     c.z:=a.z+b.z;
end;
procedure vsub(a,b:vector; var c:vector);
begin
     c.x:=a.x-b.x;
     c.y:=a.y-b.y;
     c.z:=a.z-b.z;
end;
function vdot(v,w:vector):real;
begin
     vdot:=v.x*w.x+v.y*w.y+v.z*w.z;
end;
{
procedure vdot(a,b:vector; var c:vector);
begin
     c.x:=a.x*b.x;
     c.y:=a.y*b.y;
     c.z:=a.z*b.z;
end;
procedure vcross(a,b:vector; var c:vector);
begin
     c.x:=a.y*b.z-b.y*a.z;
     c.y:=a.z*b.x-b.z*a.x;
     c.z:=a.x*b.y-b.x*a.y;
end;
}
procedure vdiv(k:real; a:vector; var c:vector);
begin
     c.x:=a.x/k;
     c.y:=a.y/k;
     c.z:=a.z/k;
end;
procedure vmul(k:real; a:vector; var c:vector);
begin
     c.x:=k*a.x;
     c.y:=k*a.y;
     c.z:=k*a.z;
end;
begin
end.