Unit rayun;
Interface
Uses matrix44;
Type
  p_ray = ^o_ray;
  o_ray = Object
            q, v: vektor4;
            Constructor init (iq, iv: p_vektor4);

            Function ray_to_point (lambda: Double; p: p_vektor4): p_vektor4;
          End;

Implementation
Constructor o_ray. init (iq, iv: p_vektor4);
Begin
     copy_vektor(iq,@q);
     copy_vektor(iv,@v);
     vnorm(@v,@v);
End;

Function o_ray. ray_to_point (lambda: Double; p: p_vektor4): p_vektor4;
Var
  vt: vektor4;
Begin
  vadd (@q, vmul (lambda, @v, @vt), p);
  ray_to_point := p;
End;
Begin
End.