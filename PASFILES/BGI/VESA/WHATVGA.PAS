
Uses DOS, crt, supervga;


Procedure setpix (X, Y: Word; col: LongInt);
Const
  msk: Array [0..7] Of Byte = (128, 64, 32, 16, 8, 4, 2, 1);
  plane : Array [0..1] Of Byte = (5, 10);
  plane4: Array [0..3] Of Byte = (1, 2, 4, 8);
  mscga4: Array [0..3] Of Byte = ($3f, $cf, $f3, $fc);
  shcga4: Array [0..3] Of Byte = (6, 4, 2, 0);
Var l: LongInt;
  m, z: Word;
Begin
  Case memmode Of
    _cga2: 
           Begin
             z := (Y ShR 1) * bytes + (X ShR 3);
             If Odd (Y) Then Inc (z, 8192);
             mem [$b800: z] := (mem [$b800: z] And (255 XOr msk [X And 7] ) )
                                              Or ( (col And 1) ShL (7 - (X And 7) ) );
           End;
    _cga4: 
           Begin
             z := (Y ShR 1) * bytes + (X ShR 2);
             If Odd (Y) Then Inc (z, 8192);
             mem [$b800: z] := (mem [$b800: z] And mscga4 [X And 3] )
                                              Or (col And 3) ShL shcga4 [X And 3];
           End;
    _pl2: 
          Begin
            l := Y * bytes + (X ShR 3);
            wrinx ($3ce, 3, 0);
            wrinx ($3ce, 5, 2);
            wrinx ($3c4, 2, 1);
            wrinx ($3ce, 8, msk [X And 7] );
            setbank (l ShR 16);
            z := mem [vseg: Word (l) ];
            mem [vseg: Word (l) ] := col;
          End;
    _pl2e: 
           Begin
             l := Y * 128 + (X ShR 3);
             modinx ($3ce, 5, 3, 0);
             wrinx ($3c4, 2, 15);
             wrinx ($3ce, 0, col * 3);
             wrinx ($3ce, 1, 3);
             wrinx ($3ce, 8, msk [X And 7] );
             z := mem [vseg: Word (l) ];
             mem [vseg: Word (l) ] := 0;
           End;
    _pl4: 
          Begin
            l := Y * bytes + (X ShR 4);
            wrinx ($3ce, 3, 0);
            wrinx ($3ce, 5, 2);
            wrinx ($3c4, 2, plane [ (X ShR 3) And 1] );
            wrinx ($3ce, 8, msk [X And 7] );
            setbank (l ShR 16);
            z := mem [vseg: Word (l) ];
            mem [vseg: Word (l) ] := col;
          End;
    _pk4: 
          Begin
            l := Y * bytes + (X ShR 2);
            setbank (l ShR 16);
            z := mem [vseg: Word (l) ] And mscga4 [X And 3];
            mem [vseg: Word (l) ] := z Or (col ShL shcga4 [X And 3] );
          End;
    _pl16: 
           Begin
             l := Y * bytes + (X ShR 3);
             wrinx ($3ce, 3, 0);
             wrinx ($3ce, 5, 2);
             wrinx ($3ce, 8, msk [X And 7] );
             setbank (l ShR 16);
             z := mem [vseg: Word (l) ];
             mem [vseg: Word (l) ] := col;
           End;
    _pk16: 
           Begin
             l := Y * bytes + (X ShR 1);
             setbank (l ShR 16);
             z := mem [vseg: Word (l) ];
             If Odd (X) Then z := z And $f + (col ShL 4)
             Else z := z And $f0 + col;
             mem [vseg: Word (l) ] := z;
           End;
    _p256: 
           Begin
             l := Y * bytes + X;
             setbank (l ShR 16);
             mem [vseg: Word (l) ] := col;
           End;
    _p32k, _p64k:
                 Begin
                   l := Y * bytes + (X ShL 1);
                   setbank (l ShR 16);
                   memw [vseg: Word (l) ] := col;
                 End;
    _p16m: 
           Begin
             l := Y * bytes + (X * 3);
             z := Word (l);
             m := l ShR 16;
             setbank (m);
             If z < $fffe Then Move (col, mem [vseg: z], 3)
             Else Begin
               mem [vseg: z] := Lo (col);
               If z = $ffff Then setbank (m + 1);
               mem [vseg: z + 1] := Lo (col ShR 8);
               If z = $fffe Then setbank (m + 1);
               mem [vseg: z + 2] := col ShR 16;
             End;
           End;
    Else ;
  End;
End;


Procedure setvstartxy (X, Y: Word);
Var l: LongInt;
Begin
  l := 0;
  Case memmode Of
    _pl16: l := (bytes * Y + (X Div 8) ) * 4;
    _p256: l := bytes * Y + X;
    _p32k, _p64k: l := bytes * Y + X * 2;
    _p16m: l := bytes * Y + X * 3;
  End;
  setvstart (l);
End;


Function whitecol: LongInt;
Var col: LongInt;
Begin
  Case memmode Of
    _cga2, _pl2e,
    _pl2: col := 1;
    _cga4, _pk4
    , _pl4: col := 3;
    _pk16, _pl16,
    _p256: col := 15;
    _p32k: col := $7fff;
    _p64k: col := $ffff;
    _p16m: col := $ffffff;
    Else
  End;
  whitecol := col;
End;


Procedure wrtext (X, Y: Word; txt: String);      {write TXT to pos (X,Y)}
Type
  pchar = Array [Char] Of Array [0..15] Of Byte;
Var
  p:^pchar;
  c: Char;
  i, j, z, b: Integer;
  ad, bk: Word;
  l, v, col: LongInt;
Begin
  rp. BH := 6;
  vio ($1130);
  Case memmode Of
    _cga2, _pl2e,
    _pl2: col := 1;
    _cga4, _pk4
    , _pl4: col := 3;
    _pk16, _pl16,
    _p256: col := 15;
    _p32k: col := $7fff;
    _p64k: col := $ffff;
    _p16m: col := $ffffff;
    Else
  End;
  p := Ptr (rp. ES, rp. BP);
  For z := 1 To Length (txt) Do
  Begin
    c := txt [z];
    For j := 0 To 15 Do
    Begin
      b := p^ [c] [j];
      For i := 0 To 7 Do
      Begin
        If (b And 128) <> 0 Then v := col Else v := 0;
        setpix (X + i, Y + j, v);
        b := b ShL 1;
      End;
    End;
    Inc (X, 8);
  End;
End;


Procedure drawtestpattern (nam: String);
                       {Draw Test pattern.}
Var s: String;
  l: LongInt;
  X, Y, yst: Word;
  White: LongInt;
  
Function RGB (r, g, b: Word): LongInt;
  Begin
    r := Lo (r); g := Lo (g); b := Lo (b);
    Case colbits [memmode] Of
      1: RGB := r And 1;
      2: RGB := r And 3;
      4: RGB := r And 15;
      8: RGB := r;
      15: RGB := ( (r ShR 3) ShL 5 + (g ShR 3) ) ShL 5 + (b ShR 3);
      16: RGB := ( (r ShR 3) ShL 6 + (g ShR 2) ) ShL 5 + (b ShR 3);
      24: RGB := (LongInt (r) ShL 8 + g) ShL 8 + b;
    End;
  End;


  Procedure wline (stx, sty, ex, ey: Integer);
  Var X, Y, D, mx, my: Integer;
    l: LongInt;
  Begin
    If sty > ey Then
    Begin
      X := stx; stx := ex; ex := X;
      X := sty; sty := ey; ey := X;
    End;
    Y := 0;
    mx := Abs (ex - stx);
    my := ey - sty;
    D := 0;
    Repeat
      l := RGB (Y, Y, Y);
      Y := (Y + 1) And 255;
      setpix (stx, sty, l);
      If Abs (D + mx) < Abs (D - my) Then
      Begin
        Inc (sty);
        D := D + mx;
      End
      Else Begin
        D := D - my;
        If ex > stx Then Inc (stx)
        Else Dec (stx);
      End;
    Until (stx = ex) And (sty = ey);
    
  End;

Begin
  
  White := whitecol;
  
  wline (50, 30, pixels - 50, 30);
  wline (50, lins - 30, pixels - 50, lins - 30);
  
  wline (50, 30, 50, lins - 30);
  wline (pixels - 50, 30, pixels - 50, lins - 30);
  wline (50, 30, pixels - 50, lins - 30);
  
  wline (pixels - 50, 30, 50, lins - 30);
  
  If lins > 200 Then yst := 50 Else yst := 10;
  wrtext (10, yst, Name + ' with ' + istr (mm) + ' Kbytes.');
  wrtext (10, yst + 25, nam);
  
  For X := 1 To (pixels - 10) Div 100 Do
  Begin
    For Y := 1 To 10 Do
      setpix (X * 100, Y, White);
    wrtext (X * 100 + 3, 1, istr (X) );
  End;
  
  For X := 1 To (lins - 10) Div 100 Do
  Begin
    For Y := 1 To 10 Do
      setpix (Y, X * 100, White);
    wrtext (1, X * 100 + 2, istr (X) );
  End;
  
  Case memmode Of
    _pk4,
    _pl4: For X := 0 To 63 Do
      For Y := 0 To 63 Do
        setpix (30 + X, yst + Y + 50, Y ShR 3);
    _pk16,
    _pl16: For X := 0 To 127 Do
      If lins < 250 Then
        For Y := 0 To 63 Do
          setpix (30 + X, yst + Y + 50, Y ShR 2)
      Else
        For Y := 0 To 127 Do
          setpix (30 + X, yst + Y + 50, Y ShR 3);
    _p256: For X := 0 To 127 Do
      If lins < 250 Then
        For Y := 0 To 63 Do
          setpix (30 + X, yst + 50 + Y, ( (Y ShL 2) And 240) + (X ShR 3) )
      Else
        For Y := 0 To 127 Do
          setpix (30 + X, yst + 50 + Y, ( (Y ShL 1) And 240) + (X ShR 3) );
    
    _p32k, _p64k, _p16m:
                          If pixels < 600 Then
                          Begin
                            For X := 0 To 63 Do
                            Begin
                              For Y := 0 To 63 Do
                              Begin
                                setpix (30 + X, 100 + Y, RGB (X * 4, Y * 4, 0) );
                                setpix (110 + X, 100 + Y, RGB (X * 4, 0, Y * 4) );
                                setpix (190 + X, 100 + Y, RGB (0, X * 4, Y * 4) );
                              End;
                            End;
                            For X := 0 To 255 Do
                              For Y := 170 To 179 Do
                              Begin
                                setpix (X, Y, RGB (X, 0, 0) );
                                setpix (X, Y + 10, RGB (0, X, 0) );
                                setpix (X, Y + 20, RGB (0, 0, X) );
                              End;
                          End
    Else Begin
      For X := 0 To 127 Do
        For Y := 0 To 127 Do
        Begin
          setpix (30 + X, 120 + Y, RGB (X * 2, Y * 2, 0) );
          setpix (200 + X, 120 + Y, RGB (X * 2, 0, Y * 2) );
          setpix (370 + X, 120 + Y, RGB (0, X * 2, Y * 2) );
        End;
      For X := 0 To 511 Do
        For Y := 260 To 269 Do
        Begin
          setpix (X, Y, RGB (X ShR 1, 0, 0) );
          setpix (X, Y + 10, RGB (0, X ShR 1, 0) );
          setpix (X, Y + 20, RGB (0, 0, X ShR 1) );
        End;
    End;
    
  End;
End;


Procedure testvmode;
Begin
  drawtestpattern ('Mode: ' + hex4 (curmode) + 'h: ' + istr (pixels) + 'x' + istr (lins) + ' '
  + istr (modecols [memmode] ) + ' colors');
  If ReadKey = '' Then;
  
  TextMode (3);
End;

Procedure wrmono (s: String);
Var X: Word;
Begin
  For X := 1 To Length (s) Do
    mem [$b000: X + X] := Ord (s [X] );
End;

Procedure testscrollmode;
Var s: String;
  r13, sclins, scpixs: Word;
  X0, Y0: Integer;
  CH: Char;
Begin
  sclins := lins;
  scpixs := pixels;
  s := 'Mode: ' + hex4 (curmode) + 'h: ' + istr (pixels) + 'x' + istr (lins) + ' ' + istr (modecols [memmode] ) + ' colors';
  r13 := rdinx (crtc, $13);
  If (r13 < 128) And ( (bytes * lins * planes * 5 Div 2) < mm * LongInt (1024) ) Then
  Begin
    wrinx (crtc, $13, r13 * 2);
    bytes := bytes * 2;
    pixels := pixels * 2;
  End;
  lins := mm * LongInt (1024) Div (bytes * planes);
  
  For X0 := 0 To (mm Div 64) - 1 Do
  Begin
    setbank (X0);
    FillChar (mem [vseg: 1], $ffff, 0);
    mem [vseg: 0] := 0;
  End;
  
  drawtestpattern (s);
  X0 := 0;
  Y0 := 0;
  Repeat
    setvstartxy (X0, Y0);
    wrmono (istr (X0) + ':' + istr (Y0) + '.');
    CH := ReadKey;
    If CH = #0 Then
      Case ReadKey Of
        #72: Y0 := Y0 - 16;
        #75: X0 := X0 - 16;
        #77: X0 := X0 + 16;
        #80: Y0 := Y0 + 16;
        #73: Dec (Y0);
        #81: Inc (Y0);
      End;
    If X0 < 0 Then X0 := 0;
    If Y0 < 0 Then Y0 := 0;
    If X0 > pixels - scpixs Then X0 := pixels - scpixs;
    If Y0 > lins - sclins Then Y0 := lins - sclins;
    
  Until (CH = #27) Or (CH = #13);
  
  TextMode (3);
End;







Procedure testvgamodes;           {Test extended modes}
Var m: Word;
  md: Integer;
  c: Char;
  
Procedure tmode (m: Word);
Begin
  memmode := modetbl [m].memmode;
  pixels := modetbl [m].xres;
  lins   := modetbl [m].yres;
  bytes  := modetbl [m].bytes;
  If setmode (modetbl [m].md) Then testvmode;
End;

Begin
  TextMode ($103);
  WriteLn ('Modes:');
  WriteLn;
  For m := 1 To nomodes Do
  Begin
    WriteLn ('  ' + Chr (m + 64) + ' ' + hex4 (modetbl [m].md) + 'h ' + istr (modetbl [m].xres)
    + 'x' + istr (modetbl [m].yres) + ' ' + mdtxt [modetbl [m].memmode] );
  End;
  WriteLn;
  
  WriteLn ('  *  All modes');
  
  WriteLn;
  c := UpCase (ReadKey);
  For m := 1 To nomodes Do
    If (c = '*') Or (c = Chr (m + 64) ) Then tmode (m);
  
End;

Procedure teststdvgamodes;          {Test standard VGA modes}
Var m: Word;
  md: Integer;
  c: Char;
  
Procedure tmode (m: Word);
Begin
  memmode := stdmodetbl [m].memmode;
  pixels := stdmodetbl [m].xres;
  lins   := stdmodetbl [m].yres;
  bytes  := stdmodetbl [m].bytes;
  If setmode (stdmodetbl [m].md) Then testvmode;
End;

Begin
  TextMode ($103);
  WriteLn ('Modes:');
  WriteLn;
  For m := 1 To novgamodes Do
  Begin
    WriteLn ('  ' + Chr (m + 64) + ' ' + hex4 (stdmodetbl [m].md) + 'h ' + istr (stdmodetbl [m].xres)
    + 'x' + istr (stdmodetbl [m].yres) + ' ' + mdtxt [stdmodetbl [m].memmode] );
  End;
  WriteLn;
  WriteLn ('  *  All modes');
  
  WriteLn;
  c := UpCase (ReadKey);
  For m := 1 To novgamodes Do
    If (c = '*') Or (c = Chr (m + 64) ) Then tmode (m);
  
End;


Procedure testscrollmodes;           {Test scrolling}
Var
  m: Word;
  c: Char;
  
Procedure tmode (m: Word);
Begin
  memmode := modetbl [m].memmode;
  pixels := modetbl [m].xres;
  lins   := modetbl [m].yres;
  bytes  := modetbl [m].bytes;
  If setmode (modetbl [m].md) Then testscrollmode;
End;

Begin
  TextMode ($103);
  WriteLn ('Modes:');
  WriteLn;
  For m := 1 To nomodes Do
  Begin
    WriteLn ('  ' + Chr (m + 64) + ' ' + hex4 (modetbl [m].md) + 'h ' + istr (modetbl [m].xres)
    + 'x' + istr (modetbl [m].yres) + ' ' + mdtxt [modetbl [m].memmode] );
  End;
  WriteLn;
  
  WriteLn ('  *  All modes');
  
  WriteLn;
  c := UpCase (ReadKey);
  For m := 1 To nomodes Do
    If (c = '*') Or (c = Chr (m + 64) ) Then tmode (m);
  
End;

Procedure searchformodes;      {Run through all possible modes
                                and try to id any new ones}
Type
  regblk = Record
             base: Word;
             nbr: Word;
             X: Array [0..255] Of Byte;
           End;
Var
  md, m, bseg, hig, wid, X, Y, oldbytes, wordadr: Word;
  c: Char;
  ofil: Text;
  attregs: Array [0..31] Of Byte;
  seqregs, grcregs, crtcregs, xxregs: regblk;
  stdregs: Array [$3c0..$3df] Of Byte;
  l: LongInt;
  s: String;
  
  
Procedure dumprg (base: Word; Var rg: regblk);
Var six, ix: Word;
Begin
  rg. base := base;
  six := inp (base);
  outp (base, 255);
  ix := inp (base);
  If ix > 127 Then rg. nbr := 255
  Else If ix > 63 Then rg. nbr := 127
  Else If ix > 31 Then rg. nbr := 63
  Else If ix > 15 Then rg. nbr := 31
  Else If ix > 7 Then rg. nbr := 15
  Else rg. nbr := 7;
  For ix := 0 To rg. nbr Do
    rg. X [ix] := rdinx (base, ix);
  outp (base, six);
End;

Procedure wrregs (Var f: Text; Var rg: regblk);
Var X: Word;
Begin
  Write (f, hex4 (rg. base) + ':');
  For X := 0 To rg. nbr Do
  Begin
    If (X Mod 25 = 0) And (X > 0) Then
      Write (f, '(' + hex2 (X) + '):');
    
    Write (f, ' ' + hex2 (rg. X [X] ) );
  End;
  WriteLn (f);
End;

Procedure dumpregs (Var f: Text);
Var X: Word;
Begin
  WriteLn (f, 'Mode: ' + hex2 (md) + 'h Pixels: ' + istr (pixels) + ' lines: ' + istr (lins)
  + ' bytes: ' + istr (bytes) + ' colors: ' + istr (modecols [memmode] ) );
  WriteLn (f);
  For X := $3C0 To $3CF Do Write (' ' + hex2 (stdregs [X] ) );
  WriteLn (f);
  For X := $3D0 To $3DF Do Write (' ' + hex2 (stdregs [X] ) );
  WriteLn (f);
  Write (f, '03C0:');
  For X := 0 To 31 Do
  Begin
    If X = 25 Then
    Begin
      WriteLn (f);
      Write (f, '(19):');
    End;
    Write (f, ' ' + hex2 (attregs [X] ) );
  End;
  WriteLn (f);
  wrregs (f, seqregs);
  wrregs (f, grcregs);
  wrregs (f, crtcregs);
  If xxregs. base <> 0 Then wrregs (f, xxregs);
  WriteLn (f);
End;



Procedure plotchar (X, Y, CH: Word);
Begin
  mem [bseg: (Y * wid + X) ShL 1] := CH;
End;

Procedure plotchat (X, Y, CH, at: Word);
Begin
  memw [bseg: (Y * wid + X) ShL 1] := at ShL 8 + CH;
End;

Procedure plotstr (X, Y: Word; s: String);
Var z: Word;
Begin
  For z := 1 To Length (s) Do
    plotchar (X + z - 1, Y, Ord (s [z] ) );
End;

Begin
  For md := $14 To $7f Do
  Begin
    TextMode (3);
    GotoXY (10, 10);
    Write ('Testing mode: ' + hex2 (md) );
    Delay (500);
    vio (md);
    If mem [0:$449] = md Then
    Begin
      For X := $3C2 To $3DF Do stdregs [X] := inp (X);
      X := inp ($3DA);
      stdregs [$3C0] := inp ($3C0);
      For X := 0 To 31 Do attregs [X] := rdinx ($3C0, X);
      X := rdinx ($3C0, $30);
      dumprg (crtc, crtcregs);
      dumprg ($3C4, seqregs);
      dumprg ($3CE, grcregs);
      Case chip Of
        __chips451, __chips452, __chips453: dumprg (crtc + 2, xxregs);
        Else xxregs. base := 0;
      End;
      m := grcregs. X [6];
      Case (m ShR 2) And 3 Of
        0, 1: bseg := $a000;
        2: bseg := $b000;
        3: bseg := $b800;
      End;
      If Odd (m) Then
      Begin  {graf mode}
        lins := crtcregs. X [$12] + 1;
        X := crtcregs. X [7];
        If (X And 2) <> 0 Then Inc (lins, 256);
        If (X And 64) <> 0 Then Inc (lins, 512);
        pixels := (crtcregs. X [1] + 1) * 8;
        
        wid := crtcregs. X [$13];
        wordadr := 2;
        If (crtcregs. X [$14] And 64) <> 0 Then wordadr := 8
        Else If (crtcregs. X [$17] And 64) = 0 Then wordadr := 4;
        Case chip Of
          __p2000: If (grcregs. X [$13] And 64) <> 0 Then
          Begin
            wordadr := wordadr ShR 1;
            If (grcregs. X [$21] And 32) <> 0 Then Inc (wid, 256);
          End;
          __cirrus54: 
                      Begin
                        If (crtcregs. X [$1B] And 16) <> 0 Then Inc (wid, 256);
                        If (crtcregs. X [$1A] And 1) <> 0 Then lins := lins * 2;
                      End;
          __tseng4: If (crtcregs. X [$3f] And 128) <> 0 Then Inc (wid, 256);
        End;
        X := seqregs. X [4];
        If (X And 8) <> 0 Then  {256 color}
        Begin
          memmode := _p256;
          If dactype > _dac8 Then
          Begin
            dactocomm;
            X := inp ($3c6);
            
            If X > 127 Then memmode := _p32k;
            Case dactype Of
              _dac16: If (X And 64) <> 0 Then memmode := _p64k;
              (*  _dacss24:if x=$8e then
              begin
              memmode:=_p16m;
              pixels:=pixels*3;
              end;  *)
              _dacatt: Case (X And $60) Of
                $40: memmode := _p64k;
                $60: memmode := _p16m;
              End;
              _dacadac1: Case X Of
                $E1: memmode := _p64k;
                $E5: memmode := _p16m;
                $F0: memmode := _p32k;
              End;
            End;
            dactopel;
          End;
        End
        { else if (x and 4)<>0 then
        begin
        memmode:=_pl4;
        bytes:=wid;
        end }
        Else memmode := _pl16;
        bytes := wid * wordadr;
        Case memmode Of               {Adjust for HiColor}
          _p32k, _p64k: pixels := pixels Div 2;
          _p16m: pixels := pixels Div 3;
        End;
        If (pixels > 800) And (pixels >= 2 * lins) Then  {adjust for interlace}
          lins := lins * 2;
        
        Repeat
          oldbytes := bytes;
          
          If setmode (md) Then
          Begin
            Case colbits [memmode] Of
              15: s := '32K';
              16: s := '64K';
              24: s := '16M';
              Else s := istr (modecols [memmode] );
            End;
            drawtestpattern ('Mode: ' + hex2 (md) + ' (' + istr (pixels) + 'x' + istr (lins) + ' '
            + s + ' col) ' + istr (bytes) + ' bytes.');
          End;
          
          Case ReadKey Of
            #0: 
                Begin
                  c := ReadKey;
                  Case c Of
                    #73: bytes := bytes ShL 1;
                    #81: bytes := bytes ShR 1;
                    #72: Inc (bytes);
                    #80: Dec (bytes);
                  End;
                End;
            'd', 'D': 
                      Begin
                        bytes := oldbytes;
                        TextMode ($103);
                        dumpregs (Output);
                        If ReadKey = '' Then;
                      End;
            'f', 'F': 
                      Begin
                        bytes := oldbytes;
                        Assign (ofil, 'register.vga');
                        {$i-}
                        Append (ofil);
                        {$i+}
                        If IOResult <> 0 Then Rewrite (ofil);
                        dumpregs (ofil);
                        Close (ofil);
                      End;
          End;
        Until bytes = oldbytes;
      End
      Else Begin {text mode}
        For X := 0 To 16383 Do
          memw [bseg: X + X] := $720;
        wid := memw [0:$44a];
        For X := 0 To wid - 1 Do
        Begin
          plotchar (X, 0, (X Mod 10) + Ord ('0') );
          If (X Mod 10) = 0 Then
            plotchar (X, 1, ( (X Div 10) Mod 10) + Ord ('0') );
        End;
        hig := mem [0:$484];
        For X := 0 To hig Do
        Begin
          plotchar (0, X, (X Mod 10) + Ord ('0') );
          If (X Mod 10) = 0 Then
            plotchar (1, X, ( (X Div 10) Mod 10) + Ord ('0') );
        End;
        plotstr (5, 5, 'Testing mode ' + hex2 (md) + 'h: ' + istr (wid) + 'x' + istr (hig + 1) );
        For X := 0 To 255 Do
          plotchat (X And 15 + 10, X ShR 4 + 7, 65, X);
        If ReadKey = '' Then;
        X := X;
      End;
    End;
  End;
  TextMode (3);
End;



Procedure testvesamodes;          {Test VESA modes}
Type
  modelist = Array [1..100] Of Word;
Var
  vesahrec: Record
              sign: LongInt;
              version: Word;
              oemname:^Char;
              capabilities: LongInt;
              list:^modelist;
              xx: Array [1..256] Of Byte;  {Might be filled by AX=4F00h}
            End;
  Mode, X, Y, novesamodes: Word;
  oldchip: chips;
  c: Char;
  
Procedure tmode (m: Word);
Begin
  vesamodeinfo (m);
  pixels := vesarec. width;
  lins   := vesarec. height;
  bytes  := vesarec. bytes;
  If setmode (m) Then testvmode;
End;


Begin
  oldchip := chip;
  chip := __vesa;
  rp. ES := Seg (vesahrec);
  rp. DI := Ofs (vesahrec);
  vesahrec. sign := $41534556;
  vio ($4f00);
  Mode := 1;
  
  {S3 VESA driver can return wrong segment if run with QEMM}
  If {(oldchip=__s3) and} (Seg (vesahrec. list^) = $e000) Then
    vesahrec. list := Ptr ($c000, Ofs (vesahrec. list^) );
  TextMode ($103);
  WriteLn ('Modes:');
  WriteLn;
  While vesahrec. list^ [Mode] <> $ffff Do
  Begin
    vesamodeinfo (vesahrec. list^ [Mode] );
    WriteLn ('  ' + Chr (Mode + 64) + ' ' + hex4 (vesahrec. list^ [Mode] ) + 'h '
    + istr (vesarec. width) + 'x' + istr (vesarec. height) + ' '
    + mdtxt [memmode] );
    
    Inc (Mode);
  End;
  novesamodes := Mode;
  WriteLn;
  WriteLn ('  *  All modes');
  
  WriteLn;
  c := UpCase (ReadKey);
  For Mode := 1 To novesamodes Do
    If (c = '*') Or (c = Chr (Mode + 64) ) Then
      tmode (vesahrec. list^ [Mode] );
  chip := oldchip;
  TextMode (3);
  ClrScr;
End;


Var
  stop: Boolean;
  
  
Procedure loadmodes;              {Load extended modes for this chip}
Var
  t: Text;
  s, pat: String;
  md, X, xres, yres, err, mreq, byt: Word;
  
  
Function unhex (s: String): Word;
Var X: Word;
Begin
  For X := 1 To 4 Do
    If s [X] > '9' Then
      s [X] := Chr (Ord (s [X] ) And $5f - 7);
  unhex := ( ( (Word (Ord (s [1] ) - 48) ShL 4
  +  Word (Ord (s [2] ) - 48) ) ShL 4
  +  Word (Ord (s [3] ) - 48) ) ShL 4
  +  Word (Ord (s [4] ) - 48) );
End;

Function mmode (s: String): mmods;
Var X: mmods;
Begin
  For X := _text To _p16m Do
    If s = mmodenames [X] Then mmode := X;
  
End;

Begin
  nomodes := 0;
  pat := '[' + header [chip] + ']';
  Assign (t, 'whatvga.lst');
  Reset (t);
  s := ' ';
  While (Not EoF (t) ) And (s <> pat) Do ReadLn (t, s);
  s := ' ';
  ReadLn (t, s);
  While (s [1] <> '[') And (s <> '') Do
  Begin
    md := unhex (Copy (s, 1, 4) );
    memmode := mmode (Copy (s, 6, 4) );
    Val (Copy (s, 11, 5), xres, err);
    Val (Copy (s, 17, 4), yres, err);
    Case memmode Of
      _text, _text4: bytes := xres * 2;
      _pl2e, _herc, _cga2, _pl2: bytes := xres ShR 3;
      _pk4, _pl4, _cga4: bytes := xres ShR 4;
      _pl16, _pk16: bytes := xres ShR 1;
      _p256: bytes := xres;
      _p32k, _p64k: bytes := xres * 2;
      _p16m: bytes := xres * 3;
      Else
    End;
    Case dactype Of
      _dac8: If memmode > _p256 Then memmode := _text;
      _dac15: If memmode > _p32k Then memmode := _text;
      _dac16: If memmode = _p16m Then memmode := _text;
      _dacss24: If memmode = _p64k Then memmode := _text;
    End;
    Val (Copy (s, 22, 5), byt, err);
    If (err = 0) And (byt > 0) Then bytes := byt;
    If err <> 0 Then mreq := (LongInt (bytes) * yres + 1023) Div 1024;
    Case memmode Of
      _pl16: bytes := xres ShR 3;
    End;
    If (memmode > _text4) And (mm >= mreq) Then
    Begin
      Inc (nomodes);
      modetbl [nomodes].xres := xres;
      modetbl [nomodes].yres := yres;
      modetbl [nomodes].md := md;
      modetbl [nomodes].bytes := bytes;
      modetbl [nomodes].memmode := memmode;
    End;
    ReadLn (t, s);
  End;
  Close (t);
End;


Var
  chp, force_chip: chips;
  s: String;
  force_mm: Word;
  err, X: Word;
  
  
Begin
  FillChar (dotest, SizeOf (dotest), Ord (True) );   {allow test for all chips}
  force_mm := 0;
  force_chip := __none;
  For X := 1 To ParamCount Do
  Begin
    s := ParamStr (X);
    Case s [1] Of
      '-': 
           Begin
             s := upstr (strip (Copy (s, 2, 255) ) );
             For chp := chips (1) To __none Do
               If upstr (header [chp] ) = s Then
                 dotest [chp] := False;
           End;
      '+': 
           Begin
             s := upstr (strip (Copy (s, 2, 255) ) );
             FillChar (dotest, SizeOf (dotest), Ord (False) );
             For chp := chips (1) To __none Do
               If upstr (header [chp] ) = s Then
               Begin
                 dotest [chp] := True;
                 force_chip := chp;
               End;
           End;
      '=': Val (Copy (s, 2, 255), force_mm, err);
    End;
  End;
  
  findvideo;
  
  If force_chip <> __none Then chip := force_chip;
  If force_mm <> 0 Then mm := force_mm;
  
  loadmodes;
  
  
  
  stop := False;
  Repeat
    TextMode (3);
    WriteLn ('WHATVGA v. 1.0    23/jan/93    Copyright 1991,92,93  Finn Thoegersen');
    WriteLn;
    
    Write ('Video system: ', video, ' with ' + istr (mm) + ' Kbytes.');
    If _crt <> '' Then Write (' Monitor: ' + _crt);
    WriteLn;
    If secondary <> '' Then WriteLn ('Secondary display: ' + secondary);
    Write ('Chipset: ' + header [chip] );
    If Name <> '' Then Write ('  Name: ' + Name);
    WriteLn;
    If extra <> '' Then WriteLn (extra);
    WriteLn ('Dac: ' + dacname);
    
    WriteLn;
    WriteLn ('     1  Test Standard VGA modes');
    WriteLn ('     2  Test Extended VGA modes');
    WriteLn ('     3  Test scroll function');
    WriteLn ('     4  Search for video modes');
    If vesa <> 0 Then
      WriteLn ('     5  Test VESA modes.');
    WriteLn ('     9  Stop');
    WriteLn;
    Case ReadKey Of
      '1': teststdvgamodes;
      '2': testvgamodes;
      '3': testscrollmodes;
      '4': searchformodes;
      '5': If vesa <> 0 Then testvesamodes;
      
      '9': stop := True;
    End;
    
  Until stop;
  
  
  vio (3);
End.