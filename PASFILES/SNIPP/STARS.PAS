{Ä Fido Pascal Conference ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ PASCAL Ä
Msg  : 423 of 533
From : Daniel Schlenzig                    2:241/5400.10        23 Apr 93  14:42
To   : Stephen Cheok
Subj : STARFIELD
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Hi Stephen,

 >         Hmm.. does anyone have an example of a starfield routine in
 > Turbo Pascal.. or can be used with Turbo Pascal.. using the
 > ASSEMBLER..  I want to try to make one.. but I need some help with
 > it.  Thanx...
Here is one: }

program stars;

const maxstars = 50;

var star  : array[0..maxstars] of word;
    speed : array[0..maxstars] of byte;
    i     : word;

procedure create;
begin
  for i := 0 to maxstars do begin
    star[i] := random(320) + random(200) * 320;
    speed[i] := random(3) + 1;
    if mem[$a000:star[i]] = 0 then mem[$a000:star[i]] := 100;
  end;
end;

Procedure moveit; assembler;
asm
     xor   bp,bp
     mov   ax,0a000h
     mov   es,ax
     lea   bx,star
     lea   si,speed
     mov   cx,320

@l1: mov   di,[bx]
     mov   al,es:[di]
     cmp   al,100
     jne   @j1
     xor   al,al
     stosb
@j1: mov   al,[si]
     xor   ah,ah
     add   [bx],ax
     mov   ax,bx
     xor   dx,dx
     div   cx
     mul   cx
     mov   dx,bx
     sub   dx,ax
     cmp   dx,319
     jle   @j3
     sub   [bx],cx
@j3: mov   di,[bx]
     mov   al,es:[di]
     or    al,al
     jnz   @j2
     mov   al,100
     stosb
@j2: add   bx,2
     inc   si
     inc   bp
     cmp   bp,maxstars
     jle   @l1
end;

begin
  asm
    mov   ax,13h
    int   10h
    call  create

@l1:
    mov   dx,3dah
@r1:
    in    al,dx
    test  al,8
    je    @r1

    call moveit
    in   al,60h
    cmp  al,1
    jne  @l1;
  end;
end.

Well, it can be done faster, but it' s enough to learn from :-)
cu Daniel

--- GEcho 1.00
 * Origin: Don't panic! (2:241/5400.10)

