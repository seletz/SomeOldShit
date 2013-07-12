{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 271 of 309
From : Peter Beeftink                      1:163/307.25         16 Apr 93  11:37
To   : Ethan Brodsky                       1:121/8.0
Subj : wild cards
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Hello Ethan!

Tuesday April 13 1993 15:19, Ethan Brodsky wrote to All:

 EB> I am interested in making utilities that accept wildcards I.E.
 EB>                 *.*     ???TP.ZIP    WIN*.EXE
 EB> in Turbo Pascal 6.0.   Does anybody know how to do that?

I don't know what you exactly mean by 'accepting' but underneath is my function
wild, which might help you?

Peter }

Function Wild(flname,card:string):boolean;
{Returns true if the wildcard description in 'card' matches 'flname'
according to DOS wildcard principles.  The 'card' string MUST have a period!
Example: Wild('test.tat','t*.t?t' returns TRUE}

var
 c:char;
 p,i,n,l:byte;

Begin
  wild:=true;
  {test for special case first}
  if card='*.*' then exit;
  wild:=false;
  p:=pos('.',card);
  i:=pos('.',flname);
  if p=0 then
     Begin
           writeln('Invalid use of function "wild".  Program halted.');
           writeln('Wild card must contain a period.');
           halt;
           End;
  {test the situation before the period}
    n:=1;
    Repeat
    c:=upcase(card[n]);
    if c='*' then n:=p
     else if (upcase(flname[n]) = c) OR (c = '?') then inc(n)
      else exit;
  Until n >= p;

    {Now check after the period}
    n:=p+1; {one position past the period of the wild card}
    l:=length(flname);
    inc(i); {one position past the period of the filename}
    repeat
    if n > length(card) then exit;
    c:=upcase(card[n]);
         if c='*' then i:=l+1 {in order to end the loop}
          else
             if (upcase(flname[i]) = c) or (c = '?') then
                Begin
      inc(n);
      inc(i);
      End
     else exit;
  until i > l;

  wild:=true;

End;