Program test_OU2;
Uses crt, objektun;
Var o, o1: o_objekt;
Begin
  textmode(co80+font8x8);
  ClrScr;
  o. Load_from_file ('c:\tp70\3d\haus.3d');
  o. done;
  ReadLn;
  ClrScr;
  o1.Load_from_file ('c:\tp70\3d\wurfel.3d');
  o1.done;
  ReadLn;
End.