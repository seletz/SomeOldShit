{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 116 of 150                                                               
From : Sean Palmer                         1:104/123.0          08 Apr 93  15:36 
To   : All                                                                       
Subj : G:Keys unit                                                            
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
{by Sean Palmer, 1993}
{Turbo Pascal 6.0}
{released to the public domain}

unit keys;
interface

const
 kEsc=1;
 k1=2; k2=3; k3=4; k4=5; k5=6; k6=7; k7=8; k8=9; k9=10; k0=11;
 kMinus=12; kEqual=13; kBack=14;
 kTab=15;
 kQ=16; kW=17; kE=18; kR=19; kT=20; kY=21; kU=22; kI=23; kO=24; kP=25;
 kLfBracket=26; kRtBracket=27;
 kEnter=28;
 kA=30; kS=31; kD=32; kF=33; kG=34; kH=35; kJ=36; kK=37; kL=38;
 kColon=39; kQuote=40; kBackQuote=41;
 kBackSlash=43;
 kZ=44; kX=45; kC=46; kV=47; kB=48; kN=49; kM=50;
 kComma=51; kPeriod=52; kSlash=53;
 kSpace=57;
 kF1=59; kF2=60; kF3=61; kF4=62; kF5=63; kF6=64; kF7=65; kF8=66; kF9=67;
 kF10=68;  kHome=71; kUp=72; kPgUp=73; kPadMinus=74;
 kLf=75; kPad5=76; kRt=77; kPadPlus=78;
 kEnd=79; kDn=80; kPgDn=81;
 kIns=82; kDel=83;

 kShift=3;
 kCtrl=4;
 kAlt=8;
 kScroll=16;
 kNum=32;
 kCaps=64;

var
 shiftStatus:byte absolute $40:$17;

function readKey:char;Inline(
  $B4/$07/               { mov ah,7}
  $CD/$21);              { int $21}
   
function keyPressed:boolean;Inline(
  $B4/$0B/               { mov ah,$B}
  $CD/$21/               { int $21}
  $24/$FE);              { and al,$FE}
   
function scanKey:byte;Inline(
  $31/$C0/               { xor ax,ax}
  $CD/$16/               { int $16}
  $88/$E0);              { mov al,ah}
   
function shiftKey:boolean;Inline(
  $B8/$40/$00/           { mov ax,$40}
  $8E/$C0/               { mov es,ax}
  $26/$A0/$17/$00/       { es: mov al,[$17]}
  $24/kShift);           { and al,kShift}

function ctrlKey:boolean;Inline(
  $B8/$40/$00/           { mov ax,$40}
  $8E/$C0/               { mov es,ax}
  $26/$A0/$17/$00/       { es: mov al,[$17]}
  $24/kCtrl);            { and al,kCtrl}
   
function altKey:boolean;Inline(
  $B8/$40/$00/           { mov ax,$40}
  $8E/$C0/               { mov es,ax}
  $26/$A0/$17/$00/       { es: mov al,[$17]}
  $24/kAlt);             { and al,kAlt}

implementation

end.
