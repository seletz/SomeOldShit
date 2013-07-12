program matrixtst;
uses crt;
type matr = array[1..4,1..4] of real;
     matrix = record z,s:integer; m:matr;
var null,e,a,b,c:matrix;
procedure clearm(var a:matrix);
var i,j:integer;
begin
     for i:=1 to a.z do
      for j:=1 to a.s do
          a.m[i,j]:=0;
end;
procedure init;
var i,j:integer;
begin
     null.z:=4;
     null.s:=4;
     clearm(null);
     e:=null;
     e[1,1]:=1;
     e[2,2]:=1;
     e[3,3]:=1;
     e[4,4]:=1;
end;
procedure subm(x,y:matrix; var z:matrix);
var i,j:integer;
begin
     for i:=1 to x.s do
         for j:=1 to x.z do
             begin
                  z.m[i,j]:=x.m[i,j]-y.m[i,j];
             end;
end;
procedure addm(x,y:matrix; var z:matrix);
var i,j:integer;
begin
     for i:=1 to x.s do
         for j:=1 to x.z do
             begin
                  z.m[i,j]:=x.m[i,j]+y.m[i,j];
             end;
end;
procedure smulm(a:real; var x:matrix);
var i,j:integer;
begin
     for i:=1 to x.s do
         for j:=1 to x.z do
             begin
                  x.m[i,j]:=x.m[i,j]*a;
             end;
end;
procedure sdivm(a:real; var x:matrix);
var i,j:integer;
begin
     for i:=1 to x.s do
         for j:=1 to x.z do
             begin
                  x.m[i,j]:=x.m[i,j]/a;
             end;
end;
procedure mulm(a,b:matrix; var c:matrix);
var i,j,k,l:integer;
begin
     c:=null;
     c.z:=a.z;
     c.s:=b.s;
     for i:=1 to a.z do
         begin
              for j:=1 to a.s do
                  begin
                       for k:= 1 to 3 do
                           begin
                                c[i,j]:=c[i,j]+a[k,j]*b[i,k];
                           end;
                  end;
         end;
end;
procedure printm(x:matrix);
var i,j:integer;
begin
     for i:=1 to 3 do
         for j:=1 to 3 do
             begin
                  gotoxy(j*13,i*2);
                  write(round(x[j,i]));
             end;
end;
function det(m:matrix): real;
begin
     det:=m[1,1]*m[2,2]*m[3,3]+m[1,2]*m[2,3]*m[3,1]+m[1,3]*m[2,1]*m[3,2]
          -m[1,3]*m[2,2]*m[3,1]-m[1,1]*m[2,3]*m[3,2]-m[1,2]*m[2,1]*m[3,3]
end;
begin
     clrscr;
     init;
     a[1,1]:=1; a[2,1]:=2; a[3,1]:=3;
     a[1,2]:=0; a[2,2]:=1; a[3,2]:=2;
     a[1,3]:=4; a[2,3]:=0; a[3,3]:=5;

     b[1,1]:=4; b[2,1]:=2; b[3,1]:=0;
     b[1,2]:=0; b[2,2]:=1; b[3,2]:=5;
     b[1,3]:=2; b[2,3]:=3; b[3,3]:=0;

     mulm(a,b,c);
     printm(c);
end.