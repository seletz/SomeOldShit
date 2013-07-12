Unit tgaunit;
Interface
Uses crt, Colors, graph, VGA256;
Const
  nograph = 0;
  grau = 1;
  farbe = 2;
  TGA_MAXZEILE = 1280;
Type tgaheader = Record
                   indent_len,
                   cmap_type,
                   image_type: Byte;
                   cmap_orgin,
                   cmap_len: word;
                   centry_size: Byte;
                   image_xorg,
                   image_yorg,
                   image_width,
                   image_height: word;
                   pixel_size,
                   image_discr: Byte;
                 End;

  Buffer = Array [1..TGA_MAXZEILE, 1..3] Of Byte;

  TGAfile = Object
              modus: Integer;
              DX, dy: Real;
              filename: String;
              tgah: tgaheader;
              c: Integer;
              total_bytes, num_flush: LongInt;
              zeile: Buffer;
              Destructor done;
              Constructor init (fn: String; breite, hoehe: Integer; im: Integer);
              Procedure WriteHeader;
              Procedure Flush;
              Procedure Output (X, Y: Integer; r, g, b: Byte);
            End;

Implementation
Destructor TGAfile. done;
Begin
  Flush;
  If Not ( modus = nograph) Then grafikaus;
  WriteLn ('TGAfile. done : # Flushed:     ', num_flush);
  WriteLn ('                Bytes written: ',
  total_bytes, ' Bytes = ',
  (total_bytes / 1024 ): 3: 3, ' kB = ',
  (total_bytes / 1024 / 1024): 3: 3, ' MB .');
End;
Constructor TGAfile. init;
Begin
  WriteLn ('TGAfile. init : filename=', fn, ' breite=', breite, ' hoehe=', hoehe);
  WriteLn ('                filesize=', LongInt (breite) * LongInt (hoehe) * 3 + SizeOf (tgaheader), ' Bytes');
  total_bytes := 0;
  num_flush := 0;
  filename := fn;
  With tgah Do
  Begin
    indent_len := 0;
    cmap_type := 0;
    image_type := 2;
    cmap_orgin := 0;
    cmap_len := 0;
    centry_size := 24;
    image_xorg := 0;
    image_yorg := 0;
    image_width := breite;
    image_height := hoehe;
    pixel_size := 24;
    image_discr := 32;
  End; { 18 byte }
  c := 1;
  Modus := im;

  Case modus Of
    nograph: {tu nix} ;
    farbe:
          Begin
            grafikein;
            DX := GetMaxX / (breite - 1);
            dy := GetMaxY / (hoehe - 1);
            init_palette_farbe;
          End;
    grau:
         Begin
           grafikein;
           DX := GetMaxX / (breite - 1);
           dy := GetMaxY / (hoehe - 1);
           init_palette_grau;
         End;
  End;

End;

Procedure TGAfile. WriteHeader;
Var ft: File Of tgaheader;
Begin
  Assign (ft, filename);
  Rewrite (ft);
  Write (ft, tgah);
  Close (ft);
End;
Procedure TGAfile. Output (X, Y: Integer; r, g, b: Byte);
Var
  gr: Integer;
Begin
  If Not (modus = nograph ) Then
  Begin
    Case modus Of
      farbe: convert (r / 255, g / 255, b / 255, gr);
      grau:  gr := (r + g + b) Div 3;
    End;

    SetColor (gr);
    SetFillStyle (SolidFill, gr);
    Bar (Round (X * DX), Round ( Y * dy),
    Round ( (X + 1) * DX), Round ( (Y + 1) * dy) );
  End;

  zeile [c, 1] := b;
  zeile [c, 2] := g;
  zeile [c, 3] := r;

  If (c = tgah. image_width) Then Begin
    Flush;
    c := 1;
  End Else Inc (c);

End;

Procedure tgafile. Flush;
Var
  i, j: Integer;
  f: file of byte;
Begin
  If c <> 1 Then
  Begin
    Assign (f, filename);
    Reset (f);
    seek( f, filesize(f) );
    For i := 1 To c Do Begin
      For j := 1 To 3 Do
        Write (f, zeile [i, j] );

      Inc ( total_bytes, 3);
    End;
    Close (f);
    Inc (num_flush);
  End;
End;
Begin
End.