Unit rt_math;
{ version 0.9 }
{ $n+ $e-}
Interface

Uses rt_types;

Function errepsilon (X: Double): Double;
Function RT_solve_qgl (p, q: Double; Var l1, l2: Double): Boolean;
Function RT_solve_qglabc (a, b, c: Double; Var l1, l2: Double): Boolean;
Function pow (X, Y: Double): Double;
Function max3Real (a, b, c: Double): Double;
Function Min3Real (a, b, c: Double): Double;


Procedure rot ( p: rt_point; a, b, c: Double; Var pt: rt_point);

Procedure p2vector (p1, p2: RT_point; Var v: RT_vector);
Procedure p2ray (p1, p2: RT_point; Var v: RT_ray);
Procedure ray2point (X: rt_ray; t: Double; Var p: rt_point);
Procedure vzero (Var a: RT_vector);
Procedure vinit (ix, iy, iz: Double; Var a: RT_vector);
Procedure pinit (ix, iy, iz: Double; Var p: RT_point);
Procedure vnorm (v: RT_vector; Var n: RT_vector);
Procedure cinit (ix, iy, iz: Double; Var a: RT_color);
Procedure cnorm (c: RT_color; Var nc: RT_color);
Procedure cmul (k: Double; a: RT_color; Var c: rt_color);
Procedure cmul2 (a, b: RT_color; Var c: rt_color);
Procedure cadd (a, b: RT_color; Var c: RT_color);
Function vcosw (v, w: RT_vector): Double;
Function vdot (v, w: RT_vector): Double;
Procedure vcross (v, w: rt_vector; Var n: RT_vector);
Function vcos (v, w: RT_vector): Double;
Function vabs (v: RT_vector): Double;
Function distance (a,b: RT_point): Double;


Procedure vadd (a, b: RT_vector; Var c: RT_vector);
Procedure vsub (a, b: RT_vector; Var c: RT_vector);
Procedure vdiv (k: Double; a: RT_vector; Var c: RT_vector);
Procedure vmul (k: Double; a: RT_vector; Var c: RT_vector);
Procedure Write1r (s: String; r: Double);
Procedure writepoint (s: String; a: RT_point);
Procedure writecolor (s: String; a: RT_color);
Procedure writeray (s: String; X: RT_ray);
procedure writedeg(s:string; w:double);
Function det2 (a11, a12,
              a21, a22: Double): Double;
Function det3 (a11, a12, a13,
              a21, a22, a23,
              a31, a32, a33: Double): Double;
Procedure writevector (s: String; a: RT_vector);

Function lround (s: Single) : LongInt;
Function mul4b (b1, b2, b3, b4: Byte): LongInt;
Function IntToStr (i: LongInt): String;

Implementation
Uses crt;
Function IntToStr (i: LongInt): String;
{ Convert any Integer type to a string }
Var
  s: String [11];
Begin
  Str (i, s);
  IntToStr := s;
End;
Function errepsilon (X: Double): Double;
Begin
  If Abs (X) < EPSILON Then errepsilon := 0 Else errepsilon := X;
End;
Procedure writevector (s: String; a: RT_vector);
Begin
  ClrEol; WriteLn (s, '( ', a. X: 3: 3, ' / ', a. Y: 3: 3, ' / ', a. z: 3: 3, ' )');
End;
Procedure ray2point;
Begin
  vmul (t, X. v, X. v);
  vadd (rt_vector (X. q), X. v, rt_vector (p) );
End;
Procedure writepoint (s: String; a: RT_point);
Begin
  ClrEol; WriteLn (s, '( ', a. X: 3: 3, ' | ', a. Y: 3: 3, ' | ', a. z: 3: 3, ' )');
End;
Procedure writecolor (s: String; a: RT_color);
Begin
  ClrEol; WriteLn (s, '( R:', a. r: 3: 3, ' G:', a. g: 3: 3, ' B:', a. b: 3: 3, ' )');
End;
Procedure writeray (s: String; X: RT_ray);
Begin
  WriteLn (s);
  writepoint ('Q:=', X. q);
  writevector ('v:=', X. v);
End;

Procedure p2vector (p1, p2: RT_point; Var v: RT_vector);
Begin
  vinit (p2.X - p1.X, p2.Y - p1.Y, p2.z - p1.z, v);
End;
Procedure p2ray (p1, p2: RT_point; Var v: RT_ray);
Begin
  vinit (p2.X - p1.X, p2.Y - p1.Y, p2.z - p1.z, v. v);
  vnorm (v. v, v. v);
  v. q := p1;
End;
Function pow (X, Y: Double) : Double;
Begin
  If X = 0 Then Begin pow := 0; Exit End;
  X := Ln (X) * Y; If X < - 10 Then pow := 0 Else pow := Exp (X);
End;
Function max3Real (a, b, c: Double): Double;
Begin
  If a > b Then Begin
    If a > c Then Begin
      max3Real := a;
    End Else Begin
      max3Real := c;
    End;
  End Else Begin
    If b > c Then Begin
      max3Real := b
    End Else Begin
      max3Real := c
    End;
  End;
End;
Function Min3Real (a, b, c: Double): Double;
Begin
  If a < b Then Begin
    If a < c Then Begin
      Min3Real := a;
    End Else Begin
      Min3Real := c;
    End;
  End Else Begin
    If b < c Then Begin
      Min3Real := b
    End Else Begin
      Min3Real := c
    End;
  End;
End;
Function RT_solve_qgl (p, q: Double; Var l1, l2: Double): Boolean;
Var D: Double;
Begin
  RT_solve_qgl := True;
  D := Sqr (p) / 4 - q;
  If D > 0 Then
  Begin
    l1 := - p / 2 - Sqrt (D);
    l2 := - p / 2 + Sqrt (D);
  End
  Else
    rt_solve_qgl := False;
End;
Function RT_solve_qglabc (a, b, c: Double; Var l1, l2: Double): Boolean;
Var D: Double;
Begin
  RT_solve_qglabc := True;
  D := Sqr (b) - 4 * a * c;
  If D > 0 Then
  Begin
    l1 := ( - b - Sqrt (D) ) / (2 * a);
    l2 := ( - b + Sqrt (D) ) / (2 * a);
  End
  Else
    rt_solve_qglabc := False;
End;
Procedure vnorm (v: RT_vector; Var n: RT_vector);
Begin
  vdiv (Sqrt (Sqr (v. X) + Sqr (v. Y) + Sqr (v. z) ), v, n);
End;
Procedure cnorm (c: RT_color; Var nc: RT_color);
Var D: Double;
Begin
  D := (Sqrt (Sqr (c. r) + Sqr (c. g) + Sqr (c. b) ) );
  nc. r := c. r / D;
  nc. g := c. g / D;
  nc. b := c. b / D;
End;
Function vcosw (v, w: RT_vector): Double;
Begin
  vcosw := vdot (v, w) / (vdot (v, v) * vdot (w, w) );
End;
Function det2 (a11, a12,
              a21, a22: Double): Double;
Begin
  det2 := a11 * a22 - a12 * a21;
End;
Function det3 (a11, a12, a13,
              a21, a22, a23,
              a31, a32, a33: Double): Double;
Begin
  det3 := a11 * a22 * a33 + a12 * a23 * a31 + a13 * a21 * a32
  - a13 * a22 * a31 - a11 * a23 * a32 - a12 * a21 * a33;
End;
Procedure vzero (Var a: RT_vector);
Begin
  a. X := 0;
  a. Y := 0;
  a. z := 0;
End;
Procedure vinit (ix, iy, iz: Double; Var a: RT_vector);
Begin
  With a Do Begin
    X := ix; Y := iy; z := iz;
  End;
End;
Procedure cinit (ix, iy, iz: Double; Var a: RT_color);
Begin
  With a Do Begin
    r := ix; g := iy; b := iz;
  End;
End;
Procedure pinit (ix, iy, iz: Double; Var p: RT_point);
Begin
  p. X := ix; p. Y := iy; p. z := iz;
End;
Procedure vadd (a, b: RT_vector; Var c: RT_vector);
Begin
  c. X := a. X + b. X;
  c. Y := a. Y + b. Y;
  c. z := a. z + b. z;
End;
Procedure cadd (a, b: RT_color; Var c: RT_color);
Var h: rt_color;
Begin
  h. r := a. r + b. r;
  h. g := a. g + b. g;
  h. b := a. b + b. b;
  If h. r > 1 Then h. r := 1;
  If h. g > 1 Then h. g := 1;
  If h. b > 1 Then h. b := 1;
  c := h;
End;
Procedure vsub (a, b: RT_vector; Var c: RT_vector);
Begin
  c. X := a. X - b. X;
  c. Y := a. Y - b. Y;
  c. z := a. z - b. z;
End;
Function vabs (v: RT_vector): Double;
Begin
  vabs := Sqrt (v. X * v. X + v. Y * v. Y + v. z * v. z);
End;
Function distance (a,b: RT_point): Double;
var dx,dy,dz:double;
begin
     dx:=a.x-b.x;
     dy:=a.y-b.y;
     dz:=a.z-b.z;
     distance:=sqrt(dx*dx+dy*dy+dz*dz);
end;
Function vdot (v, w: RT_vector): Double;
Begin
  vdot := v. X * w. X + v. Y * w. Y + v. z * w. z;
End;
Procedure vcross (v, w: rt_vector; Var n: RT_vector);
Begin
  n. X := v. Y * w. z - v. z * w. Y;
  n. Y := - v. X * w. z + v. z * w. X;
  n. z := v. X * w. Y - v. Y * w. X;
End;
Function vcos (v, w: RT_vector): Double;
Var h: Double;
Begin
  h := vdot (v, w);
  If h <> 0 Then vcos := h / (vabs (v) * vabs (w) ) Else Begin WriteLn ('vcos: Division by Zero'); Halt (10); End;
End;

Procedure vdiv (k: Double; a: RT_vector; Var c: RT_vector);
Begin
  If k = 0 Then Begin c := INFINITE_VECTOR; Exit End;
  c. X := a. X / k;
  c. Y := a. Y / k;
  c. z := a. z / k;
End;
Procedure vmul (k: Double; a: RT_vector; Var c: RT_vector);
Begin
  c. X := k * a. X;
  c. Y := k * a. Y;
  c. z := k * a. z;
End;
Procedure cmul (k: Double; a: RT_color; Var c: RT_color);
Begin
  c. r := k * a. r;
  c. g := k * a. g;
  c. b := k * a. b;
End;
Procedure cmul2 (a, b: RT_color; Var c: RT_color);
Begin
  c. r := a. r * b. r;
  c. g := a. g * b. g;
  c. b := a. b * b. b;
End;
Procedure Write1r;
Begin ClrEol; WriteLn (s, r: 3: 3) End;
procedure writedeg(s:string; w:double);
begin
     writeln(s,w*180/PI:3:3,'ø');
end;
Function lround (s: Single) : LongInt;
Begin
  If s > MaxLongInt Then lround := MaxLongInt Else
    If s < - MaxLongInt Then lround := - MaxLongInt Else lround := Round (s);
End;
Function mul4b (b1, b2, b3, b4: Byte): LongInt; Assembler;
Asm
  mov AL, b1; mul b2; push AX; mov AL, b3; mul b4; pop BX; mul BX;
End;

Procedure rot ( p: rt_point; a, b, c: Double; Var pt: rt_point);
Var sa, ca, sb, cb, sc, cc: Double;
Begin
  sa := Sin (a); sb := Sin (b); sc := Sin (c);
  ca := Cos (a); cb := Cos (b); cc := Cos (c);
  
  pt. Y := p. Y * ca -  p. X * sa;
  pt. X := pt. X * cb +  p. z * sb;
  pt. z := p. z * cb - pt. X * sb;
  pt. Y := pt. Y * cc + pt. z * sc;
  pt. z := pt. z * cc - pt. Y * sc;
  (*
  writepoint('p=',p);
  writepoint('pt=',pt);
  *)
End;

Begin
End.