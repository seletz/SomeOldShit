Unit vesa;
(****************************************************************************
 *
 * VESA-Grafikmodi, setpixel.
 *
 *
 *
 ***************************************************************************)

(***************************************************************************)
(***************************************************************************)
(***************************************************************************)
(***************************************************************************)
Interface
Uses
  DOS;
Const
  {
  VESA-Modi
  }
  mode_640X400X256		 = $100;
  mode_640X480X256    = $101;
  mode_800X600X16     = $102;
  mode_800X600X256    = $103;
  mode_1024X768X16    = $104;
  mode_1024X768X256   = $105;
  mode_1280X1024X16   = $106;
  mode_1280X1024X256  = $107;
  mode_80X60xtext     = $108;
  mode_132X25xtext    = $109;
  mode_132X43xtext    = $10a;
  mode_132X50xtext    = $10b;
  mode_132X60xtext    = $10c;
  { ------------ VBE v1.2+ ------------------}
  mode_320X200X32k    = $10D;
  mode_320X200X64k    = $10e;
  mode_320X200X16M    = $10f;
  mode_640X480X32k    = $110;
  mode_640X480X64k    = $111;
  mode_640X480X16M    = $112;
  mode_800X600X32k    = $113;
  mode_800X600X64k    = $114;
  mode_800X600X16M    = $115;
  mode_1024X768X32k   = $116;
  mode_1024X768X64k   = $117;
  mode_1024X768X16M   = $118;
  mode_1280X1024X32k  = $119;
  mode_1280X1024X64k  = $11a;
  mode_1280X1024X16M  = $11b;
  
Type
  mmods = (_text,
  _text2,
  _text4,
  _pl2 ,   {plain mono, 8 pixels per byte}
  _pl2e,   {mono odd/even, 8 pixels per byte, two planes}
  _herc,   {Hercules mono, 4 "banks" of 8kbytes}
  _cga2,   {CGA 2 color, 2 "banks" of 16kbytes}
  _cga4,   {CGA 4 color, 2 "banks" of 16kbytes}
  _pl4 ,   {4 color odd/even planes}
  _pk4 ,   {4 color "packed" pixels 4 pixels per byte}
  _pl16,   {std EGA/VGA 16 color: 4 planes, 8 pixels per byte}
  _pk16,   {ATI mode 65h two 16 color pixels per byte}
  _p256,   {one 256 color pixel per byte}
  _p32k,   {Sierra 15 bit}
  _p64k,   {Sierra 16bit/XGA}
  _p16m);  {RGB 3bytes per pixel}
  
  modetype = Record
               md, xres, yres, bytes: Word;
               memmode: mmods;
             End;

  modelist = Array [$0..$100] Of Word;

  vesa_rec_p = ^vesa_rec;
  vesa_rec = 	Record
                VESA_signatur: Array [1..4] Of Char;
                VESA_version_major: Byte;
                VESA_version_minor: Byte;
                Hersteller: PChar; { Zeiger auf ASCII - String  }
                cap_flag: LongInt;
                mode_list: ^modelist; { Liste der unterstuetzten modi }
                xx: Array [1..$ff] Of Byte;
              End;

  mode_cap_p = ^mode_cap;
  mode_cap = Array [$100..$200] Of Boolean;

  vesainfo = 	Record
                Attr: Word;
                wina, winb: Byte;
                gran, winsiz, SegA, SegB: Word;
                pagefunc: pointer;
                bytes, width, height: Word;
                charw, charh, planes, bits, nbanks, model, banks: Byte;
                X: Array [Byte] Of Byte;    {might get trashed by 4F01h}
              End;
Var
  is_vesa: Boolean;
  curmode: Word;
  pixels: Word;     {Pixels in a scanline in current mode}
  lins: Word;       {lines in current mode}
  bytes: LongInt;   {bytes in a scanline}
  planes: Word;     {number of video planes}
  vesarec: vesainfo;
  vesacapabilities: mode_cap; { erlaubte modi }
  (************************************************************************)
  (************************************************************************)
Procedure vio (AX: Word);         {INT 10h reg ax=AX. other reg. set from RP
                                 on return rp.ax=reg AX}
Function inp (reg: Word): Byte;     {Reads a byte from I/O port REG}
Procedure outp (reg, Val: Word);    {Write the low byte of VAL to I/O port REG}
Function rdinx (pt, inx: Word): Word;       {read register PT index INX}
Procedure wrinx (pt, inx, Val: Word);       {write VAL to register PT index INX}
Procedure modinx (pt, inx, mask, nwv: Word);  {In register PT index INX sets
                                          the bits in MASK as in NWV
                                          the other are left unchanged}
Function setmode (md: Word): Boolean;
Procedure setbank (bank: Word);
Procedure vesamodeinfo (md: Word);
Procedure setpix (X, Y: Word; col: LongInt);
Function RGB (r, g, b: Word): LongInt;
(***************************************************************************)
(***************************************************************************)
(***************************************************************************)
(***************************************************************************)
(***************************************************************************)
Implementation
Const
  colbits: Array [mmods] Of Integer =
  (0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 4, 4, 8, 15, 16, 24);
  hx: Array [0..15] Of Char = '0123456789ABCDEF';
Var
  rp: Registers;
  vseg: Word;       {Video buffer base segment}
  mm: Word;         {Video memory in kilobytes}
  memmode: mmods;   {current memory mode}
  old, curbank: Word;
  biosseg: Word;
  vgran: Word;
  vesa_cap: vesa_rec;

Function hex2 (w: Word): string;
Begin
  hex2 := hx [ (w ShR 4) And 15] + hx [w And 15];
End;

Function hex4 (w: Word): string;
Begin
  hex4 := '0x' + hex2 (Hi (w) ) + hex2 (Lo (w) );
End;

Procedure vio (AX: Word);         {INT 10h reg ax=AX. other reg. set from RP
                                 on return rp.ax=reg AX}
Begin
  rp. AX := AX;
  Intr (16, rp);
End;

Function inp (reg: Word): Byte;     {Reads a byte from I/O port REG}
Begin
  reg := port [reg];
  inp := reg;
End;

Procedure outp (reg, Val: Word);    {Write the low byte of VAL to I/O port REG}
Begin
  port [reg] := Val;
End;


Function rdinx (pt, inx: Word): Word;       {read register PT index INX}
Var X: Word;
Begin
  If pt = $3C0 Then X := inp ($3DA);    {If Attribute Register then reset Flip-Flop}
  outp (pt, inx);
  rdinx := inp (pt + 1);
End;

Procedure wrinx (pt, inx, Val: Word);       {write VAL to register PT index INX}
Begin
  outp (pt, inx);
  outp (pt + 1, Val);
End;

Procedure modinx (pt, inx, mask, nwv: Word);  {In register PT index INX sets
                                          the bits in MASK as in NWV
                                          the other are left unchanged}
Var temp: Word;
Begin
  temp := (rdinx (pt, inx) And Not mask) + (nwv And mask);
  wrinx (pt, inx, temp);
End;
Function setmode (md: Word): Boolean;
Var X: Word;
Begin
  If Not is_vesa Then
  Begin
    WriteLn ('setmode(): Keine VESA-Karte.');
    Halt (99);
  End;
  if (md<$100) and (md >=$200) then
  begin
    WriteLn ('setmode(): Modus # ', hex4 (md) , ' ist kein VESA-Modus.');
    Halt (99);
  end;
  If Not vesacapabilities [md] Then
  Begin
    WriteLn ('setmode(): Diese Karte unterstÅtzt Modus # ', hex4 (md) , ' nicht.');
    Halt (99);
  End;
  setmode := True;
  curmode := md;
  rp. BX := md;
  vio ($4f02);
  If rp. AX <> $4f Then setmode := False
  Else Begin
    vesamodeinfo (md);
  End;
  curbank := $ffff;    {Set curbank invalid }
  planes := 1;

  For X := 1 To mm Div 64 Do
  Begin
    setbank (X - 1);
    mem [$a000:$ffff] := 0;
    FillChar (mem [$a000: 0], $ffff, 0);
  End;
  modinx ($3c4, 4, 2, 2);    {Set "more than 64K" flag}
  vseg := $a000;
End;

Procedure setbank (bank: Word);
Var X: Word;
Begin
  vseg := $a000;
  If bank = curbank Then Exit;   {Only set bank if diff. from current value}
  rp. BX := 0;
  rp. DX := bank * LongInt (64) Div vgran;
  vio ($4f05);
  rp. BX := 1;
  vio ($4f05);
  curbank := bank;
End;

Procedure vesamodeinfo (md: Word);
Begin
	if not vesacapabilities[ md ] then
  begin
    WriteLn ('vesamodeinfo(): Diese Karte unterstÅtzt Modus # ', hex4 (md) , ' nicht.');
    Halt (99);
  end;
  rp. CX := md;
  rp. ES := Seg (vesarec);
  rp. DI := Ofs (vesarec);
  vio ($4f01);
  vgran := vesarec. gran;
  bytes := vesarec. bytes;
  pixels := vesarec. width;
  lins := vesarec. height;
  Case vesarec. bits Of
    4: memmode := _pl16;
    8: memmode := _p256;
    15: memmode := _p32k;
    16: memmode := _p64k;
    24: memmode := _p16m;
  End;
End;

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
Function testvesa ( mi: vesa_rec_p; modecap: mode_cap_p): Boolean;
Var
  return: Boolean;
  Mode : Word;
Begin
  return := False;
  mi^. VESA_signatur := 'VESA';
  rp. ES := Seg (mi^);
  rp. DI := Ofs (mi^);
  vio ($4f00);
  If (rp. AL = $4f) And (rp. AH = $00) Then
  Begin
    return := True;
    Mode := $0;
 		If (Seg (mi^. mode_list^) = $e000) Then
    	mi^. mode_list := Ptr ($c000, Ofs (mi^. mode_list^) );
    While mi^. mode_list^ [Mode] <> $ffff Do
    Begin	writeln( 'Modus #', hex4( mi^. mode_list^[mode] ), ' unterstÅtzt.');
      modecap ^[ mi^. mode_list^ [Mode] ] := True;
      Inc (Mode);
    End;
  End
  Else
  Begin
    return := False;
  End;
End;
Begin
  {
  Karte prÅfen
  }
  If Not testvesa ( @vesa_cap, @vesacapabilities) Then
  Begin
    WriteLn ('Achtung: Keine VESA-Karte erkannt.');
    is_vesa := False;
  End
  Else
    is_vesa := True;
End.