Unit sgraph2;
(*==========================================================================*
 *                                                                          *
 *                                                                          *
 *   Sgraph2 : erstellt am 17.7.1994                                        *
 *                                                                          *
 *                                                                          *
 * o Grafikmodus ein/aus                                                    *
 *                                                                          *
 * o Line-Clipping gegen Rechteck                                           *
 *                                                                          *
 * o graphics_error                                                                        *
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




Interface




Uses crt, graph, matrix44;

Function rad (deg: Real) : Real;
Procedure CohenSutherlandLineClipAndDraw (X0, Y0, X1, Y1: Real; win: t_win);
Procedure grafikein;
Procedure grafikaus;
Procedure graphics_error (s: String);




Implementation




Function rad (deg: Real) : Real;
Begin
  rad := (deg * Pi) / 180;
End;

Procedure grafikein;
Var gd, gm: Integer;
Begin
  gd := IBM8514; gm := IBM8514Hi;
  InitGraph (gd, gm, 'c:\tp70\bgi\');
End;

Procedure grafikaus;
Begin
  CloseGraph;
End;

Procedure graphics_error (s: String);
Begin
  WriteLn (s + Chr (7) );
  Halt (1);
End;

Procedure CohenSutherlandLineClipAndDraw;
Type
  edge = (Left, Right, Bottom, Top);
  outcode = Set Of edge;
Var
  accept, done: Boolean;
  outcode0, outcode1, outcodeOut: outcode;
  X, Y: Real;
  xh, yh, xmin, xmax, ymin, ymax: Real;
  
Procedure CompOutCode (X, Y: Real; Var code: outcode);
   Begin
     code := [];
     If Y > ymax Then code := [Top]
     Else If Y < ymin Then code := [Bottom];
     If X > xmax Then code := code + [Right]
     Else If X < xmin Then code := code + [Left];
   End;
Begin
  accept := False;
  done := False;

  xmin := win [1]; xmax := win [2];
  ymin := win [3]; ymax := win [4];
  xh := xmin + (xmax - xmin) / 2; yh := ymin + (ymax - ymin) / 2;
  
  X0 := X0 + xh; Y0 := - Y0 + yh;
  X1 := X1 + xh; Y1 := - Y1 + yh;
  
  
  CompOutCode (X0, Y0, outcode0); CompOutCode (X1, Y1, outcode1);
  
  Repeat
    If (outcode0 = [] ) And (outcode1 = [] ) Then
    Begin
      accept := True;
      done := True
    End
    Else If (outcode0 * outcode1) <> [] Then done := True
    Else
    Begin
      If outcode0 <> [] Then
        outcodeOut := outcode0
      Else
        outcodeOut := outcode1;
      If Top In outcodeOut Then
      Begin
        X := X0 + (X1 - X0) * (ymax - Y0) / (Y1 - Y0);
        Y := ymax
      End
      Else If Bottom In outcodeOut Then
      Begin
        X := X0 + (X1 - X0) * (ymin - Y0) / (Y1 - Y0);
        Y := ymin
      End
        Else If Right In outcodeOut Then
        Begin
          Y := Y0 + (Y1 - Y0) * (xmax - X0) / (X1 - X0);
          X := xmax
        End
          Else If Left In outcodeOut Then
          Begin
            Y := Y0 + (Y1 - Y0) * (xmin - X0) / (X1 - X0);
            X := xmin
          End;
      
      If outcodeOut = outcode0 Then
      Begin
        X0 := X; Y0 := Y;
        CompOutCode (X0, Y0, outcode0);
      End
      Else
      Begin
        X1 := X; Y1 := Y;
        CompOutCode (X1, Y1, outcode1);
      End
    End
  Until done;
  
  If accept Then Line ( Round (X0), Round (Y0), Round (X1), Round (Y1) );
  
End;



Var exitsave: pointer;
Procedure myexit; Far;
Begin
  ExitProc := exitsave;
  grafikaus
End;
Begin
  exitsave := ExitProc;
  ExitProc := @myexit;
End.