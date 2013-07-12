Unit rt_objects;
Interface
{ $n+ $e-}
Uses rt_types, rt_lists, rt_textures, rt_math;
Var
  DEBUG_OBJ_XYPLANE: Boolean;
  DEBUG_OBJ_PARA: Boolean;
Type
  t_objekttypen = (_2D, _3D);
	RT_colorproc = Procedure (obnr: Integer; p: rt_point; Var c: RT_color);
	RT_object_pointer = ^RT_object;
	rt_olist_p = ^rt_olist;
	rt_olist = Object (rt_list)
							 Function get_object: rt_object_pointer;
							 Procedure Insert (insnode: rt_object_pointer);
						 End;
	RT_object = Object (rt_obase)
								typ: Set Of t_objekttypen;
								obj_name: String;
								material: rt_mat_p;
								Procedure compute_normal ( intersection: RT_point;
								Var normal: RT_normal)
								; Virtual;
								Function intersect (ray: RT_ray; tiefe: Integer; Var p: RT_point; Var t: Double): Boolean; Virtual;
								Procedure transform (alpha, beta, gamma: Double; D: rt_vector; s: Double); Virtual;
							End;
	RT_obj_kugel_p = ^RT_obj_kugel;
	RT_obj_Kugel = Object (RT_object)
									 center: RT_point;
									 radius, square_radius: Double;
									 Constructor init (icentr: RT_point; r: Double; imat: rt_mat_p; iname: String);
									 Procedure compute_normal ( intersection: RT_point;
									 Var normal: RT_normal)
									 ; Virtual;
									 Function intersect (ray: RT_ray; tiefe: Integer; Var p: RT_point; Var t: Double): Boolean; Virtual;
									 Procedure transform (alpha, beta, gamma: Double; D: rt_vector; s: Double); Virtual;

								 End;
  
  RT_obj_XZPlane_p = ^rt_obj_XZPlane;
  RT_obj_XZPlane = Object (RT_Object)
                     n: rt_normal;
                     dist: Double;
                     Procedure compute_normal ( intersection: RT_point;
                     Var normal: RT_normal)
                     ; Virtual;
                     Constructor init (D: Double; imat: rt_mat_p; iname: String);
                     Function intersect (ray: RT_ray; tiefe: Integer; Var p: RT_point; Var t: Double): Boolean; Virtual;
                   End;
  RT_obj_XYPlane_p = ^rt_obj_XYPlane;
  RT_obj_XYPlane = Object (RT_Object)
                     n: rt_normal;
                     dist: Double;
                     Procedure compute_normal ( intersection: RT_point;
                     Var normal: RT_normal)
                     ; Virtual;
                     Constructor init (D: Double; imat: rt_mat_p; iname: String);
                     Function intersect (ray: RT_ray; tiefe: Integer; Var p: RT_point; Var t: Double): Boolean; Virtual;
                   End;
  RT_obj_plane_p = ^rt_obj_plane;
  RT_obj_plane = Object (RT_Object)
                   hilf1, hilf2, hilf3: Double;
                   a, b, c: rt_vector;
                   normale: RT_vector;
                   Constructor init (ia, ib, ic: rt_vector; imat: rt_mat_p; iname: String);
                   Procedure compute_normal ( intersection: RT_point;
                   Var normal: RT_normal)
                   ; Virtual;
                   Function intersect (ray: RT_ray; tiefe: Integer; Var p: RT_point; Var t: Double): Boolean; Virtual;
                   Procedure transform (alpha, beta, gamma: Double; D: rt_vector; s: Double); Virtual;
                 End;
  RT_obj_para_p = ^rt_obj_para;
  RT_obj_para = Object (RT_obj_plane)
                  Function intersect (ray: RT_ray; tiefe: Integer; Var p: RT_point; Var t: Double): Boolean; Virtual;
                End;
  (*
  RT_obj_cube_p =^rt_obj_cube;
  rt_obj_cube = object
  END;
  *)
  RT_obj_dreieck_p = ^rt_obj_dreieck;
	RT_obj_dreieck = Object (RT_obj_plane)
                     Function intersect (ray: RT_ray; tiefe: Integer; Var p: RT_point; Var t: Double): Boolean; Virtual;
                   End;
  RT_obj_kreis_p = ^rt_obj_kreis;
  RT_obj_kreis = Object (RT_obj_plane)
                   Function intersect (ray: RT_ray; tiefe: Integer; Var p: RT_point; Var t: Double): Boolean; Virtual;
                 End;
Implementation
Uses sgraph;

{



        LISTEN_prozeduren



}

Function rt_olist. get_object: rt_object_pointer;
Begin
  get_object := rt_object_pointer (rt_list. get);
End;
Procedure rt_olist. Insert;
Begin
  rt_list. Insert (insnode);
End;
{



        OBJECT_prozeduren



}


Procedure rt_object. compute_normal ( intersection: RT_point;
                          Var normal: RT_normal);
Begin End;
Function rt_object. intersect (ray: RT_ray; tiefe: Integer; Var p: RT_point; Var t: Double): Boolean;
Begin End;
Procedure rt_object. transform (alpha, beta, gamma: Double; D: rt_vector; s: Double);
Begin End;

{

                KUGEL

}
Constructor RT_obj_kugel. init;
Begin
  Inherited init;

	typ:=[_3d];
	center := icentr;
	radius := r;
	square_radius := radius * radius;
	material := imat;
	obj_name := iname;
	If imat = Nil Then doerror ('Kugel: Material=NIL !');
	If iname = '' Then doerror ('Kugel: Name=''''');
End;
Procedure RT_obj_kugel. compute_normal ( intersection: RT_point;
																		Var normal: RT_normal);
Begin
	p2vector (center, intersection, normal);
	vnorm (normal, normal);
End;
Procedure rt_obj_kugel. transform;
Begin
	rot (center, alpha, beta, gamma, center);

	vadd (D, rt_vector (center), rt_vector (center) );

	square_radius := Sqr (Sqrt (square_radius) * s);
End;
Function RT_obj_kugel. intersect (ray: RT_ray; tiefe: Integer; Var p: RT_point; Var t: Double): Boolean;
Var t1, t2: Double;
	hilf: RT_vector;
	a, b, c: Double;
Begin
	vsub (RT_vector (ray. q), RT_vector (center), hilf);
	a := Sqr (ray. v. X) + Sqr (ray. v. Y) + Sqr (ray. v. z);
	b := 2 * (ray. v. X * (ray. q. X - center. X) +
	ray. v. Y * (ray. q. Y - center. Y) +
	ray. v. z * (ray. q. z - center. z) ); ;
	c := Sqr (ray. q. X - center. X) +
  Sqr (ray. q. Y - center. Y) +
  Sqr (ray. q. z - center. z) - square_radius; ;
  
  If RT_solve_qglabc (a, b, c, t1, t2) Then
  Begin
    t1 := Min3Real (t1, t2, INFINITY_HIGH);
    intersect := t1 > 0;
    vmul (t1, ray. v, hilf);
    vadd (RT_vector (ray. q), hilf, RT_vector (p) );
    t := errepsilon (t1);
    If t = 0 Then Begin
      intersect := False;
		End;
	End
	Else
	Begin
		intersect := False;
		t := -1;
	End;

End;


{                            b
															 ^      a...ortsvektor
													 a   |      b...spannt ebene auf
								EBENE   ----->*-->c  c...  -- " --

								laut buch
}



Constructor rt_obj_XZPlane. init;
Begin
	Inherited init;

	typ:=[_2d];
  
  dist := D;
  vinit (0, - 1, 0, n);
  material := imat;
  If imat = Nil Then doerror ('XZPlane: Material=NIL !');
  obj_name := iname;
  If iname = '' Then doerror ('XZPlane: Name=''''');
End;
Procedure rt_obj_XZplane. compute_normal ( intersection: RT_point;
                                       Var normal: RT_normal);
Begin
  normal := n;
End;
Function rt_obj_XZPlane. intersect (ray: RT_ray; tiefe: Integer; Var p: RT_point; Var t: Double): Boolean;
Var D: Double;
  q, v: v3t;
Begin
  q := v3t (ray. q);
  v := ray. v;
  intersect := False;
  If v. Y <> 0 Then Begin
    t := (dist - q. Y) / v. Y;
    intersect := t > 0;
    ray2point (ray, t, p)
  End Else t := - 1;
End;

Constructor rt_obj_XYPlane. init;
Begin
  Inherited init;
  

	typ:=[_2d];
	dist := D;
	vinit (0, 0, D, n);
	p2vector (rt_point (n), rt_point (NULL), n);
	vnorm (n, n);
	material := imat;
	If imat = Nil Then doerror ('XZPlane: Material=NIL !');
	obj_name := iname;
	If iname = '' Then doerror ('XZPlane: Name=''''');
End;
Procedure rt_obj_XYplane. compute_normal ( intersection: RT_point;
																			 Var normal: RT_normal);
Begin
	normal := n;
End;
Function rt_obj_XYPlane. intersect (ray: RT_ray; tiefe: Integer; Var p: RT_point; Var t: Double): Boolean;
Var D: Double;
	q, v: rt_vector;
Begin
  q := v3t (ray. q);
  v := ray. v;
  If DEBUG_OBJ_XYPLANE Then writeray ('XYplane.intersect: r=', ray);
  intersect := False;
  If v. z <> 0 Then Begin
    t := (dist - q. z) / v. z;
    intersect := (t >= 0);
    ray2point (ray, t, p);
    If DEBUG_OBJ_XYPLANE Then Write1r ('XYplane.intersect: t=', t);
    If DEBUG_OBJ_XYPLANE Then writepoint ('XYplane.intersect: p=', p);
  End Else t := - 1;
End;
Constructor rt_obj_plane. init;
Var h1, h2: RT_Vector;
Begin
  Inherited init;
  

	typ:=[_2d];
  WriteLn ('rt_obj_plane.init');
	hilf1 := det2 ( ib. Y, ic. Y, ib. z, ic. z);
	hilf2 := det2 ( ib. X, ic. X, ib. z, ic. z);
	hilf3 := det2 ( ib. X, ic. X, ib. Y, ic. Y);

	a := ia; b := ib; c := ic;

	vcross (b, c, normale);
	material := imat;
	If imat = Nil Then doerror ('Plane: Material=NIL !');
	obj_name := iname;
	If iname = '' Then doerror ('Plane: Name=''''');
End;
Procedure rt_obj_plane. transform;
Var bb, cc: v3t;
Begin
	vadd (a, b, bb);
	vadd (a, c, cc);
	rot (rt_point (a), alpha, beta, gamma, rt_point (a) );
	rot (rt_point (bb), alpha, beta, gamma, rt_point (bb) );
	rot (rt_point (cc), alpha, beta, gamma, rt_point (cc) );

	vadd (D, c, c);
	vadd (D, bb, bb);
	vadd (D, cc, cc);
	vmul (s, a, a);
	vsub (a, bb, b);
	vsub (a, cc, c);
	vcross (c, b, normale);
	vnorm (normale, normale);
End;
Procedure rt_obj_plane. compute_normal ( intersection: RT_point;
																			 Var normal: RT_normal);
Begin
	normal := normale;
End;
{
				a.x - q.x = t*v.x - r*b.x - s*c.x
				a.y - q.y = t*v.y - r*b.y - s*c.y
				a.z - q.z = t*v.z - r*b.z - s*c.z


}
Function rt_obj_plane. intersect (ray: RT_ray; tiefe: Integer; Var p: RT_point; Var t: Double): Boolean;
Var D: Double;
	q, v: v3t;
Begin
	q := v3t (ray. q);
	v := ray. v;
	intersect := False;
	{     d:=det3( v.x,b.x,c.x,
	v.y,b.y,c.y,
	v.z,b.z,c.z);}

	D := v. X * hilf1 - v. Y * hilf2 + v. z * hilf3;

	If D > 0 Then Begin
		t := det3 (
		a. X - q. X, b. X, c. X,
		a. Y - q. Y, b. Y, c. Y,
		a. z - q. z, b. z, c. z
		) / D;
		t := errepsilon (t);
		intersect := t > 0;
		ray2point (ray, t, p);
	End Else
		t := - 1;


End;
Function rt_obj_para. intersect (ray: RT_ray; tiefe: Integer; Var p: RT_point; Var t: Double): Boolean;
Var D: Double;
  r, s: Double;
  Q, V: rt_vector;
  hit: Boolean;
Begin
	q := v3t (ray. q);
  v := ray. v;
  intersect := True;
  hit := rt_obj_plane. intersect (ray, tiefe, p, t);
  D := det3 ( v. X, b. X, c. X,
  v. Y, b. Y, c. Y,
  v. z, b. z, c. z);
  
  If hit Then Begin
		r := det3 ( v. X, a. X - q. X, c. X,
		v. Y, a. Y - q. Y, c. Y,
		v. z, a. z - q. z, c. z) / D;
		s := det3 ( v. X, b. X, a. X - q. X,
		v. Y, b. Y, a. Y - q. Y,
		v. z, b. z, a. z - q. z) / D;

		If DEBUG_OBJ_PARA Then Write1r ('para.intersect: s=', s);
		If DEBUG_OBJ_PARA Then Write1r ('para.intersect: r=', r);
		If (r < 0) Or (s < 0) Or (r > 1) Or (s > 1) Then
			intersect := False;
	End Else Begin
    t := - 1;
    intersect := False;
  End;
End;

Function rt_obj_dreieck. intersect (ray: RT_ray; tiefe: Integer; Var p: RT_point; Var t: Double): Boolean;
Var D: Double;
  r, s: Double;
  Q, V: rt_vector;
  hit: Boolean;
Begin
  q := v3t (ray. q);
  v := ray. v;
  intersect := True;
  hit := rt_obj_plane. intersect (ray, tiefe, p, t);
  D := det3 ( v. X, b. X, c. X,
  v. Y, b. Y, c. Y,
  v. z, b. z, c. z);
  
  If hit Then Begin
    r := det3 ( v. X, a. X - q. X, c. X,
    v. Y, a. Y - q. Y, c. Y,
    v. z, a. z - q. z, c. z) / D;
		s := det3 ( v. X, b. X, a. X - q. X,
    v. Y, b. Y, a. Y - q. Y,
    v. z, b. z, a. z - q. z) / D;
    
    If (r < 0) Or (s < 0) Or (r > 1) Or (s > 1) Or (s + r > 1) Then
      intersect := False;
  End Else Begin
    t := - 1;
    intersect := False;
  End;
End;
Function rt_obj_kreis. intersect (ray: RT_ray; tiefe: Integer; Var p: RT_point; Var t: Double): Boolean;
Var D: Double;
  r, s: Double;
  Q, V: rt_vector;
  hit: Boolean;
Begin
  q := rt_vector (ray. q);
  v := rt_vector (ray. v);
  
	intersect := True;
  hit := rt_obj_plane. intersect (ray, tiefe, p, t);
  
  D := det3 ( v. X, b. X, c. X,
  v. Y, b. Y, c. Y,
  v. z, b. z, c. z);
  
  If hit Then Begin
    r := det3 ( v. X, a. X - q. X, c. X,
    v. Y, a. Y - q. Y, c. Y,
    v. z, a. z - q. z, c. z) / D;
    s := det3 ( v. X, b. X, a. X - q. X,
    v. Y, b. Y, a. Y - q. Y,
    v. z, b. z, a. z - q. z) / D;
    
    If (r * r + s * s > 1) Then
      intersect := False;
  End Else Begin
    t := - 1;
    intersect := False;
  End;
End;

Begin
End.