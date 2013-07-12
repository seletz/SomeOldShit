{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 348 of 353
From : Sean Palmer                         1:104/123.0          13 Apr 93  15:08
To   : Dane Walther
Subj : Setting Bits
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
 DW> What if I want to just access a bit?  Say I have a byte, to store
 DW> various access levels (if it does/doesn't have this, that, or the
 DW> other).  How can I

 DW> 1)  Access, say, bit 4?
 DW> 2)  Give, say, bit 4, a value of 1?

 DW> I have a simple routine that does "GetBit:= Value SHR 1;" to return
 DW> a value, but how can I *SET* a value?  And is the above a good
 DW> method? I only have TP5.5, so I can't do the ASM keyword (yet..).

OK. No feelthy 6.0 inline assembling....

You COULD use TP sets to do it...        }

type
 tByte=set of 0..7;
var
 b:byte;

to get:
 write('Bit 0 is ',boolean(0 in tByte(b)));

to set:
 tByte(b):=tByte(b)+[1,3,4]-[0,2];


{these next routines should be fairly fast...}

type
 bitNum=0..7;
 bit=0..1;

function getBit(b:byte;n:bitNum):bit;begin
 getBit:=bit(odd(b shr n));
 end;

function setBit(b:byte;n:bitNum):byte;begin
 setBit:=b or (1 shl n);
 end;

function clrBit(b:byte;n:bitNum):byte;begin
 clrBit:=b and hi($FEFF shl n);
 end;

OR.....using INLINE() code  (the fastest)

{These are untested but I'm getting fairly good at assembling by hand...8) }

function getBit(b:byte;n:bitNum):bit;inline(
 $59/      {pop cx}
 $58/      {pop ax}
 $D2/$E8/  {shr al,cl}
 $24/$01); {and al,1}

function setBit(b:byte;n:bitNum):byte;assembler;
($59/      {pop cx}
 $58/      {pop ax}
 $B3/$01/  {mov bl,1}
 $D2/$E3/  {shl bl,cl}
 $0A/$C3); {or al,bl}
 end;

function clrBit(b:byte;n:bitNum):byte;assembler;
($59/      {pop cx}
 $58/      {pop ax}
 $B3/$FE/  {mov bl,$FE}
 $D2/$C3/  {rol bl,cl}
 $22/$C3); {or al,bl}
 end;