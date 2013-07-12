Program ex55_02;
{

        inkrementale 2D-Drehung

}
Uses crt, graph, sgraph;
Type
  p_matrix2D = ^matrix2D;
  matrix2D = Array [1..3, 1..3] Of Double;
  p_punkt2D = ^punkt2D;
  punkt2D = Array [1..3] Of Double;

Const
  faktor = 25;
  RAD = Pi / 180;
  NM2D: matrix2D = ( (0, 0, 0), (0, 0, 0), (0, 0, 0) );
  E2D: matrix2D = ( (1, 0, 0), (0, 1, 0), (0, 0, 1) );
  NP2D: punkt2D = (0, 0, 0);
  
  
Var
  p, p_: Array [1..5] Of punkt2D;
Function init_P (X, Y: Double; p: p_punkt2D): p_punkt2D;
Begin
  p^ [1] := X;
  p^ [2] := Y;
  p^ [3] := 1;
  init_p := p;
End;
Function homogenize (p: p_punkt2D): p_punkt2D;
Var w: Double;
Begin
  w := p^ [3];
  If (w = 0) Or (w = 1) Then Exit;
  
  p ^ [1] := p^ [1] / w;
  p ^ [2] := p^ [2] / w;

  homogenize := p;
End;
Function M_mal_P (M: p_matrix2D; p, p_: p_punkt2D): p_punkt2D;
Begin
  p_^ [1] := m^ [1] [1] * p^ [1] + m^ [1] [2] * p^ [2] + m^ [1] [3] * p^ [3];
  p_^ [2] := m^ [2] [1] * p^ [1] + m^ [2] [2] * p^ [2] + m^ [2] [3] * p^ [3];
  p_^ [3] := m^ [3] [1] * p^ [1] + m^ [3] [2] * p^ [2] + m^ [3] [3] * p^ [3];
  M_mal_P := p_;
End;
Function M_mal_M (A, B: p_matrix2D; C: p_matrix2D): p_matrix2D;
Var i, j: Integer;
Begin
  For i := 1 To 3 Do
    For j := 1 To 3 Do
    Begin
      C^ [i] [j] := A^ [i] [1] * B^ [1] [j] + A^ [i] [2] * B^ [2] [j] + A^ [i] [3] * B^ [3] [j];
    End;
  M_mal_M := C;
End;
Procedure write_m (s:string; M: matrix2D);
procedure abst (l: Integer);
Var i:integer;
Begin For i := 1 To l Do Write (' ') End;
var x:integer;
Begin
  X:=length(s)+1;
  abst(x); WriteLn ('|', m [1] [1] : 3: 3, ' ', m [1] [2] : 3: 3, ' ', m [1] [3] : 3: 3, '|');
  write(s,'=');WriteLn ('|', m [2] [1] : 3: 3, ' ', m [2] [2] : 3: 3, ' ', m [2] [3] : 3: 3, '|');
  abst(x);WriteLn ('|', m [3] [1] : 3: 3, ' ', m [3] [2] : 3: 3, ' ', m [3] [3] : 3: 3, '|');
End;
Procedure write_p (p: punkt2D);
Begin
  WriteLn ('(', p [1] : 3: 3, ' ', p [2] : 3: 3, ' ', p [3] : 3: 3, ')');
End;
Procedure linep (p1, p2: punkt2D; c: Integer);
Begin
  
  homogenize (@p1);
  homogenize (@p2);
  
  SetColor (c);
  Line ( Round (p1 [1] * faktor + GetMaxX / 2), Round ( - p1 [2] * faktor + GetMaxY / 2),
  Round (p2 [1] * faktor + GetMaxX / 2), Round ( - p2 [2] * faktor + GetMaxY / 2) );
End;
Function make_R (w: Double; R: p_matrix2D): p_matrix2D;
Begin
  R^ := E2D;
  R^ [1, 1] := Cos (w * RAD);   R^ [1, 2] := Sin (w * RAD);
  R^ [2, 1] := - Sin (w * RAD);   R^ [2, 2] := Cos (w * RAD);
  make_R := R;
End;
Function make_T (p: p_punkt2D; R: p_matrix2D): p_matrix2D;
Begin
  homogenize (p);
  R^ := E2D;
  R^ [1, 3] := p^ [1];
  R^ [2, 3] := p^ [2];
End;
Procedure init_house;
Var
  i: Integer;
Begin
  For i := 1 To 5 Do Begin p [1] := NP2D; p_ [i] := NP2D End;

  p [1] [1] := 0;
  p [1] [2] := 0;
  p [1] [3] := 1;
  
  p [2] [1] := 0;
  p [2] [2] := 4;
  p [2] [3] := 1;
  
  p [3] [1] := 2;
  p [3] [2] := 6;
  p [3] [3] := 1;
  
  p [4] [1] := 4;
  p [4] [2] := 4;
  p [4] [3] := 1;
  
  p [5] [1] := 4;
  p [5] [2] := 0;
  p [5] [3] := 1;
  
  For i := 1 To 5 Do
  Begin
    p_ [i] := p [i];
  End;
  
End;
Var
  R, T, T1, M: matrix2D;
  P1, P2: punkt2D;
  i: Integer;
  exitsave: pointer;
Procedure myexit; Far;
Begin
  ExitProc := exitsave;
  grafikaus;
End;
Begin
  exitsave := ExitProc;
  ExitProc := @myexit;
  init_house;
  init_p (3, 3, @p1);
  init_p ( - 3, - 3, @p2);
  make_T (@p1, @T);
  make_T (@p2, @T1);
  make_R (0.1, @R);
  M_mal_M (@T1, M_mal_M (@R, @T, @M), @M);
  
  ClrScr;
  
  write_m ('T ', T);
  Writeln;
  write_m ('R ',R);
  Writeln;
  write_m ('T1', T1);
  Writeln;
  write_m ('M ', M);
  ReadLn;
  
  For i := 1 To 5 Do
  Begin
    M_mal_P (@R, @p_ [i], @p_ [i] );
  End;
  
  grafikein;
  SetRGBPalette (0, 0, 0, 0);
  SetRGBPalette (1, $ff, $ff, $ff);
  
  Repeat
    linep (p_ [1], p_ [2], 0);
    linep (p_ [2], p_ [3], 0);
    linep (p_ [3], p_ [4], 0);
    linep (p_ [4], p_ [5], 0);
    linep (p_ [5], p_ [1], 0);
    For i := 1 To 5 Do
    Begin
      M_mal_P (@M, @p_ [i], @p_ [i] );
      
    End;
    linep (p_ [1], p_ [2], 1);
    linep (p_ [2], p_ [3], 1);
    linep (p_ [3], p_ [4], 1);
    linep (p_ [4], p_ [5], 1);
    linep (p_ [5], p_ [1], 1);
    
  Until KeyPressed;
  grafikaus;
End.