Unit prim_obj;
Interface
Uses crt, matrix44, liste, liste_3D, obj_3D;
Procedure gen_ellipse3D (o, a, b: p_vektor4; n, start, farbe: Integer; obj: obj_3d_p);
Implementation
(*
 * 	Ellipse im R3;	O...Ortsvektor A,B...Achsen
 *									n...Anzahl Punkte start...startnummer
 *
 *
 *)
Procedure gen_ellipse3D (o, a, b: p_vektor4; n, start, farbe: Integer; obj: obj_3d_p);
Var
  w, cw, sw, D, DX, dy, dz: Double;
  i,count: integer;
  p:punkt_p;
  l:linie_p;
Begin
	count:=start;
  if count=-1 then
  	count:=punkt_p(obj^.pl.first)^.nummer+1;
  p:=new(punkt_p, init);
  p^.set_nummer(count); inc(count);
  p^.set_k(o^[1]+a^[1],o^[2]+a^[2],o^[3]+a^[3]);
  obj^.pushpunkt(p);

  w := Pi * 2 / n;
  D := w;
  Repeat
  	cw:=cos(w); sw:=sin(w);
  	dx:=o^[1]+a^[1]*cw+b^[1]*sw;
  	dy:=o^[2]+a^[2]*cw+b^[2]*sw;
  	dz:=o^[3]+a^[3]*cw+b^[3]*sw;
    p:=new(punkt_p, init);
		p^.set_k(dx,dy,dz);
    p^.set_nummer(count); inc(count);
  	obj^.pushpunkt(p);
    w:=w+d;
  Until (w >= (Pi * 2 + D / 2) );
  i:=start;
  l:=new(linie_p, init);
  l^.set_ab(count-1,start);
  l^.set_farbe(farbe);
  obj^.pushlinie(l);
  while (i<(count-1)) do
  begin
    l:=new(linie_p, init);
	  l^.set_ab(i,i+1);
  	l^.set_farbe(farbe);
  	obj^.pushlinie(l);

  	i:=i+1;
  end;
End;

Begin
End.