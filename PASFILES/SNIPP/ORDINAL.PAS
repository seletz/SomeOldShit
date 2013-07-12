{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 260 of 267                                                               
From : Rob Perelman                        1:202/1308.0         14 Apr 93  23:23 
To   : Chris Bratene                                                             
Subj : Pascal Probs                                                           
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
CB>  -  What's the CHARACTER that is returned when you hit your arrow keys?  I'
  >     using a CHAR variable for input and would like to know what the arrow
  >     keys give out as a CHAR.

CB>     ie. When you hit Return/Enter key it gives out #13

CB>   Could you lay out the commands for all 4 arrow keys like so:


CB>                                /-\  up arrow = ??
  >                                 |
  >              left arrow = ?? <-- -->  right arrow = ??
  >                                 |
  >                                \_/
  >                                     down arrow = ??

Try using this program to figure out how to use it:}

Program Ordinal;

Uses Crt;

Var Letter: Char;
I: Integer;

Begin
  TextBackGround(Black);
  TextColor(LightGray);
  Clrscr;
  Repeat
    Letter:=ReadKey;
    If Letter=#0 then Begin
      Letter:=ReadKey;
      Writeln('Special characters: 0, ',Ord(Letter),' (',Letter,')');
    End Else Writeln(Letter,' = ',Ord(Letter));
  Until Letter=#27; {Escape}
End.

This will show you how to use arrow keys, F-keys, and Alt-key (and a few
other keys)!