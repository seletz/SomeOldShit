Program testm4X4;
Uses crt, matrix44;
Const
  winkel = 30;
  MK: matrix4 = ( (1, 2, 3, 9), (3, 4, 6, 8), (6, 3, 2, 7), (5, 3, 2, 6) );
  win:t_win=(50,-50,50,-50);
Var
  ok: Boolean;
  i, j, k: Integer;
  R, M, MT: Matrix4;
  R_, M_, MT_: p_matrix4;
  p, p0, p1, p2, p3, pv: vektor4;
  p_, p0_, p1_, p2_, p3_, pv_: p_vektor4;
  view:o_view;
Begin

  R_ := @R;
  M_ := @M;
  MT_ := @MT;
  P_ := @P;
  P0_ := @P0;
  P1_ := @P1;
  P2_ := @P2;
  P3_ := @P3;
  Pv_ := @Pv;
{
  copy_matrix (@E4, M_);
  
  ClrScr;
  
  WriteLn ('Verschiebe P  um Pv ');
  WriteLn;
  WriteLn;

  put_vektor (0, 0, 1, p_);
  put_vektor (5, 5, 5, pv_);
  
  write_p ('p   ', p_);
  WriteLn;
  
  T (PV_, MT_);
  mdotm (MT_, M_, M_);
  
  Write_m ('T ', MT_);
  WriteLn;
  Write_m ('M ', M_);
  
  mdotv (MT_, P_, P0_);
  
  WriteLn;
  write_p ('p  ', P0_);
  ReadLn;
  
  ClrScr;

  WriteLn ('Rotiere P ', winkel, '¯ um die X-Achse');
  WriteLn;
  WriteLn;
  write_p ('p   ', p0_);
  WriteLn;
  RX (winkel, R_);
  mdotm (R_, M_, M_);
  Write_m ('RX', R_);
  WriteLn;
  Write_m ('M ', M_);
  mdotv (R_, P0_, P1_);
  WriteLn;
  write_p ('p*  ', P1_);
  ReadLn;
  
  ClrScr;
  
  WriteLn ('Rotiere P* ', winkel, '¯ um die Z-Achse');
  WriteLn;
  WriteLn;
  write_p ('p*  ', p1_);
  WriteLn;
  RZ (winkel, R_);
  mdotm (R_, M_, M_);
  Write_m ('RZ', R_);
  WriteLn;
  Write_m ('M ', M_);
  mdotv (R_, P1_, P2_);
  WriteLn;
  write_p ('p** ', p2_);
  ReadLn;
  
  ClrScr;

  WriteLn ('Rotiere P*** ', winkel, '¯ um die Y-Achse');
  WriteLn;
  WriteLn;
  write_p ('p** ', p2_);
  WriteLn;
  RY (winkel, R_);
  mdotm (R_, M_, M_);
  Write_m ('RY', R_);
  WriteLn;
  Write_m ('M ', M_);
  mdotv (R_, P2_, P3_);
  WriteLn;
  write_p ('p***', p3_);
  ReadLn;

  ClrScr;

  WriteLn ('Rotiere P um die XYZ-Achsen mit einer Matrix');
  WriteLn;
  WriteLn;
  write_p ('p   ', p_);
  write_p ('p***', p3_);
  put_vektor (0, 0, 0, p3_);
  WriteLn;
  WriteLn;
  mdotv (M_, P_, P3_);
  Write_m ('M=RY.RZ.RX.T', M_);
  write_p ('p***', p3_);
  ReadLn;

  ClrScr;
  WriteLn ('Und wieder zurÅck mit der Inversen Matrix');
  WriteLn;
  WriteLn;
  write_p ('p   ', p_);
  write_p ('p***', p3_);
  put_vektor (0, 0, 0, p_);
  WriteLn;
  minv (@M, MT_);
  WriteLn;
  mdotv (MT_, P3_, P_);
  Write_m ('X=M^(-1)', MT_);
  write_p ('p   ', p_);
  ReadLn;
}

  put_vektor (0, 1, 0, p_);
  put_vektor (0, 0, 1, p1_);
  put_vektor (0, 0, 0, p2_);
  put_vektor (0, 0, 5, p3_);

  ClrScr;
  WriteLn ('kreuzprodukt:');
  WriteLn;
  WriteLn;
  vcross(p_,p1_,p2_);
  write_p('a',p_);
  write_p('b',p1_);
  write_p('a x b',p2_);
  readln;
  ClrScr;
  WriteLn ('Transformationsmatrix:');
  WriteLn;
  WriteLn;
  write_p ('VUP ', p_);
  write_p ('VPN ', p1_);
  write_p ('VRP ', p2_);
  write_p ('PRP ', p3_);
  view.init(p_,p1_,p2_,p3_,win);
  WriteLn;
  MT_:=view.gimme_mtr;
  Write_m ('Mtr', MT_);
  ReadLn;



End.
