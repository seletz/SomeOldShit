Unit SVGA;

Interface
Uses crt, DOS, graph;

Type DacPalette256 = Array [0..255] Of Array [0..2] Of Byte;

  (* These are the currently supported modes *)
Const
  SVGA320X200X256	 = 0; 	 (* 320x200x256 Standard VGA *)
  SVGA640X400X256	 = 1; 	 (* 640x400x256 Svga *)
  SVGA640X480X256	 = 2; 	 (* 640x480x256 Svga *)
  SVGA800X600X256	 = 3; 	 (* 800x600x256 Svga *)
  SVGA1024X768X256	 = 4; 	 (* 1024x768x256 Svga *)

  TRANS_COPY_PIX	 = 8;
Var
	svga_colors: DacPalette256;
  SVGA_Mode,MaxX, MaxY, MaxColor: Integer;
  
Procedure SetVGAPalette256 (PalBuf : DacPalette256);

Procedure Initialize;

Implementation

(* Setvgapalette sets the entire 256 color palette *)
(* PalBuf contains RGB values for all 256 colors   *)
(* R,G,B values range from 0 to 63	           *)
Procedure SetVGAPalette256 (PalBuf : DacPalette256);
Var
  Reg : Registers;
Begin
  reg. AX := $1012;
  reg. BX := 0;
  reg. CX := 256;
  reg. ES := Seg (PalBuf);
  reg. DX := Ofs (PalBuf);
  Intr ($10, reg);
End;

{$F+}
function DetectVGA256 : integer;
{ Detects VGA or MCGA video cards }
var
  DetectedDriver : integer;
  SuggestedMode  : integer;
begin
  DetectGraph(DetectedDriver, SuggestedMode);
  if svga_mode =-1 then
  if (DetectedDriver = VGA) or (DetectedDriver = MCGA) then
  begin
    Writeln('Which video mode would you like to use?');
    Writeln('  0) 320x200x256');
    Writeln('  1) 640x400x256');
    Writeln('  2) 640x480x256');
    Writeln('  3) 800x600x256');
    Writeln('  4) 1024x768x256');
    Write('> ');
    Readln(SuggestedMode);
    DetectVGA256 := SuggestedMode;
  end
  else
    DetectVGA256 := grError { Couldn't detect hardware }
  else
  	Detectvga256 := SVGA_Mode;
end; { DetectVGA256 }
{$F-}
Var
  AutoDetectPointer : pointer;

Procedure Initialize;
{ Initialize graphics and report any errors that may occur }
Var
  InGraphicsMode : Boolean; { Flags initialization of graphics mode }
  PathToDriver   : String;  { Stores the DOS path to *.BGI & *.CHR }
  graphdriver,graphmode,errorcode:integer;
Begin
  { when using Crt and graphics, turn off Crt's memory-mapped writes
  DirectVideo := False; }
  PathToDriver := 'z:\tp70\bgi';
  Repeat
    AutoDetectPointer := @DetectVGA256;
    GraphDriver := InstallUserDriver ('Svga256', AutoDetectPointer);
    GraphDriver := Detect;
    InitGraph (GraphDriver, GraphMode, PathToDriver);
    ErrorCode := GraphResult;             { preserve error return }
    If ErrorCode <> grOK Then             { error? }
    Begin
      WriteLn ('Graphics error: ', GraphErrorMsg (ErrorCode) );
      If ErrorCode = grFileNotFound Then  { Can't find driver file }
      Begin
        WriteLn ('Enter full path to BGI driver or type <Ctrl-Break> to quit:');
        ReadLn (PathToDriver);
        WriteLn;
      End
      Else
        Halt (1);                          { Some other error: terminate }
    End;
  Until ErrorCode = grOK;
  Randomize;                { init random number generator }
  MaxColor := GetMaxColor;  { Get the maximum allowable drawing color }
  MaxX := GetMaxX;          { Get screen resolution values }
  MaxY := GetMaxY;
End; { Initialize }


Var
  svga_oldExit: pointer;

Procedure svga_Exit; Far;
Begin
  ExitProc := svga_oldExit;
  CloseGraph;
End;
Begin
  svga_oldExit := ExitProc;
  ExitProc := @svga_exit;

  svga_mode:=-1;
  Maxx:=-1; maxy:=-1; maxcolor:=-1;
End.