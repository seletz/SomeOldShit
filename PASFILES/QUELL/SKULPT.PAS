program skulptur;
uses crt;
var i,j,k:integer;
    alphai,betai,a,b,bs,l,bi,ti:real;

function pow(x,y:real) : real;
begin
     if x=0 then begin pow:=0; exit end;
     x:=ln(x)*y; if x<-10 then pow:=0 else pow:=exp(x);
end;

begin
     bi:=0;
     ti:=0;
     alphai:=0;
     betai:=0;
     a:=100;
     b:=100;
     k:=10;

     bs:=0;
     ti:=-b/2;
     clrscr;

     for j:=0 to k do
         begin
              bi:=(b/pow(1,j));
              bs:=bs+bi;
              ti:=ti+bi;
              l:=sqrt(bi*bi+a*a);
              alphai:=arctan(a/bi);
              betai:=-alphai;
              writeln( j,' : Summe b:',bs:3:3,
                            ' bi :',bi:3:3,
                            ' ti :',ti:3:3,
                            ' alphai :',180*alphai/pi:3:3,
                            ' l :',l:3:3);
         end;
end.