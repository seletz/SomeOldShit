program test_view;
uses crt,matrix44;
const
  VRP: vektor4 = (0, 0, 0, 1);
  VPN: vektor4 = (0, 0, 1, 1);
  VUP: vektor4 = (0, 1, 0, 1);
  PRP: vektor4 = (4, 2, 7, 1);
  Q  : vektor4 = (-6, 3, -8, 1);

  WindowWC: t_win = (  - 50, 50, - 50, 50 );
  WindowBS: t_win = (  0, 500, 0, 500 );
var
Qp:vektor4;
view:o_view;
begin
     clrscr;

     view.init(@VUP,@VPN,@VRP,@PRP,WindowWC,WindowBS);

     write_p('Q ',@Q);
     write_p('Qp',view.dreiD_to_BS(@Q,@Qp));

     readln;
end.