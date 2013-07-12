Program projektion;
Uses crt, graph, sgraph, rt_types, rt_math;
Const
  breited2 = 1024 / 2;
  hoehed2 = 768 / 2;
  faktor = 50;
  
  ws: Double = Pi / 16;
  anzahl_ecken = 16;
  
  o: rt_point = (X: 0; Y: 0; z: 0);
  e1: rt_point = (X: 3; Y: 0; z: 0);
  e2: rt_point = (X: 0; Y: 3; z: 0);
  e3: rt_point = (X: 0; Y: 0; z: 3);
  
Var
  {
  GLOBAL
  }
  exitsave: pointer;
  
  cop, prp: rt_point;
  alpha, beta, gamma, sina, sinb, sinc, cosa, cosb, cosc, dph: Double;
  
Procedure berechne_winkel;
Var D1: Double;
Begin
  dph := distance (cop, prp);
  Write1r ('DPH=', dph);
  D1 := Sqrt ( (cop. X - prp. X) * (cop. X - prp. X) + (cop. Y - prp. Y) * (cop. Y - prp. Y) );
  Write1r ('D1 =', D1);
  
  If D1 = 0 Then Begin
    sina := 0;
    cosa := 1
  End Else Begin
    sina := (cop. X - prp. Y) / D1;
    cosa := (cop. X - prp. X) / D1;
  End;
  
  If dph = 0 Then Begin
    sinb := 0;
    cosb := 1;
  End Else Begin
    sinb := (cop. z - prp. z) / dph;
    cosb := D1 / dph;
  End;
  
  If cosa = 0 Then alpha := Pi / 2 Else alpha := ArcTan (sina / cosa);
  
  If cosa < 0 Then alpha := alpha + Pi;
  
  If cosb = 0 Then beta := Pi / 2 Else beta := ArcTan (sinb / cosb);
  
  If cosb < 0 Then beta := beta + Pi;
  
  cosc := 1;
  sinc := 0;
  gamma := 0;
  
  WriteLn;
  
  writedeg ('alpha=', alpha);
  writedeg ('beta =', beta);
  writedeg ('gamma=', gamma);
  
End;
Procedure berechne_neu (ialpha, ibeta, igamma: Double; iprp: rt_point; idph: Double);
Begin
  alpha := ialpha;
  beta := ibeta;
  gamma := igamma;
  
  
  While alpha > Pi * 2 Do alpha := alpha - Pi * 2;
  While beta > Pi * 2 Do beta := beta - Pi * 2;
  While gamma > Pi * 2 Do gamma := gamma - Pi * 2;
  
  While alpha <0 Do alpha := alpha + Pi * 2;
  While beta < 0 Do beta := beta + Pi * 2;
  While gamma < 0 Do gamma := gamma + Pi * 2;
  
  sina := Sin (alpha);
  cosa := Cos (alpha);
  sinb := Sin (beta);
  cosb := Cos (beta);
  sinc := Sin (gamma);
  cosc := Cos (gamma);
  
  dph := idph;
  
  prp := iprp;
  
  cop. X := prp. X + dph * cosa * cosb;
  cop. Y := prp. Y + dph * sina * cosb;
  cop. z := prp. z + dph * sinb;
  
End;
Procedure transform (p: rt_point; Var pt: rt_point);
Var X1, Y1, z1: Double;
Begin
  vsub (v3t (p), v3t (prp), v3t (p) );
  X1 := p. X * cosa +  p. Y * sina;
  Y1 := p. Y * cosa -  p. X * sina;
  z1 := p. z;
  pinit (X1, Y1, z1, p);
  X1 := p. X * cosb + p. Z * sinb;
  Y1 := p. Y;
  z1 := p. Z * cosb - p. X * sinb;
  pinit (X1, Y1, z1, p);
  pt. X := p. X;
  pt. Y := pt. Y * cosc + pt. Z * sinc;
  pt. Z := pt. z * cosc - pt. Y * sinc;
End;

Procedure to_2D (p: rt_point; Var pt: rt_point);
Begin
  pt. X := (p. Y * dph) / (dph - p. X);
  pt. Y := (p. z * dph) / (dph - p. X);
  pt. z := 0;
End;

Function xscale (X: Double): Integer;
Begin
  xscale := Round ( (X * faktor) + breited2);
End;

Function yscale (Y: Double): Integer;
Begin
  yscale := Round (hoehed2 - (Y * faktor) );
End;


Procedure linep (a, b: rt_point);
Begin
  Line ( xscale (a. X), yscale (a. Y),
  xscale (b. X), xscale (b. Y) );
End;
Procedure Line3D (a, b: rt_point);
Begin
  transform (a, a);
  transform (b, b);
  to_2D (a, a);
  to_2D (b, b);
  linep (a, b);
End;
Procedure kreis3d_xy (m: rt_point; r: Double; c: Integer);
Var
  winkelschritt, w: Double;
  i: Integer;
  p1, p2: rt_point;
Begin
  SetColor (c);
  
  winkelschritt := 360 / anzahl_ecken;
  
  w := 0;
  p1.X := m. X + r * Cos (w * RAD);
  p1.Y := m. Y + r * Sin (w * RAD);
  p1.z := m. z;
  For i := 2 To anzahl_ecken Do
  Begin
    w := w + winkelschritt;
    p2.X := m. X + r * Cos (w * RAD);
    p2.Y := m. Y + r * Sin (w * RAD);
    p2.z := m. z;
    Line3D (p1, p2);
    p1 := p2;
  End;
End;
Var p: rt_point;
  pw: Array [1..8] Of rt_point;
  stop: Boolean;
  
Procedure koordinaten (c: Integer);
Begin
  If c = 0 Then Begin
    SetColor (c);
    Line3D (o, e1);
    Line3D (o, e2);
    Line3D (o, e3);
  End Else
  Begin
    SetColor (255);
    Line3D (o, e1);
    SetColor (254);
    Line3D (o, e2);
    SetColor (253);
    Line3D (o, e3);
  End;
  
  
End;

Procedure wuerfel_init;
Begin
  pinit (0, 0, 0, pw [1] );
  pinit (1, 0, 0, pw [2] );
  pinit (1, 1, 0, pw [3] );
  pinit (0, 1, 0, pw [4] );
  pinit (0, 0, 1, pw [5] );
  pinit (1, 0, 1, pw [6] );
  pinit (1, 1, 1, pw [7] );
  pinit (0, 1, 1, pw [8] );
End;

Procedure wuerfel_show (c: Integer);
Begin
  SetColor (c);
  
  Line3D (pw [1], pw [2] );
  Line3D (pw [2], pw [3] );
  Line3D (pw [3], pw [4] );
  Line3D (pw [4], pw [1] );
  Line3D (pw [1], pw [5] );
  Line3D (pw [2], pw [6] );
  Line3D (pw [3], pw [7] );
  Line3D (pw [4], pw [8] );
  Line3D (pw [5], pw [6] );
  Line3D (pw [6], pw [7] );
  Line3D (pw [7], pw [8] );
  Line3D (pw [8], pw [5] );
  
End;
Procedure myexit; Far;
Begin
  grafikaus;
End;

Var
  c: Char;
  
Begin
  exitsave := ExitProc;
  ExitProc := @myexit;
  ClrScr;
  
  pinit (10, 10, 10, cop);   { Center Of Projection          }
  pinit (0, 0, 0, prp);   { Projection Reference Point    }

  berechne_winkel;
  ReadLn;

  grafikein;
  SetRGBPalette (0, $00, $00, $00);
  SetRGBPalette (1, $ff, $ff, $ff);
  SetRGBPalette (2, $ff, $00, $00);
  SetRGBPalette (3, $00, $ff, $ff);
  SetRGBPalette (255, $ff, $00, $ff);
  SetRGBPalette (254, $ff, $ff, $00);
  SetRGBPalette (253, $00, $ff, $ff);

  wuerfel_init;

  While Not stop Do
  Begin
    {    wuerfel_show (1);}
    koordinaten (2);
    kreis3d_xy(o,2,3);
    Repeat Until KeyPressed;
    c := ReadKey;
    {    wuerfel_show (0);}
    koordinaten (0);
    kreis3d_xy(o,2,0);
    Case c Of
      'x': stop := True;
      'D': berechne_neu (alpha, beta, gamma, prp, dph + 0.1);
      'd': berechne_neu (alpha, beta, gamma, prp, dph - 0.1);
      'A': berechne_neu (alpha + ws, beta, gamma, prp, dph + 0.1);
      'a': berechne_neu (alpha - ws, beta, gamma, prp, dph - 0.1);
      'B': berechne_neu (alpha, beta + ws, gamma, prp, dph + 0.1);
      'b': berechne_neu (alpha, beta - ws, gamma, prp, dph - 0.1);
      'C': berechne_neu (alpha, beta, gamma + ws, prp, dph + 0.1);
      'c': berechne_neu (alpha, beta, gamma - ws, prp, dph - 0.1);
    End;
    
  End;
  
  grafikaus;
  Write1r ('DPH=', dph);
  
  writedeg ('alpha=', alpha);
  writedeg ('beta =', beta);
  writedeg ('gamma=', gamma);
  writepoint ('COP=', cop);
  writepoint ('PRP=', prp);
  
End.