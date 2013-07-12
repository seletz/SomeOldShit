Program rec_simp;
Uses rt_types, rt_math, rt_tga, rt_output;
Const
  ebene_t = 1;
  kugel_t = 2;

  num_k = 1;
  Crot:rt_color=(r:1; g:0; b:0);
  Cgrun:rt_color=(r:0; g:1; b:0);
  Cblau:rt_color=(r:0; g:0; b:1);
  Cgelb:rt_color=(r:1; g:1; b:0);
  Ccyan:rt_color=(r:0; g:1; b:1);
  Cmangenta:rt_color=(r:1; g:0; b:1);
  Cweiss:rt_color=(r:1; g:1; b:1);
  Cschwarz:rt_color=(r:0; g:0; b:0);
  Cgrau:rt_color=(r:0.5; g:0.5; b:0.5);



Type
  material_p = ^material;
  material = Record
               farbe: rt_color;
               reflection, refraction, phong, ambient, diffuse: Double
             End;
  kugel_p = ^kugel;
  kugel = Record
            mittelpunkt: v3t;
            radius_2: Double;
            material: material_p;
          End;
  ebene_p = ^ebene;
  ebene = Record
            punkt, normale: v3t;
            material: material_p;
          End;
Var
  koerper: Array [1..num_k] Of pointer;
  koerpertyp: Array [1..num_k] Of Integer;
Function Root (p, q: Double): Double;
Var t1, t2: Double;
Begin
  t1 := 0;
  t2 := 0;
  
  p := p / 2;
  
  t1 := - p + Sqrt (p * p - q);
  t2 := - p - Sqrt (p * p - q);
  
  If t1 <> t2 Then
    If t1 > t2 Then Root := t2 Else Root := t1
  Else Root := t1;
End;
Function Kugel_root (R_quadrat, M, Q, V: Double): Double;
Var t1, t2: Double;
Begin
  If v <> 0 Then Begin
    t1 := - q + Sqrt ( (q * q + r_quadrat) / (v * v) ) * v + M;
    t2 := - q - Sqrt ( (q * q + r_quadrat) / (v * v) ) * v + M;
    If t1 = t2 Then Kugel_Root := t1 / v Else
      If t1 > t2 Then Kugel_Root := t2 / v Else Kugel_Root := t1 / v
  End Else Begin
    Kugel_Root := - 1;
  End;
End;
Function Mat_init(f:rt_color; amb,diff,sp,tr,ph:double):material_p;
var temp:material_p;
begin
     with temp^do begin
          Farbe:=f;
          ambient:=amb;
          diffuse:=diff;
          reflection:=sp;
          refraction:=tr;
          phong:=ph
     end;
end;
Function Kugel_init (m: v3t; radius: Double; mat: material_p): kugel_p;
Var temp: kugel_p;
Begin
  temp := New (kugel_p);
  With temp^ Do Begin
    Mittelpunkt := m;
    Radius_2 := radius * radius;
    material := mat
  End;
End;

Begin
     koerper[1]:=Kugel_init(NULL,1,mat_init(CROT,0.3,0.7,0,0,1000));
End.