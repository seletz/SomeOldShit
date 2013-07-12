Unit MCGALib;

interface

Procedure SetGraphMode (Num:Byte);
Procedure SetPixel     (X,Y:Integer;Color:Byte);

implementation

var
  ScreenWide  :  Integer;
  ScreenAddr  :  Word;

Procedure SetGraphMode (Num:Byte);
begin
  asm
    mov al,Num
    mov ah,0
    int 10h
    end;
  Case Num of
    $13 : ScreenWide := 320;
    end;
  ScreenAddr := $A000;
end;
{
Function PixelAddr (X,Y:Word) : Word;
begin
  PixelAddr := Y * ScreenWide + X;
end;

Procedure SetPixel (X,Y:Integer;Color:Byte);
var
  Ofs    :  Word;
begin
  Ofs := PixelAddr (X,Y);
  Mem [ScreenAddr:Ofs] := Color;
end;
}

Procedure SetPixel (X,Y:Integer;Color:Byte);
begin
  asm
    push ds
    mov  ax,ScreenAddr
    mov  ds,ax

    mov  ax,Y
    mov  bx,320
    mul  bx
    mov  bx,X
    add  bx,ax

    mov  al,Color
    mov  byte ptr ds:[bx],al
    pop  ds
    end;
end;

Begin
End.
