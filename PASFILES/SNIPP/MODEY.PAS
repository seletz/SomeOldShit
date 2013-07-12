{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 375 of 385
From : Kai Rohrbacher                      2:241/7451.7         10 Apr 93  19:55
To   : David Todd                          1:259/423.0
Subj : Mode X/Y (was Re: Faster MOVE/FILLCHAR)
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
DT>  Hello Kai,
DT>            I was wondering if you have time, (or patients) to explain
DT>  MODE X.
How comes me getting that honour? :-)

  Well,  I don't care much about Mode X (which is 320x240x256), but use Mode Y
  (=320x200x256)  --at least I think that this mode is called "Mode Y" (as far
  as  I  know, the terms were introduced by a series of Michael Abrash in "Dr.
  Dobb's  Journal" (?)). Nevertheless, things are identical with the exception
  of initialising the VGA card! So here we go; note that the ASM code examples
  were taken from my ANIVGA-toolkit: the PASCAL-equivalents when given are "on
  the  fly"  ASM->PASCAL  translations  for  improved  clarity (I hope...); in
  doubt, rely on the ASM part.

MODE Y in a nutshell
~~~~~~~~~~~~~~~~~~~~

  Basically,  Mode  Y  works  like  this:  use  the BIOS to switch into normal
  320x200x256  mode,  then reprogram the sequencer to unchain the 4 bitplanes.
  This  results  in  a bitplaned VRAM layout very similiar to the EGA/VGA's 16
  color modes: }

PROCEDURE InitGraph; ASSEMBLER;
ASM
  MOV AX,0013h
  INT 10h
  MOV DX,03C4h
  MOV AL,04
  OUT DX,AL
  INC DX
  IN  AL,DX
  AND AL,0F7h
  OR  AL,04
  OUT DX,AL
  MOV DX,03C4h
  MOV AL,02
  OUT DX,AL
  INC DX
  MOV AL,0Fh
  OUT DX,AL
  MOV AX,0A000h
  MOV ES,AX
  SUB DI,DI
  MOV AX,DI
  MOV CX,8000h
  CLD
  REP STOSW

  MOV DX,CRTAddress
  MOV AL,14h
  OUT DX,AL
  INC DX
  IN  AL,DX
  AND AL,0BFh
  OUT DX,AL
  DEC DX
  MOV AL,17h
  OUT DX,AL
  INC DX
  IN  AL,DX
  OR  AL,40h
  OUT DX,AL
END;

{
  CRTAddress  and  StatusReg  are the port addresses for the VGA ports needed;
  they  are 3B4h and 3BAh on a monochrome display and 3D4h and 3DAh on a color
  display, but can be determined at run-time, too: }

ASM
  MOV DX,3CCh
  IN AL,DX
  TEST AL,1
  MOV DX,3D4h
  JNZ @L1
  MOV DX,3B4h
 @L1:
  MOV CRTAddress,DX
  ADD DX,6
  MOV StatusReg,DX
END;


{  The  VRAM  layout  is  this:  underneath  each  memory  address in the range
  $A000:0000..$A000:$FFFF,  there  are  4 bytes, each representing one pixel's
  color.
  Whenever you write to or read from such an address, an internal logic of the
  VGA-card determines which one of those 4 pixels is accessed.
  A  line  of  320  pixels (=320 bytes) thus only takes 320/4=80 bytes address
  space,  but  to  address  a pixel, you need a) its VRAM address and b) which
  bitplane it's on.
  The  pixels  are arranged linearly: thus, the mapping from point coordinates
  to memory addresses is done by (x,y) <-> mem[$A000: y*80+ (x div 4)] and the
  bitplane is determined by (x mod 4).
  (Note coordinates start with 0 and that "div 4" can be computed very fast by
  "shr 2"; "mod 4" by "and 3").

  So  you  computed the proper address and bitplane. If you want to _read_ the
  pixel's color, you issue commands like this:
   portw[$3CE]:=(bitplane SHL 8)+4; color:=mem[$A000:y*80+(x shr 2)]
  Or for better speed & control, do it in ASM: }
 MOV AL,4
 MOV AH,bitplane
 MOV DX,3CEh
 CLI
 OUT DX,AX
 MOV AL,ES:[DI]
 STI

{  _Writing_  a pixel's color works similiar, but needs an additional step: the
  mask is computed by 1 SHL bitplane (that is: 1/2/4/8 for mod4 values 0/1/2/3
  respectively):
   portw[$3C4]:=(1 SHL bitplane+8)+2; mem[$A000:y*80+(x shr 2)]:=color
  Or using ASM again: }
 MOV CL,bitplane
 MOV AH,1
 SHL AH,CL
 MOV AL,2
 MOV DX,3C4h
 CLI
 OUT DX,AX
 STOSB
 STI

{  As  stated  above, one address represents 4 pixels, so 320x200 pixels occupy
  16000  address  bytes.  We  do  have  65536  (=$A000:0..$A000:$FFFF) though,
  therefore  a  bit  more  than 4 pages are possible. It's up to you to define
  your  pages,  0..15999=page  0,  16000..31999=page  1,  32000..47999=page 2,
  48000..63999=page 3, 64000..65535=unused  is the most obvious layout.

  Which  part  of  the VRAM is actually displayed can be programmed by writing
  the  offset  part of the starting address to the CRT-controller (the segment
  part is implicitly set to $A000): }

ASM
  MOV DX,CRTAddress
  MOV AL,$0D
  CLI
  OUT DX,AL
  INC DX
  MOV AL,low byte of starting offset
  OUT DX,AL
  DEC DX
  MOV AL,$0C
  OUT DX,AL
  INC DX
  MOV AL,high byte of starting offset
  OUT DX,AL
  STI
END;

{
  N.B.: if you reprogram the display's starting address more often than "every
  now  and  then",  you  better  synchronize  that  to the vertical retrace or
  horizontal  enable  signal  of  your VGA card; otherwise, an annoying screen
  flicker will become visible during switching!


  For  example,  if  you do a "FOR i:=1 TO 100 DO SetAddress(i*80)", this will
  result  in a blinding fast hardware scroll: with each iteration of the loop,
  the  display will start 80 address bytes (=320 pixels = 1 row) later, giving
  the impression of the display scrolling upwards.

  Note  that  Mode  X/Y  do  not differ in any other respect than their memory
  layouts  from  all  the  other  bitplaned VGA modes: palette handling is the
  same,  as  is usage of the VGA's write modes! In (default) write mode 0, you
  can access the VRAM by bytes, words or dwords. Write mode 1 is handy to copy
  the  contents  of  one  graphic  page to another: you are restricted to byte
  accesses, but each one will transfer 4 bytes at once.
  For example, a sequence like the following...
  portw[$3C4]:=$0f02; portw[$3CE]:=$4105;
  move(mem[$a000:0000],mem[$a000:$3e80],16000);
  portw[$3CE]:=$4005
  ...enables  all 4 planes, switches to write mode 1, copies the (64000 bytes)
  contents  of  the  2nd graphic page to the 1st one and then switches back to
  write mode 0 again. }