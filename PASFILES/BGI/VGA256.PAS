Unit VGA256;
Interface
Uses DOS, crt, graph;
Const
  Mode320X200X256 = 0;
  Mode640X400X256 = 1;
  Mode640X480X256 = 2;
  Mode800X600X256 = 3;
  Mode1024X768X256 = 4;
  GraphMode: Integer = Mode800X600X256;
Var
  GraphDriver: Integer;
(*
 *
 *  SVGA.inc
 *
 *)
type DacPalette256 = array[0..255] of array[0..2] of Byte;

(* These are the currently supported modes *)
const
  SVGA320x200x256	= 0;	(* 320x200x256 Standard VGA *)
  SVGA640x400x256	= 1;	(* 640x400x256 Svga *)
  SVGA640x480x256	= 2;	(* 640x480x256 Svga *)
  SVGA800x600x256	= 3;	(* 800x600x256 Svga *)
  SVGA1024x768x256	= 4;	(* 1024x768x256 Svga *)

  TRANS_COPY_PIX	= 8;

Function GetMode: Integer;
Procedure setmode (Mode: Integer);
Procedure grafikein;
Procedure grafikaus;
procedure SetVGAPalette256(PalBuf : DacPalette256);
Implementation
{$F+}
Function GetMode: Integer; Begin GetMode := GraphMode End;
{$F+}
procedure SetMode; begin GraphMode:= Mode end;
Procedure grafikein;
Var
  fname: String;
Begin
  fname := GetEnv ( 'BGIPATH' ) + '\' + 'SVGA256';
  writeln(fname);
  
  GraphDriver := InstallUserDriver ( fname, @GetMode);
  GraphDriver := Detect;
  InitGraph ( GraphDriver, GraphMode, '' );
End;
Procedure grafikaus;
Begin
  CloseGraph;
End;
(* Setvgapalette sets the entire 256 color palette *)
(* PalBuf contains RGB values for all 256 colors   *)
(* R,G,B values range from 0 to 63	           *)
procedure SetVGAPalette256(PalBuf : DacPalette256);
var
  Reg : Registers;

begin
  reg.ax := $1012;
  reg.bx := 0;
  reg.cx := 256;
  reg.es := Seg(PalBuf);
  reg.dx := Ofs(PalBuf);
  intr($10,reg);
end;
Begin
End.