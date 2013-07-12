Unit sgraph;
Interface
Uses crt, graph, vectorun;
Type 
  complex = Record a, b: Real; End;
  vectorarray = Array [1..20] Of vector;
  flaeche3D = Record numpoints: Integer; points: vectorarray; End;
  
  point = Record X, Y: Integer; End;
  winkel = Real;
  view3D = Record
             f1, f2, f3, a, b, c, fpz, swa, swb, swg, coa, sia, cob, sib, cog, sig: Real;
             v1, v2: Integer;
           End;
  view = Object
           maxx, minx, maxy, miny: Integer;
           Constructor init (imaxx, imaxy, iminx, iminy: Integer);
           Destructor done;
           Function scx (ix: Integer): Integer;
           Function scy (iy: Integer): Integer;
         End;
  
Var myview3D: view3D;
Function rad (deg: Real) : Real;
Procedure init3D (mf1, mf2, mf3, ma, mb, mc, mfpz, mswa, mswb, mswg: Real);
Procedure dreidtobs (v: vector; Var p: PointType);
Procedure drehpt (p: vector; a, b, g: Real; Var dp: vector);
Procedure mline (p1, p2: PointType);
Procedure Line3D (a, b: vector);
Procedure tri3D (v, a, b: vector; col: Integer; Fill: Boolean);
Procedure poly3D (numpoints: Integer; polypoints: vectorarray; Fill: Boolean);
Procedure grafikein;
Procedure grafikaus;
Implementation

Constructor view. init (imaxx, imaxy, iminx, iminy: Integer);
Begin maxx := imaxx; maxy := imaxy; minx := iminx; miny := iminy; End;
Destructor view. done;
Begin End;
Function view. scx (ix: Integer): Integer;
Begin
  scx := ix;
  If ix < minx Then Begin
    scx := maxx - (minx - ix);
  End Else Begin
    If ix > maxx Then scx := minx + (ix - maxx);
  End;
End;
Function view. scy (iy: Integer): Integer;
Begin
  scy := iy;
  If iy < miny Then Begin
    scy := maxy - (miny - iy);
  End Else Begin
    If iy > maxy Then scy := miny + (iy - maxy);
  End;
End;



Function rad (deg: Real) : Real;
Begin
  rad := (deg * Pi) / 180;
End;
Procedure grafikein;
Var gd, gm: Integer;
Begin
  gd := VGA; gm := vgahi;
  InitGraph (gd, gm, 'z:\tp70\bgi\');
  ClearDevice;
End;
Procedure grafikaus;
Begin
  CloseGraph;
End;
Procedure init3D (mf1, mf2, mf3, ma, mb, mc, mfpz, mswa, mswb, mswg: Real);
Begin
  With myview3D Do
  Begin
    f1 := mf1;
    f2 := mf2;
    f3 := mf3;
    a := ma;
    b := mb;
    c := mc;
    fpz := mfpz;
    swa := mswa;
    swb := mswb;
    swg := mswg;
    coa := Cos (rad (swa) ); sia := Sin (rad (swa) );
    cob := Cos (rad (swb) ); sib := Sin (rad (swb) );
    cog := Cos (rad (swg) ); sig := Sin (rad (swg) );
    v1 := GetMaxX Div 2;
    v2 := GetMaxY Div 2;
  End;
End;


Procedure dreidtobs (v: vector; Var p: PointType);
Var q: Real;
Begin
  With myview3D Do
  Begin
    (*
    p.x:=round( f1*(v.x+a) + f3*(v.y+c)*co) + v1;
    p.y:=round(-f2*(v.z+b) - f3*(v.y+c)*si) + v2;
    *)
    
    v. Y := v. Y * coa + v. z * sia;
    v. z := - v. Y * sia + v. z * coa;
    v. X := v. X * cob + v. z * sib;
    v. z := - v. X * sib + v. z * cob;
    v. X := v. X * cog + v. Y * sig;
    v. Y := - v. X * sig + v. Y * cog;
    
    q := 1 - (f3 * v. z + c) / fpz;
    p. X := Round ( (f1 * v. X + a) / q) + v1;
    p. Y := Round ( (f2 * v. Y + b) / q) + v2;
  End;
End;
Procedure drehpt (p: vector; a, b, g: Real; Var dp: vector);
Var ra, rb, rg: Real;
Begin
  ra := rad (a); rb := rad (b); rg := rad (g);
  dp := p;
  If a <> 0 Then
  Begin
    dp. Y := p. Y * Cos (ra) + p. z * Sin (ra);
    dp. z := - p. Y * Sin (ra) + p. z * Cos (ra);
  End;
  If b <> 0 Then
  Begin
    dp. X := p. X * Cos (rb) + p. z * Sin (rb);
    dp. z := - p. X * Sin (rb) + p. z * Cos (rb);
  End;
  If g <> 0 Then
  Begin
    dp. X := p. X * Cos (rg) + p. Y * Sin (rg);
    dp. Y := - p. X * Sin (rg) + p. Y * Cos (rg);
  End;
  
End;
Procedure mline (p1, p2: PointType);
Begin
  If ( (p1.X In [0..GetMaxX] ) And  (p1.Y In [0..GetMaxY] ) And
     (p2.X In [0..GetMaxX] ) And (p2.Y In [0..GetMaxY] ) ) 
  Then
  Begin
    Line (p1.X, p1.Y, p2.X, p2.Y);
  End;
End;
Procedure Line3D (a, b: vector);
Var p1, p2: PointType;
Begin
  dreidtobs (a, p1);
  dreidtobs (b, p2);
  mline (p1, p2);
End;

Procedure tri3D (v, a, b: vector; col: Integer; Fill: Boolean);
Var t : Array [1..4] Of PointType;
  i: Integer;
  h: vector;
Begin
  dreidtobs (v, t [1] );
  vadd (v, a, h);
  dreidtobs (h, t [2] );
  vadd (v, b, h);
  dreidtobs (h, t [3] );
  t [4] := t [1];
  SetColor (col);
  If Fill Then FillPoly (4, t) Else DrawPoly (4, t);
End;
Procedure poly3D (numpoints: Integer; polypoints: vectorarray; Fill: Boolean) ;
Var i: Integer;
  t : Array [1..20] Of PointType;
Begin
  If Not Fill Then
  Begin
    For i := 1 To numpoints - 1 Do
    Begin
      Line3D (polypoints [i], polypoints [i + 1] );
    End;
  End
  Else
  Begin
    For i := 1 To numpoints Do dreidtobs (polypoints [i], t [i] );
    FillPoly (numpoints, t);
  End;
End;
Begin
End.