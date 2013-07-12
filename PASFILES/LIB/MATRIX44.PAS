Unit matrix44;
(*==========================================================================*
 *                                                                          *
 *                                                                          *
 *   Matrix44: erstellt am 10.7.1994                                        *
 *                                                                          *
 *                                                                          *
 *                                                                          *
 *                                                                          *
 *                                                                          *
 *                                                                          *
 *                                                                          *
 *                                                                          *
 *                                                                          *
 *                                                                          *
 *                                                                          *
 *                                                                          *
 *                                                                          *
 *                                                                          *
 *                                                                          *
 *                                                                          *
 *                                                                          *
 *                                                                          *
 *                                                                          *
 *                                                                          *
 *==========================================================================*)

  { define debug_matrix44}

Interface
Uses crt;
Type
  p_matrix4 = ^matrix4;
  p_vektor4 = ^vektor4;
  p_vektor3 = ^vektor3;
  p_vektor2 = ^vektor2;
  matrix4 = Array [1..4, 1..4] Of Real;
  vektor4 = Array [1..4] Of Real;
  vektor3 = Array [1..3] Of Real;
  vektor2 = Array [1..2] Of Real;

  p_win = ^t_win;
  t_win = Array [1..4] Of Double;


Const
  RAD = Pi / 180;
  E4: matrix4 = ( (1, 0, 0, 0), (0, 1, 0, 0), (0, 0, 1, 0), (0, 0, 0, 1) );
  N4: matrix4 = ( (0, 0, 0, 0), (0, 0, 0, 0), (0, 0, 0, 0), (0, 0, 0, 0) );

Function put_window(xmin,ymin,xmax,ymax:double; w:p_win):p_win;

Function put_vektor (X, Y, z: Double; v: p_vektor4): p_vektor4;
Procedure get_vektor (p: p_vektor4; Var X, Y, z: Double);
Function homogenize (v: p_vektor4): p_vektor4;



Procedure copy_vektor (src, dest: p_vektor4);
Procedure copy_matrix (src, dest: p_matrix4);

Function mzero (m: p_matrix4): p_matrix4;
Function vzero (v: p_vektor4): p_vektor4;
Function midentity (m: p_matrix4): p_matrix4;

Procedure put_row (row: Integer; p: p_vektor4; m: p_matrix4);
Procedure put_col (col: Integer; p: p_vektor4; m: p_matrix4);

Function get_row (row: Integer; m: p_matrix4; p: p_vektor4): p_vektor4;
Function get_col (col: Integer; m: p_matrix4; p: p_vektor4): p_vektor4;

Function make_vektor_string (s: String; v: p_vektor4): String;
Function make_window_string (s: String; v: p_win): String;

Procedure write_p (s: String; p: p_vektor4);
Procedure write_m (s: String; M: p_matrix4);

Function p2v (a, b, v: p_vektor4): p_vektor4;
Function vabs3 (a: p_vektor4): Real;
Function vabs4 (a: p_vektor4): Real;
Function vneg (a, an: p_vektor4): p_vektor4;
Function vmul (k: Double; a, a_: p_vektor4): p_vektor4;
Function vadd (a,b, c: p_vektor4): p_vektor4;
Function vsub (a,b, c: p_vektor4): p_vektor4;
Function vnorm (a, an: p_vektor4): p_vektor4;
Function vcross (a, b, c: p_vektor4): p_vektor4;
Function vdotv (a, b: p_vektor4): Real;
Function mdotm (a, b, c: p_matrix4): p_matrix4;
Function mdotv (a: p_matrix4; b, c: p_vektor4): p_vektor4;
Function vcos (a, b: p_vektor4): Real;
Function vcosn (a, b: p_vektor4): Real;

Function gauss_elimination (A: p_matrix4; R: P_vektor4; L: p_vektor4; ok: Boolean): p_vektor4;

Function minv (a, a_: p_matrix4): p_matrix4;
Function mtransp (a, a_: p_matrix4): p_matrix4;


Function T (p: p_vektor4; m: p_matrix4): p_matrix4;
Function S (p: p_vektor4; m: p_matrix4): p_matrix4;
Function SH (shx, shy: Double; m: p_matrix4): p_matrix4;
Function RX (alpha: Double; m: p_matrix4): p_matrix4;
Function RY (beta: Double; m: p_matrix4): p_matrix4;
Function RZ (gamma: Double; m: p_matrix4): p_matrix4;
Function Nper (VUP, VPN, VRP, PRP: p_vektor4; Window: t_win; m: p_matrix4): p_matrix4;

Implementation
(*=========================================*
 *                                         *
 *                                         *
 *         Hilfsfunktionen                 *
 *                                         *
 *                                         *
 *=========================================*)
Function vzero (v: p_vektor4): p_vektor4;
begin
	v^[1]:=0;
	v^[2]:=0;
	v^[3]:=0;
	v^[4]:=0;
end;
Function put_window(xmin,ymin,xmax,ymax:double; w:p_win):p_win;
begin
     w^[1]:=xmin;
     w^[2]:=xmax;
     w^[3]:=ymin;
     w^[4]:=ymax;

     put_window:=w;
end;
Function homogenize (v: p_vektor4): p_vektor4;
Var i: Integer;
Begin
  If v^ [4] <> 0 Then Begin
    For i := 1 To 4 Do v^ [i] := v^ [i] / v^ [4];
    homogenize := v;
  End
  Else
    homogenize := Nil
End;
Function mzero (m: p_matrix4): p_matrix4;
Begin
  FillChar (m^, SizeOf (matrix4), 0);
End;
Function midentity (m: p_matrix4): p_matrix4;
Var i: Integer;
Begin
  FillChar (m^, SizeOf (matrix4), 0);
  For i := 1 To 4 Do m^ [i] [i] := 1;
End;

Function make_vektor_string (s: String; v: p_vektor4): String;
Var
  t: String;
  i: Integer;
Begin
  s := s + '=(';
  For i := 1 To 3 Do
  Begin
    Str (v^ [i] : 3: 3, t);
    s := s + t + ' | ';
  End;
  Str (v^ [4] : 3: 3, t);
  s := s + t + ' )';
  make_vektor_string := s;
End;
Function make_window_string (s: String; v: p_win): String;
Var
  t: String;
  i: Integer;
Begin
  s := s + '=(';
  For i := 1 To 3 Do
  Begin
    Str (v^ [i] : 3: 3, t);
    s := s + t + ' | ';
  End;
  Str (v^ [4] : 3: 3, t);
  s := s + t + ' )';
  make_window_string := s;
End;
Procedure write_m;
Procedure abst (l: Integer);
Var i: Integer;
Begin For i := 1 To l Do Write (' ') End;
Var
  i, j, X: Integer;
  ms: Array [1..4, 1..4] Of  String;
Begin
  X := Length (s) + 1;
  For i := 1 To 4 Do
    For j := 1 To 4 Do
    Begin
      Str (m^ [i] [j] : 3: 3, ms [i] [j] );
      If m^ [i] [j] > 0 Then ms [i] [j] := '+' + ms [i] [j];
      If m^ [i] [j] = 0 Then ms [i] [j] := ' ' + ms [i] [j];
    End;
  abst (X); WriteLn ('| ', ms [1] [1], ' ', ms [1] [2], ' ', ms [1] [3], ' ', ms [1] [4], ' |');
  abst (X); WriteLn ('|                             |');
  abst (X); WriteLn ('| ', ms [2] [1], ' ', ms [2] [2], ' ', ms [2] [3], ' ', ms [2] [4], ' |');
  Write (s, '='); WriteLn ('|                             |');
  abst (X); WriteLn ('| ', ms [3] [1], ' ', ms [3] [2], ' ', ms [3] [3], ' ', ms [3] [4], ' |');
  abst (X); WriteLn ('|                             |');
  abst (X); WriteLn ('| ', ms [4] [1], ' ', ms [4] [2], ' ', ms [4] [3], ' ', ms [4] [4], ' |');
End;
Procedure write_p;
Begin
  WriteLn (s, '=(', p^ [1] : 3: 3, ' ', p ^ [2] : 3: 3, ' ', p ^ [3] : 3: 3, ' ', p ^ [4] : 3: 3, ')T');
End;

Procedure copy_vektor (src, dest: p_vektor4);
Begin
  Move (src^, dest^, SizeOf (vektor4) );
End;
Procedure copy_matrix (src, dest: p_matrix4);
Begin
  Move (src^, dest^, SizeOf (matrix4) );
End;

Function put_vektor (X, Y, z: Double; v: p_vektor4): p_vektor4;
Begin
  v^ [1] := X;
  v^ [2] := Y;
  v^ [3] := z;
  v^ [4] := 1;
  put_vektor := v;
End;
Procedure get_vektor (p: p_vektor4; Var X, Y, z: Double);
Begin
  X := p^ [1];
  Y := p^ [2];
  z := p^ [3];
End;
Procedure put_row (row: Integer; p: p_vektor4; m: p_matrix4);
Var i: Integer;
Begin
  For i := 1 To 4 Do m^ [row] [i] := p^ [i];
End;
Procedure put_col (col: Integer; p: p_vektor4; m: p_matrix4);
Var i: Integer;
Begin
  For i := 1 To 4 Do m^ [i] [col] := p^ [i];
End;

Function get_row (row: Integer; m: p_matrix4; p: p_vektor4): p_vektor4;
Var i: Integer;
Begin
  For i := 1 To 4 Do p^ [i] := m^ [row] [i];
  get_row := p;
End;
Function get_col (col: Integer; m: p_matrix4; p: p_vektor4): p_vektor4;
Var i: Integer;
Begin
  For i := 1 To 4 Do p^ [i] := m^ [i] [col];
  get_col := p;
End;
Function vmul (k: Double; a, a_: p_vektor4): p_vektor4;
Var
  i: Integer;
Begin
  For i := 1 To 3 Do a_^ [i] := k * a^ [i];
  a_^ [4] := 1;
  vmul := a_;
End;
Function vadd (a,b, c: p_vektor4): p_vektor4;
Var
  i: Integer;
Begin
  For i := 1 To 3 Do c^ [i] := a^ [i]+b^[i];
  c^ [4] := 1;
  vadd := c;
End;
Function vsub (a,b, c: p_vektor4): p_vektor4;
Var
  i: Integer;
Begin
  For i := 1 To 3 Do c^ [i] := a^ [i]-b^[i];
  c^ [4] := 1;
  vsub := c;
End;
(*=========================================*
 *                                         *
 *                      _                  *
 *         Absolutwert |A|                 *
 *                                         *
 *                                         *
 *=========================================*)
Function vabs3 (a: p_vektor4): Real;
Begin
  vabs3 := Sqrt (a^ [1] * a^ [1] + a^ [2] * a^ [2] + a^ [3] * a^ [3] )
End;
Function vabs4 (a: p_vektor4): Real;
Begin
  vabs4 := Sqrt (a^ [4] * a^ [4] + a^ [1] * a^ [1] + a^ [2] * a^ [2] + a^ [3] * a^ [3] )
End;
(*=========================================*
 *                                         *
 *         _ __         A,B...punkte       *
 *         V=AB         V.....vektor       *
 *                                         *
 *                                         *
 *=========================================*)

Function p2v (a, b, v: p_vektor4): p_vektor4;
Var
  i: Integer;
Begin
  For i := 1 To 3 Do v^ [i] := b^ [i] - a^ [i];
  v^ [4] := 1;
  p2v := v;
End;
(*=========================================*
 *                                         *
 *         __  _        A,AN..Vektoren     *
 *         AN=-A                           *
 *                                         *
 *                                         *
 *=========================================*)
Function vneg (a, an: p_vektor4): p_vektor4;
Var
  i: Integer;
Begin
  For i := 1 To 4 Do an^ [i] := - a^ [i];
  vneg := an;
End;
(*=========================================*
 *              _                          *
 *              A                          *
 *             ---                         *
 *              _                          *
 *             |A|                         *
 *=========================================*)
Function vnorm (a, an: p_vektor4): p_vektor4;
Var t: Real;
Begin
  t := vabs3 (a);
  If t <> 0 Then Begin
    an^ [4] := 1;
    an^ [1] := a^ [1] / t;
    an^ [2] := a^ [2] / t;
    an^ [3] := a^ [3] / t;
  End;
  vnorm := an;
End;
(*=========================================*
 *                                         *
 *                       _   _             *
 *         Kreuzprodukt  A x B             *
 *                                         *
 *                                         *
 *=========================================*)
Function vcross (a, b, c: p_vektor4): p_vektor4;
Begin
  c^ [1] := + a^ [2] * b^ [3] - b^ [2] * a^ [3];
  c^ [2] := - a^ [1] * b^ [3] + b^ [1] * a^ [3];
  c^ [3] := + a^ [1] * b^ [2] - b^ [1] * a^ [2];
  c^ [4] := 1;
  vcross := c;
End;
(*=========================================*
 *                                         *
 *                       _   _             *
 *         Skalarprodukt A . B             *
 *                                         *
 *                                         *
 *=========================================*)
Function vdotv (a, b: p_vektor4): Real;
Begin
  vdotv := a^ [1] * b^ [1] + a^ [2] * b^ [2] + a^ [3] * b^ [3] + a^ [4] * b^ [4];
End;
Function mdotm (a, b, c: p_matrix4): p_matrix4;
Var i, j: Integer;
  temp: p_matrix4;
Begin
  New (temp);
  For j := 1 To 4 Do
    For i := 1 To 4 Do Begin
      temp^ [j, i] := b^ [1, i] * a^ [j, 1] + b^ [2, i] * a^ [j, 2] + b^ [3, i] * a^ [j, 3] + b^ [4, i] * a^ [j, 4];
    End;
  copy_matrix (temp, c);
  Dispose (temp);
  mdotm := c;
End;
Function mdotv (a: p_matrix4; b, c: p_vektor4): p_vektor4;
Var
  i: Integer;
  temp: p_vektor4;
Begin
  New (temp);
  temp^ [1] := a^ [1] [1] * b^ [1] + a^ [1] [2] * b^ [2] + a^ [1] [3] * b^ [3] + a^ [1] [4] * b^ [4]; ;
  temp^ [2] := a^ [2] [1] * b^ [1] + a^ [2] [2] * b^ [2] + a^ [2] [3] * b^ [3] + a^ [2] [4] * b^ [4]; ;
  temp^ [3] := a^ [3] [1] * b^ [1] + a^ [3] [2] * b^ [2] + a^ [3] [3] * b^ [3] + a^ [3] [4] * b^ [4]; ;
  temp^ [4] := a^ [4] [1] * b^ [1] + a^ [4] [2] * b^ [2] + a^ [4] [3] * b^ [3] + a^ [4] [4] * b^ [4]; ;
  copy_vektor (temp, c);
  Dispose (temp);
  mdotv := c;
End;
(*=========================================*
 *                                         *
 *         L”sung von A.L=R                *
 *         mit Gauá -Algorithmus           *
 *    _                                    *
 *    L...L”sungsvektor                    *
 *    A...Koeffizientenmatrix (4x4)        *
 *    R...Vektor der konstanten Glieder    *
 *                                         *
 *    ok..True,wenn eine L”sung vorhanden. *
 *=========================================*)
Function gauss_elimination (A: p_matrix4; R, L: P_vektor4; ok: Boolean): p_vektor4;
Const
  i = 4; {zeilen}
  j = 4; {spalten}
Type
  p_matrix4_erw = ^matrix4_erw;
  p_vektor4_erw = ^vektor4_erw;
  matrix4_erw = Array [1..4, 1..5] Of Double;
  vektor4_erw = Array [1..5] Of Double;
Function mul_z (z: Integer; c: Double; M: p_matrix4_erw; COL: p_vektor4_erw ): p_vektor4_erw;
Var
  i: Integer;
Begin
  For i := 1 To 5 Do COL^ [i] := c * M^ [z] [i];
  mul_z := COL;
End;
Procedure sub_z (z: Integer; M: p_matrix4_erw; p: p_vektor4_erw);
Var
  i: Integer;
Begin
  For i := 1 To 5 Do M^ [z] [i] := M^ [z] [i] - P^ [i];
End;

Var
  X, Y, zeile, spalte, index, t: Integer;
  kk, rr, s: Double;
  B: matrix4_erw;
  temp: vektor4_erw;
Begin
  ok := True;
  {
  Erweiterte Matrix in B bilden: B=(A,R)
  }
  For X := 1 To 4 Do
  Begin
    For Y := 1 To 4 Do
    Begin
      B [X] [Y] := A^ [X] [Y];
    End;
    B [X] [5] := R^ [X];
  End;
  {
  Dreiecksmatrix bilden in B
  }
  For spalte := 1 To j - 1 Do
  Begin
    For zeile := spalte + 1 To i Do
    Begin
      {$ifdef debug_matrix44}
      ClrScr;
      WriteLn ('spalte=', spalte, ' zeile=', zeile);
      For X := 1 To 4 Do
      Begin
        For Y := 1 To 5 Do Write (B [X] [Y] : 3: 3, ' ');
        WriteLn;
      End;
      WriteLn;
      {$endif}
      mul_z (spalte, B [zeile] [spalte] / B [spalte] [spalte], @B, @temp);
      sub_z (zeile, @B, @temp);
      
      {$ifdef debug_matrix44}
      For X := 1 To 4 Do
      Begin
        For Y := 1 To 5 Do Write (B [X] [Y] : 3: 3, ' ');
        WriteLn;
      End;
      ReadLn;
      {$endif}

    End;
  End;
  {
  L”sungsvektor L errechnen
  }
  For index := i Downto 1 Do
  Begin
    {$ifdef debug_matrix44}
    WriteLn ('index:', index);
    {$endif}
    kk := B [index] [index];
    rr := B [index] [j + 1];
    L^ [index] := rr;
    s := 0;
    t := j;
    {$ifdef debug_matrix44}
    Write ('t:');
    {$endif}
    While (t >= (index + 1) ) Do
    Begin
      {$ifdef debug_matrix44}
      Write (t);
      {$endif}
      s := s + L^ [t] * B [index] [t];
      Dec (t);
    End;
    {$ifdef debug_matrix44}
    WriteLn;
    {$endif}
    L^ [index] := (L^ [index] - s) / kk;
  End;
  gauss_elimination := L;
  {$ifdef debug_matrix44}
  write_p ('L', l);
  {$endif}
End;
(*=========================================*
 *                                         *
 *                                         *
 *         Matrix Inverse                  *
 *                                         *
 *                                         *
 *         B:=minv(A,B)                    *
 *                                         *
 *         wobei in B nachher A^(-1) steht *
 *                                         *
 *                                         *
 *                                         *
 *=========================================*)
Function minv (a, a_: p_matrix4): p_matrix4;
Const
  i = 4;
  j = 4;
Var
  n: Integer;
  EN, XN: vektor4;
  ok: Boolean;
Begin
  For n := 1 To j Do
  Begin
    get_col (n, @E4, @EN);
    gauss_elimination (A, @EN, @XN, ok);
    put_col (n, @XN, A_);
  End;
End;
(*=========================================*
 *                                         *
 *                                         *
 *         Matrix Transpose                *
 *                                         *
 *                                         *
 *=========================================*)
Function mtransp (a, a_: p_matrix4): p_matrix4;
Var
  i, j: Integer;
Begin
  For i := 1 To 4 Do
    For j := 1 To 4 Do
      a_^ [i] [j] := a^ [j] [i];
  mtransp := a_;
End;
(*=========================================*
 *                                         *
 *                                 _    _  *
 *         cosinus des winkels zw. A u. b  *
 *                                         *
 *                                         *
 *=========================================*)
Function vcos (a, b: p_vektor4): Real;
Begin
  vcos := vdotv (a, b) / (vabs3 (a) * vabs3 (b) );
End;
Function vcosn (a, b: p_vektor4): Real;
Begin
  vcosn := vdotv (a, b);
End;
(*=========================================*
 *                                         *
 *                                         *
 *         3D-Funktionen                   *
 *                                         *
 *                                         *
 *=========================================*)

Function T (p: p_vektor4; m: p_matrix4): p_matrix4;
Begin
  midentity (M);
  
  put_col (4, p, m);
  m^ [4] [4] := 1;
  T := m;
End;
Function S (p: p_vektor4; m: p_matrix4): p_matrix4;
Var
  i: Integer;
Begin
  midentity (M);
  
  For i := 1 To 4 Do m^ [i] [i] := p ^ [i];
End;
Function SH (shx, shy: Double; m: p_matrix4): p_matrix4;
Begin
  midentity (M);
  
  m^ [1] [3] := shx;
  m^ [2] [3] := shy;
  SH := M;
End;
Function RX (alpha: Double; m: p_matrix4): p_matrix4;
Var
  sa, ca: Double;
Begin
  midentity (M);
  
  sa := Sin (alpha * RAD);
  ca := Cos (alpha * RAD);
  
  m^ [2] [2] := + ca; m^ [2] [3] := - sa;
  m^ [3] [2] := + sa; m^ [3] [3] := + ca;
  
  RX := M;
End;
Function RY (beta: Double; m: p_matrix4): p_matrix4;
Var
  sa, ca: Double;
Begin
  midentity (M);
  
  sa := Sin (beta * RAD);
  ca := Cos (beta * RAD);

  m^ [1] [1] := + ca; m^ [1] [3] := + sa;
  m^ [3] [1] := - sa; m^ [3] [3] := + ca;
  
  RY := M;
End;
Function RZ (gamma: Double; m: p_matrix4): p_matrix4;
Var
  sa, ca: Double;
Begin
  midentity (M);
  
  sa := Sin (gamma * RAD);
  ca := Cos (gamma * RAD);
  
  m^ := E4;
  
  m^ [1] [1] := + ca; m^ [1] [2] := - sa;
  m^ [2] [1] := + sa; m^ [2] [2] := + ca;
  
  RZ := M;
End;
(*=========================================*
 *                                         *
 *    berechnet Nper                       *
 *                                         *
 *=========================================*)
Function Nper (VUP, VPN, VRP, PRP: p_vektor4; Window: t_win; m: p_matrix4): p_matrix4;
Const
  B = 0;
  F = - 1.2;
Var
  DOP, CW, RA, RB, RC, vt: vektor4;
  Mper, Tvrp, Tprp, R, Svp, Sper, SHpar: matrix4;
  vrp_z_2, du, dv: Double;
Begin
  
  midentity (M);

  T (vneg (VRP, @vt), @Tvrp);
  
  mdotm (@Tvrp, M, M);
  
  {$ifdef debug_matrix44}
  WriteLn ('Nper:');
  WriteLn;
  write_m ('T(-VRP)', @Tvrp);
  WriteLn;
  write_m ('M', M);
  ReadLn;
  {$endif}
  
  {
  M=T(-VRP)
  }
  
  vnorm (VPN, @RC);
  vnorm (vcross (VUP, @RC, @vt), @RA);
  vcross (@RC, @RA, @RB);
  put_row (1, @RA, @R);
  put_row (2, @RB, @R);
  put_row (3, @RC, @R);
  R [1] [4] := 0;
  R [2] [4] := 0;
  R [3] [4] := 0;
  
  mdotm (@R, M, M);
  
  {$ifdef debug_matrix44}
  write_m ('R', @R);
  WriteLn;
  write_m ('M', M);
  ReadLn;
  {$endif}
  
  {
  M=R.T(-VRP)
  }
  
  T (vneg (PRP, @vt), @Tprp);
  
  mdotm (@Tprp, M, M);
  
  {$ifdef debug_matrix44}
  write_m ('T(-PRP)', @Tprp);
  WriteLn;
  write_m ('M', M);
  ReadLn;
  {$endif}
  
  {
  M=T(-PRP).R.T(-VRP)
  }
  
  put_vektor ( (Window [2] + Window [1] ) / 2, (Window [4] + Window [3] ) / 2, 0, @CW);
  p2v (PRP, @CW, @DOP);
  
  {$ifdef debug_matrix44}
  write_P ('CW ', @cw);
  write_P ('DOP', @DOP);
  {$endif}
  
  SH ( - DOP [1] / DOP [3], - DOP [2] / DOP [3], @SHpar);
  
  mdotm (@SHpar, M, M);

  {$ifdef debug_matrix44}
  write_M ('SHpar', @SHpar);
  WriteLn;
  write_m ('M', M);
  ReadLn;
  {$endif}
  
  {
  M=SHpar.T(-PRP).R.T(-VRP)
  }
  dv := Window [4] - Window [3];
  du := Window [2] - Window [1];
  vrp_z_2 := - 2 * PRP^ [3];
  
  S (
  put_vektor (
  vrp_z_2 / (du * (B - PRP^ [3] ) ),
  vrp_z_2 / (dv * (B - PRP^ [3] ) ),
  - 1 / (B - PRP^ [3] ),
  @vt),
  @Sper);
  
  mdotm (@Sper, M, M);
  
  {$ifdef debug_matrix44}
  write_m ('Sper', @Sper);
  WriteLn;
  write_m ('M', M);
  ReadLn;
  {$endif}
  
  {
  M=Sper.SHpar.T(-PRP).R.T(-VRP)
  }
  
  midentity (@Mper);

  Mper [3] [3] := 0;
  Mper [4] [3] := 1 / PRP^ [3];
  
  mdotm (@Mper, M, M);
  
  {$ifdef debug_matrix44}
  write_m ('Mper', @Mper);
  WriteLn;
  write_m ('M', M);
  ReadLn;
  {$endif}
  
  {
  M=Mper.Sper.SHpar.T(-PRP).R.T(-VRP)
  }

  S (put_vektor (200, 200, 1, @vt), @Svp);

  mdotm (@Svp, M, M);

  {$ifdef debug_matrix44}
  write_m ('Svp', @Svp);
  WriteLn;
  write_m ('M', M);
  ReadLn;
  {$endif}

  {
  M=Svp.Mper.Sper.SHpar.T(-PRP).R.T(-VRP)
  }

  Nper := M;

End;
Begin
End.

