program elek;
uses crt,graph,sgraph;
const maxch = 1000;
      schwelle = 95;
      periode =5;
      paarschw = 0.1;
      mutschw = 0.1;
var  eleks : array [1..100,1..16] of integer;
     zustand : array [1..100] of integer;
     best,worst:integer;
     chron:integer;
     umwelt : array [1..100] of integer;
     punkte : array [1..100] of integer;
     statistik: array[1..maxch,1..3] of integer;
procedure init;
var i,j,k:integer;
    x:array [0..periode] of integer;
begin
     writeln('initial..');
     randomize;
     for i:=1 to 100 do
         begin
              for j:=1 to 16 do
                  begin
                       if odd(j) then
                          begin
                               eleks[i,j]:=random(2);
                          end
                       else
                           begin
                                eleks[i,j]:=random(4);
                           end;
                  end;
              writeln;
         end;
     for i:=0 to periode do
         begin
              x[i]:=random(20) mod 2;
         end;

     for i:=1 to 100 do
         begin
              umwelt[i]:=x[i mod periode];
         end;
     writeln;
     for i:=1 to 100 do begin zustand[i]:=0; punkte[i]:=0 end;

end;
procedure pxy(x,y:integer; a:string);
begin
     gotoxy(x,y);
     write(a);
end;
procedure outchrom(x,y,nr:integer);
var i,j,k:integer;
begin
     gotoxy(x,y);
     write(nr,': ');
     for i:=1 to 16 do
         begin
              if odd(i) then
                 write(eleks[nr,i])
              else
                 write(chr(ord('A')+eleks[nr,i]));

         end;
end;
procedure teste;
var i,j,k:integer;
    l:integer;
    p:integer;
begin
     for i:=1 to 100 do begin zustand[i]:=0; punkte[i]:=0 end;
     for i:= 1 to 100 do
         begin
         for j:=1 to 98 do
             begin
                  l:=4*zustand[i]+2*umwelt[j]+1;
                  if eleks[i,l]=umwelt[j+1] then
                     inc(punkte[i]);
                  zustand[i]:=eleks[i,l+1]
             end;
         end;
end;
procedure werte;
var i,j,k:integer;
    b,w:integer;
begin
     b:=0; w:=10000;
     best:=0; worst:=0;
     for i:=1 to 100 do
         begin
              if punkte[i]<w then
                 begin
                      worst:=i;
                      w:=punkte[i];
                 end;
              if punkte[i]>b then
                 begin
                      best:=i;
                      b:=punkte[i];
                 end;
         end;
     statistik[chron,1]:=punkte[best];
     statistik[chron,2]:=punkte[worst];
     gotoxy(5,5); clreol;
     write('Best:',best,' ',punkte[best]);
     gotoxy(20,5);
     write('Worst: ',worst,' ',punkte[worst]);
end;
procedure mutiere;
var i,j,k,l:integer;
begin
     k:=random(6)+1;
     for l:=1 to k do begin

     i:=random(100)+1;
     j:=random(16)+1;
     if odd(j) then eleks[i,j]:=(eleks[i,j]+1) mod 2 else eleks[i,j]:=(eleks[i,j]+1) mod 4;
     gotoxy(3,7);clreol;
     writeln('Elek ',i,' Mutiert...');
     outchrom(3,9,i);

     end;
end;
procedure paare;
var elek1,elek2,c1,c2,i,j,k:integer;
begin
     pxy(3,17,'Paarung:');
     elek1:=random(100)+1;
     elek2:=random(100)+1;
     outchrom(3,18,best);
     outchrom(3,19,elek1);
     c1:=random(16)+1;
     c2:=random(16)+1;
     if c1>c2 then
        begin
             i:=c2;
             c2:=c1;
             c1:=i;
        end;
     for i:=1 to 16 do
        begin
             if (i<c1) or (i>c2) then
                begin
                     eleks[worst,i]:=eleks[elek1,i];
                end
             else
                 begin
                      eleks[worst,i]:=eleks[best,i];
                 end;

        end;
     outchrom(3,20,worst);
end;
procedure stats;
var xstep,ystep:integer;
    xorg,yorg:integer;
    i,j,k:integer;
begin
     grafikein;
     xstep:=round((getmaxx - 100) / chron);
     ystep:=round((getmaxy - 100) / 100);
     xorg:=0;
     yorg:=getmaxy ;
     line(xorg,yorg,xorg,yorg-100*ystep);
     line(xorg,yorg,getmaxx,yorg);
     i:=xorg;
     while i<=chron*xstep do
           begin
                line(i,0,i,getmaxy);
                i:=i+xstep;
           end;
     i:=yorg;
     while i<=100*ystep do
           begin
                line(0,i,getmaxx,i);
                i:=i-ystep;
           end;
     for i:=2 to chron do
         begin
             setcolor(3);
             line((i-1)*xstep,yorg-statistik[i-1,1]*ystep,
             i*xstep,yorg-statistik[i,1]*ystep);
             setcolor(4);
             line((i-1)*xstep,yorg-statistik[i-1,2]*ystep,
             i*xstep,yorg-statistik[i,2]*ystep);
         end;
     while not keypressed do;
     grafikaus;
end;
begin
    writeln('Eleks...');
    init;
    chron:=0; best:=1;
    while punkte[best]<=schwelle do
          begin
               gotoxy(1,1); write('Zeit:',chron);
               inc(chron);
               teste;
               werte;
               if mutschw<random then mutiere;
               if paarschw<random then paare;
          end;
    stats;
end.