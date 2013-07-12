{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 309 of 318
From : Bob Swart                           2:281/256.12         09 Apr 93  17:04
To   : Manh Tran                           1:273/704.0
Subj : Bug In Pascal Code
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Hi Manh!

 > Does anyone see what is wrong with the following pascal code.
Yes, the bug is in your until-statement, you continue to run

 >   Until (est = factor) or (est = factor+0.01) or (est = factor-0.01);
i.e. until you have one of three EXACT MATCHES!!

If there's one thing you cannot rely on, it's exact matches with reals.

It is obvious you want to terminate the loop if est is within the range
[factor-@,factor+@], where @ is some sort of accuracy you can get with reals.
Since reals are accurate to 11 digits, you should divide the factor by the est
(or the other way around if you like), and see if the resulting quotient minus
one (ans the absolute value of that result) is less of equal 10 times the
negative number of significant digits you want.

Like this:

  until abs(1-(factor/est)) <= delta;

if you want 2 significant digits, you should set delta to 0.01 (1e-2), etc.

To clearify all this, look at the modified code for 4 significant digits: }


Program SQRT_approx;
Uses Crt;
Const delta = 1e-4;
var Num,i: LongInt;
    Est, new_est, factor: Real;
begin
  Clrscr;
  write('Enter a number: ');
  readln(Num);
  writeln;
  if Num > 0 then
  begin
    i := 1;
    Est := Num / 2;
    writeln('REAL Square root of ',Num,' is ',sqrt(Num):6:4);
    writeln;
    writeln('Estimate       Factor     New_est   # Of Oper. ');
    repeat
      Factor := Num / est;
      New_est := (est + factor) / 2 ;
      writeln(est:8:4, factor:11:4, New_est:14:4,i:8);
      Inc(i) ;
      est := new_est
    until abs(1-(factor/est)) <= delta
  end
  else
    writeln('Error: cannot calculate the square root of a negative number.')
end.