program cube;
uses crt,graph,sgraph;
type cuber = record
                  v,a,b,c:vector;
                  alpha,beta,gamma:real;
            end;
var w:cuber;
begin
     with w do
          begin
               v.x:=0;
               v.y:=0;
               v.z:=0;

               a.x:=10;
               a.y:=0;
               a.z:=0;

               b.x:=0;
               b.y:=10;
               b.z:=0;

               c.x:=0;
               c.y:=0;
               c.z:=10;

               alpha:=0;
               beta:=0;
               gamma:=0;
          end;
     grafikein;
     init3d(10,10,10,0,0,0,1000,0);
     cube3d(w.v,w.a,w.b,w.c,w.alpha,w.beta,w.gamma);
     wartetaste;
     grafikaus;
end.