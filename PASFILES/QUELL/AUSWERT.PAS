program auswert;
uses crt;
var x : array [0..3,0..100] of real;
    f : text;
    xi: real;
    i : integer;
    j : integer;
begin
     clrscr;

     assign(f,'c:\tp\data.dat');
     reset(f);

     i:=1;
     while not eof(f) do
           begin
                readln(f,xi);
                xi:=xi+273;
                writeln(i,'. Datenwert: ',xi:3:3);
                x[1,i]:=xi;
                x[0,i]:=60*i;
                x[3,i]:=ln(xi);
                x[2,i]:=ln(60*i);
                inc(i);
           end;

     close(f);
     assign(f,'c:\tp\data_neu.dat');
     rewrite(f);

     writeln(f,'[t]=s ; [T]=K ; ln(t) ; ln(T) ;');
     j:=i;
     for i:=1 to j-1 do
         begin
              writeln(f,i,' ; ',x[0,i]:3:3,' ; ',x[1,i]:3:3,' ; ',x[2,i]:3:3,' ; ',x[3,i]:3:3,' ;');
              writeln(x[0,i]:3:3,' ; ',x[1,i]:3:3,' ; ',x[2,i]:3:3,' ; ',x[3,i]:3:3,' ;');
         end;

     close(f);
end.