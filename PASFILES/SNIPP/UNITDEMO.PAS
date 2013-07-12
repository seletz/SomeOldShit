{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 119 of 150
From : Sean Palmer                         1:104/123.0          08 Apr 93  15:37
To   : All
Subj : G:Smooth Text Mouse prog
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
**** SOMETHING IS WRONG WITH THIS PROGRAM OR THE UNITS IT USES! ****

it leaves mouse trails on the screen, seemingly at random, and I can't figure
it out. PLEASE HELP! It only happens when hiding and showing the mousecursor,
if you just leave it on all the time it's fine (but you have to hideit
sometimes if you modify the screen at all...)

I've tried disabling interrupts in various places but it doesn't help. My
logic seems to be ok, but every once in a while it will just fail to erasethe
cursor...

Whoever points out the error will get his/her name in the credits and my
eternal gratitude!! }


{ Unit Demo v1.0 }
{   03/28/93     }
{ Just a junker program that demonstrates how to use my other units }
{ Copyright (c) 1993 Sean L. Palmer }
{ Released to the Public Domain }

{ You may distribute this freely and incorporate it with no royalties. }
{ Please credit me if your program uses these routines! }
{ If you really like them or learn something neat from me then I'd }
{ appreciate a small ($1 to $5) donation. }
{ Or contact me if you need something programmed or like my work... }
{ I probably have the wierdest indenting style for pascal ever! 8)  }
{ And, by God my stuff is optimized!! }

{ Sean L. Palmer (aka Ghost)}
{ 2237 Lincoln St. }
{ Longmont, CO 80501 }
{ (303) 651-7862 }
{ also on FIDO, or at palmers@spot.colorado.edu }

program unitDemo;
uses crt,fnt8x8,rodent,sync; {requires vga,mouse,Turbo Pascal 6.0,and 286+}

var done:boolean;
procedure drawRodent;far;begin fnt8x8.drawMouse(rodent.x,rodent.y);end;
procedure erasRodent;far;begin fnt8x8.eraseMouse;end;
procedure liftRodent;far;begin done:=true; end;

var i:byte;
begin
 textattr:=8*16+7;clrscr;
 for i:=0 to 255 do memw[$B800:640+2*i]:=i+(i shl 8);
 rodent.confine(0,0,633,392);
 rodent.drawHook(drawRodent);
 rodent.erasHook(erasRodent);
 rodent.liftHook(liftRodent);
 rodent.show(true);
 done:=false;
 repeat
  sync.tick;   {synchronize with timer tick}
  rodent.show(false);
  gotoxy(1,1); write(sync.ticks:5); {demonstrate hiding mouse while updating}
  rodent.show(true);
  if keypressed then begin done:=true; readkey; end;
  until done;
 rodent.show(false);
 end.