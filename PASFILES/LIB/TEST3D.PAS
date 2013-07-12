program test3d;
uses crt, sgraph2, matrix44, liste_3d, obj_3d, prim_obj, viewunit;
const
	vp:viewparameter_t=( VUP: (0, 1, 0, 1);
											 VPN: (0, 0, 1, 1);
											 VRP: (0, 0, 0, 1);
                       PRP: (10, 10, 30, 1);
                       WindowWC: (-15,15,-15,15);
                       WindowBS: (10,400,10,400)
                     );
	o:vektor4=(0,0,0,1);
  a1:vektor4=(10,0,0,1);
  b1:vektor4=(0,0,5,1);
  a2:vektor4=(10,0,0,1);
  b2:vektor4=(0,5,0,1);
  a3:vektor4=(0,0,5,1);
  b3:vektor4=(0,5,0,1);
var
	ellipse:obj_3d_t;
  view:view_t;
begin
	clrscr;
	ellipse.init('Ellipse');
  gen_ellipse3d(@o,@a1,@b1,36,1,2,@ellipse);
  gen_ellipse3d(@o,@a2,@b2,36,-1,3,@ellipse);
  gen_ellipse3d(@o,@a3,@b3,36,-1,4,@ellipse);
  ellipse.print;

  readln;
  view.init(@vp);

  grafikein;
  view.draw_window;
  view.draw_object(@ellipse);
  readln;
  grafikaus;

  view.done;
  ellipse.done;
end.