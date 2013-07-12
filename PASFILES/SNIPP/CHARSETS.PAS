� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 627 of 702                                                               
From : Salim Samaha                        1:167/110.0          20 Apr 93  16:16 
To   : Bernie Pallek                       1:247/128.0                           
Subj : ASM to redefine charset                                                
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Alright, try to solve this problem. The procedure I made in asm works as long
as i don't pass the parameter data as an argument, that is as long as data is a
const : array[1..16] of byte = (......);

Here is the procedure :

Procedure SetAsciiChar(Charnum : Word; Var Data); Assembler;
ASM
   mov ah,11h
   mov al,10h
   mov bh,10h
   mov bl,0
   mov cx,1      {set 1 character only}
   mov dx,charnum     {what charnum to modify }
   mov bp,seg data   {seg of the char}
   mov es,bp
   mov bp,offset data  {ofs of the char}
   int 10h
End;

Hope you can transform it so that Data can be passed as a parameter to the
procedure. I'm new to this Pascal-ASM stuff. I you come up with anything, let
me know.


By the way, I'll tell you how to make textmode have 80chars x 43 chars in the
next few days, I know of a way, give me time to try it.

                                SAL

--- Maximus/2 2.01wb
 * Origin: Programmer's Quest BBS (1:167/110)

