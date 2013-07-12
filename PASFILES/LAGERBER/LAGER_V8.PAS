{$undef debug
}
Program auflager;
Uses crt, strings, graph;
Const festlager = 1;
  loslager = 2;
  eingespannt = 3;
  rad: Real = Pi / 180;
  grafik = True;
  max_kraft_anzahl = 100;
  teil_q = 10;
Type kraft = Record
               f, fx, fy: Real;
               alpha: Real;
               lx, ly: Real
             End;
  lager = Record
            typ: Integer;
            X, Y: Real;
            alpha: Real;
          End;
  traeger = Record
              l: Real;
              xo, xu: Real;
              iy: Real;
              gewicht: Real;
              a, b: lager;
              fa, fb: kraft;
              maxmb, maxq, maxt, maxf, x_maxf, x_maxq, x_maxt, x_maxmb: Real;
              minW, minI, zulMb: Real;
            End;
  
Var  f: Array [0..max_kraft_anzahl] Of kraft;
  e: Real;
  start_f_input, anzahl_F: Integer;
  ende: Boolean;
  tr: traeger;
  maxf_berechnet, maxmb_berechnet, auflager_berechnet, daten_vorhanden: Boolean;
  pfad, s: String;
  
Function pow (X, Y: Real): Real;
Begin If X > 0 Then pow := Exp (Y * Ln (X) ) Else pow := 0; End;
Function sgn(x:real):integer;
begin if abs(x)=x then sgn:=+1 else sgn:=-1 end;
Procedure out_f (s: String; F: kraft);
Begin
  TextColor (LightGreen);
  WriteLn ( s, '   Betrag: ', F. f: 3: 3, ' N;', ' Richtung:', F. alpha * 180 / Pi: 3: 3, ' Grad;');
  WriteLn (' Fx: ', f. fx: 3: 3, ' N; Fy: ', F. fy: 3: 3, ' N;');
  TextColor (White);
End;

Procedure wartetaste;
Begin
  WriteLn;
  WriteLn ('Bitte eine Taste drcken.');
  Repeat Until KeyPressed; ReadLn
End;
Function grafikein: Boolean;
Var gd, gm: Integer;
Begin
  gd := VGA;
  gm := VGAHi;
  InitGraph (gd, gm, 'z:\tp70\bgi\');
  grafikein := GraphResult = 0;
End;

Procedure fehler (s: String);
Begin
  ClrScr;
  TextColor (LightRed + Blink);
  GotoXY (30, 12); WriteLn (s);
  Delay (2000);
  TextBackground (Black);
  TextColor (White);
End;
Function frage: Boolean;
Var c: Char;
Begin
  Write (' (j/n) ? ');
  c := ReadKey;
  If c in ['j'] Then frage := True Else frage := False;
  WriteLn (c);
End;
Procedure Write1r (s: String; X: Real; s2: String);
Begin
  WriteLn (s, X: 3: 9, ' ', s2);
End;
Procedure Read1r (s: String; Var X: Real; xu, xo: Real);
Var xx: Real;
Begin
  Write (s); WriteLn (X: 3: 3);
  WriteLn;
  Write ('Wert „ndern');
  If frage Then Begin
    xx := X;
    GotoXY (WhereX, WhereY - 2);
    Repeat
      GotoXY (WhereX, WhereY - 1);
      Write (s); ReadLn (xx);
      X := xx;
    Until (xx >= xu) And (xx <= xo);
    GotoXY (WhereX, WhereY - 1); ClrEol; WriteLn;
    GotoXY (WhereX, WhereY - 1); Write (s); WriteLn (X: 3: 3);
    GotoXY (WhereX, WhereY + 1); ClrEol; WriteLn;
    GotoXY (WhereX, WhereY - 2);
  End Else Begin
    GotoXY (WhereX, WhereY - 1); ClrEol; WriteLn;
    GotoXY (WhereX, WhereY - 2);
  End;
End;

Procedure init_debug;
Var
  i: Integer; X, xstep, f_teil: Real;
Begin
  {
  *****************************************************************************
  *****************************************************************************
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                    INIT-DEBUG                                           **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  *****************************************************************************
  *****************************************************************************
  }
  {
  
  einfacher Tr„ger fr testzwecke, '0' im Men drcken
  
  buch seite 57
  
  }
  With tr Do
  Begin
    gewicht := 100;
    l := 10;
    f_teil := (gewicht * l) / teil_q;
    xstep := l / teil_q;
  End;
  X := 0;
  For i := 1 To teil_q Do
  Begin
    With f [i] Do
    Begin
      ly := 0;
      lx := X;
      alpha := 90 * rad;
      f := f_teil;
      fx := Cos (alpha) * f;
      fy := Sin (alpha) * f;
    End;
    X := X + xstep;
  End;
  anzahl_f := teil_q + 2;
  With tr. b Do Begin
    X := 10;
    Y := 0;
    alpha := 0 * rad;
    typ := loslager;
  End;
  With tr. a Do Begin
    X := 0;
    Y := 0;
    alpha := 0;
    typ := festlager;
  End;
  With f [teil_q + 1] Do Begin
    lx := 5;
    ly := 0;
    f := 1000;
    alpha := 270 * rad;
    fx := 0;
    fy := 0;
  End;
  With f [teil_q + 2] Do Begin
    lx := 7.5;
    ly := 0;
    f := 1000;
    alpha := 45 * rad;
    fx := 0;
    fy := 0;
  End;
  e := 210000;
  tr. iy := 50000;
  tr. xu := 0;
  tr. xo := 10;
  tr. l := 10;
  daten_vorhanden := True;
  maxmb_berechnet := False;
  auflager_berechnet := False;
End;
Procedure init;
Var i: Integer;
  n: Real;
  s: String;
  ok: Boolean;
  max_x, min_x, X, xstep: Real;
  f_teil: Real;
  {
  *****************************************************************************
  *****************************************************************************
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                     INIT                                                **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  *****************************************************************************
  *****************************************************************************
  }
Procedure clear_teil (sz, ez: Integer);
Var i: Integer;
Begin
  For i := sz To ez Do Begin
    GotoXY (1, i);
    ClrEol;
  End;
End;
Begin
  max_x := - 1e37;
  min_x := 1e37;
  ClrScr;
  ok := False;
  maxmb_berechnet := False;
  auflager_berechnet := False;
  maxf_berechnet := False;
  {

  A ..... Festlager
  B ..... Loslager

  Fa u. Fb immer in positiver Richtung


  A()---------------------------()B
  /\                           /\


  }
  With tr Do
  Begin
    WriteLn ('Gewicht Tr„ger eingeben:');
    Read1r ('Gewicht in N/m :', gewicht, 0, 1e37);
    Read1r ('L„nge in m     :', l, 0.00000001, 1e37);
    max_x:=l;
    if gewicht<>0 then f_teil := (gewicht * l) / teil_q else f_teil:=0;
    xstep := l / teil_q;
  End;
  X := 0;
  For i := 1 To teil_q Do
  Begin
    With f [i] Do
    Begin
      ly := 0;
      lx := X;
      alpha := 90 * rad;
      f := f_teil;
      fx := Cos (alpha) * f;
      fy := Sin (alpha) * f;
    End;
    X := X + xstep;
  End;

  With tr. a Do
  Begin
    WriteLn ('Position Festlager == Nullpunkt !');
    x:=0;
    y:=0;
    If X >= max_x Then max_x := X
    Else If x<= min_x Then min_x := X;
  End;
  With tr. b Do
  Begin
    WriteLn;
    WriteLn ('Position Loslager eingeben:');
    Read1r ('X-Koordinate:', X, - 1e37, 1e37);
    Read1r ('Y-Koordinate:', Y, - 1e37, 1e37);
    alpha := alpha / rad;
    Read1r ('Winkel zur positiven X-Achse:', alpha, 0, 360);
    alpha := alpha * rad;
    If X >= max_x Then max_x := X
    Else If X <= min_x Then min_x := X;
  End;
  WriteLn;

  WriteLn;
  If anzahl_f > 0 Then
    n := anzahl_f - teil_q
  Else n := anzahl_f;

  Read1r ('Anzahl der angreifenden Kr„fte ( 0 => Ende):', n, 0, max_kraft_anzahl - teil_q);
  WriteLn;
  WriteLn;
  WriteLn;

  anzahl_f := Round (n);
  If anzahl_f > 0 Then
    For i := teil_q + 1 To teil_q + anzahl_f Do
    Begin
      With f [i] Do
      Begin
        clear_teil (13, 24);
        GotoXY (1, 12);
        Write ('Kraft nummer ');
        TextColor (Yellow);
        WriteLn (i - teil_q);
        TextColor (White);
        WriteLn;
        Read1r ('X-Koordinate    : ', lx, - 1e37, 1e37);
        Read1r ('Y-Koordinate    : ', ly, - 1e37, 1e37);
        If lx >= max_x Then max_x := lx
        Else If lx <= min_x Then min_x := lx;
        Read1r ('Betrag in Newton: ', f, 1, 1e37);
        alpha := alpha / rad;
        Read1r ('Winkel zur positiven X-Achse in Grad: ', alpha, 0, 360);
        alpha := alpha * rad;
        Read1r ('X-komponente in Newton: ', fx, 1, 1e37);
        Read1r ('Y-komponente in Newton: ', fy, 1, 1e37);
        If f = 0 Then Begin
          f := Sqrt (Sqr (fx) + Sqr (fy) );
          If fx <> 0 Then
            alpha := ArcTan (fy / fx)
          Else
            alpha := Pi * fy / Abs (2 * fy);
        End;
        WriteLn;
      End;
    End;
  anzahl_f := anzahl_f + teil_q;
  tr. xu := min_x;
  tr. xo := max_x;
  daten_vorhanden := True;
End;

Function berechne_quadrant (xi, yi, xf, yf: Real): Integer;
Begin
  {
  in welchem Quadrant liegt (xi,yi) ,  wenn (xf,yf) den
  Nullpunkt eines rechtwinkligen Koordinatensystems bildet?
  }
  If (xi >= xf) And (yi >= yf) Then berechne_quadrant := 1;
  If (xi < xf) And (yi >= yf) Then berechne_quadrant := 2;
  If (xi < xf) And (yi < yf) Then berechne_quadrant := 3;
  If (xi >= xf) And (yi < yf) Then berechne_quadrant := 4;
End;

Procedure berechne_auflager;
Var i: Integer;
  em, emx, emy, efx, efy: Real;
  xi, yi: Real;
  quadrant: Integer;
  {
  *****************************************************************************
  *****************************************************************************
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                  BERECHNE AUFLAGER                                      **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  *****************************************************************************
  *****************************************************************************
  }
Begin
  ClrScr;
  em := 0;
  emx := 0;
  emy := 0;
  efx := 0;
  efy := 0;
  
  {
  E M(festl)
  }
  
  For i := 1 To anzahl_f Do Begin With f [i] Do Begin
    
    quadrant := berechne_quadrant (lx, ly, tr. a. X, tr. a. Y);
    
    fx := Cos (alpha) * f;
    fy := Sin (alpha) * f;
    
    efx := efx + fx;
    efy := efy + fy;
    
    yi := Abs (ly - tr. a. Y);
    xi := Abs (lx - tr. a. Y);
    
    Case quadrant Of
      1: 
         Begin
           emx := emx + ( - fx * yi);
           emy := emy + ( + fy * xi);
         End;
      2: 
         Begin
           emx := emx + ( - fx * yi);
           emy := emy + ( - fy * xi);
         End;
      3:
        Begin
          emx := emx + ( + fx * yi);
          emy := emy + ( - fy * xi);
        End;
      4: 
         Begin
           emx := emx + ( + fx * yi);
           emy := emy + ( + fy * xi);
         End;
    End;
  End; 
  End;
  
  em := emx + emy;
  
  yi := Abs (tr. b. Y - tr. a. Y);
  xi := Abs (tr. b. X - tr. a. X);
  tr. fb. alpha := tr. b. alpha + Pi / 2;
  
  quadrant := berechne_quadrant (tr. b. X, tr. b. Y, tr. a. X, tr. a. Y);
  Case quadrant Of
    1: 
       Begin
         tr. fb. f := ( - em) / ( + Sin (tr. fb. alpha) * xi - Cos (tr. fb. alpha) * yi);
       End;
    2:
       Begin
         tr. fb. f := ( - em) / ( - Sin (tr. fb. alpha) * xi - Cos (tr. fb. alpha) * yi);
       End;
    3: 
       Begin
         tr. fb. f := ( - em) / ( - Sin (tr. fb. alpha) * xi + Cos (tr. fb. alpha) * yi);
       End;
    4: 
       Begin
         tr. fb. f := ( - em) / ( + Sin (tr. fb. alpha) * xi + Cos (tr. fb. alpha) * yi);
       End;
  End;
  
  tr. fb. fx := Cos (tr. fb. alpha) * tr. fb. f;
  tr. fb. fy := Sin (tr. fb. alpha) * tr. fb. f;
  
  tr. fa. fx := - (efx + tr. fb. fx);
  tr. fa. fy := - (efy + tr. fb. fy);
  tr. fa. f := Sqrt (Sqr (tr. fa. fx) + Sqr (tr. fa. fy) );
  tr. fa. alpha := ArcTan (Abs (tr. fa. fy) / Abs (tr. fa. fx) );
  
  quadrant := berechne_quadrant (tr. fa. fx, tr. fa. fy, 0, 0);
  
  Case quadrant Of
    1: 
       Begin
         tr. fa. alpha := tr. fa. alpha;
       End;
    2: 
       Begin
         tr. fa. alpha := Pi  - tr. fa. alpha;
       End;
    3: 
       Begin
         tr. fa. alpha := Pi  + tr. fa. alpha;
       End;
    4: 
       Begin
         tr. fa. alpha := 2 * Pi - tr. fa. alpha;
       End;
  End;
  
  auflager_berechnet := True;
  
End;

Procedure ausgabe_auflager;
Var s: String;
  {
  *****************************************************************************
  *****************************************************************************
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                 AUSGABE AUFLAGER                                        **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  *****************************************************************************
  *****************************************************************************
  }
Begin
  If auflager_berechnet Then Begin
    ClrScr;
    WriteLn ('Auflagerreaktionen');
    WriteLn ('==================');
    WriteLn;
    WriteLn;
    out_f ('Festlager :', tr. fa);
    WriteLn;
    out_f ('Loslager  :', tr. fb);
    WriteLn;
    WriteLn ('Taste drcken'); Repeat Until KeyPressed; ReadLn;
  End Else Begin
    ClrScr;
    WriteLn ('Auflager noch nicht berechnet!');
    wartetaste;
  End;
End;
Procedure mb (X: Real; Var mbx, q, t: Real);
Var mfa, mfb: Real;
  i: Integer;
Begin
  mbx := 0;
  q := 0;
  t := 0;
  mfa := 0;
  mfb := 0;
  i := 1;
  Repeat
    If f [i].lx < X Then Begin
      With f [i] Do Begin
        t := t + fx;
        q := q + fy;
        mbx := mbx + fy * (X - lx);
      End;
    End;
    Inc (i);
  Until i > anzahl_f;
  If tr. a. X < X Then Begin
    t := t + tr. fa. fx;
    q := q + tr. fa. fy;
    mfa := tr. fa. fy * (X - tr. a. X);
  End Else mfa := 0;
  
  If tr. b. X < X Then Begin
    t := t + tr. fb. fx;
    q := q + tr. fb. fy;
    mfb := tr. fb. fy * (X - tr. b. X);
  End Else mfb := 0;
  
  mbx := mfa + mfb + mbx;
  
End;
Procedure berechne_mbq_beliebig;
Var X, q, t, mbx: Real;
  i: Integer;
  ende: Boolean;
  {
  *****************************************************************************
  *****************************************************************************
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                  MB Beliebig                                            **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  *****************************************************************************
  *****************************************************************************
  }
Begin
  X := (tr. b. X - tr. a. X) / 2;
  q := 0;
  t := 0;
  i := 0;
  ende := False;
  ClrScr;
  If auflager_berechnet Then Begin
    Repeat
      ClrScr;
      Read1r ('Schnitt-X-Koordinate bitte eingeben (in meter):', X, - 1e37, 1e37);
      
      mb (X, mbx, q, t);
      
      WriteLn;
      
      WriteLn ('Mb an der stelle x=', X: 3: 3, 'm betr„gt ', mbx: 3: 3, 'Nm');
      WriteLn ('Q an der stelle x=', X: 3: 3, 'm betr„gt ', q: 3: 3, 'N');
      WriteLn ('T an der stelle x=', X: 3: 3, 'm betr„gt ', t: 3: 3, 'N');
      
      Write ('Nochmal (j/n) ?');
      Repeat Until KeyPressed;
      If ReadKey = 'n' Then ende := True;
      WriteLn;
    Until ende;
  End Else Begin
    WriteLn ('Zuerst schritte 1 u. 2 ausfhren !');
    wartetaste;
  End;
End;
Procedure berechne_maxmbq;
Var mbx, q, t, xu, xo, X, sx, l: Real;
  mx, my, mx1, my1, my2, mx2: Real;
  {
  *****************************************************************************
  *****************************************************************************
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                          MAX MB                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  *****************************************************************************
  *****************************************************************************
  }
Begin
  ClrScr;
  X := 0;
  xu := tr. xu;
  xo := tr. xo;
  sx := 0.001 * (xo - xu);
  tr. maxQ := 0;
  tr. maxT := 0;
  tr. maxMb := 0;
  mbx := 0;
  q := 0;
  t := 0;
  
  If tr. a. X > tr. b. X Then l := tr. a. X Else l := tr. b. X;
  
  Read1r ('untere Grenze:', xu, - 1e37, 1e37);
  Read1r ('obere Grenze :', xo, - 1e37, 1e37);
  tr. xu := xu;
  tr. xo := xo;
  Read1r ('Schrittweite bitte eingeben (in meter):', sx, - 1e37, 1e37);
  If sx = 0 Then Exit;
  WriteLn;
  X := xu;
  
  While (X < (xo - sx) ) Do Begin
    mb (X, mbx, q, t);
    If Abs (mbx) > Abs (tr. maxMb) Then Begin
      tr. maxMb := mbx;
      tr. x_maxmb := X;
    End;
    If Abs (t) > Abs (tr. maxt) Then Begin
      tr. maxt := t;
      tr. x_maxt := X;
    End;
    If Abs (q) > Abs (tr. maxq) Then Begin
      tr. maxq := q;
      tr. x_maxq := X;
    End;
    X := X + sx;
    WriteLn ('x=', X: 3: 3);
    GotoXY (WhereX, WhereY - 1);
  End;
  
  {$ifndef debug}
  
  If grafik And grafikein Then Begin
    
    MoveTo (0, 30);
    OutText ('Mb- Q- T- Verlauf');
    
    
  End;
  
  {$endif}
  mx := GetMaxX / tr. l;
  my := (GetMaxY / 2) / tr. maxmb;
  mx1 := GetMaxX / tr. l;
  my1 := (GetMaxY / 2) / tr. maxq;
  mx2 := GetMaxX / tr. l;
  my2 := (GetMaxY / 2) / tr. maxt;
  
  Line (0, GetMaxY Div 2, GetMaxX, GetMaxY Div 2);
  Circle (Round (tr. a. X * mx), GetMaxY Div 2, 10);
  Circle (Round (tr. b. X * mx), GetMaxY Div 2, 10);
  
  X := xu;

  While (X < (xo - sx) ) Do Begin
    mb (X, mbx, q, t);
    PutPixel (Round (X * mx), GetMaxY Div 2 + Round (mbx * my), 2);
    PutPixel (Round (X * mx), GetMaxY Div 2 + Round (q * my), 3);
    If Abs (t) > 0.001 Then
      PutPixel (Round (X * mx), GetMaxY Div 2 - Round (t * my), 4);
    X := X + sx;
  End;
  Circle (Round (tr. x_maxmb * mx), GetMaxY Div 2 + Round (tr. maxmb * my), 2);
  Line (Round (tr. x_maxmb * mx), GetMaxY, Round (tr. x_maxmb * mx), 0);
  OutTextXY (Round (tr. x_maxmb * mx) + 10, 30, 'maxMb');
  wartetaste;
  CloseGraph;

  WriteLn;
  WriteLn;
  TextColor (LightGreen);
  WriteLn ('maxMb an der stelle x=', tr. x_maxmb: 3: 3, 'm betr„gt ', tr. maxmb: 3: 3, 'Nm');
  WriteLn ('maxQ an der stelle x=', tr. x_maxq: 3: 3, 'm betr„gt ', tr. maxq: 3: 3, 'N');
  WriteLn ('maxT an der stelle x=', tr. x_maxt: 3: 3, 'm betr„gt ', tr. maxt: 3: 3, 'N');
  TextColor (White);
  
  wartetaste;
  
  maxmb_berechnet := True;
  
End;
Function efy (X: Real): Real;
Var i: Integer;
  s: Real;
Begin
  s := 0;
  For i := 1 To anzahl_f Do Begin
    If f [i].lx < X Then Begin
      s := s + f [i].fy;
    End;
  End;
  efy := s;
End;

Function get_fa (X: Real): Real;
Begin If tr. a. X < X Then get_fa := tr. fa. fy Else get_fa := 0; End;

Function get_fb (X: Real): Real;
Begin If tr. b. X < X Then get_fb := tr. fb. fy Else get_fb := 0; End;

Function ber_q (X: Real): Real;
Var q: Real;
Begin
  {
  Q := - E Fyi|lxi<x + Fay|xa<x + Fby|xb<x;
  }
  If Not auflager_berechnet Then Begin fehler ('ber_q: Auflager nicht berechnet??'); Halt; End;
  q := 0;
  q := - efy (X) + get_fa (X) + get_fb (X);
  ber_q := q;
End;
Function ber_f (X, e, iy: Real): Real;
Var a, b, l: Real;
  tan_a_a,tan_a_b,ta_a,ta_b,a_a,a_b,x_s, dt, t, tf: Real;
  i: Integer;
Begin
  {
  *****************************************************************************
  *****************************************************************************
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                       DURCHBIEGUNG                                      **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  *****************************************************************************
  *****************************************************************************
  }
  {

  F„lle siehe Dubbel C20


  }
  t := 0;
  dt := 0;
  ta_a:=0;
  ta_b:=0;
  a_a:=0;
  a_b:=0;
  tan_a_a:=0;
  tan_a_b:=0;
  {

  neigungswinkel in den lagerstellen

  }
  for i:=1 to anzahl_f do
  begin
    tf := f [i].fy;
    If f [i].lx <> tr. a. X Then
      If f [i].lx < tr. a. X Then Begin
        { Fall 11 umgekehrt }
      End
    Else
      If (f [i].lx > tr. a. X) And (f [i].lx < tr. b. X) Then Begin
        { Fall 2}
        a := f [i].lx - tr. a. X;
        b := (tr. b. X - tr. a. X) - a;
        l := a + b;

        ta_a:=sgn(tf)*(tf*a*b*(l+b))/(6*l*e*iy);
        ta_b:=sgn(tf)*(tf*a*b*(l+a))/(6*l*e*iy);

      End Else
        If f [i].lx > tr. b. X Then Begin
          { Fall 11 }
          a := f [i].lx - tr. b. X;
          l := tr. b. X - tr. a. X;
        	ta_a:=-sgn(tf)*(tf*a*l)/(6*e*iy);
        	ta_b:=2*a_a;
        End;
    a_a:=a_a+ta_a;
    a_b:=a_b+ta_b;
  End;

  tan_a_a:=-sin(a_a)/cos(a_a);
  tan_a_b:=-sin(a_b)/cos(a_b);
  {

  Durchbiegung (superpositionsmethode nach dubbel c20/21)

  }
  For i := 1 To anzahl_f Do
  Begin
    tf := f [i].fy;
    If f [i].lx <> tr. a. X Then
      If f [i].lx < tr. a. X Then Begin
        { Fall 11 umgekehrt }
      End
    Else
      If (f [i].lx > tr. a. X) And (f [i].lx < tr. b. X) Then Begin
        { Fall 2}

        a := f [i].lx - tr. a. X;
        b := (tr. b. X - tr. a. X) - a;
        l := a + b;
        if (x>=tr.a.x) and (tr.b.x>=x) then
        	If X <= a Then dt := ( (tf * a * b * b) / (6 * e * iy) ) * ( (1 + l / b) *    X / l - pow ( X , 3) / (a * b * l) )
        	Else         dt := ( (tf * a * a * b) / (6 * e * iy) ) * ( (1 + l / a) * (l - X) / l - pow (l - X, 3) / (b * a * l) )
        else
        	if x<tr.a.x then
            dt:=tan_a_b*(x)
          else
          if x>tr.b.x then
            dt:=tan_a_b*(x-l);
      End Else
        If f [i].lx > tr. b. X Then Begin
          { Fall 11 }
          a := f [i].lx - tr. b. X;
          l := tr. b. X - tr. a. X;

          If X <= l Then
            dt := (tf * a * l * l / (6 * e * iy) * (X / l - pow (X / l, 3) ) );
          If X > l  Then
            dt := tan_a_b*(x-l) +
						(tf * pow (a, 3) / (6 * e * iy) * (2 * l * b / (a * a) + 3 * pow (b / l, 2) - pow (b / l, 3) ) );
        End;
    t := t + dt;
  End;

  ber_f := 100 * t;
End;
Procedure berechne_f_beliebig;
Var X, fx: Real;
Begin
  ClrScr;
  X := (tr. b. X - tr. a. X) / 2;
  fx := 0;
  Repeat
    ClrScr;
    GotoXY (1, 1);
    Read1r ('Konstante E (N/mm^2) :', e, 1, 1e37);
    Read1r ('Iy          ( cm^3 ) :', tr. iy, 0.01, 1e37);
    WriteLn;
    Read1r ('x           (  m   ) :', X, - 1e37, 1e37);
    
    fx := ber_f (X, e, tr. iy);
    WriteLn;
    TextColor (LightGreen);
    WriteLn ('f(x) = ', fx: 3: 3, 'm = ', fx * 1000: 3: 3, 'mm');
    TextColor (White);
    WriteLn;
    Write ('Nochmal');
  Until Not frage;
End;
Procedure berechne_maxf;
Var mx, my, f, X, xu, xo, DX: Real;
  {
  *****************************************************************************
  *****************************************************************************
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                   DURCHBIEGUNG BELIEBIG                                 **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  *****************************************************************************
  *****************************************************************************
  }
Begin
  X := 0;
  f := 0; tr. maxf := 0;
  xu := tr. xu;
  xo := tr. xo;
  DX := (xo - xu) / 1000;
  ClrScr;
  Read1r ('Konstante E (N/mm^2) :', e, 1, 1e37);
  Read1r ('Iy          ( cm^3 ) :', tr. iy, 0.01, 1e37);
  WriteLn;
  Read1r ('Xu ( m ) :', xu, - 1e37, 1e37);
  Read1r ('Xo ( m ) :', xo, - 1e37, 1e37);
  Read1r ('dX ( m ) :', DX, - 1e37, 1e37);
  
  {$ifndef debug}
  
  If grafik And grafikein Then Begin
    
    MoveTo (0, 30);
    OutText ('Biegelinie');
    
  End;
  
  {$endif}
  
  ClrScr;

  X := xu;
  Repeat
    GotoXY (1, 8); ClrEol;
    Write1r ('x=', X, ' m');
    GotoXY (1, 9); ClrEol;
    Write1r ('f=', f * 1000, ' mm');
    f := ber_f (X, e, tr. iy);
    If Abs (f) > Abs (tr. maxf) Then Begin tr. maxf := f; tr. x_maxf := X End;
    X := X + DX;
  Until X > (xo - DX);
  
  mx := Round ( ( 1024 - 20 )         / (xo - xu) );
  my := Round ( ( (768 Div 2 )  - 100) / abs(tr. maxf) );
  
  {$ifdef debug }
  
  Write1r ('MX=', mx, '');
  Write1r ('MY=', my, '');
  
  {$endif}
  
  If grafik Then
    {$ifndef debug}
  Begin
    Line (10, GetMaxY Div 2, Round (mx * tr. l), GetMaxY Div 2);
    Circle (Round (tr. a. X * mx), GetMaxY Div 2, 10);
    Circle (Round (tr. b. X * mx), GetMaxY Div 2, 10);
  End;
  {$endif}
  {$ifdef debug}
  {$endif}

  X := xu;
  If grafik Then
    Repeat
      
      f := ber_f (X, e, tr. iy);
      
      If grafik Then
        {$ifndef debug}
        PutPixel (Round (X * mx), (GetMaxY Div 2) + Round (f * my), 2);      {$endif}
      {$ifdef debug}
    Begin
      WriteLn (Round (X * mx), ' ', Round (f * my) + (GetMaxY Div 2), ' ', 2);
    End;
  {$endif}
  X := X + DX;
  
  Until X > (xo - DX);
  
  wartetaste;
  CloseGraph;
  
  tr. maxf := 1000 * tr. maxf;
  
  WriteLn;
  WriteLn;
  
  TextColor (LightGreen);
  Write1r ('maxf = ', tr. maxf, ' mm');
  Write1r ('an der Stelle x=', tr. x_maxf, ' m');
  TextColor (White);
  
  WriteLn;
  
  wartetaste;
  maxf_berechnet := True;
End;
Procedure dimensioniere;
Var minW: Real;
  sigma_zul: Real;
  fzul: Real;
  D: Real;
  i, j: Integer;
  {
  *****************************************************************************
  *****************************************************************************
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **             DIMENSIONIEREN                                              **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  *****************************************************************************
  *****************************************************************************
  }
Begin
  ClrScr;
  WriteLn ('Dimensionierung OHNE Beachtung der zul.Durchbiegung:');
  WriteLn ('====================================================');
  WriteLn;
  WriteLn;
  sigma_zul := 140;
  Read1r ('max. zul. Spannung (N/mm^2) :', sigma_zul, 0.01, 1e37);
  
  minW := tr. maxMb / sigma_zul;
  tr. minw := minw;
  WriteLn;
  TextColor (LightGreen);
  WriteLn ('min. erford. Widerstandsmoment = ', minW: 3: 3, 'cm^3');
  TextColor (White);
  WriteLn;
  If maxf_berechnet Then Begin
    WriteLn ('Dimensionierung M I T Beachtung der zul.Durchbiegung:');
    WriteLn ('====================================================');
    WriteLn;
    
    fzul := tr. l / 500 * 1000;
    
    Read1r ('max. zul. Durchbiegung eingeben (in mm):', fzul, - 1e37, 1e37);
    WriteLn;
    
    tr. minI := Abs (tr. iy * (tr. maxf / fzul) );
    
    WriteLn;
    TextColor (LightGreen);
    WriteLn ('min. erford. Fl„chentr„gheitsmoment = ', tr. minI: 3: 3, 'cm^4');
    TextColor (Yellow);
    WriteLn;
    WriteLn ('vorhandenes  Fl„chentr„gheitsmoment = ', tr. iy: 3: 3, 'cm^4');
    WriteLn;
    If tr. mini < tr. iy Then Begin
      TextColor (Green + Blink);
      WriteLn ('Iy vorh > Iy erf. => OK !');
      WriteLn;
      Write1r ('Sicherheit :', tr. iy / tr. minI, '');
    End Else Begin
      TextColor (Red + Blink);
      WriteLn ('Iy vorh < Iy erf. => UNTERDIMENSIONIERT !');
      WriteLn;
      Write1r ('Sicherheit :', tr. iy / tr. minI, '');
    End;
    
    TextColor (White);
    WriteLn;
    
  End;
  wartetaste;
End;
Procedure optimize; Begin End;
  {
  *****************************************************************************
  *****************************************************************************
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **             Daten Laden                                                 **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  *****************************************************************************
  *****************************************************************************
  }
Procedure load_it (s: String);
Var
  fi: Text;
  ff: File Of kraft;
  ft: File Of traeger;
  i: Integer;
  n, id: String;
Begin
	if s='' then begin fehler ('Bitte name angeben!'); exit end;
  n := pfad + s + '.tbi';
  Assign (fi, n);
  Reset (fi);
  ReadLn (fi, id);
  If id <> 'Tr„ber V8 Infofile (c) 08-08-994 by StE' Then
    fehler ('Falsches Dateiformat!')
  Else Begin
    ReadLn (fi, anzahl_f);
    ReadLn (fi, i); If i = 1 Then daten_vorhanden := True Else daten_vorhanden := False;
    ReadLn (fi, i); If i = 1 Then auflager_berechnet := True Else  auflager_berechnet := False;
    ReadLn (fi, i); If i = 1 Then maxmb_berechnet := True Else maxmb_berechnet := False;
    ReadLn (fi, i); If i = 1 Then maxf_berechnet := True Else maxf_berechnet := False;
    Close (fi);
    
    n := pfad + s + '.tbt';
    Assign (ft, n);
    Reset (ft);
    Read (ft, tr);
    Close (ft);
    
    n := pfad + s + '.tbf';
    Assign (ff, n);
    Reset (ff);
    For i := 1 To anzahl_f Do Read (ff, f [i] );
    Close (ff)
  End;
End;
  {
  *****************************************************************************
  *****************************************************************************
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **             Daten Speichern                                             **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  *****************************************************************************
  *****************************************************************************
  }
Procedure save_it (s: String);
Var
  fi: Text;
  ff: File Of kraft;
  ft: File Of traeger;
  i: Integer;
  n, id: String;
Begin
  n := pfad + s + '.tbi';
  Assign (fi, n);
  Rewrite (fi);
  WriteLn (fi, 'Tr„ber V8 Infofile (c) 08-08-994 by StE');
  WriteLn (fi, anzahl_f);
  If daten_vorhanden Then i := 1 Else i := 0;
  WriteLn (fi, i);
  If auflager_berechnet Then i := 1 Else i := 0;
  WriteLn (fi, i);
  If maxmb_berechnet Then i := 1 Else i := 0;
  WriteLn (fi, i);
  If maxf_berechnet Then i := 1 Else i := 0;
  WriteLn (fi, i);
  Close (fi);
  
  n := pfad + s + '.tbt';
  Assign (ft, n);
  Rewrite (ft);
  Write (ft, tr);
  Close (ft);
  
  n := pfad + s + '.tbf';
  Assign (ff, n);
  Rewrite (ff);
  For i := 1 To anzahl_f Do Write (ff, f [i] );
  Close (ff)
End;
Procedure disk_menu;
Var wahl, c, i: Integer;
  s: String;
  {
  *****************************************************************************
  *****************************************************************************
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  *****************************************************************************
  *****************************************************************************
  }
Begin
  wahl := - 1;
  ClrScr;
  WriteLn ('                  Disk Menu');
  WriteLn ('                  =========');
  WriteLn;
  WriteLn;
  WriteLn;
  WriteLn ('          1......Laden');
  WriteLn ('          2......Speichern');
  WriteLn;
  WriteLn ('          0......Ende');
  GotoXY (5, 15);
  While (wahl < 0) Or (wahl > 2) And (c <> 0)  Or ende Do Begin
    TextColor (LightGreen);
    Write ('Ihre Wahl:');
    TextColor (White);
    ReadLn (s);
    Val (s, wahl, c);
  End;
  Case wahl Of
    0: ;
    1:
      Begin
        GotoXY (5, 17);
        Write ('Name bitte (OHNE .tbr)'); ReadLn (s);
        load_it (s);
      End;
    
    2:
      Begin
        GotoXY (5, 17);
        Write ('Name bitte (OHNE .tbr)'); ReadLn (s);
        save_it (s);
      End;
  End;
End;
Procedure tabelle; Begin End;
Procedure init_hand; Begin End;
Procedure config; Begin End;

Procedure status;
Begin
  TextColor (LightBlue);
  GotoXY (1, 30); Write ('-+*=========================- STATUS -======================================*+-');
  
  WriteLn;
  WriteLn ('Anzahl Kr„fte:', anzahl_f-teil_q);

  textcolor(lightgreen);
  If auflager_berechnet Then begin
    out_f ('Festlager :', tr. fa);
    out_f ('Loslager  :', tr. fb);
  end;

  WriteLn;
  
  TextColor (Yellow);
  If maxmb_berechnet Then Begin
    WriteLn ('maxMb an der stelle x=', tr. x_maxmb: 3: 3, 'm betr„gt ', tr. maxmb: 3: 3, 'Nm');
    WriteLn ('maxQ an der stelle x=', tr. x_maxq: 3: 3, 'm betr„gt ', tr. maxq: 3: 3, 'N');
    WriteLn ('maxT an der stelle x=', tr. x_maxt: 3: 3, 'm betr„gt ', tr. maxt: 3: 3, 'N');
  End;
  WriteLn;
  TextColor (LightRed);
  If maxf_berechnet Then Begin
    Write1r ('maxf = ', tr. maxf, ' mm');
    Write1r ('an der Stelle x=', tr. x_maxf, ' m');
  End;
  TextColor (LightBlue);
  
  GotoXY (1, 49); Write ('-+*=========================================================================*+-');
End;

Procedure menu;
Var wahl, c: Integer;
  s: String;
  {
  *****************************************************************************
  *****************************************************************************
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **               M  E  N  U  E                                             **
  **              ~~~~~~~~~~~~~~~                                            **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  **                                                                         **
  *****************************************************************************
  *****************************************************************************
  }
Begin
  TextMode (co80 + Font8X8);
  TextColor (White);
  wahl := - 1;
  ClrScr;
  WriteLn ('                  Tr„ber V1.00');
  WriteLn ('                  ============');
  WriteLn;
  WriteLn;
  WriteLn;
  WriteLn ('          1......Dateneingabe');
  If daten_vorhanden Then TextColor (White) Else TextColor (Yellow);
  WriteLn ('          2......Auflagerreaktionen berechnen');
  If auflager_berechnet Then TextColor (White) Else TextColor (Yellow);
  WriteLn ('          3......Auflagerreaktionen anzeigen');
  If auflager_berechnet Then TextColor (White) Else TextColor (Yellow);
  WriteLn ('          4......Biegemoment Mb u. Querkraft Q an einer beliebigen');
  WriteLn ('                 Stelle x anzeigen');
  If auflager_berechnet Then TextColor (White) Else TextColor (Yellow);
  WriteLn ('          5......max. Mb berechnen und anzeigen');
  If auflager_berechnet Then TextColor (White) Else TextColor (Yellow);
  WriteLn ('          6......Durchbiegung an einer beliebigen Stelle x');
  WriteLn ('                 berechnen und anzeigen');
  If auflager_berechnet Then TextColor (White) Else TextColor (Yellow);
  WriteLn ('          7......maximale Durchbiegung anzeigen');
  If maxmb_berechnet Then TextColor (White) Else TextColor (Yellow);
  WriteLn ('          8......Dimensionierung');
  If maxmb_berechnet Then TextColor (White) Else TextColor (Yellow);
  WriteLn ('          9......Optimierung');
  TextColor (White);
  WriteLn ('          10.....Daten von Hand eingeben');
  WriteLn ('          11.....Konfiguration');
  WriteLn ('          12.....Tabelle');
  WriteLn;
  WriteLn ('          13.....Disk-opreationen');
  WriteLn;
  WriteLn ('          0.....Programmende');
  TextColor (Red);
  GotoXY (50, 24); Write ('(C) 1994 by Stefan Eletzhofer');
  
  status;
  
  GotoXY (10, 26);
  
  While (wahl < 0) Or (wahl > 9) And (c <> 0)  Or ende Do Begin
    TextColor (LightGreen);
    GotoXY (10, WhereY - 1);
    Write ('Ihre Wahl:');
    TextColor (White);
    ReadLn (s);
    If s <> '' Then Val (s, wahl, c) Else wahl := - 1;
  End;
  Case wahl Of
    0: ende := True;
    1: If auflager_berechnet Then Begin init; auflager_berechnet := False End Else init;
    2: If daten_vorhanden Then berechne_auflager Else fehler ('Zuerst Daten eingeben!');
    3: If auflager_berechnet Then ausgabe_auflager Else fehler ('Zuerst Auflager berechnen!');
    4: If auflager_berechnet Then berechne_mbq_beliebig Else fehler ('Zuerst Auflager berechnen!');
    5: If auflager_berechnet Then berechne_maxmbq Else fehler ('Zuerst Auflager berechnen!');
    6: If auflager_berechnet Then berechne_f_beliebig Else fehler ('Zuerst Auflager berechnen!');
    7: If auflager_berechnet Then berechne_maxf Else fehler ('Zuerst Auflager berechnen!');
    8: If maxmb_berechnet Then dimensioniere Else fehler ('Zuerst maximales Biegemoment berechnen!');
    9: optimize;
    10: init_hand;
    12: Tabelle;
    11: Config;
    13: Disk_menu;
  End;
End;
Var
  exitsave: pointer;
Procedure myexit; Far;
Begin
  ExitProc := exitsave;
  CloseGraph;
End;
Begin
  exitsave := ExitProc;
  ExitProc := @myexit;
  pfad := 'z:\tp70\lagerber\';
  HighVideo;
  TextBackground (Black);
  TextColor (White);
  ende := False;
  maxmb_berechnet := False;
  auflager_berechnet := False;
  maxf_berechnet := False;
  init_debug;
  load_it ('default');
  Repeat
    menu;
  Until ende;
End.