Unit rt_cameras;
Interface
Uses rt_types, rt_math;
Var
  DEBUG_CAMERA_UNIT: Boolean;
Type
  RT_camera = Object (rt_obase)
                cop: RT_point;
                vrz: RT_point;
                minmax, sicht: RT_rect;
                xh, yh, sx, sy,x0,y0: Double;
                Constructor init (ivrz, icop: RT_point;
                imm, isicht: RT_rect);
                Procedure compute_ray (X, Y: Integer; Var ray: RT_ray);

              End;
  
Implementation
Constructor RT_camera. init;
Var p: rt_point;
  DX, dy: Double;
Begin
  cop := icop; vrz := ivrz; minmax := imm; sicht := isicht;
  
  {
  imm.p1.x<=x<=imm.p2.x
  imm.p1.y<=y<=imm.p2.y
  
  daraus folgt:
  
      abs(sicht.p1.x)+abs(sicht.p2.x))
  sx= --------------------------------
      abs(imm.p1.x)  +  abs(imm.p2.x))

      abs(sicht.p1.y)+abs(sicht.p2.y))
  sy= --------------------------------
      abs(imm.p1.y)  +  abs(imm.p2.y))
  }

  xh := (minmax. p2.X - minmax. p1.X) / 2;
  yh := (minmax. p2.Y - minmax. p1.Y) / 2;

  dx := Abs (imm. p1.X)  +  Abs (imm. p2.X);
  dy := Abs (imm. p1.Y)  +  Abs (imm. p2.Y);
  If (DX = 0) Or (dy = 0) Then Begin
    WriteLn ('RT_camera.init: d=0');
    Halt (10);
  End;
  sx := (Abs (sicht. p1.X) + Abs (sicht. p2.X) ) / DX;
  sy := (Abs (sicht. p1.Y) + Abs (sicht. p2.Y) ) / dy;

  if sicht.p1.x<sicht.p2.x then x0:=sicht.p1.x else x0:=sicht.p2.x;
  if sicht.p1.y<sicht.p2.y then y0:=sicht.p1.y else y0:=sicht.p2.y;

  If DEBUG_CAMERA_UNIT Then Begin
    WriteLn ('RT_camera.init:');
    WriteLn;
    Write1r ('sx=', sx);
    Write1r ('sy=', sy);
    Write1r ('dx=', dy);
    Write1r ('dy=', dy);
  End;
End;
Procedure rt_camera. compute_ray (X, Y: Integer; Var ray: RT_ray);
Var p: RT_point;
Begin
  p. X := x0 + X * sx;
  p. Y := y0 + Y * sy;
  p2ray (cop, p, ray);
  if DEBUG_CAMERA_UNIT then writeray('RT_camera.compute_ray=',ray);
End;

Begin
End.