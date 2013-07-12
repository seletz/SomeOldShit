Unit viewunit;
(*==========================================================================*
 *                                                                          *
 *                                                                          *
 *   Viewunit: erstellt am 17.7.1994                                        *
 *                                                                          *
 *                                                                          *
 *   o_view: View-Objekt, mit Gafikfenster etc.                             *
 *                                                                          *
 *                                                                          *
 *                                                                          *
 *                                                                          *
 *                                                                          *
 *                                                                          *
 *                                                                          *
 *                                                                          *
 *                                                                          *
 *                                                                          *
 *                                                                          *
 *                                                                          *
 *                                                                          *
 *                                                                          *
 *                                                                          *
 *                                                                          *
 *                                                                          *
 *==========================================================================*)
{ debug_viewunit}
Interface

Uses crt, matrix44, graph, sgraph2, objektun;
Type
  p_view_parameter = ^t_view_parameter;
  t_view_parameter = Record
                       VUP, VPN, VRP: vektor4;
                       PRP: vektor4;
                       WindowWC: t_win;
                       WindowBS: t_win;
                     End;
  o_view = Object
             PRP, CW: vektor4;
             PRP_: vektor4;
             VUP, VPN, VRP: vektor4;
             DOP: vektor4;
             WindowWC: t_win;
             WindowBS: t_win;
             Mtr, Mbs: matrix4;
             Constructor init (ivpar:p_view_parameter);

             Procedure draw_window;
             Procedure draw_object (obj: p_objekt);
             Procedure draw_object_m (obj: p_objekt; M:p_matrix4);

             Function gimme_Mtr: p_matrix4;
             Function dreiD_to_BS (Q, Qp: p_vektor4): p_vektor4;
           End;

Implementation

(*=========================================*
 *                                         *
 *        View-Objekt                      *
 *                                         *
 *                                         *
 *=========================================*)

Constructor o_view. init;
Var
  RA, RB, RC, vt: vektor4;
  Tvrp, R, Mper, Svp: matrix4;
Begin
  copy_vektor (@ivpar^.vup, @vup);
  copy_vektor (@ivpar^.vpn, @vpn);
  copy_vektor (@ivpar^.vrp, @vrp);
  copy_vektor (@ivpar^.prp, @prp);

  WindowWC := ivpar^.WindowWC;
  WindowBS := ivpar^.WindowBS;

  midentity (@Mtr);
  midentity (@Mbs);

  put_vektor ( (WindowWC [2] + WindowWC [1] ) / 2, (WindowWC [4] + WindowWC [3] ) / 2, 0, @CW);
  p2v (@PRP, @CW, @DOP);

  {$ifdef debug_viewunit}
  WriteLn ('View.Init:');
  write_p ('VUP', @VUP);
  write_p ('VPN', @VPN);
  write_p ('VRP', @VRP);
  write_p ('PRP', @PRP);
  WriteLn;
  write_P ('CW ', @cw);
  write_P ('DOP', @DOP);
  {$endif}

  { T(-VRP) }
  T (vneg (@VRP, @vt), @Tvrp);

  { R }
  midentity (@R);
  vnorm (@VPN, @RC);
  vnorm (vcross (@VUP, @RC, @vt), @RA);
  vcross (@RC, @RA, @RB);
  put_row (1, @RA, @R);
  put_row (2, @RB, @R);
  put_row (3, @RC, @R);
  R [1] [4] := 0;
  R [2] [4] := 0;
  R [3] [4] := 0;

  { Mtr }
  mdotm (@Tvrp, @Mtr, @Mtr);
  mdotm (@R, @Mtr, @Mtr);

  { Svp }
  S
  (
  put_vektor (
  (WindowBS [2] - WindowBS [1]) / (WindowWC [2] - WindowWC [1] ),
  (WindowBS [4] - WindowBS [3]) / (WindowWC [4] - WindowWC [3] ),
  1,
  @vt),
  @Svp
  );

  { Mbs }

  mdotm (@Svp, @Mbs, @Mbs);

  {$ifdef debug_viewunit}
  write_m ('View.Init     : Mtr', @Mtr);
  WriteLn;
  write_m ('                Mbs', @Mbs);
  ReadLn;
  {$endif}
End;
(*=========================================*
 *                                         *
 *                                         *
 *                                         *
 *                                         *
 *                                         *
 *=========================================*)
Procedure o_view. draw_window;
Const
  xmin = 1;
  ymin = 3;
  xmax = 2;
  ymax = 4;
Begin
  {$ifndef debug_viewunit}
  SetFillStyle (XhatchFill, 0);
  Bar (xmin, ymin, xmax, ymax);
  Line (
  Round (WindowBS [xmin] ), Round (WindowBS [ymin] ),
  Round (WindowBS [xmax] ), Round (WindowBS [ymin] )
  );
  Line (
  Round (WindowBS [xmin] ), Round (WindowBS [ymax] ),
  Round (WindowBS [xmax] ), Round (WindowBS [ymax] )
  );
  Line (
  Round (WindowBS [xmin] ), Round (WindowBS [ymin] ),
  Round (WindowBS [xmin] ), Round (WindowBS [ymax] )
  );
  Line (
  Round (WindowBS [xmax] ), Round (WindowBS [ymin] ),
  Round (WindowBS [xmax] ), Round (WindowBS [ymax] )
  );
  {$endif}
End;
(*=========================================*
 *                                         *
 *                                         *
 *                                         *
 *                                         *
 *                                         *
 *=========================================*)
Procedure o_view. draw_object;
Var
  i: Integer;
  p1,p2,p1_, p2_: vektor4;

Begin
  obj^. setfirst;
  For i := 1 To obj^. gimme_num_lines Do
  Begin
    copy_vektor(obj^. gimme_next,@p1);
    copy_vektor(obj^. gimme_next,@p2);

    dreiD_to_BS (@p1, @p1_);
    dreiD_to_BS (@p2, @p2_);

    {$ifdef debug_viewunit}
    Write_P('P1',@p1_);
    Write_P('P2',@p2_);
    {$else}

    CohenSutherlandLineClipAndDraw (p1_ [1], p1_ [2], p2_ [1], p2_ [2], WindowBS);
    {$endif}
  End;
End;
Procedure o_view. draw_object_m (obj: p_objekt; M:p_matrix4);
Var
  i: Integer;
  p1,p2,p1_, p2_: vektor4;

Begin
  obj^. setfirst;
  For i := 1 To obj^. gimme_num_lines Do
  Begin
    copy_vektor(obj^. gimme_next,@p1);
    copy_vektor(obj^. gimme_next,@p2);

    mdotv(M,@p1,@p1);
    mdotv(M,@p2,@p2);

    dreiD_to_BS (@p1, @p1_);
    dreiD_to_BS (@p2, @p2_);

    {$ifdef debug_viewunit}
    Write_P('P1',@p1_);
    Write_P('P2',@p2_);
    {$else}

    CohenSutherlandLineClipAndDraw (p1_ [1], p1_ [2], p2_ [1], p2_ [2], WindowBS);
    {$endif}
  End;
End;
(*=========================================*
 *                                         *
 *                                         *
 *                                         *
 *                                         *
 *                                         *
 *=========================================*)

Function o_view. gimme_Mtr: p_matrix4;
Begin
  gimme_mtr := @mtr;
End;
Function o_view. dreiD_to_BS (Q, Qp: p_vektor4): p_vektor4;
Var
  lambda, k: Double;
  Q_, V, vt: vektor4;
Begin
  mdotv (@Mtr, Q, @Q_);

  k := (Q_ [3] - PRP [3] );
  If k = 0 Then
  Begin
    k := (Q_ [2] - PRP [2] );
  End;
  If k = 0 Then
  Begin
    k := (Q_ [1] - PRP [1] );
  End;
  If k <> 0 Then
    lambda := - PRP [3] / k
  Else
    graphics_error ('o_View. dreiD_to_BS: t = infinity ! (-> Q==PRP ?) ');

  p2v (@PRP, @Q_, @V);
  Qp := vadd (@PRP, vmul (lambda, @V, @vt), Qp);

  {$ifdef debug_viewunit}
  WriteLn ('lambda=', lambda: 3: 3);
  write_p ('Q ', Q);
  write_p ('Q_', @Q_);
  write_p ('Qp', Qp);
  write_p ('V ', @V);
  {$endif}


  mdotv (@Mbs, Qp, Qp);

  dreiD_to_BS := Qp;
End;

Begin
End.