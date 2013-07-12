Program qbist;
{$define DPMI}
Uses crt, tgaunit, vesa;
Const
  out_path : String = 'c:\temp';
  { 3x3 }
  rows = 3;
  cols = 3;
  
  qbist_graphmode = mode_640X480X64k;
  
  qbist_random = 0;
  qbist_hold1 = 1;
  qbist_hold2 = 2;
  qbist_hold3 = 3;
  
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
  qbist_modus: Integer;
  breite: Word;
  hoehe: Word;
  rand_x: Word;
  rand_y: Word;
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
  
  qbist_modus := qbist_random;

  setmode ( qbist_graphmode);
  
  rand_x := 10;
  breite := (vesarec. width Div rows) - rand_x;
  rand_y := 10;
  hoehe := (vesarec. height Div cols) - rand_y;
  
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
gen_grob
-------------------------------------------------------------------------
}
Procedure gen_grob;
Var
  i: Integer;
Begin
  For i := 1 To num_transformations Do
  Begin
    If (i Mod 3) = 0 Then
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
gen_mittel
-------------------------------------------------------------------------
}
Procedure gen_mittel;
Var
  i: Integer;
Begin
  For i := 1 To num_transformations Do
  Begin
    With transformlist [i] Do
    Begin
      source := 1 + Random ( num_registers );
      control := 1 + Random ( num_registers );
      dest := 1 + Random ( num_registers );
    End;
  End;
End;
{
-------------------------------------------------------------------------
gen_fein
-------------------------------------------------------------------------
}
Procedure gen_fein;
Var
  i: Integer;
Begin
  For i := 1 To num_transformations Do
  Begin
    If (i Mod 2) = 0 Then
      With transformlist [i] Do
      Begin
        source := 1 + Random ( num_registers );
        control := 1 + Random ( num_registers );
        dest := 1 + Random ( num_registers );
      End;
  End;
End;
{
-------------------------------------------------------------------------
load_transformlist
-------------------------------------------------------------------------
}
Function load_transformlist ( fn: String): Boolean;
Var
  return: Boolean;
  datafile: File Of tlist;
Begin
  {$I-}
  Assign ( datafile, fn + '.qbi');
  Reset ( datafile );
  return := IOResult = 0;
  If return Then
    Read (datafile, transformlist);
  Close (datafile);
  {$I+}
  load_transformlist := return;
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
Procedure draw (offx, offy: Word; fn: String);
Var
  X, Y, i: Integer;
  r, g, b: Byte;
  tfile: tgafile;
  datafile : File Of tlist;
Begin
  tfile. init (fn + '.tga' , breite, hoehe, mode_quiet );
  tfile. writeheader;
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
  wrtext( offx+1,offy+1,RGB($ff,$ff,$ff), fn);
  tfile. done;
  
  Assign ( datafile, fn + '.qbi');
  Rewrite ( datafile );
  Write (datafile, transformlist);
  Close (datafile);
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
  sn, sd, fn: String;
  datafile: File Of tlist;
Begin
  num_pics := rows * cols;

  For n := 1 To num_pics Do
  Begin
    Str (n, sn);
    Str (durchlauf, sd);
    fn := out_path + '\qb' + sn + '-' + sd;

    Case qbist_modus Of
      qbist_random: gen_random;
      qbist_hold1: gen_grob;
      qbist_hold2: gen_mittel;
      qbist_hold2: gen_fein;
    End;

    offx := ( (n - 1) Mod ( rows ) ) * ( breite + rand_x);
    offy := ( (n - 1) Div rows ) * (hoehe + rand_y);
    
    draw ( offx, offy, fn);
    
  End;
  
End;
{
-------------------------------------------------------------------------
------|   MAIN
-------------------------------------------------------------------------
}
Var
  ok, stop: Boolean;
  i: Integer;
  bsave, hsave, rxsave, rysave: Word;
  X: Char;
  sd, fn: String;
Begin
  Randomize;
  init;
  stop := False;
  i := 0;
  Repeat
    TextMode (c80 + Font8X8);
    setmode ( qbist_graphmode);
    draw_pics (i);
    Repeat Until KeyPressed;
    Read (X);
    If X = 'x' Then stop := True;
    If X In ['1'..'9'] Then
    Begin
      Str (i, sd);
      fn := out_path + '\qb' + X + '-' + sd;
      If load_transformlist ( fn ) Then
      Begin
        bsave := breite; hsave := hoehe;
        rxsave := rand_x; rysave := rand_y;
        
        breite := vesarec. width; hoehe := vesarec. height;
        rand_x := 0; rand_y := 0;
        
        draw ( 0, 0, fn + 'big');
        
        breite := bsave; hoehe := hsave;
        rand_x := rxsave; rand_y := rysave;
      End;
    End;
    If X In ['q', 'w', 'e', 'r', 't', 'z', 'u', 'i', 'o'] Then
    Begin
      ok := False;
      Str (i, sd);
      Case X Of
        'q':
            Begin
              fn := out_path + '\qb1' + '-' + sd;
              ok := load_transformlist ( fn );
            End;
        'w':
            Begin
              fn := out_path + '\qb2' + '-' + sd;
              ok := load_transformlist ( fn );
            End;
        'e':
            Begin
              fn := out_path + '\qb3' + '-' + sd;
              ok := load_transformlist ( fn );
            End;
        'r':
            Begin
              fn := out_path + '\qb4' + '-' + sd;
              ok := load_transformlist ( fn );
            End;
        't':
            Begin
              fn := out_path + '\qb5' + '-' + sd;
              ok := load_transformlist ( fn );
            End;
        'z':
            Begin
              fn := out_path + '\qb6' + '-' + sd;
              ok := load_transformlist ( fn );
            End;
        'u':
            Begin
              fn := out_path + '\qb7' + '-' + sd;
              ok := load_transformlist ( fn );
            End;
        'i':
            Begin
              fn := out_path + '\qb8' + '-' + sd;
              ok := load_transformlist ( fn );
            End;
        'o':
            Begin
              fn := out_path + '\qb9' + '-' + sd;
              ok := load_transformlist ( fn );
            End;
      End;
      If ok Then
        Case qbist_modus Of
          qbist_random:	qbist_modus := qbist_hold1;
          qbist_hold1:	qbist_modus := qbist_hold2;
          qbist_hold2:	qbist_modus := qbist_hold3;
        End;
    End;
    Inc (i);
  Until stop;
  TextMode (c80 + Font8X8);
End.