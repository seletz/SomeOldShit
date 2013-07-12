{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 115 of 150
From : Sean Palmer                         1:104/123.0          08 Apr 93  15:35
To   : All
Subj : G:Rodent unit
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
{ Rodent unit  v1.1      OooO }
{   03/28/93              \/  }
{ Interrupt-style interface for Microsoft mouse, Turbo Pascal 6.0}
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

unit Rodent;
{$A-,B-,D-,E-,F-,G+,I-,L-,N-,O-,R-,S-,V-,X+}
{make sure you alloc enough stack space in main program!}
{as written, requires a 286+ and that the mouse exists}
interface

const
 x:integer=0; y:integer=0;   {current mouse pos}
 xs:integer=0; ys:integer=0; {mickey counts (unreliable)}
 left=1; center=2; right=4;  {button masks:(btn and left)<>0 if left button
down}
 b:boolean=false;            {button status, true if any button down}
var
 btn:byte absolute b;
 hidden:boolean;
type
 pMouseHook=^tMouseHook;
 tMouseHook=procedure;

{avoid calling dos, bios, and mouse routines from these if possible}
function erasHook(h:tMouseHook):pMouseHook;
function moveHook(h:tMouseHook):pMouseHook;
function drawHook(h:tMouseHook):pMouseHook; {change out handlers}
function clikHook(h:tMouseHook):pMouseHook;
function liftHook(h:tMouseHook):pMouseHook;

procedure show(f:boolean);          {true=show}
procedure confine(l,t,r,b:integer); {set min,max bounds}
procedure moveTo(h,v:integer);
procedure setSpeed(xs,ys,thr:word); {set x,y pix per 16 mickeys, double speed
threshold}

implementation

{This unit should work in any mode, but you need to provide the routines
 to draw and erase the cursor.}
{note: reason coords are scaled *16 throughout is because mouse driver}
 {stupidly messes with the values differently in different modes.}
 {This is just a work-around.}
{PS: don't trust mickey counts in DI & SI in event handler.}
 {I found that they are extremely inaccurate, so I left them out.}
{You could use my Ticker unit to access clock ticks to time double clicks!}

var
 hideCount:byte absolute hidden;

procedure defaultMouseHook;far;assembler;asm end;

procedure cli;inline($FA);
procedure sti;inline($FB);

const
 vDrawHook:tMouseHook=defaultMouseHook;
 vErasHook:tMouseHook=defaultMouseHook;
 vMoveHook:tMouseHook=defaultMouseHook;
 vClikHook:tMouseHook=defaultMouseHook;
 vLiftHook:tMouseHook=defaultMouseHook;

function drawHook(h:tMouseHook):pMouseHook;begin drawHook:=@vDrawHook; cli;
vDrawHook:=h; sti; end;
function erasHook(h:tMouseHook):pMouseHook;begin erasHook:=@vErasHook; cli;
vErasHook:=h; sti; end;
function moveHook(h:tMouseHook):pMouseHook;begin moveHook:=@vMoveHook; cli;
vMoveHook:=h; sti; end;
function clikHook(h:tMouseHook):pMouseHook;begin clikHook:=@vClikHook; cli;
vClikHook:=h; sti; end;
function liftHook(h:tMouseHook):pMouseHook;begin liftHook:=@vLiftHook; cli;
vLiftHook:=h; sti; end;

{calling regs:}
 {ax:triggering event bit mask}
 {bx:button status bit mask (bit 0=left,1=center,2=right)}
 {cx:mouse X/bit 7 is sign for di,bit 0 always=0}
 {dx:mouse Y/bit 7 is sign for si}
 {di:abs mouse Delta X}
 {si:abs mouse Delta Y}

{bits in event mask:}
 {0:move}
 {1:left btn down}
 {2:left btn up}
 {3,4:center btn}
 {5,6:right btn}

{This code is real easy to break, be careful!}
procedure doMouseHook;far;assembler;asm
 cli;
 push ax; mov ax,seg @DATA; mov ds,ax; pop ax;
 mov xs,si; mov ys,di; {disregard di,si mickey counts}
 mov btn,bl;
 and cx,$3FFF; shr cx,3; and dx,$3FFF; shr dx,3; {strip hi bits}
 push ax; push cx; push dx;  {save event status}
 test hidden,$FF; jnz @NOERAS; call vErasHook; @NOERAS:
 pop dx; mov y,dx; pop cx; mov x,cx;
 call vMoveHook;  {always assume mouse has moved, disregard bit 0 of ax}
 test hidden,$FF; jnz @NODRAW; call vDrawHook; @NODRAW:
 pop ax; {restore event status}
@CLIK: test al,00101010b; jz @LIFT; {check any button clik flag}
 push ax; call vClikHook; pop ax;
@LIFT: test al,01010100b; jz @EXIT; {check any button lift flag}
 call vLiftHook;
@EXIT: sti;
 end;

procedure show(f:boolean);begin
 cli;
 if f then begin
  if hidden then begin dec(hideCount); if not hidden then vDrawHook; end;
  end
 else begin if not hidden then vErasHook; inc(hideCount); end;
 sti;
 end;

Procedure confine(l,t,r,b:integer);assembler;asm
 mov ax,7; mov cx,l; shl cx,3; mov dx,r; shl dx,3; int $33;
 mov ax,8; mov cx,t; shl cx,3; mov dx,b; shl dx,3; int $33;
 end;

procedure moveTo(h,v:integer);begin
 if not hidden then vErasHook;
 asm mov cx,h; mov x,cx; shl cx,3;
     mov dx,v; mov y,dx; shl dx,3;
     mov ax,4; int $33; end;
 if not hidden then vDrawHook;
 end;

procedure setSpeed(xs,ys,thr:word);assembler;asm
 mov ax,$1A; mov bx,xs; shl bx,3; mov cx,ys; shl cx,3; mov dx,thr; int $33;
 end;

var
 oldMouseHook:pointer;
 oldEventMask:word;

procedure removeMouse;begin
 if not hidden then show(false);
 asm les dx,oldMouseHook; mov cx,oldEventMask; mov ax,$C; int $33;end;
 end;

var
 mouseHook:pointer absolute 0:$33*4;
const
 eventMask=$7F;  {all events}

function exists:boolean;assembler;asm
 xor ax,ax; mov es,ax; mov bx,es:[$33*4]; or bx,es:[$33*4+2]; jz @X; {no}
 xor ax,ax; int $33; @X:  {result in al}
 end;

begin
 if exists then begin
  setSpeed(32,64,4);    {set up a natural-feeling speed for 640x480}
  moveTo(0,0);confine(0,0,0,0); {trap the little sucker}
  hideCount:=1;
  asm
   push cs;
   pop es;
   mov dx,offset doMouseHook;
   mov cx,eventMask;
   mov ax,$14;
   int $33;
   mov oldEventMask,cx;
   mov word ptr oldMouseHook,dx;
   mov word ptr oldMouseHook+2,es;
   end;
  end
 else begin writeln('Need mouse.'); halt(1);end;
 end.
