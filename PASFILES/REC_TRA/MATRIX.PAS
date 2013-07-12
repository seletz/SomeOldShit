unit matrix;
INTERFACE
uses crt;
type m4x4 = array [1..4,1..4] of double;

const E:m4x4=( (1,0,0,0),
               (0,1,0,0),
               (0,0,1,0),
               (0,0,0,1));
      NULL:m4x4 =( (0,0,0,0),
                   (0,0,0,0),
                   (0,0,0,0),
                   (0,0,0,0));

function det(x:m4x4):double;
procedure transpose(var x:m4x4);
procedure m_add(a:m4x4; var b:m4x4);
procedure m_scale(k:double; var x:m4x4);
procedure m_mul(a:m4x4; var b:m4x4);
procedure init_point(x,y,z:double; var p:m4x4);
procedure init_trans(dx,dy,dz:double; var m:m4x4);
procedure init_scale(sx,sy,sz:double; var m:m4x4);
procedure init_rotx(w:double; var m:m4x4);
procedure init_roty(w:double; var m:m4x4);
procedure init_rotz(w:double; var m:m4x4);


procedure write_matrix(s:string; x:m4x4);

IMPLEMENTATION
function spat(z,s:m4x4; i,j:integer):double;
var k,l:integer;
    t:double;
begin
     t:=0;
     for k:=1 to 4 do t:=t + z[i,k]*s[k,j];
     spat:=t;
end;
function det2x2( x11,x12,
                 x21,x22:double):double;
begin
     det2x2:= x11*x22 - x12*x21;
end;
function det3x3( x11,x12,x13,
                 x21,x22,x23,
                 x31,x32,x33:double):double;
begin
     det3x3:=x13*det2x2( x21,x22,
                        x31,x32) - x23*det2x2( x11,x12,
                                               x31,x32) + x33*det2x2( x11,x12,
                                                                      x21,x22);
end;
function det(x:m4x4):double;
var t:double;
begin
     t:=0;

     t:=t + (-x[1,4]*det3x3( x[2,1],x[2,2],x[2,3],
                             x[3,1],x[3,2],x[3,3],
                             x[4,1],x[4,2],x[4,3]));

     t:=t + (+x[2,4]*det3x3( x[1,1],x[1,2],x[1,3],
                             x[3,1],x[3,2],x[3,3],
                             x[4,1],x[4,2],x[4,3]));

     t:=t + (-x[3,4]*det3x3( x[1,1],x[1,2],x[1,3],
                             x[2,1],x[2,2],x[2,3],
                             x[4,1],x[4,2],x[4,3]));

     t:=t + (+x[4,4]*det3x3( x[1,1],x[1,2],x[1,3],
                             x[2,1],x[2,2],x[2,3],
                             x[3,1],x[3,2],x[3,3]));
     det:=t;
end;
procedure transpose(var x:m4x4);
var t:m4x4;
    i,j:integer;
begin
     t:=x;

     for i:=1 to 4 do
         for j:=1 to 4 do begin
             x[j,i]:=t[i,j];
         end;
end;
procedure m_add(a:m4x4; var b:m4x4);
var i,j:integer;
begin
     for i:=1 to 4 do
         for j:=1 to 4 do begin
             b[i,j]:=a[i,j]+b[i,j];
         end;
end;
procedure m_scale(k:double; var x:m4x4);
var i,j:integer;
begin
     for i:=1 to 4 do
         for j:=1 to 4 do begin
             x[i,j]:=k*x[i,j];
         end;
end;
procedure m_mul(a:m4x4; var b:m4x4);
var i,j,k:integer;
    t:m4x4;
begin
     t:=null;
     for i:=1 to 4 do
         for j:=1 to 4 do begin
             for k:=1 to 4 do begin
                 t[i,j]:=t[i,j] + a[i,k]*b[k,j];
             end;
         end;
     b:=t;
end;
procedure write_matrix(s:string; x:m4x4);
var i,j:integer;
begin
     writeln(s);
     for i:=1 to 4 do begin
         for j:=1 to 4 do begin
             write(x[i,j]:3:3,'   ');
         end;
         writeln;
     end;
end;
procedure init_point(x,y,z:double; var p:m4x4);
begin
     p:=NULL;
     p[1,1]:=x;
     p[2,1]:=y;
     p[3,1]:=z;
     p[4,1]:=1;
end;
procedure init_trans(dx,dy,dz:double; var m:m4x4);
var r:m4x4;
begin
     r:=E;
     r[4,1]:=dx;
     r[4,2]:=dy;
     r[4,3]:=dz;
     m_mul(r,m);
end;
procedure init_scale(sx,sy,sz:double; var m:m4x4);
var r:m4x4;
begin
     r:=E;
     r[1,1]:=sx;
     r[2,2]:=sy;
     r[3,3]:=sz;
     m_mul(r,m);
end;
procedure init_rotx(w:double; var m:m4x4);
var r:m4x4;
begin
     r:=E;
     r[2,2]:= cos(w); r[2,3]:=-sin(w);
     r[3,2]:= sin(w); r[3,3]:= cos(w);
     m_mul(r,m);
end;
procedure init_roty(w:double; var m:m4x4);
var r:m4x4;
begin
     r:=E;
     r[1,1]:= cos(w); r[1,3]:= sin(w);
     r[3,1]:=-sin(w); r[3,3]:= cos(w);
     m_mul(r,m);
end;
procedure init_rotz(w:double; var m:m4x4);
var r:m4x4;
begin
     r:=E;
     r[1,1]:= cos(w); r[1,2]:=-sin(w);
     r[2,1]:= sin(w); r[2,2]:= cos(w);
     m_mul(r,m);
end;
begin
end.