{ Super VGA  Demo Program           }
{   Thomas Design                   }
{   August 11, 1989                 }
program test;
uses
  Graph,crt,
  VGAEXTRA,                            { dacpalette(..) and flashmodes }
  ORCDET;
var
  Gd, Gm : integer;
  DAC    : RGB;                        { DAC is a byte aligned array of char }

{------------- Hue Saturation & Intensity  TO  rgb -----------------}
procedure hsi2rgb(h,s,i: real; var Rvalue,Gvalue,Bvalue : integer);
  var
      t: real;
      rv,gv,bv: real;
  begin { procedure hsi2rgb }
    t:=2*pi*h;
    rv:=1+s*sin(t-2*pi/3);
    gv:=1+s*sin(t);
    bv:=1+s*sin(t+2*pi/3);
    t:=63.999*i/2;
    Rvalue:=trunc(rv*t);
    Gvalue:=trunc(gv*t);
    Bvalue:=trunc(bv*t);
end;

{------------- Load the inital color palette -----------------------}
procedure LoadPalette(HueStep: real;SatStep : real;IntenStep : real);
var index : integer;
    h,s,i : real;
    h1,s1,i1 : real;
    r,g,b : integer;
begin
    h1 := 1.0 / HueStep;
    h  := 0;                           { start with hue value of zero }
    s  := 1.00;
    i  := 1.00;
    for index := 1 to 255 do begin
      hsi2rgb(h,s,i,R,G,B);            { compute RGB values using HSI }
      DAC[index][0] := 0;              { load each RGB value into the array }
      DAC[index][1] := g;
      DAC[index][2] := 0;
      h := h + h1;
      i := i - IntenStep;
      s := s - SatStep;
    end;
    Dac[0][0] := 0;                    { Insure the background stays black }
    Dac[0][1] := 0;
    Dac[0][2] := 0;
    dacpalette(DAC);
end;

{------------ Initialize the graphics system -----------------------}
procedure InitGraphics;                { setup the SuperVGA driver }
  var count : integer;
begin
  gd := InstallUserDriver('ORC256',@_DetectORC256);  { must say   gd := Install...  to work }
  gd := DETECT;
  InitGraph(gd, gm ,'');               { use the default graphics mode }
  LoadPalette(64,0,0);
end;

{------------ use circles in graphics demo -------------------------}
procedure CirclePlay;
  var
     FillColor                  : integer;
     MaxX, MaxY                 : integer;
     MaxRadius                  : integer;
     Xcenter,Ycenter            : integer;
     Ballx,Bally                : integer;
     Index                      : byte;
     xincrement,yincrement      : integer;
     Testx,Testy                : integer;
     MirrorX,MirrorY            : integer;
begin
  Maxradius  := getmaxx div 40;
  MaxX       := getmaxx;
  MaxY       := getmaxy;
  Xcenter    := MaxX div 2;
  Ycenter    := MaxY div 2;
  Ballx      := Xcenter;
  Bally      := Ycenter;
  xincrement := -Maxradius;
  yincrement := -Maxradius;
  randomize;
  Index  := 1;
  repeat
      SetColor(Index);
      SetFillStyle(SOLIDFILL, Index);
      FillEllipse(Ballx, Bally,Maxradius, Maxradius);
      Testx := Ballx - Xcenter;
      Testy := Bally - Ycenter;
      MirrorX := -Testx + Xcenter;
      FillEllipse(MirrorX,Bally,Maxradius, Maxradius);
      MirrorY := -Testy + Ycenter;
      FillEllipse(Ballx,MirrorY,Maxradius, Maxradius);
      FillEllipse(MirrorX,MirrorY,Maxradius, Maxradius);
      Ballx := Ballx + xincrement;
      Bally := Bally + yincrement;
      If ((Ballx <= 0) or (Ballx >= MaxX)) then xincrement := xincrement * -1;
      If ((Bally <= 0) or (Bally >= MaxY)) then yincrement := yincrement * -1;
      inc(index);
      if (Index = 0) then begin
          inc(Index);
          LoadPalette(random(128)+64,random/100,random/100);
      end;
  until KeyPressed;
end;

begin
    InitGraphics;
    CirclePlay;
    restorecrtmode;
end.

