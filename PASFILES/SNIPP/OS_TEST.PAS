{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 224 of 231
From : Gregory P. Smith                    1:104/332.11         12 Apr 93  17:21
To   : Tim Strike                          1:259/423.0
Subj : Detect OS/2 and WINDOWS sessions
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
On Apr 07 07:08, Tim Strike of 1:259/423 wrote:

 TS> Is there any way to detect OS/2 (in a DOS box) sessions and Windows
 TS> Sessions? I'd like to throw in support for these multitaskers so I can
 TS> run an idlekey program.

Actual code is always the best example for me..  Look at this unit (and use it,
I think you'll like it).  Check with someone else if you want to specifically
detect winslows.  This unit will, however, give up time to any multitasker.

===================== }

(* Public Domain unit by Gregory P. Smith, No Rights Reserved *)
(* ...  This also means no guarantees  ... *)
Unit OS_Test; { DESQview, OS/2, & 386 v86 machine interfaces }
{$X+,S-,R-,F-,O-,D-,G-} { extended syntax, nothing else }
interface

const
  In_DV  : boolean = False; { are we in DESQview? }
  In_VM  : boolean = False; { are we in a 386+ virtual machine? }
  In_OS2 : boolean = False; { are we in OS/2? }

function  OS2_GetVersion: word; { Get OS/2 version # }
Function  DV_GetVersion: word; { update In_DV and get version # }
Function  DV_Get_Video_Buffer(vseg:word): word; { get the alt video buffer }
Procedure DV_Pause; { give up time slice }
Procedure MT_Pause; Inline($cd/$28); { give up time in most multitaskers }
Procedure KillTime; { Release time in any situation }
Procedure DV_Begin_Critical; { don't slice away }
  Inline($b8/$1b/$10/$cd/$15);
Procedure DV_End_Critical; { allow slicing again }
  Inline($b8/$1c/$10/$cd/$15);
Procedure DV_Sound(freq,dur:integer); { Create a sound in the Bkg }

implementation

function OS2_GetVersion: word; assembler;
asm
  MOV    AH, 30h  { DOS Get Version Call }
  INT    21h      { AL = major version * 10, AH = minor version }
  MOV    BH, AH   { save minor version }
  XOR    AH, AH
  MOV    CL, 10
  DIV    CL       { divide by 10 to get the major version }
  MOV    AH, BH   { restore minor version }
  XCHG   AH, AL   { AH = major, AL = minor }
end;

Function DV_GetVersion: word; assembler;
asm
  MOV    CX,'DE'     { CX+DX to 'DESQ' (invalid date) }
  MOV    DX,'SQ'
  MOV    AX,02B01H   { Dos' set date funct. }
  INT    21H         { call dos }
  CMP    AL,0FFH     { Was it invalid? }
  JE     @No_dv      { yep, no dv }
  MOV    AX,BX       { AH=major AL=minor }
  MOV    In_DV,1     { Set In_DV flag }
  JMP    @DvGv_x     { other routines }
@No_dv:
  XOR    AX,AX       { Return 0 or no DV }
@DvGv_x:
end; { DV_GetVersion }

Function DV_Get_Video_Buffer(vseg:word): word; assembler;
asm                      { Modified by Scott Samet April 1992 }
  CALL   DV_GetVersion   { Returns AX=0 if not in DV }
  MOV    ES,vseg         { Put current segment into ES }
  TEST   AX,AX           { In DV? }
  JZ     @DVGVB_X        { Jump if not }
  MOV    AH,0FEH         { DV's get video buffer function }
  INT    10H             { Returns ES:DI of alt buffer }
@DVGVB_X:
  MOV    AX,ES           { Return video buffer }
end; { DV_Get_Video_Buffer }

Procedure DV_Pause;
begin
  if In_DV then
   asm
     MOV AX, 1000h    { pause function }
     INT 15h
   end;
end; { DV_Pause }

Procedure KillTime;
begin
  if In_VM then
   asm
     MOV AX, 1680h    { give up VM time slice }
     INT 2Fh
   end
  else if In_DV then
   asm
     MOV AX, 1000h    { DV pause call }
     INT 15h
   end
  else MT_Pause;      { DOS Idle call }
end;

(* Procedure DV_Begin_Critical; assembler;
asm
  MOV AX,$101B       { DV begin critical function }
  INT 15h
end; { DV_Begin_Critical }

Procedure DV_End_Critical; assembler;
asm
  MOV AX,$101C       { DV end critical function }
  INT 15h
end; { DV_End_Critical }  *)

Procedure DV_Sound(freq,dur:integer); assembler; { sound a tone }
asm
  MOV   AX,1019H
  MOV   BX,freq  { frequency above 20 Hz }
  MOV   CX,dur   { duration in clock ticks }
  INT   15H
end;

{ ** -- initalization -- ** }

BEGIN
  DV_GetVersion; { discard answer.  Just update In_DV }
  asm
    MOV AX, 1680h
    INT 2Fh          { Gives up time slice in most 386+ virtual machines }
    NOT AL           { AL = 00h if supported, remains 80h if not }
    MOV CL, 7
    SHR AL, CL       { move bit 7 to bit 0 for a boolean }
    MOV In_VM, AL    { update the flag }
  end;
  In_OS2 := (OS2_GetVersion >= $0100); { version 1.0 or greater }
END.

 .. Greg

--- msgedsq/2 2.2b
 * Origin: Greg's Pascal with OS/2 & pickles point (1:104/332.11)

