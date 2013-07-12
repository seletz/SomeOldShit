{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 114 of 150
From : Sean Palmer                         1:104/123.0          08 Apr 93  15:35
To   : All
Subj : G:Sync Unit
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
{ Sync unit  v1.0 }
{   04/06/93      }
{ Minimal support for cpu-independent timing, Turbo Pascal 6.0}
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

unit sync;
{$A-,B-,D-,E-,F-,G-,I-,L-,N-,O-,R-,S-,V-,X-}
interface
var ticks:word absolute $40:$6C;   {ticks happen 18.2 times/second}

procedure tick;                             {pauses until next tick}
function ticked:boolean;    {true if tick occurred since last check}
procedure waitTicks(n:word);  {pauses for specified number of ticks} 

implementation

var curTick:word;

procedure tick;begin curTick:=succ(ticks);repeat until ticks=curTick;end;

function ticked:boolean;begin
 if curTick<>ticks then begin curTick:=ticks; ticked:=true; end
 else ticked:=false;
 end;

procedure waitTicks(n:word);begin
 curTick:=ticks+n;  {will wrap}
 repeat until ticks=curTick;
 end;

begin
 curTick:=ticks;
 end.
___ Blue Wave/QWK v2.12

--- Maximus 2.01wb
 * Origin: >>> Sun Mountain BBS <<< (303)-665-6922 (1:104/123)

