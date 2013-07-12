{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 455 of 535
From : Gregory P. Smith                    1:104/332.11         21 Apr 93  14:59
To   : Joe Maffuccio                       1:321/212.0
Subj : Generating AVT/0 & ANSI codes
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
On Apr 19 23:40, Joe Maffuccio of 1:321/212 wrote:

 JM> I just recieved your PAvatar 1.50 package in the mail. Um, haha, I have a
 JM> question. How do I use it? Hhaa. Ok, lets say in a door. Something
 JM> simple. Say this. I have a door, the function that sends strings out to
 JM> the user is called Procedure Print(var Message:string);. Let's say I
 JM> wanted to send that message in the color light blue to the user. How
 JM> would I go about doing that with PAvatar.  I also want to add something
 JM> that will allow me to just call a procedure with a number or two, and
 JM> have PAvatar change color both locally and over the modem.

Here's a unit I just pieced together from some old code I wrote a couple years
ago.  It'll generate AVT/0+ and ANSI codes:

========== }

Unit TermCode;  {$S-,D-,L-,R-,F-,O-}
{  Generate ANSI and AVT/0+ codes for color and cursor ctrl }
{  Public Domain -- by Gregory P. Smith  }  { untested }

interface

type
  Str12 = string[12];  { Maximum size for most ANSI strings }
  Str3  = string[3];
  grTermType = (TTY, ANSI, AVT0); { TTY, ANSI or Avatar/0+ }

var
  grTerm : grTermType;
  grColor : Byte;  { Last color set }

{ Non Specific functions }
Function grRepChar(c:char;n:byte): string;   { Repeat Chars }
Function grSetPos(x,y:byte): Str12;   { Set Cursor Position }
Function grCLS: Str12;          { Clear Screen + reset Attr }
Function grDelEOL: Str12;                   { Delete to EOL }

Function grSetAttr(a:byte): Str12;      { Change writing color }
Function grSetColor(fg,bg:byte): Str12; { Change color fg & bg }

{ AVT/0+ Specific functions }
Function AVTRepPat(pat:string;n:byte): string; { Repeat Pattern (AVT/0+) }
Function AVTScrollUp(n,x1,y1,x2,y2:byte): Str12;
Function AVTScrollDown(n,x1,y1,x2,y2:byte): Str12;
Function AVTClearArea(a,l,c:byte): Str12;
Function AVTInitArea(ch:char;a,l,c:byte): Str12;

IMPLEMENTATION

const
  hdr = #27'['; { ansi header }

{ Misc support functions }

function bts(x:byte): str3; { byte to string }
var
  z: str3;
begin
  Str(x,z);
  bts := z;
end;

function Repl(n:byte; c:char): string;
var
  z : string;
begin
  fillchar(z[1],n,c);
  z[0] := chr(n);
  repl := z;
end;

{ Cursor Control functions }

function grRepChar(c:char;n:byte): string;
begin
  if grTerm = AVT0 then
    grRepChar := ^Y+c+chr(n)
  else
    grRepChar := repl(n,c);
end; { repcahr }

function grSetPos(x,y:byte): Str12;
begin
  case grTerm of
    ANSI : if (x = 1) and (y > 1) then
             grSetPos := hdr+bts(y)+'H'   { x defualts to 1 }
           else
             grSetPos := hdr+bts(y)+';'+bts(x)+'H';
    AVT0 : grSetPos := ^V+^H+chr(y)+chr(x);
    TTY  : grSetPos := '';
  end; { case }
end;


function grCLS: Str12;
begin
  case grTerm of
    ANSI : grCLS := hdr+'2J';
    TTY,
    AVT0 : grCLS := ^L;
  end;
  if grTerm = AVT0 then GrColor := 3; { reset the color }
end; { cls }

function grDelEOL: Str12; { clear rest of line }
begin
  case grTerm of
    ANSI : grDelEOL := hdr+'K';
    AVT0 : grDelEOL := ^V^G;
    TTY  : grDelEOL := '';
  end;
end;

{ Color functions }

function grSetAttr(a:byte): Str12;
const
  ANS_Colors : Array[0..7] of char = ('0','4','2','6','1','5','3','7');
var
  tmp : Str12;
begin
  tmp := '';
  case grTerm of
    ANSI : begin
      tmp := hdr;
      if (a and $08)=8 then tmp := tmp+'1' else tmp := tmp+'0'; { bright }
      if (a and $80)=$80 then tmp := tmp+';5';  { blink }
      tmp := tmp+';3'+ANS_Colors[a and $07]; { foreground }
      tmp := tmp+';4'+ANS_Colors[(a shr 4) and $07]; { background }
      grSetAttr := tmp+'m'; { complete ANSI code }
    end;
    AVT0 : begin
      tmp := ^V+^A+chr(a AND $7f);
      if a > 127  then tmp := tmp+^V+^B; { Blink }
      grSetAttr := tmp;
    end;
    TTY  : grSetAttr := '';
  end; { case }
  GrColor := a; { Current Attribute }
end; { setattr }

function grSetColor(fg,bg:byte): Str12;
begin
  grSetColor := grSetAttr((bg shl 4) OR (fg and $0f));
end; { SetColor }

{ AVATAR Specific functions: }

function AVTRepPat(pat:string;n:byte): string; { Repeat Pattern (AVT/0+) }
begin
  AVTRepPat := ^V+^Y+pat[0]+pat+chr(n); { Repeat pat n times }
end;

function AVTScrollUp(n,x1,y1,x2,y2:byte): Str12;
begin
  AVTScrollUp := ^V+^J+chr(n)+chr(y1)+chr(x1)+chr(y2)+chr(x2);
end; { AVTScrollUp }

function AVTScrollDown(n,x1,y1,x2,y2:byte): Str12;
begin
  AVTScrollDown := ^V+^K+chr(n)+chr(y1)+chr(x1)+chr(y2)+chr(x2);
end; { AVTScrollDown }

function AVTClearArea(a,l,c:byte): Str12;
var
  b:byte;
  s:Str12;
begin       { Clear lines,columns from cursor pos with Attr }
  b := a and $7f;
  s := ^V+^L+chr(b)+chr(l)+chr(c);
  if a > 127 then Insert(^V+^B,s,1); { blink on }
  AVTClearArea := s;
  GrColor := a;
end; { AVTClearArea }

function AVTInitArea(ch:char;a,l,c:byte): Str12;
var
  b:byte;
  s:Str12;
begin
  b := a AND $7f;
  s := ^V+^M+chr(b)+ch+chr(l)+chr(c);
  if a > 127 then Insert(^V+^B,s,1);
  AvtInitArea := s;
  GrColor := a;
end; { AVTInitArea }

{ Initalization code }
BEGIN
  GrTerm  := AVT0;  { Default to Avatar }
  GrColor := 3;     { Cyan is the AVT/0+ defualt }
END.

=============

set GrTerm to whatever terminal codes you want to create; then you can use the 
common routines to generate ANSI or Avatar codes.  Here's a Print procedure
that you were mentioning:

Procedure Print(var msg:string);
var
  idx : byte
begin
  if length(msg) > 0 then
    for idx := 1 to length(msg) do begin
      Parse_AVT1(msg[idx]);
      SendOutComPortThingy(msg[idx]);
    end; { for }
end;

You could modify this so that it pays attention to the TextAttr variable of the
Crt unit if you wish so that it compares TextAttr to GrColor and adds a
SetAttr(TextAttr) command in before it sends msg.

Hope that helps,

 .. Greg