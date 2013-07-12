Program cluster;
Uses crt, graph, sgraph, vectorun;
Const g = 39;
  maxstars = 4;
  epsilon = 0.1;
  textm = True;
  graphic = True;
  minx = 10;
  maxx = 1000;
  miny = 10;
  maxy = 750;
Type  point = Record X, Y, z: Real End;
  star = Record a, v, Pos: vector; m: Real End;
Var stars : Array [1..4] Of star;
  null: vector;
  zoom: Integer;
  
Function inrange (i, u, o: Real): Boolean;
Begin
  inrange := ( (i > u) And (i < o) );
End;
Function scalex (X: Real): Real;
Begin
  If inrange ( (maxx - minx) / 2 + X, minx, maxx) Then
    scalex := (maxx - minx) / 2 + X
  Else Begin
    scalex := 0
  End;
End;

Function scalew (w: Real): Real;
Begin
  If inrange (w, - 2 * Pi, 2 * Pi) Then
    scalew := w
  Else Begin
    If w > 2 * Pi Then w := - 2 * Pi;
    If w < ( - 2 * Pi) Then w := 2 * Pi - w;
    scalew := w
  End;
End;

Function scaley (Y: Real): Real;
Begin
  If inrange ( (maxy - miny) / 2 + Y, miny, maxy) Then
    scaley := (maxy - miny) / 2 + Y
  Else Begin
    scaley := 0
  End;
End;

Procedure init;
Begin
  null. X := 0;
  null. Y := 0;
  null. z := 0;
  stars [1].a := null;
  
  stars [1].v. X := 0.5;
  stars [1].v. Y := - 0.5;
  stars [1].v. z := 0;
  
  stars [1].Pos. X := - 500;
  stars [1].Pos. Y := - 500;
  stars [1].Pos. z := 150;
  
  stars [2].a := null;
  
  stars [2].v. X := 0.5;
  stars [2].v. Y := 0.5;
  stars [2].v. z := 0.0;
  
  stars [2].Pos. X := 500;
  stars [2].Pos. Y := - 500;
  stars [2].Pos. z := 0;
  
  stars [3].a := null;
  
  stars [3].v. X := - 0.5;
  stars [3].v. Y := 0.5;
  stars [3].v. z := 0.0;
  
  stars [3].Pos. X := 500;
  stars [3].Pos. Y := 500;
  stars [3].Pos. z := - 150;
  
  stars [4].a := null;
  
  stars [4].v. X := - 0.5;
  stars [4].v. Y := - 0.5;
  stars [4].v. z := 0;
  
  stars [4].Pos. X := - 500;
  stars [4].Pos. Y := 500;
  stars [4].Pos. z := 0;
  If graphic = True Then Begin
    grafikein;
    zoom := 1000;
  End;
End;
Procedure clearstars;
Begin
End;
Procedure drawstars;
Var i, j: Integer;
Begin
  If textm = True Then Begin
    ClrScr;
    WriteLn ('X:', stars [1].Pos. X: 3: 3);
    WriteLn ('Y:', stars [1].Pos. Y: 3: 3);
    WriteLn ('Z:', stars [1].Pos. z: 3: 3);
    WriteLn;
    WriteLn ('X:', stars [2].Pos. X: 3: 3);
    WriteLn ('Y:', stars [2].Pos. Y: 3: 3);
    WriteLn ('Z:', stars [2].Pos. z: 3: 3);
    WriteLn;
    WriteLn ('X:', stars [3].Pos. X: 3: 3);
    WriteLn ('Y:', stars [3].Pos. Y: 3: 3);
    WriteLn ('Z:', stars [3].Pos. z: 3: 3);
    WriteLn;
    WriteLn ('X:', stars [4].Pos. X: 3: 3);
    WriteLn ('Y:', stars [4].Pos. Y: 3: 3);
    WriteLn ('Z:', stars [4].Pos. z: 3: 3);
  End Else If graphic Then Begin
    For i := 1 To maxstars Do Begin
      PutPixel (Round (scalex (stars [i].Pos. X / zoom) ),
      Round (scaley (stars [i].Pos. Y / zoom) ), (i + 1) );
    End;
  End;
  
End;
Procedure simstars;
Var i, j, k: Integer;
  q, D, b: Real;
Begin
  clearstars;
  For i := 1 To maxstars Do Begin
    stars [i].a := null;               (* beschleunigung null *)
    For j := 1 To maxstars Do Begin
      If i <> j Then Begin
        q := (Sqr (stars [i].Pos. X - stars [j].Pos. X) +
        Sqr (stars [i].Pos. Y - stars [j].Pos. Y) +
        Sqr (stars [i].Pos. z - stars [j].Pos. z) );
        If q <> 0 Then Begin         (* kollision ?? *)
          b := 1000 / q;
          D := Sqrt (D);
          stars [i].a. X := stars [i].a. X + b * (stars [j].Pos. X - stars [i].Pos. X) / D;
          stars [i].a. Y := stars [i].a. Y + b * (stars [j].Pos. Y - stars [i].Pos. Y) / D;
          stars [i].a. z := stars [i].a. z + b * (stars [j].Pos. z - stars [i].Pos. z) / D;
        End Else Begin
          If textm Then WriteLn ('Kollision !!!') Else
            If graphic Then Begin
            End;
        End;
      End;
    End;
  End;
  For i := 1 To maxstars Do Begin
    vadd (stars [i].v, stars [i].a, stars [i].v);
  End;
  For i := 1 To maxstars Do Begin
    vadd (stars [i].Pos, stars [i].v, stars [i].Pos);
  End;
  drawstars;
End;
Begin
  ClrScr;
  init;
  Repeat
    simstars;
  Until KeyPressed;
  If graphic = True Then grafikaus;
End.