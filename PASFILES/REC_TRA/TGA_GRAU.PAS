Unit tga;
Interface
Uses crt, graph, sgraph, Colors;
Const nograph = 0;
  grau = 1;
  farbe = 2;
  
Type  TGAfile = Object
                  m, DX, dy: Integer;
                  Destructor done;
                  Constructor init (Mode: Integer; breite, hoehe: Integer);
                  Procedure Output (X, Y: Integer; r, g, b: Byte);
                End;
Implementation
Destructor TGAfile. done;
Begin
  grafikaus;
End;
Constructor TGAfile. init (Mode: Integer; breite, hoehe: Integer);
Var i: Integer;
  h, s, v, r, g, b: Real;
Begin
  m := Mode;
  grafikein;
  DX := GetMaxX Div (breite - 1);
  dy := GetMaxY Div (hoehe - 1);
  
  Case m Of
    nograph: {tu nix} ;
    farbe: init_palette_farbe;
    grau:  init_palette_grau;
  End;
End;
Procedure TGAfile. Output (X, Y: Integer; r, g, b: Byte);
Var gr: Integer;
Begin
  If Not (m = nograph ) Then
  Begin
    Case m Of
      farbe: convert (r / 255, g / 255, b / 255, gr);
      grau:  gr := (r + g + b) Div 3;
    End;
    
    SetColor (gr);
    SetFillStyle (SolidFill, gr);
    Bar (X * DX, Y * dy, (X + 1) * DX, (Y + 1) * dy);
  End;
End;

Begin
End.