{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 120 of 150
From : Sean Palmer                         1:104/123.0          08 Apr 93  15:37
To   : All
Subj : G:[1 of 2] X320x240 unit
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
{by Sean Palmer, 1993}
{released to the Public Domain}
{$A-,B-,D+,E-,F-,G+,I-,L+,N-,O-,R-,S-,V-,X+} {TP 6.0 & 286 required!}
unit x320x240;

{in tweaked modes, each latch/bit plane contains the entire 8-bit pixel.
 the sequencer map mask determines which plane (pixel) to update, and, when
 reading, the read map select reg determines which plane (pixel) to read.}
{almost exactly opposite from regular vga 16-color modes which is why I never
 could get my routines to work for BOTH modes. 8) }

{ #=source screen pixel
  Normal 16-color         Tweaked 256-color

      Bit Mask                Bit Mask
      76543210                33333333
 Map  76543210           Map  22222222
 Mask 76543210           Mask 11111111
      76543210                00000000

  Functional equivalents
      Bit Mask        =       Seq Map Mask
      Seq Map Mask    =       Bit Mask
}


interface

var
 color:byte;

const
 xRes=320; yRes=240;   {displayed screen size}
 xMax=xRes-1; yMax=yRes-1;
 xMid=xMax div 2; yMid=yMax div 2;
 vxRes=512; vyRes=$40000 div vxRes; {virtual screen size}
 nColors=256;
 tsx:byte=8; tsy:byte=8;  {tile size}

procedure plot(x,y:integer);
function  scrn(x,y:integer):byte;

procedure hLin(x,x2,y:integer);
procedure vLin(x,y,y2:integer);
procedure rect(x,y,x2,y2:integer);
procedure pane(x,y,x2,y2:integer);

procedure line(x,y,x2,y2:integer);
procedure oval(xc,yc,a,b:integer);
procedure disk(xc,yc,a,b:integer);
procedure fill(x,y:integer);

procedure putTile(x,y:integer;p:pointer);
procedure overTile(x,y:integer;p:pointer);
procedure putChar(x,y:integer;p:word);

procedure setColor(color,r,g,b:byte); {rgb vals are from 0-63}
function  getColor(color:byte):longint; {returns $00rrggbb format}
procedure setPalette(color:byte;num:word;var rgb); {rgb is list of 3-byte rgb
vals}
procedure getPalette(color:byte;num:word;var rgb);

procedure clearGraph;
procedure setWriteMode(f:byte);
procedure waitRetrace;
procedure setWindow(x,y:integer);

{XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX}

implementation

const
 vSeg=$A000;           {video segment}
 vxBytes=vxRes div 4;  {bytes per virtual scan line}

var
 crtcPort:word;  {crt controller}
const
 seqPort=$3C4;   {Sequencer}
 gcPort=$3CE;    {Graphics Controller}
type
 tRGB=record r,g,b:byte;end;

var
 oldMode:byte;
 exitSave:pointer;

{XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX}

procedure clearGraph;assembler;asm
 mov ax,vSeg; mov es,ax; mov dx,seqPort;
 mov ax,$0F02; out dx,ax; {enable whole map mask}
 xor di,di; mov cx,$8000; {screen size in words}
 cld; mov al,color; mov ah,al; repz stosw; {clear screen}
 end;

procedure setWriteMode(f:byte);assembler;asm {copy/and/or/xor modes}
 mov ah,f; shl ah,3; mov al,3; mov dx,gcPort; out dx,ax; {function select reg}
 end;

procedure waitRetrace;assembler;asm
 mov dx,crtcPort; add dx,6; {find crt status reg (input port #1)}
@L1: in al,dx; test al,8; jnz @L1;  {wait for no v retrace}
@L2: in al,dx; test al,8; jz @L2; {wait for v retrace}
 end;

const
 attrPort=$3C0;   {attribute Controller}
var
 input1Port:word;  {crtc Input Status Reg #1=crtcPort+6}

{Since a virtual screen can be larger than the actual screen, scrolling is
 possible.  This routine sets the upper left corner of the screen to the
 specified pixel.}
{make sure 0<=x<=vxRes-xRes, 0<=y<=vyRes-yRes}
procedure setWindow(x,y:integer);assembler;asm
 mov ax,vxBytes; mul y; mov bx,x; mov cl,bl;
 shr bx,2; add bx,ax;     {bx=Ofs of upper left corner}
 mov dx,input1Port; @L: in al,dx; test al,8; jnz @L;  {wait for no v retrace}
 sub dx,6;  {CRTC port}
 mov al,$D; mov ah,bl; cli; {these values are sampled at start of retrace}
 out dx,ax;  {lo byte of display start addr}
 dec al; mov ah,bh; out dx,ax;    {hi byte}
 sti;
 add dx,6; @L2: in al,dx; test al,8; jz @L2;  {wait for v retrace}
  {this also resets Attrib flip/flop}
 mov dx,attrPort; mov al,$33; out dx,al;   {Select Pixel Pan Register}
 and cl,3; mov al,cl; shl al,1; out dx,al;   {Shift is for 256 Color Mode}
 end;

{XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX}

procedure plot(x,y:integer);assembler;asm
 mov ax,vSeg; mov es,ax;
 mov di,x; mov cx,di; shr di,2;
 mov ax,vxBytes; mul y; add di,ax;
 mov ax,$0102; and cl,3; shl ah,cl;
 mov dx,seqPort; out dx,ax; {set bit mask}
 mov al,color; stosb;
 end;

function scrn(x,y:integer):byte;assembler;asm
 mov ax,vSeg; mov es,ax;
 mov di,x; mov cx,di; shr di,2;
 mov ax,vxBytes; mul y; add di,ax;
 and cl,3; mov ah,cl; mov al,4;
 mov dx,gcPort; out dx,ax;      {Read Map Select register}
 mov al,es:[di];  {get the whole plane}
 end;

procedure hLin(x,x2,y:integer);assembler;asm
 mov ax,vSeg; mov es,ax; cld;
 mov ax,vxBytes; mul y; mov di,ax; {base of scan line}
 mov bx,x;  mov cl,bl; shr bx,2;
 mov dx,x2; mov ch,dl; shr dx,2;
 and cx,$0303;
 sub dx,bx;     {width in bytes}
 add di,bx;     {offset into video buffer}
 mov ax,$FF02; shl ah,cl; and ah,$0F; {left edge mask}
 mov cl,ch;
 mov bh,$F1; rol bh,cl; and bh,$0F; {right edge mask}
 mov cx,dx; or cx,cx; jnz @LEFT;
 and ah,bh;                  {combine left & right bitmasks}
@LEFT:
 mov dx,seqPort; out dx,ax; inc dx;
 mov al,color; stosb;
 jcxz @EXIT; dec cx; jcxz @RIGHT;
 mov al,$0F; out dx,al;     {skipped if cx=0,1}
 mov al,color; repz stosb;   {fill middle bytes}
@RIGHT:
 mov al,bh; out dx,al;       {skipped if cx=0}
 mov al,color; stosb;
@EXIT:
 end;

procedure vLin(x,y,y2:integer);assembler;asm
 mov ax,vSeg; mov es,ax; cld;
 mov di,x; mov cx,di; shr di,2;
 mov ax,vxBytes; mul y; add di,ax;
 mov ax,$102; and cl,3; shl ah,cl; mov dx,seqPort;out dx,ax;
 mov cx,y2; sub cx,y; inc cx; mov al,color;
@DOLINE: mov bl,es:[di]; stosb; add di,vxBytes-1; loop @DOLINE;
 end;

procedure rect(x,y,x2,y2:integer);var i:word;begin
 hlin(x,pred(x2),y);hlin(succ(x),x2,y2);vlin(x,succ(y),y2);vlin(x2,y,pred(y2));
 end;

procedure pane(x,y,x2,y2:integer);var i:word;begin
 for i:=y2 downto y do hlin(x,x2,i);
 end;

procedure line(x,y,x2,y2:integer);var d,dx,dy,ai,bi,xi,yi:integer;begin
 if(x<x2)then begin xi:=1;dx:=x2-x;end else begin xi:=-1;dx:=x-x2;end;
 if(y<y2)then begin yi:=1;dy:=y2-y;end else begin yi:=-1;dy:=y-y2;end;
 plot(x,y);
 if dx>dy then begin ai:=(dy-dx)*2;bi:=dy*2; d:=bi-dx;
  repeat
   if(d>=0)then begin inc(y,yi);inc(d,ai);end else inc(d,bi);
   inc(x,xi);plot(x,y);
   until(x=x2);
  end
 else begin ai:=(dx-dy)*2;bi:=dx*2; d:=bi-dy;
  repeat
   if(d>=0)then begin inc(x,xi);inc(d,ai);end else inc(d,bi);
   inc(y,yi);plot(x,y);
   until(y=y2);
  end;
 end;

procedure oval(xc,yc,a,b:integer);var
x,y:integer;aa,aa2,bb,bb2,d,dx,dy:longint;begin
 x:=0;y:=b; aa:=longint(a)*a;aa2:=2*aa; bb:=longint(b)*b;bb2:=2*bb;
 d:=bb-aa*b+aa div 4; dx:=0;dy:=aa2*b;
 plot(xc,yc-y);plot(xc,yc+y);plot(xc-a,yc);plot(xc+a,yc);
 while(dx<dy)do begin
  if(d>0)then begin dec(y); dec(dy,aa2); dec(d,dy); end;
  inc(x); inc(dx,bb2); inc(d,bb+dx);
  plot(xc+x,yc+y); plot(xc-x,yc+y); plot(xc+x,yc-y); plot(xc-x,yc-y);
  end;
 inc(d,(3*(aa-bb)div 2-(dx+dy))div 2);
 while(y>0)do begin
  if(d<0)then begin inc(x); inc(dx,bb2); inc(d,bb+dx); end;
  dec(y); dec(dy,aa2); inc(d,aa-dy);
  plot(xc+x,yc+y); plot(xc-x,yc+y); plot(xc+x,yc-y); plot(xc-x,yc-y);
  end;
 end;

procedure disk(xc,yc,a,b:integer);var
x,y:integer;aa,aa2,bb,bb2,d,dx,dy:longint;begin
 x:=0;y:=b; aa:=longint(a)*a;aa2:=2*aa; bb:=longint(b)*b;bb2:=2*bb;
 d:=bb-aa*b+aa div 4; dx:=0;dy:=aa2*b;
 vLin(xc,yc-y,yc+y);
 while(dx<dy)do begin
  if(d>0)then begin dec(y); dec(dy,aa2); dec(d,dy); end;
  inc(x); inc(dx,bb2); inc(d,bb+dx);
  vLin(xc-x,yc-y,yc+y);vLin(xc+x,yc-y,yc+y);
  end;
 inc(d,(3*(aa-bb)div 2-(dx+dy))div 2);
 while(y>=0)do begin
  if(d<0)then begin
   inc(x); inc(dx,bb2); inc(d,bb+dx);
   vLin(xc-x,yc-y,yc+y);vLin(xc+x,yc-y,yc+y);
   end;
  dec(y); dec(dy,aa2); inc(d,aa-dy);
  end;
 end;

var fillVal:byte;
{This routine only called by fill}
function lineFill(x,y,d,prevXL,prevXR:integer):integer;var
xl,xr,i:integer;label _1,_2,_3;begin
 xl:=x;xr:=x;
 repeat dec(xl); until(scrn(xl,y)<>fillVal)or(xl<0); inc(xl);
 repeat inc(xr); until(scrn(xr,y)<>fillVal)or(xr>xMax); dec(xr);
 hLin(xl,xr,y);
 inc(y,d);
 if word(y)<=yMax then
  for x:=xl to xr do
   if(scrn(x,y)=fillVal)then begin
    x:=lineFill(x,y,d,xl,xr);
    if word(x)>xr then goto _1;
    end;
_1:dec(y,d+d); asm neg d;end;
 if word(y)<=yMax then begin
  for x:=xl to prevXL do
   if(scrn(x,y)=fillVal)then begin
    i:=lineFill(x,y,d,xl,xr);
    if word(x)>prevXL then goto _2;
    end;
_2:for x:=prevXR to xr do
   if(scrn(x,y)=fillVal)then begin
    i:=lineFill(x,y,d,xl,xr);
    if word(x)>xr then goto _3;
    end;
_3:end;
 lineFill:=xr;
 end;

procedure fill(x,y:integer);begin
 fillVal:=scrn(x,y);if fillVal<>color then lineFill(x,y,1,x,x);
 end;


{XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX}

procedure putTile(x,y:integer;p:pointer);assembler;asm
 push ds; lds si,p;
 mov ax,vSeg; mov es,ax;
 mov di,x; mov cx,di; shr di,2;
 mov ax,vxBytes; mul y; add di,ax;
 mov ax,$102; and cl,3; shl ah,cl;      {make bit mask}
 mov dx,seqPort; mov bh,tsy;
@DOLINE: mov cl,tsx; xor ch,ch; push ax; push di;    {save starting bit mask}
@LOOP: {mov al,2;} out dx,ax;
 shl ah,1;       {give it some time to respond}
 mov bl,es:[di]; movsb; dec di;
 test ah,$10; jz @SAMEBYTE; mov ah,1; inc di; @SAMEBYTE:
 loop @LOOP;
 pop di; add di,vxBytes; pop ax; {start of next line}
 dec bh; jnz @DOLINE;
 pop ds;
 end;

procedure overTile(x,y:integer;p:pointer);assembler;asm
 push ds; lds si,p;
 mov ax,vSeg; mov es,ax;
 mov di,x; mov cx,di; shr di,2;
 mov ax,vxBytes; mul y; add di,ax;
 mov ax,$102; and cl,3; shl ah,cl;      {make bit mask}
 mov bh,tsy; mov dx,seqPort;
@DOLINE: mov ch,tsx; push ax; push di;    {save starting bit mask}
@LOOP: mov al,2; mov dx,seqPort; out dx,ax; shl ah,1;
 xchg ah,cl; mov al,4; mov dl,gcPort and $FF; out dx,ax; xchg ah,cl; inc cl;
and cl,3;
 lodsb; or al,al; jz @SKIP;
 mov bl,es:[di]; cmp bl,$C0; jae @SKIP; stosb; dec di; @SKIP:
 test ah,$10; jz @SAMEBYTE; mov ah,1; inc di; @SAMEBYTE:
 dec ch; jnz @LOOP;
 pop di; add di,vxBytes; pop ax; {start of next line}
 dec bh; jnz @DOLINE;
 pop ds;
 end;

{won't handle chars wider than 1 byte}
procedure putChar(x,y:integer;p:word);assembler;asm
 mov si,p;  {offset of char in DS}
 mov ax,vSeg; mov es,ax;
 mov di,x; mov cx,di; shr di,2;
 mov ax,vxBytes; mul y; add di,ax;
 mov ax,$0102; and cl,3; shl ah,cl;      {make bit mask}
 mov dx,seqPort; mov cl,tsy; xor ch,ch;
@DOLINE: mov bl,[si]; inc si; push ax; push di;    {save starting bit mask}
@LOOP: mov al,2; out dx,ax; shl ah,1;
 shl bl,1; jnc @SKIP; mov al,color; mov es:[di],al; @SKIP:
 test ah,$10; jz @SAMEBYTE; mov ah,1; inc di; @SAMEBYTE:
 or bl,bl; jnz @LOOP;
 pop di; add di,vxBytes; pop ax; {start of next line}
 loop @DOLINE;
 end;

{XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX}

const
 tableReadIndex=$3C7;
 tableWriteIndex=$3C8;
 tableDataRegister=$3C9;

procedure setColor(color,r,g,b:byte);assembler;asm {set DAC color}
 mov dx,tableWriteIndex; mov al,color; out dx,al; inc dx;
 mov al,r; out dx,al; mov al,g; out dx,al; mov al,b;out dx,al;
 end; {write index now points to next color}

function getColor(color:byte):longint;assembler;asm {get DAC color}
 mov dx,tableReadIndex; mov al,color; out dx,al; add dx,2; cld;
 xor bh,bh; in al,dx; mov bl,al; in al,dx; mov ah,al; in al,dx; mov dx,bx;
 end; {read index now points to next color}

procedure setPalette(color:byte;num:word;var rgb);assembler;asm
 mov cx,num; jcxz @X; mov ax,cx; shl cx,1; add cx,ax; {mul by 3}
 push ds; lds si,rgb; cld;
 mov dx,tableWriteIndex; mov al,color; out dx,al; inc dx;
@L: lodsb; out dx,al; loop @L; pop ds; @X:
 end;

procedure getPalette(color:byte;num:word;var rgb);assembler;asm
 mov cx,num; jcxz @X; mov ax,cx; shl cx,1; add cx,ax; {mul by 3}
 les di,rgb; cld;
 mov dx,tableReadIndex; mov al,color; out dx,al; add dx,2;
@L: in al,dx; stosb; loop @L; @X:
 end;

{XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX}

function vgaPresent:boolean;assembler;asm
 mov ah,$F; int $10; mov oldMode,al;  {save old Gr mode}
 mov ax,$1A00; int $10;    {check for VGA}
 cmp al,$1A; jne @ERR;     {no VGA Bios}
 cmp bl,7; jb @ERR;        {is VGA or better?}
 cmp bl,$FF; jnz @OK;
@ERR: xor al,al; jmp @EXIT;
@OK: mov al,1;
@EXIT:
 end;

const
 crtcRegLen=10;
 crtcRegTable:array[1..crtcRegLen]of word=
  ($0D06,$3E07,$4109,$EA10,$AC11,$DF12,$0014,$E715,$0616,$E317);

procedure graphBegin;var p:array[0..255]of tRGB; i,j,k,l:byte;begin
 asm mov ax,$0013; int $10;end;   {set BIOS mode}
 l:=0;
 for i:=0 to 5 do for j:=0 to 5 do for k:=0 to 5 do
  with p[l] do begin r:=(i*63)div 5;g:=(j*63)div 5;b:=(k*63)div 5;inc(l);end;
 for i:=216 to 255 do with p[i] do begin l:=((i-216)*63)div
39;r:=l;g:=l;b:=l;end;
 setpalette(0,256,p); color:=0;
 asm
  mov dx,seqPort; mov ax,$0604; out dx,ax; {disable chain 4}
  mov ax,$0100; out dx,ax; {synchronous reset asserted}
  dec dx; dec dx; mov al,$E3; out dx,al;   {misc output port at $3C2}
 {use 25mHz dot clock, 480 lines}
  inc dx; inc dx; mov ax,$0300; out dx,ax; {restart sequencer}
  mov dx,crtcPort; mov al,$11; out dx,al;    {select cr11}
  inc dx; in al,dx; and al,$7F; out dx,al; dec dx; {remove write protect from
cr0-cr7}
  mov si,offset crtcRegTable; mov cx,crtcRegLen;
  repz outsw;      {set crtc data}
  mov ax,vxBytes; shr ax,1;  {words per scan line}
  mov ah,al; mov al,$13; out dx,ax; {set CRTC offset reg}
  end;
 clearGraph;
 end;

procedure graphEnd;far;begin
 exitProc:=exitSave;
 asm mov al,oldMode; mov ah,0; int $10; end;
 end;

begin
 crtcPort:=memw[$40:$63]; input1Port:=crtcPort+6;
 if vgaPresent then begin exitSave:=exitProc; exitProc:=@graphEnd; graphBegin; 
end
 else begin writeln(^G+'VGA required.');halt(1); end;
 end.