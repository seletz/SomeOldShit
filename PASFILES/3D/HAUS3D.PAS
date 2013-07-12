Program haus3D;
Uses crt, graph, sgraph, matrix44, VIEWUNIT;
Const
  sqrt2=1.4142135;
{$define haus}

  {$ifdef wurfel }
  faktorx = 15;
  faktory = 15;
  {$endif}

  {$ifdef haus }
  faktorx = 10;
  faktory = 10;
  {$endif         }

  {$ifdef wurfel }
  punkte = 8;
  haus_punkte: Array [1..punkte] Of vektor4 =
  (
  ( - 0.5, - 0.5, - 0.5, 1),
  (0.5, - 0.5, - 0.5, 1),
  (0.5, 0.5, - 0.5, 1),
  ( - 0.5, 0.5, - 0.5, 1),
  ( - 0.5, - 0.5, 0.5, 1),
  (0.5, - 0.5, 0.5, 1),
  (0.5, 0.5, 0.5, 1),
  ( - 0.5, 0.5, 0.5, 1)
  );
  linien = 12;
  haus_linien: Array [1..linien, 1..2] Of Integer =
  (
  (1, 2),
  (2, 3),
  (3, 4),
  (4, 1),
  (5, 6),
  (6, 7),
  (7, 8),
  (8, 5),
  (1, 5),
  (2, 6),
  (3, 7),
  (4, 8)
  );
  {$endif         }

  {$ifdef haus }

  punkte = 10;
  haus_punkte: Array [1..10] Of vektor4 =
  (
  (0, 0, 30, 1), (0, 10, 30, 1),
  (8, 16, 30, 1), (16, 10, 30, 1),
  (16, 0, 30, 1),
  (0, 0, 54, 1), (0, 10, 54, 1),
  (8, 16, 54, 1), (16, 10, 54, 1),
  (16, 0, 54, 1)
  );
  linien = 15;
  haus_linien: Array [1..15, 1..2] Of Integer =
  (
  (1, 2),
  (2, 3),
  (3, 4),
  (4, 5),
  (5, 1),
  (6, 7),
  (7, 8),
  (8, 9),
  (9, 10),
  (10, 6),
  (1, 6),
  (2, 7),
  (3, 8),
  (4, 9),
  (5, 10)
  );

  VRP: vektor4 = (8, 8, 54, 1);
  VPN: vektor4 = (1, 0, 1, 1);
  VUP: vektor4 = (0, 1, 0, 1);
  PRP: vektor4 = (0, 30, 30, 1);
  WindowWC: t_win = (  -1, 17, -1, 17 );
  WindowBS: t_win = (  0, 500, 0, 500 );
  {$endif         }

  {$ifdef wurfel }
  VRP: vektor4 = (0, 0, 0, 1);
  VPN: vektor4 = (1, 0, 1, 1);
  VUP: vektor4 = (0, 1, 0, 1);
  PRP: vektor4 = (0, 0, 1, 1);
  WindowWC: t_win = (  - 50, 50, - 50, 50 );
  WindowBS: t_win = (  0, 500, 0, 500 );
  {$endif         }

Procedure linep (p1, p2: vektor4);
Begin
  homogenize (@p1);
  p1 [1] := p1 [1];
  p1 [2] := p1 [2];
  homogenize (@p2);
  p2 [1] := p2 [1];
  p2 [2] := p2 [2];

  SetColor (1);
  Line
  (
  Round (p1 [1] * faktorx ) + GetMaxX Div 2, - Round (p1 [2] * faktory ) + GetMaxY Div 2,
  Round (p2 [1] * faktorx ) + GetMaxX Div 2, - Round (p2 [2] * faktory ) + GetMaxY Div 2
  );
End;
Var
  ende:boolean;
  wahl:char;
  view: o_view;
  p: vektor4;
  p_: Array [1..punkte] Of vektor4;
  i: Integer;

Begin
  ClrScr;


  view. init (@VUP, @VPN, @VRP, @PRP, WindowWC,WindowBS);


  For i := 1 To punkte Do
  Begin
    view.dreid_to_bs(@haus_punkte[i],@p_[i]);
    write_p ('p_', @p_[i] );
  End;
  ReadLn;
  grafikein;
  while not ende do
  begin
  For i := 1 To linien Do
  Begin
    linep
    (
    p_ [haus_linien [i] [1] ],
    p_ [haus_linien [i] [2] ]
    );
  End;
  repeat until keypressed;
  wahl:=readkey;

  ende:=true;
  end;

  grafikaus;
End.