Unit objektun;

Interface
Uses crt, util, matrix44, rayun, listeun;

Type
  t_otyp = (Licht, Ebene, Ebene2, Kugel);
  
  p_mat  = ^t_mat;
  t_mat  = Record
             
             kd, ks, kr, kt, phong: Double;
             eta_r, eta_r_quadrat: Double;
             Od, Os: p_color;
             
           End;
  t_flaps = Record
              onoff: Array [1..6] Of Boolean;
              flaps: Array [1..6] Of Double;
            End;
  
  p_objekt = ^o_objekt;
  p_oliste = ^o_oliste;
  
  o_oliste = Object (o_liste)
               
               Constructor init (iobjekt: p_objekt);
               Destructor done; Virtual;
               
               Function insert_new (iobjekt: p_objekt): p_oliste;
               Function gimme_next: p_objekt;
             End;
  
  o_objekt = Object
               typ: Set Of t_otyp;
               Name: String;
               material: p_mat;
               
               reflective, refractive: Boolean;
               inside: Boolean;
               
               Constructor init (imat: p_mat; iname: String);
               Destructor done;
               
               Function berechne_schnitt (ray: p_ray; Var l: Double; s: p_vektor4; original: Boolean): Boolean; Virtual;
               Function berechne_normale (p, n: p_vektor4): p_vektor4; Virtual;
             End;
  p_licht = ^o_licht;
  o_licht = Object (o_objekt)
              Ip: p_color;
              position: vektor4;
              Constructor init (ipos: p_vektor4; iIp: p_color; iname: String);
              Function gimme_Ip (P: p_vektor4; Var oip: Color): p_color; Virtual;
            End;
  p_spot_licht = ^o_spot_licht;
  o_spot_licht = Object (o_licht)
                   cos_gamma: Double;
                   power: Double;
                   point_at: vektor4;
                   Constructor init (ipos, ipointat: p_vektor4; gamma: Double; ipow: Double; iIp: p_color; iname: String);
                   Function gimme_Ip (P: p_vektor4; Var oip: Color): p_color; Virtual;
                 End;
  p_flap_licht = ^o_flap_licht;
  o_flap_licht = Object (o_licht)
                   flaps: t_flaps;
                   Constructor init (ipos: p_vektor4; iflaps: t_flaps; iIp: p_color; iname: String);
                   Function gimme_Ip (P: p_vektor4; Var oip: Color): p_color; Virtual;
                 End;
  p_ebene = ^o_ebene;
  o_ebene = Object (o_objekt)
              A, B, C, D: Double;
              P, N: vektor4;
              
              Constructor init (p1, p2, p3: p_vektor4; imat: p_mat; iname: String);
              Function berechne_schnitt (ray: p_ray; Var l: Double; s: p_vektor4; original: Boolean): Boolean; Virtual;
              Function berechne_normale (ps, n_: p_vektor4): p_vektor4; Virtual;
            End;
  p_ebene2 = ^o_ebene2;
  o_ebene2 = Object (o_objekt)
               qr1, r1, r2, r3, N: vektor4;
               h1, h2, h3: Double;
               mu, mv: matrix4;
               ok: Boolean;
               Constructor init (p1, p2, p3: p_vektor4; imat: p_mat; iname: String);
               Procedure gimme_uv (ray: p_ray; D: Double; Var u, v: Double; original: Boolean);
               Function uv_ok (u, v: Double): Boolean; Virtual;
               Function berechne_schnitt (ray: p_ray; Var l: Double; s: p_vektor4; original: Boolean): Boolean; Virtual;
               Function berechne_normale (ps, n_: p_vektor4): p_vektor4; Virtual;
             End;
  p_3eck = ^o_3eck;
  o_3eck = Object (o_ebene2)
             Function uv_ok (u, v: Double): Boolean; Virtual;
           End;
  p_4eck = ^o_4eck;
  o_4eck = Object (o_ebene2)
             Function uv_ok (u, v: Double): Boolean; Virtual;
           End;
  p_kreis = ^o_kreis;
  o_kreis = Object (o_ebene2)
              Function uv_ok (u, v: Double): Boolean; Virtual;
            End;
  p_kugel = ^o_kugel;
  o_kugel = Object (o_objekt)
              r_quadrat: Double;
              m, q_sub_m: vektor4;
              h: Double;
              h_ok: Boolean;
              Constructor init (im: p_vektor4; ir: Double; imat: p_mat; iname: String);
              Function berechne_schnitt (ray: p_ray; Var l: Double; s: p_vektor4; original: Boolean): Boolean; Virtual;
              Function berechne_normale (p, n: p_vektor4): p_vektor4; Virtual;
            End;
(*
  p_raum = ^o_raum;
  o_raum = object (o_objekt)
  					r1,r2,r3,r4:vektor4;
            qt:vektor4;

            Constructor init (ir1,ir2,ir3,ir4: p_vektor4; imat: p_mat; iname: String);
            Function berechne_schnitt (ray: p_ray; Var l: Double; s: p_vektor4; original: Boolean): Boolean; Virtual;
            Function berechne_normale (p, n: p_vektor4): p_vektor4; Virtual;
  				 end;
*)
Implementation
Procedure objekt_error (s: String);
Begin
  WriteLn ('Fehler in Unit "ObjektUN" :' + Chr ($07) );
  WriteLn;
  WriteLn (s);
  Halt (1);
End;

(*=========================================*
 *                                         *
 *                                         *
 *   Liste von Objekten                    *
 *                                         *
 *                                         *
 *=========================================*)
Constructor o_oliste. init;
Begin
  Inherited init;
  
  data := iobjekt;
End;
Destructor o_oliste. done;
Var
  temp: p_liste;
Begin
  If first^. next = Nil Then Exit;
  
  setfirst;
  
  While Not (actual = Nil) Do
  Begin
    temp := actual^. next;
    p_objekt (actual^. data)^. done;
    Dispose (actual^. data);
    actual := temp;
  End;
  
  Inherited done;
End;

Function o_oliste. insert_new (iobjekt: p_objekt): p_oliste;
Begin
  insert_new := p_oliste (Inherited insert_new (iobjekt) );
End;
Function o_oliste. gimme_next: p_objekt;
Begin
  gimme_next := p_objekt (Inherited gimme_next)
End;
(*=========================================*
 *                                         *
 *                                         *
 *    Objekt-Grundtyp                      *
 *                                         *
 *                                         *
 *=========================================*)
Constructor o_objekt. init;
Begin
  material := imat;
  Name := iname;
  
  material^. eta_r_quadrat := Sqr (material^. eta_r);
  
  refractive := (material^. kt > 0);
  reflective := (material^. kr > 0);
  inside := False;
End;
Destructor o_objekt. done;
Begin End;
Function o_objekt. berechne_schnitt (ray: p_ray; Var l: Double; s: p_vektor4; original: Boolean): Boolean;
Begin End;
Function o_objekt. berechne_normale (p, n: p_vektor4): p_vektor4;
Begin End;
(*=========================================*
 *                                         *
 *                                         *
 *    Punktlichtquelle                     *
 *                                         *
 *                                         *
 *=========================================*)
Constructor o_licht. init;
Begin
  typ := [Licht];
  Name := iname;
  Ip := iip;
  copy_vektor (ipos, @position);
End;
Function o_licht. gimme_Ip (p: p_vektor4; Var oip: Color): p_color;
Begin
  oip [1] := Ip^ [1];
  oip [2] := Ip^ [2];
  oip [3] := Ip^ [3];
End;
(*=========================================*
 *                                         *
 *                                         *
 *     Spotlight                           *
 *                                         *
 *                                         *
 *=========================================*)
Constructor o_spot_licht. init;
Begin
  typ := [Licht];
  
  Inherited init (ipos, iip, iname);
  
  p2v (@position, ipointat, @point_at);
  vnorm (@point_at, @point_at);
  cos_gamma := Cos (gamma * RAD);
  power := ipow;
End;
Function o_spot_licht. gimme_Ip (p: p_vektor4; Var oip: Color): p_color;
Var
  L: vektor4;
  cos_w, k: Double;
Begin
  p2v (@position, p, @L);
  vnorm (@l, @l);
  cos_w := vdotv (@L, @point_at);
  If cos_w >= cos_gamma Then Begin
    k := pow (cos_w, power);
    oip [1] := k * Ip^ [1];
    oip [2] := k * Ip^ [2];
    oip [3] := k * Ip^ [3];
    gimme_ip := p_color (@Ip)
  End Else Begin
    oip := c_black;
    gimme_ip := @c_black
  End
End;
(*=========================================*
 *                                         *
 *                                         *
 *     Licht mit Flap-Control              *
 *                                         *
 *                                         *
 *=========================================*)
Constructor o_flap_licht. init;
Begin
  typ := [Licht];
  
  Inherited init (ipos, iip, iname);
  
  flaps := iflaps;
End;
Function o_flap_licht. gimme_Ip (p: p_vektor4; Var oip: Color): p_color;
Var
  i: Integer;
  accept: Boolean;
Begin
  accept := True;
  i := 0;
  With flaps Do Begin
    Repeat
      Inc (i);
      If onoff [i] Then Begin
        If i <= 3  Then Begin
          accept := p^ [i] > flaps [i]
        End Else Begin
          accept := p^ [i - 3] < flaps [i]
        End
      End;
    Until (i = 6);
  End;
  If accept Then Begin
    oip [1] := Ip^ [1];
    oip [2] := Ip^ [2];
    oip [3] := Ip^ [3];
    gimme_ip := p_color (@Ip)
  End Else Begin
    oip := c_black;
    gimme_ip := @c_black
  End;
End;
(*=========================================*
*                                         *
*                                         *
*     Ebenetyp                            *
*                                         *
*                                         *
*=========================================*)
Constructor o_ebene. init;
Var
  v1, v2: vektor4;
Begin
  Inherited init (imat, iname);
  typ := [Ebene];
  
  copy_vektor (p1, @P);
  p2v (p1, p2, @v1);
  p2v (p1, p3, @v2);
  
  Vcross (@v1, @v2, @n);
  A := N [1]; B := N [2]; C := N [3]; D := - A * p1^ [1] - B * p1^ [2] - C * p1^ [3];
  
End;
Function o_ebene. berechne_schnitt (ray: p_ray; Var l: Double; s: p_vektor4; original: Boolean): Boolean;
Var
  v: vektor4;
  ndotv: Double;
Begin
  (*  Ebene:
  *  aus (X-P).N=0   folgt mit X=Q+tV :
  *
  *         N.V         N.V
  *  t= - -------  = - ------
  *        N.(Q-P)      N.PQ
  *)
  {  vsub (@ray^.Q, @P, @V);}
  ndotv := vdotv (@N, @ray^. V);
  If Abs (ndotv) > epsilon Then
  Begin
    {    l := -  vdotv(@N, @V) / ndotv;}
    l := - (D + vdotv (@ray^. Q, @N) ) / ndotv;
    berechne_schnitt := l > epsilon;
    ray^. ray_to_point (l, s);
  End  Else Begin
    berechne_schnitt := False;
    l := - 1
  End
End;
Function o_ebene. berechne_normale (ps, n_: p_vektor4): p_vektor4;
Begin
  copy_vektor (@N, n_);
  berechne_normale := @N;
End;
 (*=========================================*
  *                                         *
  *                                         *
  *     Ebenetyp 2                          *
  *                                         *
  *                                         *
  *=========================================*)
Constructor o_ebene2. init;
Var
  v1, v2: vektor4;
Begin
  Inherited init (imat, iname);
  typ := [Ebene2];
  
  copy_vektor (p1, @r1);
  copy_vektor (p2, @r2);
  copy_vektor (p3, @r3);
  
  vcross (@r2, @r3, @n);
  vnorm (@n, @n);
  
  h1 := r2 [2] * r3 [3] - r3 [2] * r2 [3];
  h2 := r2 [1] * r3 [3] - r3 [1] * r2 [3];
  h3 := r2 [1] * r3 [2] - r3 [1] * r2 [2];
  
  ok := False;
  mzero (@mu);
  mzero (@mv);
End;
Procedure o_ebene2. gimme_uv (ray: p_ray; D: Double; Var u, v: Double; original: Boolean);
Var
  du, dv: Double;
  m: matrix4;
Begin
  If original Then Begin
    If Not ok Then Begin
      ok := True;
      put_col (2, @qr1, @mu);
      put_col (3, @r3, @mu);
      
      put_col (2, @r2, @mv);
      put_col (3, @qr1, @mv);
    End;
    put_col (1, @ray^. v, @mu);
    put_col (1, @ray^. v, @mv);
    du := det3 (@mu);
    dv := det3 (@mv);
  End Else Begin
    mzero (@m);
    
    put_col (1, @ray^. v, @m);
    put_col (2, @qr1, @m);
    put_col (3, @r3, @m);
    
    put_col (1, @ray^. v, @m);
    put_col (2, @r2, @m);
    put_col (3, @qr1, @m);
    du := det3 (@m);
    dv := det3 (@m);
  End;
  
  u := du / D; v := dv / D;
  
End;
Function o_ebene2. uv_ok (u, v: Double): Boolean;
Begin
  uv_ok := True;
End;
Function o_ebene2. berechne_schnitt (ray: p_ray; Var l: Double; s: p_vektor4; original: Boolean): Boolean;
Var
  D, u, v: Double;
Begin
  {  If Not ok Then Begin
  ok := True;}
  vsub (@r1, @ray^. q, @qr1);
  {  End;}
  
  D := - ray^. v [1] * h1 + ray^. v [2] * h2 - ray^. v [3] * h3;
  
  If Abs (D) > 0 Then
  Begin

    gimme_uv (ray, D, u, v, original);

    If not uv_ok (u, v) Then
    Begin
      l := - 1;
      berechne_schnitt := False;
    End Else
    Begin
      l := ( - qr1 [1] * h1 + qr1 [2] * h2 - qr1 [3] * h3) / D;
      berechne_schnitt := l > epsilon;
      ray^. ray_to_point (l, s);
    End;
  End Else
  Begin
    l := - 1;
    berechne_schnitt := False;
  End;
End;
Function o_ebene2. berechne_normale (ps, n_: p_vektor4): p_vektor4;
Begin
  copy_vektor (@N, n_);
  berechne_normale := @N;
End;
(*=========================================*
 *                                         *
 *                                         *
 *      Dreieck                            *
 *                                         *
 *                                         *
 *=========================================*)
Function o_3eck. uv_ok (u, v: Double): Boolean;
Begin
  uv_ok := (u > 0) And (v > 0) And (u < 1) And (v < 1) And (u + v < 1);
End;
(*=========================================*
 *                                         *
 *																				 *
 *     Viereck                             *
 *                                         *
 *                                         *
 *=========================================*)
Function o_4eck. uv_ok (u, v: Double): Boolean;
Begin
  uv_ok := (u > 0) And (v > 0) And (u < 1) And (v < 1);
End;
(*=========================================*
 *                                         *
 *                                         *
 *       Scheibe flach, kreisfîrmig        *
 *                                         *
 *                                         *
 *=========================================*)
Function o_kreis. uv_ok (u, v: Double): Boolean;
Begin
  uv_ok := (u * u + v * v <= 1);
End;
(*=========================================*
 *                                         *
 *                                         *
 *     Kugeltyp                            *
 *                                         *
 *                                         *
 *=========================================*)
Constructor o_kugel. init;
Begin
  Inherited init (imat, iname);
  If ir <> 0 Then
    r_quadrat := ir * ir
  Else
    objekt_error ('O_kugel: Radius=0!');
  copy_vektor (im, @m);
  
  h := 0;
  h_ok := False;
  
  typ := [Kugel];
End;
Function o_kugel. berechne_schnitt (ray: p_ray; Var l: Double; s: p_vektor4; original: Boolean): Boolean;
Var
  a, b, c, w, t1, t2: Double;
  vt:vektor4;
Begin
  {
  Kugel:
  0=t˝V˝+2tV(Q-M)+Q˝+M˝-2MQ-r˝
  }
  a := Sqr (ray^. v  [1] ) + Sqr (ray^. v  [2] ) + Sqr (ray^. v  [3] );

  If original Then Begin
    If Not h_ok Then Begin
      h_ok := True;
      vsub (@ray^. q, @m, @q_sub_m);
      h := vdotv(@q_sub_M,@q_sub_m) - r_quadrat;
    End;
    c := h;
    b := 2 * vdotv(@ray^.v,@q_sub_m);
  End Else Begin
    vsub (@ray^. q, @m, @vt);
    b := 2 * vdotv(@ray^.v,@vt);
    c := vdotv(@vt,@vt) - r_quadrat;
  End;
  w := b * b - 4 * a * c;
  If w >= 0 Then Begin
    berechne_schnitt := True;
    If w > 0 Then Begin
      w := Sqrt (w);
      t1 := - b + w;
      t2 := - b - w;
      inside := ( (t1 > 0) And (t2 < 0) ) Or ( (t1 < 0) And (t2 > 0) );
      t1 := Min (t1, t2);
      t1 := t1 / (2 * a);
    End Else
      { Strahl berÅhrt Kugel nur in einem Punkt }
      t1 := - b / (2 * a);
    ray^. ray_to_point (t1, s);
    l := t1;
  End Else Begin
    berechne_schnitt := False;
    l := - 1
  End
End;
Function o_kugel. berechne_normale (p, n: p_vektor4): p_vektor4;
Begin
  If Not inside Then
    n := p2v (@m, p, n)
  Else
    n := p2v (p, @m, n);
  berechne_normale := vnorm (n, n);
End;
Begin
End.