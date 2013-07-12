program gauss;
uses crt;
type tm3x3 = array[0..2,0..2] of real;
     tv1x3 = array[0..2] of real;
     tm4x4 = array[0..3,0..3] of real;
     tv1x4 = array[0..3] of real;
const      E3:tm3x3=((1,0,0),(0,1,0),(0,0,1));
           N3:tm3x3=((0,0,0),(0,0,0),(0,0,0));
           M3:tm3x3=((1,2,3),(3,4,6),(6,3,2));
           V3:tv1x3=(1,2,3);
           E4:tm4x4=((1,0,0,0),(0,1,0,0),(0,0,1,0),(0,0,0,1));
           N4:tm4x4=((0,0,0,0),(0,0,0,0),(0,0,0,0),(0,0,0,0));
           M4:tm4x4=((1,2,3,9),(3,4,6,8),(6,3,2,7),(5,3,2,6));
           V4:tv1x4=(1,2,3,4);

procedure waittast;
begin readkey; end;
procedure out_ml3x3(m:tm3x3; l:tv1x3);
const n=2;
var i,j:integer;
begin
     for i:=0 to n do begin
         for j:=0 to n do
             begin
                  gotoxy((j+1)*10,(i+1)*3);
                  write(m[i,j]:3:3);
             end;
         gotoxy((j+2)*12,(i+1)*3);
         write(l[i]:3:3);
     end;
     writeln;
end;
procedure out_ml4x4(m:tm4x4; l:tv1x4);
const n=3;
var i,j:integer;
begin
     for i:=0 to n do begin
         for j:=0 to n do
             begin
                  gotoxy((j+1)*10,(i+1)*3);
                  write(m[i,j]:3:3);
             end;
         gotoxy((j+2)*12,(i+1)*3);
         write(l[i]:3:3);
     end;
     writeln;
end;
procedure solve_gauss3x3(x:tm3x3; var v:tv1x3);
const n=2;
type tzeile= array [0..n+1] of real;
var i,j,k:integer;
    z:tzeile;
begin
     for k:=0 to n do
         x[0,k]:=x[0,k]/x[0,0];
         v[0]:=v[0]/x[0,0];
     j:=0;
     repeat
           i:=n;
           repeat
                 for k:=0 to n do
                     z[k]:=x[j,k]*(-x[i,j]/x[j,j]);
                     z[n+1]:=v[j]*(-x[i,j]/x[j,j]);
                 for k:=0 to n do
                     x[i,k]:=x[i,k]+z[k];
                     v[i]:=v[i]+z[n+1];
                 out_ml3x3(x,v);
                 writeln('++ Taste ++');
                 waittast;
                 dec(i);
           until i=j;
           inc(j);
     until j=n;
     v[n]:=v[n]/x[n,n];
     x[n,n]:=1;
     out_ml3x3(x,v);
     writeln('++ Taste ++');
     waittast;
end;
procedure solve_gauss4x4(x:tm4x4; var v:tv1x4);
const n=3;
type tzeile= array [0..n+1] of real;
var i,j,k:integer;
    z:tzeile;
begin
     for k:=0 to n do
         x[0,k]:=x[0,k]/x[0,0];
         v[0]:=v[0]/x[0,0];
     j:=0;
     repeat
           i:=n;
           repeat
                 for k:=0 to n do
                     z[k]:=x[j,k]*(-x[i,j]/x[j,j]);
                     z[n+1]:=v[j]*(-x[i,j]/x[j,j]);
                 for k:=0 to n do
                     x[i,k]:=x[i,k]+z[k];
                     v[i]:=v[i]+z[n+1];
                 out_ml4x4(x,v);
                 writeln('++ Taste ++');
                 waittast;
                 dec(i);
           until i=j;
           inc(j);
     until j=n;
     v[n]:=v[n]/x[n,n];
     x[n,n]:=1;
     out_ml4x4(x,v);
     writeln('++ Taste ++');
     waittast;
end;
var a3:tm3x3;
    b3:tv1x3;
var a4:tm4x4;
    b4:tv1x4;
begin
     a4:=M4;
     b4:=V4;
     clrscr;
     out_ml4x4(a4,b4);
     waittast;
     solve_gauss4x4(a4,b4);

end.