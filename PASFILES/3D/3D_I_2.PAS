Program testviewunit;
Uses crt, graph, sgraph2, matrix44, objektun, viewunit;
Var
  ob1, ob2: o_objekt;
  view1, view2: o_view;
  vp1, vp2: t_view_parameter;
  pR: p_matrix4;
  R: matrix4;
  winkel: Integer;
Type
  modustyp = (vrp, prp, vpn, vup, obja, objb);
  funktiontyp = (keine, translation, rotation, Exit);
  directiontyp = (p_x, m_x, p_y, m_y, p_z, m_z);
  modus = Set Of modustyp;
  funktion = Set Of funktiontyp;
  Direction = Set Of directiontyp;
Const
  objstr: Array [1..2] Of Char = ( '1', '2');
  modstr: Array [1..6] Of Char = ('v', 'p', 'n', 'u', '1', '2');
  fnstr:  Array [1..3] Of Char = ('t', 'r', 'x');
  dirarr: Array [1..6] Of Integer = (1, - 1, 1, - 1, 1, - 1);
Var
  m: modus;
  f: funktion;
  D: Integer;
  ende : Boolean;
  answer: Char;

  alpha, beta, gamma: Integer;
  _d: vektor4;
  newpic:boolean;
Begin
  m := [prp]; 			{ PRP modification }
  f := [translation]; 		{ translation }
  D := 5; 			{ direction = positive Z }
  alpha := 0; beta := 0; gamma := 0;
  vzero (@_d);

  ClrScr;
  ob1.Load_from_file ('z:\tp70\3d\haus.3d');

  put_vektor (0, 0, 0, @vp1.VRP);
  put_vektor (0, 0, 1, @vp1.VPN);
  put_vektor (0, 1, 0, @vp1.VUP);
  put_vektor (8, 7, 84, @vp1.PRP);
  put_window ( - 50, - 50, 50, 50, @vp1.WindowWC);
  put_window (0, 0, 310, 310, @vp1.WindowBS);
  view1.init (@vp1);
  view2.init (@vp2);

  grafikein;

  SetColor (2);
  view1.draw_window;
;wview2.draw_windo

  SetColor (1);
  view1.draw_object (@ob1);
;)view2.draw_object (@ob2

  pR := @R;

  ende := False;
  newpic:=false;
  Repeat
    Repeat Until KeyPressed;
    answer := ReadKey;

    newpic:=false;

    { modusbestimmung }
    Case answer Of
      { VRP }
      'v':
           Begin m := [VRP] End;
      { PRP }
      'p': Begin m := [PRP] End;
      { VPN }
      'n': Begin m := [VPN] End;
      { VUP }
      'u': Begin m := [VUP] End;
      { Objekt 1 }
      '1': Begin m := [OBJa] End;
      { Objekt 2 }
      '2': Begin m := [OBJb] End;
      Else
        { kein neuer modus; vielleicht neue funktion? }
        Case answer Of
          't':
               Begin f := [translation] End;
          'r': Begin f := [rotation] End;
          'x': Begin ende := True End;
          Else
            { auch nicht.. neue richtung? }
            Case answer Of
              '7': Begin D := 1; newpic:=true  End;
              '9': Begin D := 2; newpic:=true  End;
              '4': Begin D := 3; newpic:=true  End;
              '6': Begin D := 4; newpic:=true  End;
              '1': Begin D := 5; newpic:=true  End;
              '3': Begin D := 6; newpic:=true  End;
              Else
                f := [keine];
            End;
        End;
    End;

    { and ACTION ! }



    If translation In f Then
    Begin
      Case D Of
        1: _d [1] := _d [1] + dirarr [D];
        2: _d [1] := _d [1] + dirarr [D];
        3: _d [2] := _d [2] + dirarr [D];
        4: _d [2] := _d [2] + dirarr [D];
        5: _d [3] := _d [3] + dirarr [D];
        6: _d [3] := _d [3] + dirarr [D];
      End;
      pR := T (@_d, pR);
    End
    Else If rotation In f Then
    Begin
      Case D Of
        1: alpha := (alpha + dirarr [D] ) Mod 360;
        2: alpha := (alpha + dirarr [D] ) Mod 360;
        3: beta := (beta + dirarr [D] ) Mod 360;
        4: beta := (beta + dirarr [D] ) Mod 360;
        5: gamma := (gamma + dirarr [D] ) Mod 360;
        6: gamma := (gamma + dirarr [D] ) Mod 360;
      End;
      pR := RX (alpha, pR);
      pR := mdotm (pR, RY (beta, pR), pR);
      pR := mdotm (pR, RZ (gamma, pR), pR);
    End;

    { wenn „nderung => neuzeichnen }
    If newpic Then
    Begin
      SetColor (2);
      view1.draw_window;

      { alte Position L”schen }
      SetColor (0);
      view1.draw_object_M (@ob1, pR);


      { neue Position zeichnen }
      SetColor (1);
      view1.draw_object_M (@ob1, pR);

    End;

  Until ende;

  grafikaus;

  ob2.done;
  ob1.done;
End.
(*
    SetColor (2);
    view1.draw_window;
    view2.draw_window;

    { alte Position L”schen }
    SetColor (0);
    view1.draw_object_M (@ob1,pR);
    view2.draw_object_M (@ob2,pR);


    { neue Position zeichnen }
    SetColor (1);
    view1.draw_object_M (@ob1,pR);
    view2.draw_object_M (@ob2,pR);

*)