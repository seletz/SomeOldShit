{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 432 of 442
From : Steven Tallent                      1:3811/210.0         10 Apr 93  11:58
To   : Jack Cross
Subj : Speaker Off
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
 -=> Quoting Jack Cross to All <=-

 JC> I am look for a piece of code [...] that will turn off the speaker.

This is tested code, and should do the trick.  It does its work by
turning off the PC speaker 18.2 times per second.  This should reduce
any sound to maybe a click or two.  Unfortunately, some games and
music software will bypass it (ModPlay, Wolfenstein), but most beeps
and whistles will be gone.  This is a TSR program, and takes about 3k
memory (yuk), but you can load it high if you want.  I've found it
especially useful during late-night BBSing (no alarms at connect/file
xfer finish). Hope this does the trick!  Considering its size and
relative isolation from normal programs, I didn't see fit to use CLI/STI. }

{$M 1024,0,0}  {BTW, is there any way to make this smaller?!?}
{$N-,S-,G+} { Use g- for 8088 systems, g+ for V20 and above }
PROGRAM NoSpeak;
USES Dos;

PROCEDURE ShutOff; INTERRUPT;
BEGIN
  Port [97] := Port[97] and 253; {Turn off speaker and disconnect timer}
  end;

BEGIN
  SetIntVec( $1C, @ShutOff);
  Keep(0);
  end.

... Cliche: the sound a French door makes when closing.
___ Blue Wave/QWK v2.12
--- Renegade v04-05 Beta
 * Origin: Pink's Place - Renegade Style (409)883-8344/4049 (1:3811/210)

