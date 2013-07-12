Program test_obejektun;
Uses crt, matrix44, objektun;
Var
  s:string;
  i,k: Integer;
  o: o_objekt;
Begin
  textmode(co80+font8x8);
  ClrScr;

  WriteLn ('************************************************************');
  WriteLn ('*                                                          *');
  WriteLn ('*  Testet ObjektUN.tpu                                     *');
  WriteLn ('*  ===================                                     *');
  WriteLn ('*                                                          *');
  WriteLn ('*                                                          *');
  WriteLn ('*                                                          *');
  WriteLn ('* o 5  punkte speichern                                    *');
  WriteLn ('*                                                          *');
  WriteLn ('* o 5  linien -"-                                          *');
  WriteLn ('*                                                          *');
  WriteLn ('* o der Reihe nach ausgeben                                *');
  WriteLn ('*                                                          *');
  WriteLn ('* o rckw„rts       -"-                                    *');
  WriteLn ('*                                                          *');
  WriteLn ('* o Speicher wieder freigeben                              *');
  WriteLn ('*                                                          *');
  WriteLn ('*                                                          *');
  WriteLn ('************************************************************');

  writeln;
  writeln('Speicher: ',memavail,' Byte');

  o. load_from_file('z:\tp70\3d\wurfel.3d');

  o.setfirst;

  for i:=o.gimme_num_points downto 1 do
  begin
    str(i,s);
    s:='P'+s;
    write_p(s,o. seek_point (i));
  end;

  o.setfirst;

  for i:=1 to o.gimme_num_lines do
  begin
    writeln('Linie ',i,' '+make_vektor_string('',o.gimme_next)+' -> '+make_vektor_string('',o.gimme_next));
  end;

  o. done;

  writeln('Speicher: ',memavail,' Byte');

  ReadLn;
End.