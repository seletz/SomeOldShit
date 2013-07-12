Program tensor_draw;
Uses crt, graph, sgraph2, matrix44, viewunit, objektun;
Const
  anzahl = 10;
Type
  tensor_p = ^tensor_t;
  tensor_t = Array [1..10, 1..10, 1..10] Of vektor4;
Const
  vparam: t_view_parameter = (
	vup: (0, 1, 0, 1);
  vpn: (0, 0, 1, 1);
  vrp: (-2, 0, 0, 1);
  prp: (-2, 0, 25, 1);
  windowwc: ( - 15, 15, - 15, 15);
  windowbs: (10, 400, 10, 400)
  );

  x_start: Double = - 15;
  y_start: Double = - 15;
  z_start: Double = - 15;

  x_end: Double = 15;
  y_end: Double = 15;
  z_end: Double = 15;

  Q1v: vektor4 = ( 0.2, 0, 0, 1);
  Q2v: vektor4 = ( 0.2, 0, 0, 1);
  Q1: Double = 0;
  Q2: Double = 2;
  konstante: Double = 20;
  max_betrag:double=1;
	pfeil_punkte:array [1..6] of vektor4=( (-0.5,0,0,1),
                                         (+0.5,0,0,1),
                                         (+0.2,-0.2,0,1),
                                         (+0.2,0,-0.2,1),
                                         (+0.2,+0.2,0,1),
                                         (+0.2,0,+0.2,1)
  																			);
  pfeil_linien:array [1..9,1..2] of integer=( (1,2),
                                              (2,3),
                                              (2,4),
                                              (2,5),
                                              (2,6),
  																						(3,4),
                                              (4,5),
                                              (5,6),
                                              (6,3)
  																					 );


(************************************************************************)
Function tensor_zero (tp: tensor_p): tensor_p;
Var i, j, k: Integer;
Begin
  For i := 1 To 10 Do
    For j := 1 To 10 Do
      For k := 1 To 10 Do
        vzero (@ (tp^ [i, j, k] ) );
End;
(************************************************************************)
Function f (punkt: p_vektor4; erg: p_vektor4): p_vektor4;
Var
  r1v, r2v: vektor4;
  r1, r2: Double;
  betrag1, betrag2: Double;
Begin
  p2v (@Q1v, punkt, @r1v); (* Richtungsvektoren *)
  p2v (@Q2v, punkt, @r2v);

  r1 := vabs3 (@r1v); 			 (* Abstand *)
  r2 := vabs3 (@r2v);

  betrag1 := -konstante * (Q1) / (r1*r1);
  betrag2 := -konstante * (Q2) / (r2*r2);
  (*
  writeln('betrag1, betrag2 : ',betrag1:3,' ',betrag2:3);
  *)

  vnorm (@r1v, @r1v);
  vnorm (@r2v, @r2v);

  vmul (betrag1, @r1v, @r1v);
  vmul (betrag2, @r2v, @r2v);

  vadd (@r1v, @r2v, erg);

End;
(************************************************************************)
Procedure berechne_tensor (tp: tensor_p; vp: p_view_parameter);
Var
  sx, sy, sz, DX, dy, dz: Real; 	(* startwerte, schrittweite *)
  xp, yp, zp: Double; 				 		(* position *)
  i,j,k:integer;                  (* inidizes *)
  p:vektor4;
Begin
  sx := x_start; sy := y_start; sz := z_start;
  DX := (x_end - x_start) / anzahl;
  dy := (y_end - y_start) / anzahl;
  dz := (z_end - z_start) / anzahl;

  i:=1;
  xp := sx;
  While xp < x_end Do
  Begin
  	 yp := sy; j:=1;
    While yp < y_end Do
    Begin
    	zp := sz; k:=1;
      While zp < z_end Do
      Begin
      	put_vektor(xp,yp,zp,@p);
        f(@p,@tp^[i,j,k]);
        (*
        writeln('i , j , k  : ',i,' ',j,' ',k);
        writeln('xp, yp, zp : ',xp:3,' ',yp:3,' ',zp:3);
        write_p('tp[]: ',@tp^[i,j,k]);
        *)
      	zp:=zp+dz; inc(k)
      End;
      (*
      writeln('i , j , k  : ',i,' ',j,' ',k);
        *)
      yp:=yp+dy; inc(j)
    End;
    xp:=xp+dx; inc(i)
  End;
End;
(************************************************************************)
function make_arrow(xp,yp,zp:double; tp:p_vektor4; op:p_objekt):p_objekt;
var
	dummy,r,rz,ry:matrix4;
  t,s:matrix4;
  sphi,cphi,sgamma,cgamma,betrag:double;
  v:vektor4;
  vp:p_vektor4;

  i:integer;
begin
  vp:=@v;
  copy_vektor(tp,vp);
  betrag:=vabs3(vp);
  vp:=vnorm(vp,vp);
  { Winkel berechnen; d.h.kugelkoordinaten ber.
  sphi:=v[1]/(sqrt(v[1]*v[1]+v[3]*v[3]));
  cphi:=v[3]/(sqrt(v[1]*v[1]+v[3]*v[3]));
  }
  sphi:=v[3];
  cphi:=v[1];
  sgamma:=v[2];
  cgamma:=v[1]; {sqrt(v[3]*v[3]+v[2]*v[2]);}


  midentity(@ry);
  midentity(@rz);
  midentity(@s);
  midentity(@t);
  midentity(@dummy);

  { cos phi = vz; sin phi=vx; sin gamma=vy; cos gamma=sin gamma - pi/2

  }

  { rotation um z}
  rz[1,1]:=cgamma; rz[1,2]:=-sgamma;
  rz[2,1]:=sgamma; rz[2,1]:=cgamma;

  { rotation um y
  ry[1,1]:=cphi; ry[1,3]:=sphi;
  ry[3,1]:=-sphi; ry[3,3]:=cphi;

  { skalieren
  if betrag>max_betrag then betrag:=max_betrag;
  s[1,1]:=betrag;
  s[2,2]:=betrag;
  s[3,3]:=betrag;}

  { translation }
  t[1,4]:=xp;
  t[2,4]:=yp;
  t[3,4]:=zp;

  { R=T*ry*RZ*S}
  mdotm(@t,@ry,@dummy);
  mdotm(@dummy,@rz,@dummy);
  mdotm(@dummy,@s,@r);

  for i:=1 to 6 do begin
    vp:=mdotv(@R,@pfeil_punkte[i],vp);
    op^.add_point_k(v[1],v[2],v[3])
  end;

  for i:=1 to 9 do begin
  	op^.add_line(pfeil_linien[i,1],pfeil_linien[i,2])
  end;

end;
(************************************************************************)
Procedure zeichne_tensor (tp: tensor_p; vp: p_view);
Var
  sx, sy, sz, DX, dy, dz: Real; 	(* startwerte, schrittweite *)
  xp, yp, zp: Double; 				 		(* position *)
  i,j,k:integer;                  (* inidizes *)
  p:vektor4;
  pfeil_p:p_objekt;
Begin
  sx := x_start; sy := y_start; sz := z_start;
  DX := (x_end - x_start) / anzahl;
  dy := (y_end - y_start) / anzahl;
  dz := (z_end - z_start) / anzahl;

  i:=1;
  xp := sx;
  While xp < x_end Do
  Begin
  	 yp := sy; j:=1;
    While yp < y_end Do
    Begin
{    	zp := sz; k:=1;
      While zp < z_end Do
      Begin
     } zp:=0; k:=5;

      	pfeil_p:=new(p_objekt, init('pfeil',i*j*k+i+j+k) );

        make_arrow(xp,yp,zp,@tp^[i,j,k],pfeil_p);
        vp^.draw_object(pfeil_p);

        pfeil_p^.done;

{      	zp:=zp+dz; inc(k)
      End;}
      yp:=yp+dy; inc(j)
    End;
    xp:=xp+dx; inc(i)
  End;
End;
Var
  tensor: tensor_t;
  view:o_view;
  kasten,ladung1,ladung2:o_objekt;
  l1,l2:vektor4;
  i,j,k:integer;
(************************************************************************)
procedure make_objects;
begin
  kasten.init('kasten',-1);
  kasten.add_point_k(x_start,y_start,z_start);
  kasten.add_point_k(x_start,y_start,z_end);
  kasten.add_point_k(x_start,y_end,z_end);
  kasten.add_point_k(x_start,y_end,z_start);
  kasten.add_point_k(x_end,y_start,z_start);
  kasten.add_point_k(x_end,y_start,z_end);
  kasten.add_point_k(x_end,y_end,z_end);
  kasten.add_point_k(x_end,y_end,z_start);
  kasten.add_line(1,2);
  kasten.add_line(2,3);
  kasten.add_line(3,4);
  kasten.add_line(4,1);
  kasten.add_line(5,6);
  kasten.add_line(6,7);
  kasten.add_line(7,8);
  kasten.add_line(8,5);
  kasten.add_line(1,5);
  kasten.add_line(2,6);
  kasten.add_line(3,7);
  kasten.add_line(4,8);

  ladung1.init('ladung1',-2);
  ladung1.add_point_k(l1[1]-2,l1[2]+0,l1[3]+0);
  ladung1.add_point_k(l1[1]+2,l1[2]+0,l1[3]+0);
  ladung1.add_point_k(l1[1]+0,l1[2]-2,l1[3]+0);
  ladung1.add_point_k(l1[1]+0,l1[2]+2,l1[3]+0);
  ladung1.add_point_k(l1[1]+0,l1[2]+0,l1[3]-2);
  ladung1.add_point_k(l1[1]+0,l1[2]+0,l1[3]+2);
  ladung1.add_line(1,2);
  ladung1.add_line(3,4);
  ladung1.add_line(5,6);

  ladung2.init('ladung2',-3);
  ladung2.add_point_k(l2[1]-2,l2[2]+0,l2[3]+0);
  ladung2.add_point_k(l2[1]+2,l2[2]+0,l2[3]+0);
  ladung2.add_point_k(l2[1]+0,l2[2]-2,l2[3]+0);
  ladung2.add_point_k(l2[1]+0,l2[2]+2,l2[3]+0);
  ladung2.add_point_k(l2[1]+0,l2[2]+0,l2[3]-2);
  ladung2.add_point_k(l2[1]+0,l2[2]+0,l2[3]+2);
  ladung2.add_line(1,2);
  ladung2.add_line(3,4);
  ladung2.add_line(5,6);
end;
(************************************************************************)
Begin
	l1:=q1v; l2:=q2v;
	clrscr;
  tensor_zero(@tensor);
  write('Start...');
  berechne_tensor(@tensor,@vparam);
  writeln('fertig.');
  readln;

  make_objects;

  view.init(@vparam);
  grafikein;
  view.draw_window;

  setcolor(3);
  view.draw_object(@kasten);

  setcolor(4);
  view.draw_object(@ladung1);
	view.draw_object(@ladung2);

  setcolor(2);
  zeichne_tensor(@tensor,@view);

  readln;
  grafikaus;
  ladung1.done;
  ladung2.done;
  kasten.done;
End.