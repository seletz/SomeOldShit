(*  =======================================================================
    SAMPL1.PAS

    This is a sample of a PASCAL program which uses BGIPrint drivers.
    It uses portions of Borland's BGI Demo to illustrate the compatibility
    of BGI Print with screen drivers.

    Please note the use of calculated x-y coordinates based on values
    returned by GETMAXX and GETMAXY.

    To run this sample, ensure that the BGIPrint drivers are in the
    current directory along with the CHR files supplied with Turbo Pascal

    ====================================================================== *)


Uses CRT,DOS,Graph;
  var
    Driver, Mode, TestDriver,
    ErrCode  : Integer;
    MAxX,MaxY,MaxColor,FillColor,DefaultColor : Word;
    PrName     : String;
 Const
    NumPens = 8;  (*  plotter has this many pens *)

{$F+}
function TestDetect : Integer;
{ Autodetect function. Assume hardware is
  always present. Return value = recommended
  default mode. }
begin
  TestDetect := 1;
end;
{$F-}

function Int2Str(L : LongInt) : string;
{ Converts an integer to a string for use with OutText, OutTextXY }
var
  S : string;
begin
  Str(L, S);
  Int2Str := S;
end; { Int2Str }

function RandColor : word;
{ Returns a Random non-zero color value that is within the legal
  color range for the selected device driver and graphics mode.
  MaxColor is set to GetMaxColor by Initialize }
begin
  RandColor := Random(MaxColor)+1;
end; { RandColor }

procedure DefaultColors;
{ Select the maximum color in the Palette for the drawing color }
begin
  SetColor(MaxColor);
end; { DefaultColors }

procedure PiePlay;
{ Demonstrate  PieSlice and GetAspectRatio commands }
var
  ViewInfo   : ViewPortType;
  CenterX    : integer;
  CenterY    : integer;
  Radius     : word;
  Xasp, Yasp : word;
  X, Y       : integer;
  HH,MM,SS,FF: Word;

function AdjAsp(Value : integer) : integer;
{ Adjust a value for the aspect ratio of the device }
begin
  AdjAsp := (LongInt(Value) * Xasp) div Yasp;
end; { AdjAsp }

procedure GetTextCoords(AngleInDegrees, Radius : word; var X, Y : integer);
{ Get the coordinates of text for pie slice labels }
var
  Radians : real;
begin
  Radians := AngleInDegrees * Pi / 180;
  X := round(Cos(Radians) * Radius);
  Y := round(Sin(Radians) * Radius);
end; { GetTextCoords }

begin
  WriteLn('Doing Pie Chart');
  GetTime(HH,MM,SS,FF);
  WriteLn('Start Time > ',HH:2,':',MM:2,':',SS:2,'.',FF:2);
  GetAspectRatio(Xasp, Yasp);
  GetViewSettings(ViewInfo);
  with ViewInfo do
  begin
    CenterX := (x2-x1) div 2;
    CenterY := ((y2-y1) div 2) + 20;
    Radius := (y2-y1) div 3;
    while AdjAsp(Radius) < round((y2-y1) / 3.6) do
      Inc(Radius);
  end;
  SetTextStyle(TriplexFont, HorizDir, 4);
  SetTextJustify(CenterText, TopText);
  OutTextXY(CenterX, 0, 'This is a pie chart!');
  WriteLn('Title Done');
  SetTextStyle(TriplexFont, HorizDir, 3);
  FillColor := 2;
  WriteLn('Fill color = ',FillColor);
  SetFillStyle(SolidFill, FillColor);
  PieSlice(CenterX+10, CenterY-AdjAsp(10), 0, 90, Radius);
  GetTextCoords(45, Radius, X, Y);
  SetTextJustify(LeftText, BottomText);
  OutTextXY(CenterX+10+X+TextWidth('H'), CenterY-AdjAsp(10+Y), '25 %');
     WriteLn('Segment Done');
  FillColor := 3;
  WriteLn('Fill color = ',FillColor);
  SetFillStyle(LtSlashFill, FillColor);
  PieSlice(CenterX, CenterY, 225, 360, Radius);
  GetTextCoords(293, Radius, X, Y);
  SetTextJustify(LeftText, TopText);
  OutTextXY(CenterX+X+TextWidth('H'), CenterY-AdjAsp(Y), '37.5 %');
     WriteLn('Segment Done');
  FillColor := 4;
  WriteLn('Fill color = ',FillColor);
  SetFillStyle(BkSlashFill, FillColor);
  PieSlice(CenterX-10, CenterY, 135, 225, Radius);
  GetTextCoords(180, Radius, X, Y);
  SetTextJustify(RightText, CenterText);
  OutTextXY(CenterX-10+X-TextWidth('H'), CenterY-AdjAsp(Y), '25 %');
     WriteLn('Segment Done');

  FillColor := 5;
  WriteLn('Fill color = ',FillColor);
  SetFillStyle(WideDotFill, FillColor);
  PieSlice(CenterX, CenterY, 90, 135, Radius);
  GetTextCoords(112, Radius, X, Y);
  SetTextJustify(RightText, BottomText);
  OutTextXY(CenterX+X-TextWidth('H'), CenterY-AdjAsp(Y), '12.5 %');
     WriteLn('Chart Done');
     GetTime(HH,MM,SS,FF);
     WriteLn('End Time > ',HH:2,':',MM:2,':',SS:2,'.',FF:2);
end; { PiePlay }

procedure Bar3DPlay;
{ Demonstrate Bar3D command }
const
  NumBars   = 7;  { The number of bars drawn }
  BarHeight : array[1..NumBars] of byte = (1, 3, 2, 5, 4, 2, 1);
  YTicks    = 5;  { The number of tick marks on the Y axis }
var
  ViewInfo : ViewPortType;
  H        : word;
  XStep    : real;
  YStep    : real;
  I, J     : integer;
  Depth    : word;
  Color    : word;
  T        : Word;
begin
  WriteLn('3d Bar Chart');
  H := 3*TextHeight('M');
  T := 2*TextHeight('M');
  GetViewSettings(ViewInfo);
  SetTextJustify(CenterText, TopText);
  SetTextStyle(TriplexFont, HorizDir, 4);
  OutTextXY(MaxX div 2, T, 'These are 3D bars');
  WriteLn('Title done');
  SetTextStyle(SmallFont, HorizDir, 4);
  with ViewInfo do
    SetViewPort(x1+50, y1+40, x2-50, y2-10, ClipOn);
  GetViewSettings(ViewInfo);
  with ViewInfo do
  begin
    Line(H, H, H, (y2-y1)-H);
    Line(H, (y2-y1)-H, (x2-x1)-H, (y2-y1)-H);
    YStep := ((y2-y1)-(2*H)) / YTicks;
    XStep := ((x2-x1)-(2*H)) / NumBars;
    J := (y2-y1)-H;
    SetTextJustify(CenterText, CenterText);
    T := TextWidth('M');
    { Draw the Y axis and ticks marks }
    for I := 0 to Yticks do
    begin
      Line(H div 2, J, H, J);
      OutTextXY(H div 2-T, J, Int2Str(I));
      J := Round(J-Ystep);
    end;

    WriteLn('Y Axis done');
    Depth := trunc(0.25 * XStep);    { Calculate depth of bar }

    { Draw X axis, bars, and tick marks }
    SetTextJustify(CenterText, TopText);
    J := H;
    Color := 1;
    for I := 1 to Succ(NumBars) do
    begin
      SetColor(1);
      Line(J, (y2-y1)-H, J, (y2-y1-3)-(H div 2));
      OutTextXY(J, (y2-y1)-T*2, Int2Str(I-1));
      WriteLn(Int2Str(I-1));
      if I <> Succ(NumBars) then
      begin
        Color := Color + 1;
        SetFillStyle(I, Color);
        SetColor(Color);
        Bar3D(J, round((y2-y1-H)-(BarHeight[I] * Ystep)),
                 round(J+Xstep-Depth), round((y2-y1)-H-1), Depth, TopOn);
        J := Round(J+Xstep);
        WriteLn('Bar Done');
      end;
    end;
     WriteLn('Chart Done');
  end;
end; { Bar3DPlay }



Procedure InitPrinter;
begin
  { Install the driver }
    If PrName = 'HPGL' then
      begin
        WriteLn('Please insert paper into plotter and Press RETURN when ready');
        ReadLn;
        MaxColor := 1;
      end;
    If PrName <> 'SCREEN' then
     begin
      TestDriver := InstallUserDriver(PrName, @TestDetect);
      if GraphResult <> grOk then
        begin
         WriteLn('Error installing TestDriver');
         Halt(1);
        end;
       Driver := Detect;
       WriteLn('Initializing Graphics Buffer');
       InitGraph(Driver, Mode, '');
       ErrCode := GraphResult;
       if ErrCode <> grOk then
        begin
         WriteLn('Error during Init: ', ErrCode);
         Halt(1);
        end
       else
        begin
          WriteLn('INIT OK');
        end;
     end
    else
     begin
      Driver := Detect;
      InitGraph(Driver,Mode,'');
     end;

    MaxX := GetMaxX;          { Get screen resolution values }
    MaxY := GetMaxY;
    MaxColor := GetMaxColor;  { Get the maximum allowable drawing color }
    If PrName = 'HPGL' then
      MaxColor := 1;
    DefaultColors;
end;

Procedure Intro;
var Ch : Char;
begin
  ClrScr;
  WriteLn('                               BGI Print');
  WriteLn('                    Copyright (c) Bruce McAra, 1991');
  WriteLn('                           All Rights Reserved');
  WriteLn('                  Demonstration Program for Turbo Pascal');
  WriteLn('            *************************************************** ');
  WriteLn('                1. HP Laser Jet (PCL) on LPT1');
  WriteLn('                2. Epson Compatible Dot Matrix on LPT1');
  WriteLn('                3. HPGL Pen Plotter on COM1');
  WriteLn('                4. Screen');
  WriteLn;
    Write('                     Select a printer Driver by Number:');
  Repeat
    Ch := ReadKey;
    Case Ch of
        '1' : PrName := 'HPPCL';
        '2' : PrName := 'MATRIX';
        '3' : PrName := 'HPGL';
        '4' : PrName := 'SCREEN';
      end;
  Until Ch in ['1','2','3','4',#27];
  If Ch = #27 then
   begin
     ClrScr;
     WriteLn('Terminating program');
     Halt;
   end;
   WriteLn;
   WriteLn('Printing to ',PrName);
end;

begin
    If ParamCount = 1 then
      PrName := ParamStr(1)
    else
      Intro;

    InitPrinter;
    Randomize;                { init random number generator }

    PiePlay;
    ReadLn;
    CloseGraph;
    WriteLn('Pie Chart done');
    Readln;
    InitPrinter;

    Bar3dPlay;
    ReadLn;
    Closegraph;
  end.
