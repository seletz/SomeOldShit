Unit tgaun;
Interface
Uses crt;
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
  TGAfile = Object
              filename: String;
              f: Text;
              tgah: tgaheader;
              oldx, z: Integer;
              first: Boolean;
              zeile : Array [0..2, 0..1024] Of Byte;
              Destructor done;
              Constructor init (fn: String; breite, hoehe: Integer);
              Procedure WriteHeader;
              Procedure Flush;
              Procedure Output (X, Y: Integer; r, g, b: Double);
            End;
Implementation
Procedure tga_error (s: String);
Begin WriteLn ('TGA: ', s); Halt (1) End;
(*=========================================*
 *                                         *
 *                                         *
 *                                         *
 *                                         *
 *                                         *
 *=========================================*)
Destructor TGAfile. done;
Begin
  {$I-}
  Close (f);
  If IOResult <> 0 Then tga_error ('Close meldete Fehler !');
  {$I+}
End;
(*=========================================*
 *                                         *
 *                                         *
 *                                         *
 *                                         *
 *                                         *
 *=========================================*)
Constructor TGAfile. init (fn: String; breite, hoehe: Integer);
Begin
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
    image_discr := 0;
  End; { 18 byte }
End;
(*=========================================*
 *                                         *
 *                                         *
 *                                         *
 *                                         *
 *                                         *
 *=========================================*)
Procedure TGAfile. WriteHeader;
Var ft: File Of tgaheader;
Begin
  Assign (ft, filename);
  Rewrite (ft);
  Write (ft, tgah);
  Close (ft);
  {$I-}
  Assign (f, filename);
  Append (f);
  If IOResult <> 0 Then tga_error ('Append meldete Fehler !');
  {$I+}
End;
(*=========================================*
 *                                         *
 *                                         *
 *                                         *
 *                                         *
 *                                         *
 *=========================================*)
Procedure TGAfile. Output (X, Y: Integer; r, g, b: Double);
Var
  WAIT: Integer;
Begin
  If r > 1 Then r := 1;
  If g > 1 Then g := 1;
  If b > 1 Then b := 1;
  If r < 0 Then r := 0;
  If g < 0 Then g := 0;
  If b < 0 Then b := 0;
  If X > tgah. image_width Then tga_error ('x>Image_width !');
  If Y > tgah. image_height Then tga_error ('y>Image_height !');
{  GotoXY (1, 38); ClrEol; WriteLn ('TGAUN: (x/y): ', X, ' ', Y);}
  zeile [0, X] := Round (255 * r);
  zeile [1, X] := Round (255 * g);
  zeile [2, X] := Round (255 * b);
  If (X = tgah. image_width) Then Begin
    Flush;
{    GotoXY (1, 39); ClrEol; WriteLn ('TGAUN: Flushing line ', Y); }
  End;
End;
(*=========================================*
 *                                         *
 *                                         *
 *                                         *
 *                                         *
 *                                         *
 *=========================================*)
Procedure tgafile. Flush;
Var i: Integer;
Begin
  For i := 0 To tgah. image_width - 1 Do Begin
    Write (f, Chr (zeile [2, i] ), Chr (zeile [1, i] ), Chr (zeile [0, i] ) );
  End;
End;
Begin
End.