Program tvtest;
Uses objects, menus, drivers, views, app;
Type PStApp = ^TStApp;
  TStApp = Object (TApplication)
             Procedure InitDesktop; Virtual;
             Procedure InitStatusLine; Virtual;
           End;
Procedure TStApp. initdesktop;
Begin
  Inherited initdesktop;
  twindow
End;
Procedure TstApp. initstatusline;
Var R: TRect;
Begin
  Inherited InitStatusLine;
  
End;
Var  myapp: TStApp;
Begin
  myapp. init;
  myapp. run;
  myapp. done;
End.