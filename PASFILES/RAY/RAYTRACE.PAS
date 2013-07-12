Program raytrace;
Uses
  crt, matrix44, Colors, rayun, viewunit, listeun, objektun,
  tgaun, vesa;
Const
  hintergrund: Color = (0, 0, 0);
  Ia: Color = (1, 1, 1);
  ka = 0.1;
  
  eta_atm: Double = 1;
  
  max_tiefe = 8;
Var
  i, j, k: Integer;
  ray: o_ray;
  ray_q, ray_v: vektor4;
  viewport: t_view_parameter;
  view: o_view;
  objekte: o_oliste;
  Lichter: o_oliste;
  mat: Array [1..6] Of t_mat;
  X, Y: Integer;
  farbe: Color;
  
  outf: tgafile;
  
Procedure write_xy (s: String; X, Y: Integer);
Var AX, ay: Integer;
Begin
  {
  AX := WhereX; ay := WhereY;
  GotoXY (X, Y); ClrEol; Write (s); GotoXY (AX, ay);
  }
End;
Procedure write_p_xy (s: String; p: p_vektor4; X, Y: Integer);
Var AX, ay: Integer;
Begin
  {
  AX := WhereX; ay := WhereY;
  GotoXY (X, Y); ClrEol; write_p (s, p); GotoXY (AX, ay);
  }
End;
Procedure write_real_xy (s: String; r: Double; X, Y: Integer);
Var AX, ay: Integer;
Begin
  {
  AX := WhereX; ay := WhereY;
  GotoXY (X, Y); ClrEol; WriteLn (s, '=', r: 3: 9); GotoXY (AX, ay);
  }
End;
(*=========================================*
 *                                         *
 *  INIT                                   *
 *                                         *
 *                                          *
 *                                         *
 *=========================================*)
Procedure init;
Var
  i, j, k: Integer;
  v1, v2, v3: vektor4;
  A: matrix4;
  o: p_objekt;
  l: p_licht;
  flaps: t_flaps;
Begin
  ClrScr;
  TextMode (co80 + Font8X8);
  WriteLn ('***************************************************************');
  WriteLn ('***************************************************************');
  WriteLn ('**                                                           **');
  WriteLn ('**  SiTra by StE                                             **');
  WriteLn ('**                                                           **');
  WriteLn ('**  Version 0.1 pre-beta  25.7.1994                          **');
  WriteLn ('**          0.2  -"-      30.7.1994                          **');
  WriteLn ('**                                                           **');
  WriteLn ('**                                                           **');
  WriteLn ('**                                                           **');
  WriteLn ('**                                                           **');
  WriteLn ('**                                                           **');
  WriteLn ('***************************************************************');
  WriteLn ('***************************************************************');
  
  {$define scenario_1}
  
  {$ifdef scenario_1}
  With viewport Do Begin
    put_vektor (0, 6, 6, @VRP);
    put_vektor (0, 1, 0, @VUP);
    put_vektor (0, 1, 1, @VPN);
    put_vektor (0, 0, 14, @PRP);
    
    put_window ( - 1, - 1, 1.2, 1, @WindowWC);
    put_window (0, 0, 320 , 200, @WindowBS);
  End;
  
  With mat [1] Do Begin
    kd := 0.7;
    ks := 1.0;
    kr := 0.6;
    kt := 0.0;
    eta_r := 1;
    phong := 1000;
    Od := @c_blue;
    Os := @c_white;
  End;
  
  With mat [2] Do Begin
    kd := 0.7;
    ks := 1.0;
    kr := 0.5;
    kt := 0.5;
    eta_r := 1;
    phong := 100;
    Od := @c_grey;
    Os := @c_blue;
  End;
  
  With mat [3] Do Begin
    kd := 0.7;
    ks := 1.0;
    kt := 0.0;
    eta_r := 1;
    kr := 0.8;
    phong := 10;
    Od := @c_green;
    Os := @c_white;
  End;
  With mat [4] Do Begin
    kd := 0.7;
    ks := 1.0;
    kr := 0.1;
    kt := 0.9;
    eta_r := 1.8;
    phong := 1000;
    Od := @c_mangenta;
    Os := @c_white;
  End;
  With mat [5] Do Begin
    kd := 0.7;
    ks := 0.3;
    kr := 0.8;
    kt := 0.0;
    eta_r := 1;
    phong := 100;
    Od := @c_red03;
    Os := @c_white;
  End;
  {$endif}
  
  {$ifdef scenario_2}
  With viewport Do Begin
    put_vektor (0, 0, 0, @VRP);
    put_vektor (0, 1, 0, @VUP);
    put_vektor (0.3, 0.6, 0.9, @VPN);
    put_vektor (0, 0, 9, @PRP);
    
    put_window ( - 1, - 1, 1, 1, @WindowWC);
    put_window (0, 0, 320 , 200, @WindowBS);
  End;
  
  With mat [1] Do Begin
    kd := 0.7;
    ks := 1.0;
    kr := 0.8;
    kt := 0.0;
    eta_r := 1;
    phong := 1000;
    Od := @c_blue06;
    Os := @c_white;
  End;
  
  With mat [2] Do Begin
    kd := 0.7;
    ks := 1.0;
    kr := 0.0;
    kt := 0.0;
    eta_r := 3.5;
    phong := 100;
    Od := @c_green03;
    Os := @c_yellow;
  End;
  
  With mat [3] Do Begin
    kd := 0.7;
    ks := 1.0;
    kr := 0.0;
    kt := 0.0;
    eta_r := 1;
    phong := 100;
    Od := @c_yellow;
    Os := @c_white;
  End;
  With mat [4] Do Begin
    kd := 0.7;
    ks := 1.0;
    kr := 0.0;
    kt := 0.0;
    eta_r := 1;
    phong := 1000;
    Od := @c_white;
    Os := @c_white;
  End;
  With mat [5] Do Begin
    kd := 0.7;
    ks := 1.0;
    kr := 0.0;
    kt := 0.0;
    eta_r := 1;
    phong := 100;
    Od := @c_red;
    Os := @c_white;
  End;
  {$endif}
  
  view. init (@viewport);
  copy_matrix (view. gimme_Mtr, @A);
  
  {$ifdef scenario_1}
  put_vektor (0, 0, 0, @v1);
  put_vektor (1, 0, 0, @v2);
  put_vektor (0, 0, 1, @v3);
  mdotv (@a, @v1, @v1);
  mdotv (@a, @v2, @v2);
  mdotv (@a, @v3, @v3);
  objekte. init (New (p_ebene, init (@v1, @v2, @v3, @mat [1] , 'Ebene') ) );
  put_vektor (0, 0.3, 0, @v1);
  mdotv (@a, @v1, @v1);
  objekte. insert_new (New (p_kugel, init (@v1, 0.3, @mat [2], 'Mittlere Kugel' ) ) );
  put_vektor ( - 0.6, 0.2, 0, @v1);
  mdotv (@a, @v1, @v1);
  objekte. insert_new (New (p_kugel, init (@v1, 0.2, @mat [3], 'Kleine Kugel' ) ) );
  put_vektor (  0.8, 0.4, 0, @v1);
  mdotv (@a, @v1, @v1);
  objekte. insert_new (New (p_kugel, init (@v1, 0.4, @mat [4], 'Groáe Kugel' ) ) );
  
  put_vektor ( 5, 15 , 2, @v1);
  put_vektor (0.8, 0.4, 0, @v2);
  mdotv (@a, @v1, @v1);
  mdotv (@a, @v2, @v2);
  lichter. init (New (p_spot_licht, init (@v1, @v2, 6, 1000, @c_white, 'Spot-licht 1') ) );
  put_vektor ( - 5, 15 , 2, @v1);
  put_vektor ( - 0.6, 0.2, 0, @v2);
  mdotv (@a, @v1, @v1);
  mdotv (@a, @v2, @v2);
  lichter. insert_new (New (p_spot_licht, init (@v1, @v2, 6, 1000, @c_white, 'Licht2') ) );
  {  put_vektor ( 0, 5 , 7, @v1);
  put_vektor (0, 0.3, 0, @v2);
  mdotv (@a, @v1, @v1);
  mdotv (@a, @v2, @v2);
  lichter. insert_new (New (p_spot_licht, init (@v1, @v2, 8, 700, @c_white, 'Spot-licht 3') ) );
  put_vektor ( 0, 5 , - 7, @v1);
  put_vektor ( 0, 0.3, 0, @v2);
  mdotv (@a, @v1, @v1);
  mdotv (@a, @v2, @v2);
  lichter. insert_new (New (p_spot_licht, init (@v1, @v2, 8, 700, @c_white, 'Licht 4') ) );
  put_vektor ( 0, 15 , 0, @v1);
  mdotv (@a, @v1, @v1);
  lichter. insert_new (New (p_licht, init (@v1, @c_grey, 'Licht 5') ) );}
  {$endif}
  
  {$ifdef scenario_2}
  (**)
  put_vektor ( - 1, - 1, - 1, @v1);
  put_vektor (2, 0, 0, @v2);
  put_vektor (0, 2, 0, @v3);
  mdotv (@a, @v1, @v1);
  mdotv (@a, @v2, @v2);
  mdotv (@a, @v3, @v3);
  objekte. init (New (p_4eck, init (@v1, @v2, @v3, @mat [1] , 'Ebene hinten') ) );
  (**)
  (**)
  put_vektor ( - 1, - 1, - 1, @v1);
  put_vektor (2, 0, 0, @v2);
  put_vektor (0, 0, 2, @v3);
  mdotv (@a, @v1, @v1);
  mdotv (@a, @v2, @v2);
  mdotv (@a, @v3, @v3);
  objekte. insert_new (New (p_4eck, init (@v1, @v2, @v3, @mat [1] , 'Ebene unten') ) );
  (**)
  (**)
  put_vektor ( - 1, - 1, - 1, @v1);
  put_vektor (0, 0, 2, @v2);
  put_vektor (0, 2, 0, @v3);
  mdotv (@a, @v1, @v1);
  mdotv (@a, @v2, @v2);
  mdotv (@a, @v3, @v3);
  objekte. insert_new (New (p_4eck, init (@v1, @v2, @v3, @mat [1] , 'Ebene links') ) );
  (**)
  (**)
  put_vektor (0, 0, 0, @v1);
  mdotv (@a, @v1, @v1);
  objekte. insert_new (New (p_kugel, init (@v1, 0.2, @mat [2] , 'Kugel') ) );
  (**)
  (*
  put_vektor (0, 0, 0.7, @v1);
  mdotv (@a, @v1, @v1);
  objekte. insert_new (New (p_kugel, init (@v1, 0.2, @mat [2] , 'Kugel vorne') ) );
  put_vektor (0, 0.7, 0, @v1);
  mdotv (@a, @v1, @v1);
  objekte. insert_new (New (p_kugel, init (@v1, 0.2, @mat [2] , 'Kugel oben') ) );
  put_vektor (0.7, 0, 0, @v1);
  mdotv (@a, @v1, @v1);
  objekte. insert_new (New (p_kugel, init (@v1, 0.2, @mat [2] , 'Kugel rechts') ) );
  put_vektor (0, 0, - 0.7, @v1);
  mdotv (@a, @v1, @v1);
  objekte. insert_new (New (p_kugel, init (@v1, 0.2, @mat [2] , 'Kugel hinten') ) );
  put_vektor (0, - 0.7, 0, @v1);
  mdotv (@a, @v1, @v1);
  objekte. insert_new (New (p_kugel, init (@v1, 0.2, @mat [2] , 'Kugel unten') ) );
  put_vektor ( - 0.7, 0, 0, @v1);
  mdotv (@a, @v1, @v1);
  objekte. insert_new (New (p_kugel, init (@v1, 0.2, @mat [2] , 'Kugel links') ) );
  put_vektor (0, 0.0, 0, @v1);
  mdotv (@a, @v1, @v1);
  objekte. insert_new (New (p_kugel, init (@v1, 0.5, @mat [3] , 'Kugel mitte') ) );
  *)
  With flaps Do
  Begin
    For i := 1 To 6 Do onoff [i] := True;
    
    onoff [2] := False;
    onoff [5] := False;
    
    flaps [1] := - 0.5;
    flaps [2] := 0;
    flaps [3] := - 0.5;
    flaps [4] := 0.5;
    flaps [5] := 0;
    flaps [6] := 0.5;
  End;
  put_vektor ( 10, 10 , 10, @v1);
  put_vektor (0, 0, 0, @v2);
  mdotv (@a, @v1, @v1);
  mdotv (@a, @v2, @v2);
  lichter. init (New (p_spot_licht, init (@v1, @v2, 10, 1000, @c_white, 'Licht weiá') ) );
  {$endif}
  
  ray. init (@Ray_Q, @Ray_V);
  
  {$ifdef scenario_1}
  outf. init ('c:\temp\raytrac1.tga', Round (viewport. WindowBS [2] ), Round (viewport. WindowBS [4] ) );
  {$endif}
  {$ifdef scenario_2}
  outf. init ('c:\temp\raytrac2.tga', Round (viewport. WindowBS [2] ), Round (viewport. WindowBS [4] ) );
  {$endif}
  outf. WriteHeader;
  
End;
(*=========================================*
 *                                         *
 *                                         *
 *                                         *
 *                                         *
 *                                         *
 *=========================================*)
Procedure done;
Begin
  outf. done;
  objekte. done;
  lichter. done;
End;
(*=========================================*
 *                                         *
 *  INTERSECT                              *
 *                                         *
 *                                         *
 *                                         *
 *=========================================*)
Function intersect (ol: p_oliste; ray: p_ray; Var objekt: p_objekt; Var sp: p_vektor4; original: Boolean): Boolean;
Var
  l, lmin: Double;
  s: vektor4;
  obj_dran: p_objekt;
  hit_this, hit: Boolean;
  
Begin
  {$undef debug_intersect}
  
  lmin := 1e308; { hui ! }
  l := - 1;
  hit := False;
  hit_this := False;
  
  ol^. setfirst;
  obj_dran := ol^. gimme_actual;
  
  Repeat
    If obj_dran^. typ <> [Licht] Then Begin
      hit_this := obj_dran^. berechne_schnitt (ray, l, @s, original) And (l > epsilon);
      If (hit_this And (l < lmin) ) Then Begin
        hit := True;
        lmin := l;
        objekt := obj_dran;
        copy_vektor (@s, sp);
      End;
    End;
    obj_dran := ol^. gimme_next;
    {$ifdef debug_intersect}
    If hit_this Then
    Begin
    End;
    {$endif}
  Until obj_dran = Nil;
  If original Then
    If hit  Then write_xy ('Intersect: Objekt "' + objekt^. Name + '"', 1, 30)
    Else write_xy ('Intersect: Objekt "keines"', 1, 30);
  
  intersect := hit;
End;
(*=========================================*
 *                                         *
 *  SHADOW                                 *
 *                                         *
 *                                         *
 *                                         *
 *=========================================*)
Function shadow (ol: p_oliste; ray: p_ray; DL: Double): Double;
Var
  obj_dran: p_objekt;
  hit_this: Boolean;
  
  vt: vektor4;
  
  l, SI: Double;
  
Begin
  {$undef debug_shadow}
  SI := 1;
  hit_this := False;
  
  ol^. setfirst;
  obj_dran := ol^. gimme_actual;
  
  Repeat
    hit_this := obj_dran^. berechne_schnitt (ray, l, @vt, False) And (l > epsilon) And (l < DL);
    
    If hit_this Then Begin
      SI := SI * obj_dran^. material^. kt;
    End;
    obj_dran := ol^. gimme_next;
  Until obj_dran = Nil;
  {$ifdef debug_shadow}
  write_real_xy ('Si', SI, 1, 25);
  write_p_xy ('sRay.q', @ray^. q, 1, 27);
  write_p_xy ('sRay.v', @ray^. v, 1, 28);
  {$endif}
  shadow := SI;
End;
(*=========================================*
 *                                         *
 *  TRACE                                  *
 *                                         *
 *                                         *
 *                                         *
 *=========================================*)
Function shade (objekt: p_objekt; ray: p_ray; sp, n: p_vektor4; eta: Double; tiefe: Integer; f: p_color): p_color; Forward;

Procedure trace (ray: p_ray; eta: Double; tiefe: Integer; farbe: p_color);
Var
  obj_hit: p_objekt;
  hit: Boolean;
  N, SP: vektor4;
  sp_: p_vektor4;
  original: Boolean;
Begin
  original := tiefe = 1;
  sp_ := @sp;
  hit := intersect (@objekte, ray, obj_hit, SP_, original);
  
  If hit Then Begin
    obj_hit^. berechne_Normale (@SP, @N);
    farbe := Shade (obj_hit, ray, @SP, @N, eta, tiefe, farbe);
  End Else Begin
    farbe^ [1] := hintergrund [1];
    farbe^ [2] := hintergrund [2];
    farbe^ [3] := hintergrund [3]
  End;
End;
(*=========================================*
 *                                         *
 *  SHADE                                  *
 *                                         *
 *                                         *
 *                                         *
 *=========================================*)
Function shade (objekt: p_objekt; ray: p_ray; sp, n: p_vektor4; eta: Double; tiefe: Integer; f: p_color): p_color;
Var
  licht: p_licht;
  Q, NdotV, NdotL, RdotV: Double;
  L, Rp, Rs, T: vektor4; { Rp..  R richtung L ; Rs...R richtung V}
  vt: vektor4;
  
  Od, Os, ftemp: Color;
  eta_r, eta_r_quadrat, kd, ks, kr, kt, phong: Double;
  
  DL, SI, fatt: Double;
  
  sRay, rRay, tRay: o_ray;
  
  Ip, sColor, tColor: Color;
  
  total_inner_refraction: Boolean;
Begin
  {$undef debug_shade}
  lichter. setfirst;
  licht := p_licht (lichter. gimme_actual);
  copy_color (objekt^. material^. Od, @Od);
  copy_color (objekt^. material^. Os, @Os);
  kd := objekt^. material^. kd;
  ks := objekt^. material^. ks;
  kr := objekt^. material^. kr;
  kt := objekt^. material^. kt;
  phong := objekt^. material^. phong;
  {*
  *
  *  Ambienter teil == Ia * ka * Od
  *
  }
  f^ [1] := Ia [1] * ka * Od [1];
  f^ [2] := Ia [2] * ka * Od [2];
  f^ [3] := Ia [3] * ka * Od [3];
  ftemp [1] := 0;
  ftemp [2] := 0;
  ftemp [3] := 0;
  
  While Not (licht = Nil) Do
  Begin
    p2v (sp, @licht^. position, @L);
    DL := vabs3 (@L);
    fatt := 1 / 1; {dL;}
    
    vnorm (@L, @L);
    
    If ebene2 In objekt^. typ Then
    Begin
      n^ [1] := n^ [1] * Sin (10 * sp^ [1] );
      n^ [3] := n^ [3] * Sin (10 * sp^ [3] );
      vnorm (n, n);
    End;
    
    NdotL := vdotv (N, @L);
    
    If ebene In objekt^. typ Then
    Begin
      NdotL := Abs (NdotL);
      vneg (n, n)
    End Else
      If ebene2 In objekt^. typ Then
      Begin
        NdotL := Abs (NdotL);
        vneg (n, n)
      End;
    
    Rp [1] := 2 * N^ [1] * NdotL - L [1];
    Rp [2] := 2 * N^ [2] * NdotL - L [2];
    Rp [3] := 2 * N^ [3] * NdotL - L [3];
    
    vnorm (@Rp, @Rp);
    
    If NdotL >= 0 Then Begin
      
      p2v (SP, @licht^. position, @vt);
      vnorm (@vt, @vt);
      sRay. init (SP, @vt);
      
      SI := shadow (@objekte, @sRay, DL);
      
      RdotV := vdotv (@Rp, @ray^. v);
      If RdotV < 0 Then RdotV := 0 Else RdotV := pow (RdotV, phong);
      
      licht^. gimme_ip (sp, Ip);
      
      ftemp [1] := fatt * Ip [1];
      ftemp [2] := fatt * Ip [2];
      ftemp [3] := fatt * Ip [3];
      
      ftemp [1] := SI * ftemp [1] * (NdotL * kd * Od [1] + ks * Os [1] * RdotV);
      ftemp [2] := SI * ftemp [2] * (NdotL * kd * Od [2] + ks * Os [2] * RdotV);
      ftemp [3] := SI * ftemp [3] * (NdotL * kd * Od [3] + ks * Os [3] * RdotV);
      
      f^ [1] := f^ [1] + ftemp [1];
      f^ [2] := f^ [2] + ftemp [2];
      f^ [3] := f^ [3] + ftemp [3];
      
    End;
    
    licht := p_licht (lichter. gimme_next);
  End;
  
  If tiefe < max_tiefe Then Begin
    total_inner_refraction := False;
    If objekt^. refractive Then
    Begin
      NdotV := vdotv (N, @ray^. v);
      If eta <> eta_atm Then
        eta_r := eta / eta_atm
      Else
        eta_r := eta_atm / objekt^. material^. eta_r;
      eta_r_quadrat := Sqr (eta_r);
      
      Q := 1 - eta_r_quadrat * (1 - Sqr (NdotV) );
      If (q) >= 0 Then
      Begin
        
        T [1] := (eta_r * NdotV - Sqrt (Q) ) * N^ [1] - eta_r * ray^. v [1];
        T [2] := (eta_r * NdotV - Sqrt (Q) ) * N^ [2] - eta_r * ray^. v [2];
        T [3] := (eta_r * NdotV - Sqrt (Q) ) * N^ [3] - eta_r * ray^. v [3];
        
        tRay. init (SP, @T);
        
        write_real_xy ('Tiefe: ', tiefe + 1, 1, 40);
        
        If eta <> eta_atm Then
          trace (@tRay, eta_atm, tiefe + 1, @tColor)
        Else
          trace (@tRay, objekt^. material^. eta_r, tiefe + 1, @tColor);
        
        f^ [1] := ( - kt + 1) * f^ [1] + kt * tColor [1];
        f^ [2] := ( - kt + 1) * f^ [2] + kt * tColor [2];
        f^ [3] := ( - kt + 1) * f^ [3] + kt * tColor [3];
      End Else Begin
        total_inner_refraction := True;
        kr := kt;
      End
    End;
    If objekt^. reflective Or total_inner_refraction Then
    Begin
      rRay. init (SP, @Rp);
      write_real_xy ('Tiefe: ', tiefe + 1, 1, 40);
      trace (@rRay, eta, tiefe + 1, @sColor);
      (**)
      f^ [1] := ( - kr + 1) * f^ [1] + kr * sColor [1];
      f^ [2] := ( - kr + 1) * f^ [2] + kr * sColor [2];
      f^ [3] := ( - kr + 1) * f^ [3] + kr * sColor [3];
      (**)
    End;
  End;
End;
(*=========================================*
 *                                         *
 *  MAIN                                   *
 *                                         *
 *                                         *
 *                                         *
 *=========================================*)
Begin
  
  init;
  
  setmode (mode_640X480X16m);
  
  For Y := Round (view. WindowBS [4] ) Downto 0 Do
  Begin
    For X := 0 To Round (view. WindowBS [2] ) Do
    Begin
      write_real_xy ('Zeile : ', Y, 10, 16);
      write_real_xy ('Spalte: ', X, 10, 17);
      
      view. make_ray (X, Y, @ray);
      
      trace (@ray, eta_atm, 1, @farbe);
      
      outf. Output (X, Y, farbe [1] , farbe [2] , farbe [3] );
      setpix ( X, Y, RGB ( Round ($ff * farbe [1] ),
      Round ($ff * farbe [2] ),
      Round ($ff * farbe [3] ) ) );
      
    End;
    If KeyPressed Then Exit;
  End;
  TextMode (c80 + Font8X8);
  WriteLn ('x:', X, ' y:', Y);
  done;
End.