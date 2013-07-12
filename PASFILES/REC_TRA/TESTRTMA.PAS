program testrtmath;
uses crt,rt_math;
const ORGIN:rt_point=(x:0; y:0; z:0);
var v1,v2,v3:v3t;

begin
     clrscr;
     vinit(0,1,0,v1);
     vinit(1,0,0,v2);

     vcross(v1,v2,v3);

     writevector('n:=',v3);

     repeat until keypressed; readln;
end.
