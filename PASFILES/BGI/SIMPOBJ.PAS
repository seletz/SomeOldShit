{ Demonstrates:  Registering the BGI file in the executable. }

{ Super VGA  BGI graphics driver demo }
{        Thomas Design              }
{        August 7, 1989             }
{   Test routine                    }

uses
  Graph,crt,ORCDET,VGAEXTRA;

var
  Gd, Gm : integer;
  count  : integer;
  DAC    : RGB;                        { define the DAC array (type in TPU) }

begin
  Gd := InstallUserDriver('ORC256',@_DetectORC256);  { must say   gd := Install...  to work }
  gd := registerbgidriver(@_ORCDRIVERPROC);
  Gd := DETECT;
  InitGraph(Gd, gm ,'');
  DAC[0][0] := 0;                      { Demonstrate how to use dacpalette}
  DAC[0][1] := 0;
  DAC[0][2] := 0;
  for count := 1 to 255 do begin
      DAC[count][0] := random($3f);
      DAC[count][1] := random($3f);
      DAC[count][2] := random($3f);
  end;
  dacpalette(DAC);                  { load the DAC registers from array }
  for Count := 1 to 2000 do begin      { Test the graphics mode }
      SetColor(random(255));
      line(getmaxx div 2,getmaxy div 2,random(getmaxx),random(getmaxy));
  end;
  restorecrtmode;
end.

