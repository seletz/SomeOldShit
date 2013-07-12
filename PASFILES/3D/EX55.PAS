Program ex55_01;
{

        inkrementale 2D-Drehung

}
Uses crt, graph, sgraph;
Type
  matrix2D = Array [1..3, 1..3] Of Double;
  punkt2D = Array [1..3] Of Double;
  
Const
  faktor = 20;
  RAD = Pi / 180;
  NM2D: matrix2D = ( (0, 0, 0), (0, 0, 0), (0, 0, 0) );
  E2D: matrix2D = ( (1, 0, 0), (0, 1, 0), (0, 0, 1) );
  NP2D: punkt2D = (0, 0, 0);
  
  
Var
  p, p_: Array [1..5] Of punkt2D;
Procedure homogenize (Var p: punkt2D);
Var w: Double;
Begin
  w := p [3];
  If (w = 0) Or (w = 1) Then Exit;
  
  p [1] := p [1] / w;
  p [2] := p [2] / w;
  
End;
Procedure M_mal_P (M: matrix2D; p: punkt2D; Var p_: punkt2D);
Begin
  p_ [1] := m [1] [1] * p [1] + m [1] [2] * p [2] + m [1] [3] * p [3];
  p_ [2] := m [2] [1] * p [1] + m [2] [2] * p [2] + m [2] [3] * p [3];
  p_ [3] := m [3] [1] * p [1] + m [3] [2] * p [2] + m [3] [3] * p [3];
End;
Procedure write_m (M: matrix2D);
Begin
  WriteLn ('|', m [1] [1] : 3: 3, ' ', m [1] [2] : 3: 3, ' ', m [1] [3] : 3: 3, '|');
  WriteLn ('|', m [2] [1] : 3: 3, ' ', m [2] [2] : 3: 3, ' ', m [2] [3] : 3: 3, '|');
  WriteLn ('|', m [3] [1] : 3: 3, ' ', m [3] [2] : 3: 3, ' ', m [3] [3] : 3: 3, '|');
End;
Procedure write_p (p: punkt2D);
Begin
  WriteLn ('(', p [1] : 3: 3, ' ', p [2] : 3: 3, ' ', p [3] : 3: 3, ')');
End;
Procedure linep (p1, p2: punkt2D; c: Integer);
Begin
  
  homogenize (p1);
  homogenize (p2);
  
  SetColor (c);
  Line ( Round (p1 [1] * faktor + GetMaxX / 2), Round ( - p1 [2] * faktor + GetMaxY / 2),
  Round (p2 [1] * faktor + GetMaxX / 2), Round ( - p2 [2] * faktor + GetMaxY / 2) );
End;
Procedure make_R (w: Double; Var R: matrix2D);
Begin
  R := E2D;
  R [1, 1] := Cos (w * RAD);   R [1, 2] := Sin (w * RAD);
  R [2, 1] := - Sin (w * RAD);   R [2, 2] := Cos (w * RAD);
End;
Procedure init_p;
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
  R: matrix2D;
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
  init_p;
  make_R (0.2, R);

  ClrScr;
  write_m (R);
  For i := 1 To 5 Do
  Begin
    write(i); write_p(p_[i]);
    M_mal_P (R, p_ [i], p_ [i] );
    write(i); write_p(p_[i]);
  End;
  ReadLn;

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
      M_mal_P (R, p_ [i], p_ [i] );

    End;
    linep (p_ [1], p_ [2], 1);
    linep (p_ [2], p_ [3], 1);
    linep (p_ [3], p_ [4], 1);
    linep (p_ [4], p_ [5], 1);
    linep (p_ [5], p_ [1], 1);
    
  Until KeyPressed;
  grafikaus;
End.