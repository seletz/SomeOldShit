Program partikel_system;
Uses
  DOS, crt, vesa;
Const
  max_active = 1000;
  max_life = 200;
  delta_life = 200;
  max_radius = 50;
  delta_radius = 20;
  max_v0: Real = 5;
  delta_v0: Real = 5;


  gravity : Real = 0.1;

  maxx=600;
  maxy=400;
Type
	color_t = record r,g,b:byte end;
  vektor =  Record X, Y, z: Real End;
  partikel_p = ^partikel_typ;
  partikel_typ = 	Record
                    prev: partikel_p;
                    next: partikel_p;
                    index: LongInt;
                    initial_lifetime,
                    tl: Integer;
                    Color: color_t;

                    p0, p: vektor;
                    v0, v: vektor;
                  End;
Var
  count: LongInt;
  num_active: Integer;
  first, last: partikel_p;
  p_show: partikel_p;


Procedure partikel_compute_color (pp: partikel_p);
Begin
  With pp^Do
  Begin
    Color.r := Round (250 * (1 - tl / initial_lifetime) );
    color.g := $0f;
    color.b := $0f;
    if tl<50 then
			with color do
			begin
      	r:=round((tl mod 6)/6 * $ff);
      	g:=round((tl mod 6)/6 * $ff);
      	b:=round((tl mod 6)/6 * $ff);

			end;
  End;
End;

Procedure partikel_new;
Var
  new_list: Boolean;
  pp: partikel_p;
  r, vi: Real;
  phi: Real;
  gamma: Real;
Begin
  new_list := last = Nil;

  r := max_radius + delta_radius * Random;
  vi := max_v0 + delta_v0 * Random;
  phi := 2 * Pi * Random;     			{ 0 <=  phi  < 180ø }
  gamma := 0.125 * Pi * Random ; { 0 <= gamma < 45ø  }
  {gamma := gamma - pi/4;}
  New (pp);

  With pp^Do
  Begin
    If Not new_list Then
    Begin
      next := last^. next;
      prev := last;
    End;
    
    Inc (count);
    index := count;
    {
    WriteLn ('Partikel #', index, ' wird geboren.');
    }
    tl := Round (max_life + delta_life * Random);
    initial_lifetime := tl;
    With p0 Do
    Begin
      X := Cos (phi) * r; Y := Sin (phi) * r; z := 0;
    End;
    p := p0;
    With v0 Do
    Begin
      z := Cos (gamma) * vi; X := vi * Cos (phi) * Sin (gamma); Y := vi * Sin (phi) * Sin (gamma);
    End;
    v := v0;
  End;
  
  If Not new_list Then
  Begin
    last^. next := pp;
    last := pp;
    first^. prev := last;
  End
  Else
  Begin
    first := pp;
    last := pp;
    last^. prev := Nil;
    last^. next := last;
  End;
  
End;

Procedure partikel_die (p: partikel_p);
Begin
  {  If Not ( (p^. next = p^. prev) Or (p^. next = p^. prev^. prev) ) Then}
Begin
  With p^ Do
  Begin
    next^. prev := prev;
    prev^. next := next;
  End;
  If p = last Then last := p^. prev;
  If p = first Then first := p^. next;
  {
  WriteLn ('Partikel #', p^. index, ' stirbt.');
  }
  Dispose (p);
  Dec (num_active);
End;
End;

Procedure partikel_write (pp: partikel_p);
Begin
  With pp^ Do
  Begin
    WriteLn ('Partikel #', index);
    WriteLn ('prev: #', prev^. index, ' next: #', next^. index);
    WriteLn;
    WriteLn ('Lebensdauer     : ', tl);
    WriteLn ('Farbe           : ', Color.r);
    WriteLn ('Position        : x:', p. X: 3: 3, ' y:', p. Y: 3: 3, ' z:', p. z: 3: 3);
    WriteLn ('Geschwindigkeit : x:', v. X: 3: 3, ' y:', v. Y: 3: 3, ' z:', v. z: 3: 3);
  End;
End;

Procedure partikel_browse;
Var
  ende: Boolean;
  save: partikel_p;
  c: Char;
Begin
  textmode(c80 + font8x8);;
  ende := False;

  If p_show = Nil Then p_show := last;

  Repeat
    ClrScr;

    partikel_write (p_show);
    WriteLn;
    WriteLn ('n..n„chstes   p..vorheriges Partikel, N=neu, l=l”schen, x=ende');

    Repeat
      c := ReadKey;
    Until c In ['n', 'p', 'l', 'N', 'x'];

    If c = 'n' Then p_show := p_show^. next;
    If c = 'p' Then p_show := p_show^. prev;
    If c = 'N' Then partikel_new;
    If c = 'l' Then
    Begin
      save := p_show^. prev;
      partikel_die (p_show);
      p_show := save;
    End;

    If c = 'x' Then ende := True;
  Until ende;
  setmode(mode_640x480x64k);
End;

Procedure partikel_clear (pp: partikel_p);
Begin
  With pp^Do
  Begin
    setpix ( (MaxX Div 2) + Round (p. X) - 1, MaxY - Round (p. z) - 1
							, RGB(0,0,0) );
  End;
End;

Procedure partikel_draw (pp: partikel_p);
Begin
  With pp^Do
  Begin
    setpix ( (MaxX Div 2) + Round (p. X) - 1, MaxY - Round (p. z) - 1
							, RGB(color.r,color.g,color.b) );
  End;
End;

Procedure partikel_cycle;
Var
  save: partikel_p;
  zz: Real;
Function bereich (zahl, xu, xo: Real): Boolean;
Begin
  bereich := (zz >= xu) And (zz < xo);
End;
Begin
  {
  ClrScr;
  partikel_write (p_show);
  }
  partikel_compute_color (p_show);
  partikel_clear (p_show);
  With p_show^ Do
  Begin
    Dec (tl);
    If tl <= 0 Then
    Begin
      save := p_show^. prev;
      partikel_clear (p_show);
      partikel_die (p_show);
      p_show := save;
      
      zz := Random;
      If bereich (zz, 0, 0.7) Then
      Begin
        If num_active < max_active Then partikel_new;
      End
      Else
        If bereich (zz, 0.7, 1) Then
        Begin
          partikel_new;
          last^. p := p;
          last^. tl := 50;
          last^. v. z := 0.9 * last^. v. z;
          partikel_new;
          last^. tl := 50;
          last^. p := p;
          last^. v. z := 0.9 * last^. v. z;
          partikel_new;
          last^. tl := 50;
          last^. p := p;
          last^. v. z := 0.9 * last^. v. z;
        End;
      
    End Else
    Begin
      p. X := p. X + v. X;
      p. Y := p. Y + v. Y;
      p. z := p. z + v. z;
      
      If p. z <= 0 Then
      Begin
        zz := Random;
        save := p_show^. prev;
        partikel_clear (p_show);
        partikel_die (p_show);
        p_show := save;
        
        If bereich (zz, 0, 0.3) Then
        Begin
          If num_active < max_active Then partikel_new;
        End
        Else
          If bereich (zz, 0.8, 1) Then
          Begin
            {          partikel_new;
            last^. p := p;
            last^. v. z := 0.9 * last^. v. z;
            partikel_new;
            last^. p := p;
            last^. v. z := 0.9 * last^. v. z;
            partikel_new;
            last^. p := p;
            last^. v. z := 0.9 * last^. v. z;
            }
          End
          Else
            v. z := - Random * v. z;
      End;
      
      v. z := v. z - gravity;
      
    End;
    partikel_draw (p_show);
  End;
  p_show := p_show^. next;
End;

Procedure  partikel_init;
Var
  i: Integer;
Begin
  For i := 2 To max_active Div 2 Do
  Begin
    num_active := i;
    partikel_new;
  End;
End;

Procedure partikel_done;
Var
  i: Integer;
  save: partikel_p;
Begin
  
  p_show := first;
  last^. next := Nil;
  While Not (p_show = Nil) Do
  Begin
    save := p_show^. next;
    Dispose (p_show);
    p_show := save;
  End;
End;

Var
  oldexit: pointer;
  
Procedure myexit; Far;
Begin
  ExitProc := oldexit;

  textmode(c80 + font8x8);

  partikel_done;
End;

Var
  c: Char;
  ende: Boolean;

Begin
  oldexit := ExitProc;
  ExitProc := @myexit;

  Randomize;

  setmode(mode_640x480x64k);

  c := ' ';
  ende := False;

  last := Nil;
  num_active := 0;
  count := 0;
  p_show := last;

  partikel_init;

  p_show := first;

  Repeat
    partikel_cycle;
    If KeyPressed Then
    Begin
      c := ReadKey;
      If c = 'x' Then ende := True;
      If c = 'b' Then partikel_browse;
    End;
  Until ende;

  partikel_done;

  textmode(c80+font8x8);
End.