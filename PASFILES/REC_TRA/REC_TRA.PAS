Program rec_tra;
{ version 0.9 }
Uses crt, graph, rt_types, rt_math, rt_lists, rt_textures,
  rt_lights, rt_cameras, rt_objects,
  rt_noisef, rt_tga, rt_output;
{ n+ e-}
{type}
Const
  {$define xdebug}
  BACKGROUND_VALUE: RT_color = (r: 0.3; g: 0.3; b: 0.3);
  AMBIENT_LIGHT: Double = 0.0;
  REFL_ATTEN: Double = 1;
  MAX_DEPTH: Integer = 8;
  XMIN = 0;
	XMAX = 640;
	YMIN = 0;
	YMAX = 480;
	YES = True;
	NO = False;

	DEBUG = no;
	FULL = yes;
	GRAPHIC_MODE = farbe;     {no_graphic,grau,farbe}
	REFRACTION = no And FULL;
	TEXTURE = yes;
	REFLECTION = yes And FULL;
	TRACE_SHADOWS = YES And FULL;

	{
	DEMO_WORLD
	}

	ANZAHL_K = 16;
	RADIUS = 15;
	RADIUS_K = 4;

  {
  DEBUGGING INFOS
  }

  DEBUG_SHADE = no;
  DEBUG_TRACE = no;
  DEBUG_MAIN = no;
  DEBUG_INITSPACE = no;
  DEBUG_SHADOW = no;
  DEBUG_INTERSECT = no;
  DEBUG_REKURSION = no;

  {Externe
  =======
  }

  DEBUG_CAMERA = no;
  DEBUG_TEXTURE = no;

  { RT_OBJECTS}

  DEBUG_KUGEL = NO;
  DEBUG_XYPLANE = no;
  DEBUG_PARA  = NO;

Var

  ExitSave: pointer;

  NUM_OBJECTS: LongInt;
  NUM_LIGHTS: Integer;
  ray: RT_ray;
  pixel: RT_color;
  X, Y: Integer;
  camera: RT_camera;
  olist: rt_olist;
  mlist: rt_mlist;
  llist: rt_llist;
  TGA_file: tgafile;
  
  n_intersect, p_refl, p_refr, p_shadows, p_textured: LongInt;
  
Procedure MyExit; Far;
Begin
  ExitProc := exitsave;
  
  CloseGraph;
End;

Procedure waittast; Begin Repeat Until KeyPressed; ReadLn; End;


Procedure RT_putpixel (X, Y: Integer; Color: RT_color);
Begin
  tga_file. Output (X, Y, Color. r,
  Color. g,
  Color. b);
End;
Function transv (ve, n: rt_vector; n1, n2: Double; Var vt: rt_vector) : Boolean;
Var p, q, c, D, hhh: Double;
Begin
  p := n1 / n2;
  c := Abs (vdot (ve, n) ); D := 1 - Sqr (p) * (1 - Sqr (c) );
  If D < 0.0 Then transv := False Else Begin
    q := p * c - Sqrt (D); transv := True; vmul (p, ve, ve);
    vmul (q, n, n); vadd (ve, n, vt);
  End;
End;
Procedure rt_gen_cube (o: v3t; a: Double);
Begin
End;
Procedure equcolor (ob: rt_object_pointer; p: v3t; Var c: ct);
Begin
  c := ob^. material^. Color;
End;

Function rt_spotlight (pt: rt_point; light: rt_light_p): Double;
Var hilf: rt_vector;
  cos_gamma: Double;
Begin
  p2vector (light^. position, pt, hilf);
  vnorm (hilf, hilf);
  cos_gamma := vdot (hilf, light^. point_at);
  If cos_gamma < 0 Then cos_gamma := 0;
  If cos_gamma > light^. cos_alpha Then rt_spotlight := pow (cos_gamma, light^. p)
  Else rt_spotlight := 0;
End;

Procedure rt_texture (obj: rt_object_pointer; p: rt_point; Var c: ct);
Begin
  Case obj^. material^. texture Of
    0: equcolor (obj, v3t (p), c);
    1: marbleproc (obj, v3t (p), c);
    2: hellproc (obj, v3t (p), c);
    3: cloudproc (obj, v3t (p), c);
  End;
End;
Procedure rt_calc_color (licht: RT_light_p; material: rt_mat_p;
          pt: rt_point; shadow_atten, ndotl, rdotv: Double;
          Var Color: rt_color);

Var r, g, b: Double;
  rod, god, bod: Double;
  ros, gos, bos: Double;
  rla, gla, bla: Double;
  rlp, glp, blp: Double;
  ka, kd, ks: Double;
  phong, spot_faktor: Double;
Begin
  phong := pow (rdotv, material^. phong_value);
  ka := material^. ka;
  kd := material^. kd;
  ks := material^. ks;
  
  r := Color. r;
  g := Color. g;
  b := Color. b;
  
  rod := material^. Color. r;
	god := material^. Color. g;
  bod := material^. Color. b;
  
  ros := material^. specular_color. r;
  gos := material^. specular_color. g;
  bos := material^. specular_color. b;
  
  rla := licht^. ia. r;
  gla := licht^. ia. g;
  bla := licht^. ia. b;
  
  If licht^. spot Then Begin
    spot_faktor := rt_spotlight (pt, licht);
    If DEBUG_SHADE Then Write1r ('spot_faktor=', spot_faktor);
		rlp := licht^. ip. r * spot_faktor;
    glp := licht^. ip. g * spot_faktor;
    blp := licht^. ip. b * spot_faktor;
  End Else Begin
    rlp := licht^. ip. r;
    glp := licht^. ip. g;
    blp := licht^. ip. b;
  End;
  { ambienter teil }
  
  r := ka * rod * (rla + r);
  g := ka * god * (gla + g);
  b := ka * bod * (bla + b);
  
  { diffus und phong }
  
  r := r + rlp * (kd * rod * ndotl + ks * ros * phong);
	g := g + glp * (kd * god * ndotl + ks * gos * phong);
  b := b + blp * (kd * bod * ndotl + ks * bos * phong);
  
  cinit (shadow_atten * r, shadow_atten * g, shadow_atten * b, Color);
  
End;
Procedure dodebug (i: Integer);
Begin
  If debug Then Write (i, '.');
End;
{
*****************************************************************************
*****************************************************************************
*****************************************************************************
***************----------------**********************************************
***************----intersect---**********************************************
***************----------------**********************************************
*****************************************************************************
*****************************************************************************
*****************************************************************************
*****************************************************************************
}
Function RT_intersect ( ray: RT_ray;
                       tiefe: Integer;
                       Var obj_hit: rt_object_pointer;
                       Var intersection: RT_point) : Boolean;
Var first, hit: Boolean;
  t, tmin: Double;
	ob_dran: LongInt;
Begin
  tmin := 0;
	obj_hit := Nil;
  intersection := rt_point (NULL);
  first := True;
  ob_dran := 0;
  olist. setfirst;
  While ob_dran < NUM_OBJECTS Do
  Begin
		If DEBUG_INTERSECT Then Begin
			ClrEol; WriteLn ('intersect: testing object ''', olist. get_object^. obj_name, '''');
		End;
		Inc (N_intersect);
		Inc (ob_dran);
		hit := NO;
		hit := olist. get_object^. intersect (ray, tiefe, intersection, t);
		If hit Then Begin
			If (t < tmin) And (t >= 0) Or (first And (t > 0) ) Then Begin
        tmin := t;
        obj_hit := olist. get_object;
        first := False;
      End;
    End;
    olist. next;
  End;
  If obj_hit <> Nil Then Begin
    rt_intersect := YES;
    If DEBUG_INTERSECT Then Begin
      ClrEol; WriteLn ('intersect: Hit object ''', obj_hit^. obj_name, ''' at (',
      intersection. X: 3: 3, '|', intersection. Y: 3: 3, '|', intersection. z: 3: 3, ')');
    End
  End Else Begin
    rt_intersect := NO;
		If DEBUG_INTERSECT Then Begin
      ClrEol; WriteLn ('intersect: nothing hit.');
    End
  End;
  
End;
{
*****************************************************************************
*****************************************************************************
*****************************************************************************
***************----------------**********************************************
***************----shadow------**********************************************
***************----------------**********************************************
*****************************************************************************
*****************************************************************************
*****************************************************************************
*****************************************************************************
}
Function RT_shadow ( ray: RT_ray; dL:double) : Double;
Var first, hit: Boolean;
	t, D: Double;
	ob_dran: LongInt;
	p: rt_point;
Begin
	D := 1;
	ob_dran := 0;
	olist. setfirst;
	While ob_dran <= NUM_OBJECTS Do
	Begin
		hit := NO;
		hit := olist. get_object^. intersect (ray, - 1, p, t);
		If (abs(t) <= EPSILON) or (t>=dL)  Then hit := False;
		If hit Then Begin
			D := D * olist. get_object^. material^. refraction_value;
      If DEBUG_SHADOW Then Begin ClrEol; WriteLn ('shadow: Schatten durch ''', olist. get_object^. obj_name, '''') End;
    End;
    olist. next;
    Inc (ob_dran);
  End;
  rt_shadow := D;
  If D < 1 Then Inc (p_shadows);
End;

Procedure RT_trace (ray: RT_ray; depth: Integer; Var Color: RT_color; ior: Double); Forward;

{
*****************************************************************************
*****************************************************************************
*****************************************************************************
*****************------------------******************************************
*****************----shade---------******************************************
*****************------------------******************************************
*****************************************************************************
*****************************************************************************
*****************************************************************************
*****************************************************************************
}
Procedure RT_shade (obj: rt_object_pointer;               { Object-nummer }
                   ray: RT_ray;                  { Sehstrahl }
                   p: RT_point;              { schnittp. Obj / Sehstr. }
                   N: RT_normal;            { Ofl.Normale Obj/point }
                   n1: Double;
                   depths: Integer; Var color_back: RT_color);
Var (*color:RT_color;*)
  rRay, sRay, tRay: RT_ray;
  obj_color, rColor, tColor, shade: RT_color;
  RdotV: Double;
	NdotL: Double;
	dL:double;
	lightIP, i1, i2, fatt, satt, obj_ior, obj_ka, obj_kd, obj_ks, obj_phong: Double;
  hw: Double;
  blocking_object: rt_object_pointer;
  blocking_point: RT_point;
	L, V, R, T, H, hilf: RT_vector;
  i: Integer;
  in_shadow, rekursion: Boolean;
  licht_dran: rt_light_p;
Begin
  fatt := 1;
  satt := 1;
  in_shadow := False;
  rekursion := depths < MAX_DEPTH;
  color_back := Black;
  rcolor := Black;
  tcolor := Black;
  shade := Black;
  
  satt := 1;
  If DEBUG_SHADE Then Begin
    If (depths > 1) And Not DEBUG_REKURSION Then Exit;
    WriteLn ('shade: ', depths);
    WriteLn;
    ClrEol; WriteLn ('K”rper   :', obj^. obj_name);
    ClrEol; WriteLn ('Material :', obj^. material^. mat_name);
    ClrEol; WriteColor ('Farbe:', obj^. material^. Color);
  End;
  
  For i := 1 To NUM_LIGHTS Do
  Begin
		llist. next;
    licht_dran := llist. get_light;
    If DEBUG_SHADE Then Begin
			WriteLn    ('Licht dran ''', licht_dran^. Name, '''');
      Writepoint ('Lpos          =', licht_dran^. position);
      writecolor ('Farbe Ambient =', licht_dran^. ia);
      writecolor ('Farbe Diffus  =', licht_dran^. ip);
		End;

		p2ray (p, licht_dran^. position, sRay);
		p2vector (p, licht_dran^. position, L);
		dL:=vabs(L);
		vnorm (L, L);

		NdotL := vdot (N, L);

		if obj^.typ=[_2d] then
		begin
			Ndotl:=abs(NdotL);
			N.x:=-N.x;
			N.y:=-N.y;
			N.z:=-N.z;
		end;
		If DEBUG_SHADE And (depths = 1) Then writepoint ('p   :=', p);
		If DEBUG_SHADE And (depths = 1) Then writepoint ('Lpos:=', Licht_dran^.position);
		If DEBUG_SHADE And (depths = 1) Then writevector ('N   :=', N);
		If DEBUG_SHADE And (depths = 1) Then writevector ('L   :=', L);
		If DEBUG_SHADE And (depths = 1) Then Write1r ('NxL :=', ndotl);

		If ndotl > 0 Then  Begin { zeichen umkehrt,dotl := 0;}

			vmul (2 * NdotL, N, hilf);
			vsub (hilf, L, R);
      vnorm (R, R);
      
      p2vector (p, camera. cop, V);
      vnorm (V, V);
      
      If DEBUG_SHADE And (depths = 1) Then writevector ('R:=', R);
      If DEBUG_SHADE And (depths = 1) Then writevector ('V:=', V);
      
      RdotV := vdot (R, V);
      If DEBUG_SHADE And (depths = 1) Then Write1r ('RxV:=', RdotV);
      If RdotV < 0 Then RdotV := 0;
      
      { schatten }
      If TRACE_SHADOWS Then
			Begin
				satt := rt_shadow (sray,dL);
			End;
      
      obj_color := obj^. material^. Color;
      If TEXTURE And (obj^. material^. texture <> NO_TEXTURE) Then Begin
        RT_texture (obj, p, obj_color);
        Inc (p_textured);
      End;
      
      rt_calc_color (licht_dran, obj^. material, p, satt, ndotl, rdotv, obj_color);
      cadd (obj_color, color_back, color_back);
      
    End;
  End;
  
  
  If rekursion Then
  Begin
    If (obj^. material^. reflection_value <> 0) And REFLECTION Then
    Begin
      Inc (p_refl);
      vmul (2 * vdot (N, V), N, hilf);
      vsub (hilf, V, rRay. v);
      vnorm (rRay. v, rRay. v);
      rRay. q := p;
      
      RT_trace (rRay, depths + 1, rColor, n1);
      cmul (obj^. material^. reflection_value, rColor, rColor);
      cadd (color_back, rColor, color_back);
    End;
    If (obj^. material^. refraction_value <> 0) And REFRACTION Then
    Begin
      If n1 <> 1 Then Begin i1 := obj_ior; i2 := 1 End
      Else
      Begin i2 := obj_ior; i1 := 1 End;
      If transv (V, N, i1, i2, T) Then Begin
        Inc (p_refr);
        vnorm (t, t);
        tRay. v := T;
        tRay. q := p;
        RT_trace (tRay, depths + 1, tColor, i1);
        cmul (obj^. material^. refraction_value, tColor, rColor);
        cadd (color_back, tColor, color_back);
      End;
    End;
  End;
End;

{
*****************************************************************************
*****************************************************************************
*****************************************************************************
*****************************************************************************
******************----------------*******************************************
******************-----trace------*******************************************
******************----------------*******************************************
*****************************************************************************
*****************************************************************************
*****************************************************************************
}
Procedure RT_trace (ray: RT_ray; depth: Integer; Var Color: RT_color; ior: Double);
Var obj_hit: rt_object_pointer;
  intersection: RT_point;
  hit: Boolean;
  normal: RT_normal;
Begin
  
  hit := RT_intersect (ray, depth, obj_hit, intersection);
  
  If hit Then
  Begin
    obj_hit^. compute_normal (intersection, normal);
    RT_shade (obj_hit, ray, intersection, normal, ior, depth, Color);
  End
  Else
    Color := BACKGROUND_VALUE;
  If DEBUG_TRACE Then writecolor ('trace: Color:=', Color);
End;

{
*****************************************************************************
*****************************************************************************
*****************************************************************************
*******************-----------------*****************************************
*******************----initspace----*****************************************
*******************-----------------*****************************************
*****************************************************************************
*****************************************************************************
*****************************************************************************
*****************************************************************************
}
Procedure RT_initspace;
Var p1, p2, p3: RT_point;
  v1, v2, v3: rt_vector;
  r1, r2: RT_rect;
  kcolor, White: RT_color;
  ws, w, r: Double;
  i, ak: Integer;
  tempobj: rt_object_pointer;
  Name: String;
Begin
  ClrScr;

  If DEBUG_CAMERA Then DEBUG_CAMERA_UNIT := True;
  If DEBUG_XYPLANE Then DEBUG_OBJ_XYPLANE := True;
  If DEBUG_PARA Then DEBUG_OBJ_PARA := True;


  If DEBUG_INITSPACE Then WriteLn ('initspace:');
  {

  LISTEN

  }
  olist. init;
  mlist. init;
  llist. init;

  init_std_text (mlist);

  NUM_OBJECTS := 0;
  NUM_LIGHTS := 0;

  { stats }
  p_refl := 0; p_refr := 0; p_shadows := 0; n_intersect := 0; p_textured := 0;

  { camera }
  pinit (0, 0, 0, p1);          { VRZ }
  pinit (0, 0, 40, p2);        { COP }


	pinit (xmin, ymin, 0, r1.p1);
	pinit (xmax, ymax, 0, r1.p2);
	pinit ( - 40, 40, 0, r2.p1);
	pinit ( 40, - 40, 0, r2.p2);

	camera. init (p1, p2, r1 {aufloesung} , r2 {sicht} );

  { lights }


  pinit (0, 0, 40, p1);
  llist. Insert (New (rt_light_p, init (p1, rt_point (NULL), 0, grau90, 1, GRAU90, 10 * RAD, 8, no, 'Licht Weiá') ) );
  Inc (NUM_LIGHTS);
  {
  pinit ( - 10, 10, 0, p1);
  llist. Insert (New (rt_light_p, init (p1, rt_point (NULL), 0, grau90, 1, grau90, 10 * RAD, 8, no, 'Licht Weiá 2') ) );
  Inc (NUM_LIGHTS);
  }
	mlist. setfirst;

	ws := 360 / ANZAHL_K;
	w := 0;

	For i := 1 To ANZAHL_K Do Begin
		Name := '';
		w := w + ws;
		pinit (Cos (w * RAD) * RADIUS, Sin (w * RAD) * RADIUS, 10, p1);
		cinit ( (1 + Sin (w * RAD) ) / 2, (1 + Cos (w * RAD) ) / 2, (1 - Cos (w * RAD) ) / 2, kcolor);
		Str (i, Name);
		Name := 'KUGEL # ' + Name;
		mlist. Insert (New (rt_mat_p, init (
		kcolor, { color }
		GRAU30,   { specc }
		0.3,       { ka}
		0.7,       { kd}
		0.9,     { ks    }
		1000,     { phong    }
		00,     { sp    }
		0.0,    { tr }
		1.5        { ior   }
		, NO_TEXTURE,
		Name
		) ) );

		olist. Insert (
		New (RT_obj_Kugel_p, init (p1, RADIUS_K, mlist. get_mat, Name) )
		);
		Inc (NUM_OBJECTS);
	End;

	vinit(0,-Radius,0,v1);
	vinit(1,0,0,v2);
	vinit(0,0,1,v3);
	tempobj := New (RT_obj_Plane_p, init ( v1,v2,v3, mlist. getbyname ('blau sp'), 'Ebene') );
  olist. Insert (tempobj);
  Inc (NUM_OBJECTS);


  If DEBUG_INITSPACE Then WriteLn ('initspace done.');
End;
Procedure RT_closestuff;
Begin
  tga_file. done;
  olist. done;
End;
Procedure RT_stats;
Begin
  WriteLn ('# of Intersections testet :', N_intersect);
  WriteLn ('# of pixels reflectet     :', p_refl);
  WriteLn ('# of pixels refractet     :', p_refr);
  WriteLn ('# of pixels in shadow     :', p_shadows);
  WriteLn ('# of pixels in textured   :', p_textured);
  WriteLn;
  Write ('There were ', NUM_OBJECTS, ' Object');
  If NUM_OBJECTS > 1 Then Write ('s and ') Else Write (' and ');
  Write (NUM_LIGHTS, ' Light');
  If NUM_LIGHTS > 1 Then WriteLn ('s.') Else WriteLn ('.');
  
End;

{
*****************************************************************************
*****************************************************************************
*****************************************************************************
*****************************************************************************
**********************--------------*****************************************
**********************-----MAIN-----*****************************************
**********************--------------*****************************************
*****************************************************************************
*****************************************************************************
*****************************************************************************
}
Var i: Integer;
  
Begin
  
  TextMode (c80 + Font8X8);
  
{  ExitSave := ExitProc;
  ExitProc := @myexit;
}
  {     if GRAFIK then grafikein;}
  RT_initspace;
  
  
  { TGAfile }
  
  tga_file. init ('z:\tp70\rec_tra\test.tga', GRAPHIC_MODE, xmax, ymax);
  tga_file. WriteHeader;
  
  ClrScr;
  
  i := WhereY + 3;
  
  For Y := YMIN to YMAX Do Begin
    GotoXY (5, i);
    WriteLn ('                  ');
    GotoXY (5, i);
    WriteLn ('Zeile :', Y, ' von ', YMAX);
    For X := XMIN To XMAX Do
    Begin
      GotoXY (5, i + 2);
      WriteLn ('                     ');
      GotoXY (5, i + 2);
      WriteLn ('Pixel :', X, ' von ', XMAX);
      camera. Compute_Ray (X, Y, ray);
      RT_trace (ray, 1, pixel, 1);
      RT_putpixel (X, Y, pixel);
      If KeyPressed Then Begin
        X := XMAX;
        Y := YMIN;
        WriteLn ('USERBREAK!');
      End;
    End;
  End;
  
  waittast;
  RT_closestuff;
  {     if GRAFIK then grafikaus;}
  RT_stats;
End.