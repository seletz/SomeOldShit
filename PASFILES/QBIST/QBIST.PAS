Program qbist;
{$define DPMI}
Uses crt, tgaunit, vesa;
Const
  breite = 150;
  hoehe = 150;
  rand_x = 10;
  rand_y = 10;

  num_transformations = 36;
  num_registers = 6;
  total_transformations = 9;
  
  tname: Array [1..total_transformations] Of String =
  ( 'projektion', 'rotate', 'rotate2', 'shift', 'shiftback',
  'multiply', 'sine', 'conditional', 'complement' );
Type
  color_p = ^Color;
  Color = Record r, g, b: Real End;
  transformation = 
Procedure ( source, control, dest: color_p);
  tlistentry = 	Record
                  tr: transformation;
                  source, control, dest: Integer;
                End;
  tlist = Array [1..num_transformations] Of tlistentry;
Var
  tfile: tgafile;
  reg: Array [1..num_registers ] Of Color;
  transformations: Array [1..total_transformations] Of transformation;
  transformlist: tlist;
  
Function cut (Var r: Real): Real;
Begin
  If r > 1 Then r := 1;
  If r < 0 Then r := 0;
  cut := r;
End;
{
---------------------------------------------------------------------------
transformationen
---------------------------------------------------------------------------
}
Procedure projektion ( source, control, dest: color_p);
Var
  scpr: Real;
Begin
  scpr := source^. r * control^. r + source^. g * control^. g + source^. b * control^. b;
  dest^. r := scpr * dest^. r;
  dest^. g := scpr * dest^. g;
  dest^. b := scpr * dest^. b;
End;
Procedure rotate ( source, control, dest: color_p);
Begin
  dest^. r := source^. g;
  dest^. g := source^. b;
  dest^. b := source^. r;
End;
Procedure rotate2 ( source, control, dest: color_p);
Begin
  dest^. r := source^. b;
  dest^. g := source^. r;
  dest^. b := source^. g;
End;
Procedure shift ( source, control, dest: color_p);
Begin
  dest^. r := source^. g + control^. r;
  dest^. g := source^. b + control^. g;
  dest^. b := source^. r + control^. b;
  If dest^. r > 1 Then dest^. r := dest^. r - 1;
  If dest^. g > 1 Then dest^. g := dest^. g - 1;
  If dest^. b > 1 Then dest^. b := dest^. b - 1;
End;
Procedure shiftback ( source, control, dest: color_p);
Begin
  dest^. r := source^. g - control^. r;
  dest^. g := source^. b - control^. g;
  dest^. b := source^. r - control^. b;
  If dest^. r < 0 Then dest^. r := dest^. r + 1;
  If dest^. g < 0 Then dest^. g := dest^. g + 1;
  If dest^. b < 0 Then dest^. b := dest^. b + 1;
End;
Procedure multiply ( source, control, dest: color_p);
Begin
  dest^. r := source^. r * control^. r;
  dest^. g := source^. g * control^. g;
  dest^. b := source^. b * control^. b;
End;
Procedure sine ( source, control, dest: color_p);
Begin
  dest^. r := 0.5 + 0.5 * Sin (20 * source^. r * control^. r);
  dest^. g := 0.5 + 0.5 * Sin (20 * source^. g * control^. g);
  dest^. b := 0.5 + 0.5 * Sin (20 * source^. b * control^. b);
End;
Procedure conditional ( source, control, dest: color_p);
Begin
  If (control^. r + control^. g + control^. b) > 0.5 Then
  Begin
    dest^. r := source^. g;
    dest^. g := source^. b;
    dest^. b := source^. r;
  End
  Else
  Begin
    dest^. r := control^. g;
    dest^. g := control^. b;
    dest^. b := control^. r;
  End
End;
Procedure complement ( source, control, dest: color_p);
Begin
  dest^. r := 1 - source^. g;
  dest^. g := 1 - source^. b;
  dest^. b := 1 - source^. r;
End;

{-------------------------------------------------------------------------
init
-------------------------------------------------------------------------
}
Procedure init;
Begin
  transformations [1] := projektion;
  transformations [2] := rotate;
  transformations [3] := rotate2;
  transformations [4] := shift;
  transformations [5] := shiftback;
  transformations [6] := multiply;
  transformations [7] := sine;
  transformations [8] := conditional;
  transformations [9] := complement;
End;
{
-------------------------------------------------------------------------
gen_random
-------------------------------------------------------------------------
}
Procedure gen_random;
Var
  i: Integer;
Begin
  For i := 1 To num_transformations Do
  Begin
    With transformlist [i] Do
    Begin
      tr := transformations [ 1 + Random ( total_transformations ) ];
      source := 1 + Random ( num_registers );
      control := 1 + Random ( num_registers );
      dest := 1 + Random ( num_registers );
    End;
  End;
End;
{
-------------------------------------------------------------------------
fill_regs
-------------------------------------------------------------------------
}
Procedure fill_regs ( X, Y: Integer);
Var
  i: Integer;
Begin
  For i := 1 To num_registers Do
  Begin
    reg [i].r := X / breite;
    reg [i].g := Y / hoehe;
    reg [i].b := i / num_registers;
  End;
End;
{
-------------------------------------------------------------------------
draw
-------------------------------------------------------------------------
}
Procedure draw (offx, offy: Word);
Var
  X, Y, i: Integer;
  r, g, b: Byte;
Begin
  For Y := 0 To hoehe - 1 Do
  Begin
    For X := 0 To breite - 1 Do
    Begin
      fill_regs (X, Y);
      For i := 1 To num_transformations Do
      Begin
        With transformlist [i] Do
        Begin
          tr ( @reg [source], @reg [control], @reg [dest] );
        End;
      End;
      
      r := Round ( cut (reg [1].r) * $ff );
      g := Round ( cut (reg [1].g) * $ff );
      b := Round ( cut (reg [1].b) * $ff );
      
      setpix ( offx + X, offy + Y, RGB (r, g, b) );
      
      tfile. Output ( X, Y, r, g, b);
      
    End;
  End;
End;
{
-------------------------------------------------------------------------
draw_pics
-------------------------------------------------------------------------
}
Procedure draw_pics ( durchlauf: Integer);
Var
  num_pics, nx, ny, n: Integer;
  offx, offy: Word;
  sn, sd, fn, fn2: String;
  datafile: File Of tlist;
Begin
  nx := vesarec. width Div (breite + rand_x );
  ny := vesarec. height Div (hoehe + rand_y );
  num_pics := nx * ny;
  
  For n := 1 To num_pics Do
  Begin
    Str (n, sn);
    Str (durchlauf, sd);
    fn := 'c:\temp\qb' + sn + '-' + sd + '.tga';
    fn2 := 'c:\temp\qb' + sn + '-' + sd + '.qbi';
    
    tfile. init (fn , breite, hoehe, mode_quiet );
    tfile. writeheader;
    
    offx := ( (n - 1) Mod ( nx ) ) * ( breite + rand_x);
    offy := ( (n - 1) Div nx ) * (hoehe + rand_y);
    gen_random;
    draw ( offx, offy);
    
    tfile. done;
    
    Assign ( datafile, fn2);
    Rewrite ( datafile );
    Write (datafile, transformlist);
    Close (datafile);
  End;
  
End;
{
-------------------------------------------------------------------------
------|   MAIN
-------------------------------------------------------------------------
}
Var
  stop: Boolean;
  i: Integer;
  X: Char;
Begin
  Randomize;
  ReadLn;
  init;
  stop := False;
  i := 0;
  Repeat
    TextMode (c80 + Font8X8);
    setmode ( mode_800X600X64k);
    draw_pics (i);
    Repeat Until KeyPressed;
    Read (X);
    If X = 'x' Then stop := True;
    Inc (i);
  Until stop;
  TextMode (c80 + Font8X8);
End.