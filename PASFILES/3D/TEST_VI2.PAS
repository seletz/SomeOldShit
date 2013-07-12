Program testviewunit;
Uses crt, graph, sgraph2, matrix44, objektun, viewunit;
Var
  ob1, ob2: o_objekt;
  view1, view2: o_view;
  vp1, vp2: t_view_parameter;
Begin
  ClrScr;
  ob1.Load_from_file ('z:\tp70\3d\haus.3d');
  ob2.Load_from_file ('z:\tp70\3d\wurfel.3d');

  {
  	FÅr Haus

  }

  put_vektor (16, 8, 54, @vp1.VRP);
  put_vektor (1, 1, 1, @vp1.VPN);
  put_vektor (0, 1, 0, @vp1.VUP);
  put_vektor (0, 25, 28, @vp1.PRP);
  put_window ( 20, 20, 80, 80, @vp1.WindowWC);
  put_window (0, 0, 310, 310, @vp1.WindowBS);

  put_vektor (1, 0.5, 1, @vp2.VRP);
  put_vektor (0.5, 0, 1, @vp2.VPN);
  put_vektor (0, 1, 0, @vp2.VUP);
  put_vektor (0, 0, 3, @vp2.PRP);
  put_window (  0, 0, 1, 1, @vp2.WindowWC);
  put_window (350, 0, 629, 310, @vp2.WindowBS);

  view1.init (@vp1);
  view2.init (@vp2);

  WriteLn ('Press any key...');
  ReadLn;
  
  { $ifndef debug_testview2}
  grafikein;
  { $endif}

  { $ifndef debug_testview2}
  setcolor(2);
  view1.draw_window;
  setcolor(1);
  { $endif}
  view1.draw_object (@ob1);

  { $ifndef debug_testview2}
  setcolor(2);
  view2.draw_window;
  setcolor(1);
  { $endif}
  view2.draw_object (@ob2);
  ReadLn;

  { $ifndef debug_testview2}
  grafikaus;
  { $endif}

  ob2.done;
  ob1.done;
End.
