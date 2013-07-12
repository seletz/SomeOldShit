Program testviewunit;
Uses crt, graph, sgraph2, matrix44, objektun, viewunit;
Var
  ob1, ob2: o_objekt;
  view1, view2: o_view;
  vp1, vp2: t_view_parameter;
  pR:p_matrix4;
  R: matrix4;
  winkel:integer;
Begin
  ClrScr;
  ob1.Load_from_file ('z:\tp70\3d\haus.3d');
  ob2.Load_from_file ('z:\tp70\3d\wurfel.3d');

  put_vektor (0, 0, 0, @vp1.VRP);
  put_vektor (0, 0, 1, @vp1.VPN);
  put_vektor (0, 1, 0, @vp1.VUP);
  put_vektor (8, 7, 84, @vp1.PRP);
  put_window ( -50, -50, 50, 50, @vp1.WindowWC);
  put_window (0, 0, 310, 310, @vp1.WindowBS);

  put_vektor (1, 0.5, 1, @vp2.VRP);
  put_vektor (0.5, 0, 1, @vp2.VPN);
  put_vektor (0, 1, 0, @vp2.VUP);
  put_vektor (0, 0, 3, @vp2.PRP);
  put_window (  - 0.5, - 0.5, 1.5, 1.5, @vp2.WindowWC);
  put_window (350, 0, 629, 310, @vp2.WindowBS);

  view1.init (@vp1);
  view2.init (@vp2);

  grafikein;

  pR:=@R;

  Repeat
    SetColor (2);
    view1.draw_window;
    view2.draw_window;

    { alte Position L”schen }
    SetColor (0);
    view1.draw_object_M (@ob1,pR);
    view2.draw_object_M (@ob2,pR);

    { RotationsMatrix neu berechnen }
    winkel:=(winkel + 1) mod 360;
    pR:=RY(winkel,@R);	{ Rotationsmatrix RX(1ø) }

    { neue Position zeichnen }
    SetColor (1);
    view1.draw_object_M (@ob1,pR);
    view2.draw_object_M (@ob2,pR);

  Until KeyPressed;
  ReadLn;

  grafikaus;

  ob2.done;
  ob1.done;
End.
