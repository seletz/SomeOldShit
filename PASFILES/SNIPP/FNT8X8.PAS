{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 118 of 150                                                               
From : Sean Palmer                         1:104/123.0          08 Apr 93  15:40 
To   : All                                                                       
Subj : G:Fnt8x8 unit                                                          
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
{ Fnt8x8 unit  v1.0 }
{   03/28/93        }
{ various support routines for vga 8x8 text modes}
{ stuff for smooth text mousing and 16-color backgrounds}
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

unit fnt8x8;
interface

procedure init;
function rows:byte;
procedure drawMouse(x,y:word);
procedure eraseMouse;

implementation

function rows:byte;assembler;asm
 mov ax,$1130; xor dx,dx; int $10;
 or dx,dx; jnz @S; mov dx,24; @S: {cga/mda don't have this fn}
 inc dx; mov al,dl;
 end;

type tChar=array[0..7]of byte;
const mouseBase=220;     {spot in charset mouse cursor uses}

{method to update chars was taken from a FIDO echo}
{only works on VGA as far as I know} 

procedure accessChrMem;Inline(
  $FA/                   {cli}
  $BA/$C4/$03/           {mov dx,$3C4}
  $B8/$02/$04/           {mov ax,$0402}
  $EF/                   {out dx,ax}
  $B8/$04/$07/           {mov ax,$0704}
  $EF/                   {out dx,ax}
  $80/$C2/$0A/           {add dl,10}
  $B8/$04/$02/           {mov ax,$0204}
  $EF/                   {out dx,ax}
  $B8/$05/$00/           {mov ax,$0005}
  $EF/                   {out dx,ax}
  $B8/$06/$00/           {mov ax,$0006}
  $EF);                  {out dx,ax}
   
procedure accessVidMem;Inline(
  $BA/$C4/$03/           {mov dx,$3C4}
  $B8/$02/$03/           {mov ax,$0302}
  $EF/                   {out dx,ax}
  $B8/$04/$03/           {mov ax,$0304}
  $EF/                   {out dx,ax}
  $80/$C2/$0A/           {add dl,10}
  $B8/$04/$00/           {mov ax,$0004}
  $EF/                   {out dx,ax}
  $B8/$05/$10/           {mov ax,$1005}
  $EF/                   {out dx,ax}
  $B8/$06/$0E/           {mov ax,$0E06}
  $EF/                   {out dx,ax}
  $FB);                  {sti}

procedure SetChar(c:char;var data:tChar);begin
 accessChrMem; Move(data,mem[$A000:byte(c)*32],8); accessVidMem;
 end;

procedure getChar(c:char;var data:tChar);begin
 accessChrMem; Move(mem[$A000:byte(c)*32],data,8); accessVidMem;
 end;

const cursorData:tChar=($C0,$E0,$F0,$F8,$FC,$FE,$E0,$C0);

var
 oldChars:array[0..3]of byte;
 oldAdr:word;

procedure eraseMouse;var i:byte;a:word;begin
 asm cli; end;
 a:=oldAdr;
 for i:=0 to 3 do begin
  mem[$B800:a+i*2]:=oldchars[i];
  if i=1 then inc(a,160-4);
  end;
 asm sti;end;
 end;

procedure copyChar(s,d:char);var i:tChar;begin
 getchar(s,i);
 setChar(d,i);
 end;

procedure drawMouse(x,y:word);
var xl,yl,xr:byte;a:word;i:byte; pc,pd:^byte;
begin
 xl:=x and 7; yl:=y and 7; xr:=8-xl; x:=x shr 3; y:=y shr 3;
 a:=y*160+x*2; oldAdr:=a;
 for i:=0 to 3 do begin
  oldchars[i]:=mem[$B800:a+i*2];
  copychar(char(oldChars[i]),char(mouseBase+i));
  mem[$B800:a+i*2]:=mouseBase+i;
  if i=1 then inc(a,160-4);
  end;
 pc:=ptr($A000,mouseBase*32+yl);
 pd:=@cursorData;
 accessChrMem;
 for i:=0 to 7 do begin
  pc^:=pc^ or (pd^ shr xl); inc(word(pc),32);
  pc^:=pc^ or (pd^ shl xr); dec(word(pc),31);
  inc(word(pd));
  inc(yl); if yl=8 then inc(word(pc),56);  {handle wrap to next row}
  end;
 accessVidMem;
 end;

procedure init;assembler;asm
 mov ax,$1202; mov bl,$30; int $10; {select 400 scan lines}
 mov ax,3; int $10; {text mode}
 mov bl,0;mov ax,$1003; int $10;  {no blinking, enable 16 colors for
background}  mov ax,$1112; mov bl,0; int $10; {load 8x8 character set}
 end;

var oldmode:byte;
function vgaPresent:boolean;assembler;asm
 mov ah,$F; int $10; mov oldMode,al;  {save old Gr mode}
 mov ax,$1A00; int $10;    {check for VGA/MCGA}
 cmp al,$1A; jne @ERR;     {no VGA Bios}
 cmp bl,7; jb @ERR;        {is VGA or better?}
 cmp bl,$FF; jnz @OK;
@ERR: xor al,al; jmp @EXIT;
@OK: mov al,1;
@EXIT:
 end;

var exitSave:pointer;

procedure done;far;begin;
 exitProc:=exitSave;
 asm mov al,oldmode; xor ah,ah; int $10;end;
 end;

procedure blinkOn;assembler;asm mov bl,1;mov ax,$1003; int $10;end;

begin
 if vgaPresent then begin
  init;
  exitSave:=exitProc;exitProc:=@done;
  end
 else begin writeln('Need VGA.'); halt(1);end;
 end.
