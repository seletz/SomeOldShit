Unit tgaunit;
Interface
Uses crt;
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
  TGAfile = Object
              filename: String;
              tgah: tgaheader;
              oldx, z, c, bytes: Integer;
              first: Boolean;
              zeile : Array [0..2, 0..1024] Of Byte;
              Destructor done;
              Constructor init (fn: String; breite, hoehe: Integer);
              Procedure WriteHeader;
              Procedure Flush;
              Procedure Output (X, Y: Integer; r, g, b: Double);
            End;
Implementation
procedure tga_error(s:string);
begin writeln('TGAUNIT: ',s); halt(1) end;
Destructor TGAfile. done;
Begin
End;
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
    image_width := breite + 1;
    image_height := hoehe ;
    pixel_size := 24;
    image_discr := 0;
  End; { 18 byte }
  c := 0;
  bytes:=0;
End;
Procedure TGAfile. WriteHeader;
Var ft: File Of tgaheader;
Begin
  Assign (ft, filename);
  Rewrite (ft);
  Write (ft, tgah);
  Close (ft);
End;
Procedure TGAfile. Output (X, Y: Integer; r, g, b: Double);
var
WAIT:integer;
Begin
  If r > 1 Then r := 1;
  If g > 1 Then g := 1;
  If b > 1 Then b := 1;
  zeile [0, c] := Round (254 * r);
  zeile [1, c] := Round (254 * g);
  zeile [2, c] := Round (254 * b);
  If (c = tgah. image_width-2) Then Begin
      Flush;
{      gotoxy(1,30); clreol; writeln('FLUSH !!!  c=',c,'(x,y)=',x,' ',y);}
      c:=0;
  End Else Inc (c);
{  gotoxy(1,32); clreol; writeln('c=',c,' Bytes: ',3*bytes);}
End;

Procedure tgafile. Flush;
Var i: Integer;
  f: Text;
Begin
  {$I-}
  Assign (f, filename);
  Append (f);
  if ioresult<>0 then tga_error('Append meldete Fehler !');
  For i := 0 To c Do Begin
    Write (f, Chr (zeile [2, i] ), Chr (zeile [1, i] ), Chr (zeile [0, i] ) );
  End;
  Close (f);
  if ioresult<>0 then tga_error('Close meldete Fehler !');
  {$I+}
End;
Begin
End.