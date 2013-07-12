program test;
uses crt,vectorun;
var a,b:vector; k:real;
begin
     vzero(a); vzero(b);
     a.x:=1;
     a.y:=2;
     a.z:=3;
     k:=10;
     b:=a;
     vmul(2,a,a);
     writeln(a.x,' ',a.y,' ',a.z);
     vdiv(2,b,b);
     writeln(b.x,' ',b.y,' ',b.z);
     readln;
end.