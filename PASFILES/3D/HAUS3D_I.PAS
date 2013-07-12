Program haus3D;
(*==========================================================================*
 *                                                                          *
 *                                                                          *
 *   HAUS3D_I: erstellt am 10-17.7.1994                                     *
 *                                                                          *
 *                                                                          *
 * o Interaktive Darstellung eines Hauses; zeigt Programmierung             *
 *   des View-Objekts in ViewUnit;                                          *
 *                                                                          *
 * o Benutzer kann Interaktiv die View-Parameter ver„ndern:                 *
 *                                                                          *
 *  Aktion: 't'.....Translation                                             *
 *          'r'.....Rotation                                                *
 *                                                                          *
 *  Modus : 'x','y','z'.........Rotiert um -10ø / Verschiebt um -1          *
 *          'X','Y','Z'......... dito nur +10ø oder +1                      *
 *                                                                          *
 *          'u'....VUP                                                      *
 *          'n'....VPN    'O'......stellt Original her                      *
 *          'r'....VRP                                                      *
 *          'p'....PRP				                                              *
 *          'o'....OBJEKT 		                                              *
 *                                                                          *
 *                                                                          *
 *          8                                                               *
 *          |                                                               *
 *        4-+-6 ..... bewegt Window                                         *
 *          |                                                               *
 *          2                                                               *
 *                                                                          *
 *        +/-   ..... Zoomt Window                                          *
 *                                                                          *
 * siehe auch ViewUnit.pas, Matrix44.pas                                    *
 *==========================================================================*)
Uses crt, graph, sgraph2, matrix44, viewunit;
Const
  {$undef  debug_haus3d}
  {$define wurfel  }


  a_rot = 1;
  a_trans = 2;

  m_prp = 1;
  m_vup = 2;
  m_vpn = 3;
  m_vrp = 4;
  m_obj = 5;
  m_win = 6;

  Sqrt2 = 1.4142135;

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
  {$endif}
  
  {$ifndef debug_haus3d }
Procedure linep (p1, p2: vektor4; w: t_win; c: Integer);
Begin
  SetColor (c);
  CohenSutherlandLineClipAndDraw (p1 [1],p1 [2],p2 [1],p2 [2], w);
End;
{$else}
Procedure linep (p1, p2: vektor4; w: t_win; c: Integer);
Begin
  homogenize (@p1);
  p1 [1] := p1 [1];
  p1 [2] := p1 [2];
  homogenize (@p2);
  p2 [1] := p2 [1];
  p2 [2] := p2 [2];
  
  WriteLn ('LineP:');
  write_p ('p1', @p1);
  write_p ('p2', @p2);
End;
{$endif}
Var
  view: o_view;
  M: matrix4;
  p_: Array [1..punkte] Of vektor4;
  modus: Integer;
  aktion: Integer;
  
  VRP: vektor4;
  VPN: vektor4 ;
  VUP: vektor4 ;
  PRP: vektor4 ;
  WindowWC: t_win ;
  WindowBS: t_win ;
  
Procedure berechne_haus (v: o_view);
Var
  m: matrix4;
  i: Integer;
Begin

  For i := 1 To punkte Do
  Begin
    view. dreid_to_BS (@haus_punkte [i], @p_ [i] );
  End;
End;
{$ifndef debug_haus3d}
Procedure draw_info (c: Integer);
Var
  s: String;
Begin
  SetColor (c);
  Case aktion Of
    a_trans: s := 'Translation von ';
    a_rot: s := 'Rotation von ';
  End;
  Case modus Of
    m_prp: s := s + 'PRP';
    m_vup: s := s + 'VUP';
    m_vpn: s := s + 'VPN';
    m_vrp: s := s + 'VRP';
    m_win: s := s + 'WindowWC';
    m_obj: s := s + 'OBJ';
  End;
  OutTextXY (0, 90, s);
End;
{$else}
Procedure draw_info (c: Integer);
Begin
  write_p ('VUP', @VUP);
  write_p ('VPN', @VPN);
  write_p ('VRP', @VRP);
  write_p ('PRP', @PRP);
End;
{$endif}

Procedure draw_haus (c: Integer);
Var
  i: Integer;
  v1, v2: vektor4;
Begin
  For i := 1 To linien Do
  Begin
    linep
    (
    p_ [haus_linien [i] [1] ],
    p_ [haus_linien [i] [2] ],
    WindowBS,
    c
    );
  End;
End;
Procedure rotate_vektor (alpha, beta, gamma: Double; v, v_: p_vektor4);
Var
  R, R1, R2, R3: matrix4;
Begin
  midentity (@R);
  
  RX (alpha, @R1);
  RY (beta, @R2);
  RZ (gamma, @R3);
  
  mdotm (@r1, @r, @r);
  mdotm (@r2, @r, @r);
  mdotm (@r3, @r, @r);

  mdotv (@R, v, v_);

End;
Procedure translate_vektor (DX, dy, dz: Double; v, v_: p_vektor4);
Var
  TR: matrix4;
  D: vektor4;
Begin
  put_vektor (DX, dy, dz, @D);

  T (@D, @TR);

  mdotv (@TR, v, v_);
End;
procedure init_szene;
begin
  {$ifdef haus }
  put_vektor (0, 0, 54, @VRP);
  put_vektor (0, 1, 1, @VPN);
  put_vektor (0, 1, 0, @VUP);
  put_vektor (8, 6, 54, @PRP);
  WindowWC [1] := - 50;
  WindowWC [2] := 50;
  WindowWC [3] := - 50;
  WindowWC [4] := 50;
  WindowBS [1] := 110;
  WindowBS [2] := 400;
  WindowBS [3] := 110;
  WindowBS [4] := 400;
  {$endif         }
  {$ifdef wurfel }
  put_vektor (0, 0, 0, @VRP);
  put_vektor (0, 0, 1, @VPN);
  put_vektor (0, 1, 0, @VUP);
  put_vektor (0, 0, 5, @PRP);
  WindowWC [1] := - 1;
  WindowWC [2] := 1;
  WindowWC [3] := - 1;
  WindowWC [4] := 1;
  WindowBS [1] := 0;
  WindowBS [2] := 500;
  WindowBS [3] := 0;
  WindowBS [4] := 400;
  {$endif         }

  aktion := a_trans;
  modus := m_prp;
end;
Var
  ende: Boolean;
  wahl: Char;
  i: Integer;
  view_param:t_view_parameter;

Begin
  ClrScr;
  ende := False;

  init_szene;
  view_param.vup:=vup;
  view_param.vpn:=vpn;
  view_param.vrp:=vrp;
  view_param.prp:=prp;
  view_param.WindowWC:=WindowWC;
  view_param.WindowBS:=WindowBS;
  view. init (@view_param);

  {$ifndef debug_haus3d}
  grafikein;

  SetColor (5);

  view. draw_window;

  draw_info (3);

  SetColor (3);

  OutTextXY (0, 10, make_vektor_string ('VUP', @vup) );
  OutTextXY (0, 25, make_vektor_string ('VPN', @vpn) );
  OutTextXY (0, 40, make_vektor_string ('VRP', @vrp) );
  OutTextXY (0, 55, make_vektor_string ('PRP', @prp) );
  OutTextXY (0, 70, make_window_string ('WindowWC', @WindowWC) );
  {$endif}

  While Not ende Do
  Begin
    draw_haus (0);
    berechne_haus (view);
    draw_haus (1);

    repeat wahl := ReadKey until wahl in ['q','p','u','n','r','o','O','T','R','-','+','8','2','4','6','x','y','z','X','Y','Z'];

    {$ifndef debug_haus3d}
    draw_info (0);

    SetColor (0);

    view. draw_window;

    Case modus Of
      m_vup: OutTextXY (0, 10, make_vektor_string ('VUP', @vup) );
      m_vpn: OutTextXY (0, 25, make_vektor_string ('VPN', @vpn) );
      m_vrp: OutTextXY (0, 40, make_vektor_string ('VRP', @vrp) );
      m_prp: OutTextXY (0, 55, make_vektor_string ('PRP', @prp) );
    End;
    OutTextXY (0, 70, make_window_string ('WindowWC', @WindowWC) );
    {$endif}

    Case wahl Of
      'q': ende := True;

      'p': modus := m_prp;
      'u': modus := m_vup;
      'n': modus := m_vpn;
      'r': modus := m_vrp;
      'o': modus := m_obj;
      'O': init_szene;
      'T': aktion := a_trans;
      'R': aktion := a_rot;

      '-':
           Begin
             WindowWC [1] := WindowWC [1] - 1;
             WindowWC [2] := WindowWC [2] + 1;
             WindowWC [3] := WindowWC [3] - 1;
             WindowWC [4] := WindowWC [4] + 1;
            view. init (@view_param);
           End;

      '+':
          Begin
            WindowWC [1] := WindowWC [1] + 1;
            WindowWC [2] := WindowWC [2] - 1;
            WindowWC [3] := WindowWC [3] + 1;
            WindowWC [4] := WindowWC [4] - 1;
            view. init (@view_param);
          End;
      '8':
          Begin
            WindowWC [3] := WindowWC [3] - 1;
            WindowWC [4] := WindowWC [4] - 1;
            view. init (@view_param);
          End;
      '2':
          Begin
            WindowWC [3] := WindowWC [3] + 1;
            WindowWC [4] := WindowWC [4] + 1;
            view. init (@view_param);
          End;
      '6':
          Begin
            WindowWC [1] := WindowWC [1] - 1;
            WindowWC [2] := WindowWC [2] - 1;
            view. init (@view_param);
          End;
      '4':
          Begin
            WindowWC [1] := WindowWC [1] + 1;
            WindowWC [2] := WindowWC [2] + 1;
            view. init (@view_param);
          End;

      'x':
          Begin
            Case aktion Of
              a_rot:
                      Case modus Of
                        m_prp: rotate_vektor ( - 10, 0, 0, @prp, @prp);
                        m_vup: rotate_vektor ( - 10, 0, 0, @VUP, @vup);
                        m_vpn: rotate_vektor ( - 10, 0, 0, @vpn, @vpn);
                        m_vrp: rotate_vektor ( - 10, 0, 0, @vrp, @vrp);
                      End;
              a_trans:
                        Case modus Of
                          m_prp: translate_vektor ( - 1, 0, 0, @prp, @prp);
                          m_vup: translate_vektor ( - 1, 0, 0, @VUP, @vup);
                          m_vpn: translate_vektor ( - 1, 0, 0, @vpn, @vpn);
                          m_vrp: translate_vektor ( - 1, 0, 0, @vrp, @vrp);
                        End;
            End;
            view. init (@view_param);
          End;
      'y':
          Begin
            Case aktion Of
              a_rot:
                      Case modus Of
                        m_prp: rotate_vektor (0, - 10, 0, @prp, @prp);
                        m_vup: rotate_vektor (0, - 10, 0, @VUP, @vup);
                        m_vpn: rotate_vektor (0, - 10, 0, @vpn, @vpn);
                        m_vrp: rotate_vektor (0, - 10, 0, @vrp, @vrp);
                        m_obj: ;
                      End;
              a_trans:
                        Case modus Of
                          m_prp: translate_vektor ( 0, - 1, 0, @prp, @prp);
                          m_vup: translate_vektor ( 0, - 1, 0, @VUP, @vup);
                          m_vpn: translate_vektor ( 0, - 1, 0, @vpn, @vpn);
                          m_vrp: translate_vektor ( 0, - 1, 0, @vrp, @vrp);
                        End;
            End;
            view. init (@view_param);
          End;
      'z':
          Begin
            Case aktion Of
              a_rot:
                      Case modus Of
                        m_prp: rotate_vektor (0, 0, - 10, @prp, @prp);
                        m_vup: rotate_vektor (0, 0, - 10, @VUP, @vup);
                        m_vpn: rotate_vektor (0, 0, - 10, @vpn, @vpn);
                        m_vrp: rotate_vektor (0, 0, - 10, @vrp, @vrp);
                      End;
              a_trans:
                        Case modus Of
                          m_prp: translate_vektor ( 0, 0, - 1, @prp, @prp);
                          m_vup: translate_vektor ( 0, 0, - 1, @VUP, @vup);
                          m_vpn: translate_vektor ( 0, 0, - 1, @vpn, @vpn);
                          m_vrp: translate_vektor ( 0, 0, - 1, @vrp, @vrp);
                        End;
            End;
            view. init (@view_param);
          End;
      'X':
          Begin
            Case aktion Of
              a_rot:
                      Case modus Of
                        m_prp: rotate_vektor (10, 0, 0, @prp, @prp);
                        m_vup: rotate_vektor (10, 0, 0, @VUP, @vup);
                        m_vpn: rotate_vektor (10, 0, 0, @vpn, @vpn);
                        m_vrp: rotate_vektor (10, 0, 0, @vrp, @vrp);
                      End;
              a_trans:
                        Case modus Of
                          m_prp: translate_vektor ( 1, 0, 0, @prp, @prp);
                          m_vup: translate_vektor (  1, 0, 0, @VUP, @vup);
                          m_vpn: translate_vektor (  1, 0, 0, @vpn, @vpn);
                          m_vrp: translate_vektor (  1, 0, 0, @vrp, @vrp);
                        End;
            End;
            view. init (@view_param);
          End;
      'Y':
          Begin
            Case aktion Of
              a_rot:
                      Case modus Of
                        m_prp: rotate_vektor (0, 10, 0, @prp, @prp);
                        m_vup: rotate_vektor (0, 10, 0, @VUP, @vup);
                        m_vpn: rotate_vektor (0, 10, 0, @vpn, @vpn);
                        m_vrp: rotate_vektor (0, 10, 0, @vrp, @vrp);
                      End;
              a_trans:
                        Case modus Of
                          m_prp: translate_vektor ( 0, 1, 0, @prp, @prp);
                          m_vup: translate_vektor ( 0, 1, 0, @VUP, @vup);
                          m_vpn: translate_vektor ( 0, 1, 0, @vpn, @vpn);
                          m_vrp: translate_vektor ( 0, 1, 0, @vrp, @vrp);
                        End;
            End;
            view. init (@view_param);
          End;
      'Z':
          Begin
            Case aktion Of
              a_rot:
                      Case modus Of
                        m_prp: rotate_vektor (0, 0, 10, @prp, @prp);
                        m_vup: rotate_vektor (0, 0, 10, @VUP, @vup);
                        m_vpn: rotate_vektor (0, 0, 10, @vpn, @vpn);
                        m_vrp: rotate_vektor (0, 0, 10, @vrp, @vrp);
                      End;
              a_trans:
                        Case modus Of
                          m_prp: translate_vektor ( 0, 0, 1, @prp, @prp);
                          m_vup: translate_vektor ( 0, 0, 1, @VUP, @vup);
                          m_vpn: translate_vektor ( 0, 0, 1, @vpn, @vpn);
                          m_vrp: translate_vektor ( 0, 0, 1, @vrp, @vrp);
                        End;
            End;
            view. init (@view_param);
          End;
    End;
    {$ifndef debug_haus3d}
	  view_param.vup:=vup;
  	view_param.vpn:=vpn;
  	view_param.vrp:=vrp;
  	view_param.prp:=prp;
  	view_param.WindowWC:=WindowWC;
  	view_param.WindowBS:=WindowBS;
  	view. init (@view_param);

    draw_info (3);

    SetColor (5);

    view. draw_window;

    SetColor (3);

    Case modus Of
      m_vup: OutTextXY (0, 10, make_vektor_string ('VUP', @vup) );
      m_vpn: OutTextXY (0, 25, make_vektor_string ('VPN', @vpn) );
      m_vrp: OutTextXY (0, 40, make_vektor_string ('VRP', @vrp) );
      m_prp: OutTextXY (0, 55, make_vektor_string ('PRP', @prp) );
    End;
    OutTextXY (0, 70, make_window_string ('WindowWC', @WindowWC) );
    {$endif}
  End;
  {$ifndef debug_haus3d}
  grafikaus;
  {$endif}
End.