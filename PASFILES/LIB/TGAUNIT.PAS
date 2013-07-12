Unit tgaunit;
Interface
Uses crt, vesa;
Const
  mode_nograph = 0;
  mode_graphic = 1;
  mode_quiet = 99;

  TGA_MAXZEILE = 10*1024*3;
Type tgaheader = Record
                   indent_len,
                   cmap_type,
                   image_type: Byte;
                   cmap_orgin,
                   cmap_len: Word;
                   centry_size: Byte;
                   image_xorg,
                   image_yorg,
                   image_width,
                   image_height: Word;
                   pixel_size,
                   image_discr: Byte;
                 End;

  Buffer = Array [1..TGA_MAXZEILE] Of Byte;
  
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
  If modus = mode_graphic Then TextMode (c80);
  If Not ( (modus = mode_quiet) Or (modus = mode_graphic) ) Then
  Begin
    WriteLn ('TGAfile. done : # Flushed:     ', num_flush);
    WriteLn ('                Bytes written: ',
    total_bytes, ' Bytes = ',
    (total_bytes / 1024 ): 3: 3, ' kB = ',
    (total_bytes / 1024 / 1024): 3: 3, ' MB .');
  End;
End;
Constructor TGAfile. init;
Var
  grmode: Word;
Begin
  If Not ( (im = mode_quiet) Or (im = mode_graphic) ) Then
  Begin
    WriteLn ('TGAfile. init : filename=', fn, ' breite=', breite, ' hoehe=', hoehe);
    WriteLn ('                filesize=', LongInt (breite) * LongInt (hoehe) * 3 + SizeOf (tgaheader), ' Bytes');
  End;
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
    mode_quiet:   {tu nix} ;
    mode_nograph: {tu nix} ;
    mode_graphic:
                 Begin
                   setmode (mode_800X600X64k);
                   DX := vesarec. width / (breite - 1);
                   dy := vesarec. height / (hoehe - 1);
                   If DX > 1 Then DX := 1;
                   If dy > 1 Then dy := 1;
                 End
    Else
    Begin
      WriteLn ( 'TGAfile. init : Unbekannter Modus ', modus, ' .');
      Halt (99);
    End
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
  
  If modus = mode_graphic Then
  Begin
    setpix (X, Y, RGB ( r, g, b) );
  End;
  
  zeile [c + 0] := b;
  zeile [c + 1] := g;
  zeile [c + 2] := r;
  
  If ( (c + 2) >= TGA_MAXZEILE) Then Begin
    Flush;
    c := 1;
  End Else Inc (c, 3);
  
End;

Procedure tgafile. Flush;
Var
  i, j: Integer;
  num_written: Word;
  f: File;
Begin
  If c <> 1 Then
  Begin
    Assign (f, filename);

    Reset (f, 1);
    Seek ( f, FileSize (f) );
    BlockWrite (f, zeile, c+2);
    Inc ( total_bytes, num_written);
    Close (f);
    Inc (num_flush);
  End;
End;
Begin
End.