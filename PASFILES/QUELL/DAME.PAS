program dame22;
{
                version 0.0
                2x2 Dame by StE
                start:29.6.1993
                end  :?????????
}
uses crt;
const rot=-1;
      schwarz=1;
      q:char=chr(201);
      w:char=chr(187);
      a:char=chr(200);
      s:char=chr(188);
      e:char=chr(186);
      er:char=chr(182);
      el:char=chr(199);
      d:char=chr(205);
      dob:char=chr(209);
      du:char=chr(207);
      k:char=chr(197);
      h:char=chr(196);
      v:char=chr(179);
type  dbase = object
                  Constructor init;
                  destructor done;
              end;
      dame = object(dbase)
                          constructor init;
                          destructor done;
                          procedure draw(x,y:integer);
             end;
      brettptr = ^brett;
      brett = object(dbase)
                           feld:array [1..4,1..4] of integer;
                           code:integer;
                           constructor init(f:array [1..4,1..4] of integer; code:integer);
                           destructor done;
              end;

      blistptr = ^brettlist;
      brettlist = object(dbase);
                                b:brettptr;
                                next:blistptr;
                                prev:blistptr;
                                first:blistptr;
                                last:blistptr;
                                function addbrett(ib:brettptr; firstflag:boolean):blistptr;
                                function nextb:blistptr;
                                function prevb:blistptr;
                  end;
{

                ************** Dbase

}
constructor dbase.init; begin fail; end;
destructor dbase.done; begin end;
{

                ************** Dame

}
constructor dame.init;
var i,j:integer;
begin
     for j:=1 to 4 do
         for i:=1 to 4 do feld[i,j]:=0;
     feld[2,1]:=rot;
     feld[4,1]:=rot;
     feld[1,4]:=schwarz;
     feld[3,4]:=schwarz;
end;
destructor dame.done; begin end;
procedure dame.draw(x,y:integer);
var b,l,i,j,k:integer;
begin
     b:=8;
     l:=8;
     gotoxy(x,y);
     write(q);
     for i:=x+1 to x+b-1 do begin
         gotoxy(i,y);
         if odd(i-x) then write(d) else write(dob);
     end;
     write(w);
     for j:=y+1 to y+l-1 do begin
         gotoxy(x,j);
         if odd(j-y) then begin
            write(e);
         end else begin
            write(el);
         end;
         if odd(j-y) then begin
             for i:=x+1 to x+b-1 do begin
                 gotoxy(i,j);
                 if odd(i-x) then write ('.') else write(v);
             end;
         end else begin
             for i:=x+1 to x+b-1 do begin
                 gotoxy(i,j);
                 if odd(i-x) then begin
                    write(h)
                 end else begin
                    write(chr(197))
                 end;
             end;
         end;
         gotoxy(x+b,j);
         if odd(j-y) then write(e) else write(er);
     end;
     gotoxy(x,y+l);
     write(a);
     for i:=x+1 to x+b-1 do begin
         gotoxy(i,y+l);
         if odd(i-x) then write(d) else write(du);
     end;
     gotoxy(x+b,y+l);
     write(s);

     b:=textattr;
     for j:=1 to 4 do
         for i:= 1 to 4 do begin
             case feld[i,j] of
                  schwarz:  begin
                                 textcolor(Blue);
                                 gotoxy(x+2*i-1,y+2*j-1);
                                 write('o');
                             end;
                  rot     :  begin
                                 textcolor(red);
                                 gotoxy(x+2*i-1,y+2*j-1);
                                 write('o');
                             end;
                  2*schwarz: begin
                                 textcolor(Blue);
                                 gotoxy(x+2*i-1,y+2*j-1);
                                 write('0');
                             end;
                  2*rot: begin
                                 textcolor(red);
                                 gotoxy(x+2*i-1,y+2*j-1);
                                 write('0');
                             end;
             end;
         end;
end;
{

        ************************* Brett


}
constructor brett.init(f:array [1..4,1..4] of integer);
var i,j:integer;
begin
     for i:=1 to 4 do
     for j:=1 to 4 do feld[i,j]:=f[i,j];
end;
destructor brett.done; begin end;

{

        ************************* Brettliste


}

function brettlist.addbrett(ib:brettptr; firstflag:boolean;);
begin
     first:=nil;
     last:=nil;
     next:=nil;
     prev:=nil;
     b:=ib;
     if firstflag then begin
        first:=self;
     end else begin

     end;
end;
{

        *************************    H  A  U  P  T  P  R  O  G  R  A  M  M


}


var da:dame;
begin
     clrscr;
     da.init;
     da.draw(3,3);
     repeat until keypressed;
end.
