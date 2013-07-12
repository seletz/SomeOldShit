unit matrix;
INTERFACE
Uses crt;
{$I typen.inc}
Function vabs (a: tv1X4): Real;
Procedure vnorm (a: tv1X4; Var an: tv1X4);
Procedure vcross (a, b: tv1X3; Var c: tv1X3);
Procedure m4mul (a: tm4X4; b: tv1X4; var c: ptv1X4);
Procedure m3mul (a: tm3X3; b: tv1X3; var c: ptv1X3);
Function vdotv (a, b: tv1X4): Real;
Procedure mdotm (a, b: tm4X4; Var c: tm4X4);
Procedure vdotm (a: tv1X3; b: tm3X3; Var c: tv1X3);
Procedure mdotv (a: tm3X3; b: tv1X3; Var c: tv1X3);
Function vcos (a, b: tv1X4): Real;
Function vcosn (a, b: tv1X4): Real;
IMPLEMENTATION
(*=========================================*
 *                                         *
 *                      _                  *
 *         Absolutwert |A|                 *
 *                                         *
 *                                         *
 *=========================================*)
Function vabs (a: tv1X4): Real;
Begin
  vabs := Sqrt (a [0] * a [0] + a [1] * a [1] + a [2] * a [2] +a [3] * a [3])
End;
(*=========================================*
 *              _                          *
 *              A                          *
 *             ---                         *
 *              _                          *
 *             |A|                         *
 *=========================================*)
Procedure vnorm (a: tv1X4; Var an: tv1X4);
Var t: Real;
Begin
  t := vabs (a);
  If t <> 0 Then Begin
    an [0] := a [0] / t;
    an [1] := a [1] / t;
    an [2] := a [2] / t;
    an [3] := a [3] / t;
  End;
End;
(*=========================================*
 *                                         *
 *                       _   _             *
 *         Kreuzprodukt  A x B             *
 *                                         *
 *                                         *
 *=========================================*)
Procedure vcross (a, b: tv1X3; Var c: tv1X3);
Begin
  c [0] := + a [1] * b [2] - b [1] * a [2];
  c [1] := - a [0] * b [2] + b [0] * a [2];
  c [2] := + a [0] * b [1] - b [0] * a [1];
End;
Procedure m4mul (a: tm4X4; b: tv1X4; var c: ptv1X4);
Begin
  c^ [0] := a [0, 0] * b [0] + a [0, 1] * b [1] + a [0, 2] * b [2] + a [0, 3] * b [3];
  c^ [1] := a [1, 0] * b [0] + a [1, 1] * b [1] + a [1, 2] * b [2] + a [1, 3] * b [3];
  c^ [2] := a [2, 0] * b [0] + a [2, 1] * b [1] + a [2, 2] * b [2] + a [2, 3] * b [3];
  c^ [3] := a [3, 0] * b [0] + a [3, 1] * b [1] + a [3, 2] * b [2] + a [3, 3] * b [3];
End;
Procedure m3mul (a: tm3X3; b: tv1X3; var c: ptv1X3);
Begin
  c^ [0] := a [0, 0] * b [0] + a [0, 1] * b [1] + a [0, 2] * b [2];
  c^ [1] := a [1, 0] * b [0] + a [1, 1] * b [1] + a [1, 2] * b [2];
  c^ [2] := a [2, 0] * b [0] + a [2, 1] * b [1] + a [2, 2] * b [2];
End;
(*=========================================*
 *                                         *
 *                       _   _             *
 *         Skalarprodukt A . B             *
 *                                         *
 *                                         *
 *=========================================*)
Function vdotv (a, b: tv1X4): Real;
Var t: Real;
Begin
  t := a [0] * b [0] + a [1] * b [1] + a [2] * b [2] +a [3] * b [3];
End;
Procedure mdotm (a, b: tm4X4; Var c: tm4X4);
Var i, j: Integer;
Begin
  For j := 0 To 3 Do
    For i := 0 To 3 Do Begin
      c [j, i] := a [0, i] * b [j, 0] + a [1, i] * b [j, 1] + a [2, i] * b [j, 2];
    End;
End;
Procedure vdotm (a: tv1X3; b: tm3X3; Var c: tv1X3);
Var i: Integer;
Begin
  For i := 0 To 2 Do Begin
    c [i] := a [i] * b [i, 0] + a [i] * b [i, 1] + a [i] * b [i, 2];
  End;
End;
Procedure mdotv (a: tm3X3; b: tv1X3; Var c: tv1X3);
Var i: Integer;
Begin
  For i := 0 To 2 Do Begin
    c [i] := a [0, i] * b [i] + a [1, i] * b [i] + a [2, i] * b [i];
  End;
End;
(*=========================================*
 *                                         *
 *                                 _    _  *
 *         cosinus des winkels zw. A u. B  *
 *                                         *
 *                                         *
 *=========================================*)
Function vcos (a, b: tv1X4): Real;
Begin
  vcos := vdotv (a, b) / (vabs (a) * vabs (b) );
End;
Function vcosn (a, b: tv1X4): Real;
Begin
  vcosn := vdotv (a, b);
End;
Begin
End.
