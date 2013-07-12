Program liste_test;
Uses crt, liste;
Type
  arr_pt = ^arr;
  arr = Record
          X: Array [1..100] Of LongInt;
        End;
  data_p =  ^data_t;
  data_t = 	Object (node_t)
              pt: arr_pt;
              _index: Integer;
              Constructor init (index: Integer);
              Destructor done; Virtual;
              Procedure write_adr;
              Procedure write_arr;
            End;
  
  data_liste_p = ^data_liste;
  data_liste = 	Object (liste_t)
                  Function get_actual: data_p;
                  Function pop: data_p;
                  Procedure write_list;
                End;
  
  Constructor data_t. init;
Var
  i: Integer;
Begin
  (*  pt := New (arr_pt); 	{ speicher belegen }
  For i := 1 To 100 Do pt^. X [i] := index * 1000 + i;
  WriteLn ('data_t.init adr: ', Seg (pt), ':', Ofs (pt) ); *)
  _index := index;
  
  WriteLn ('Neue Node   #', _index);
End;
Destructor data_t. done;
Begin
  (*  WriteLn ('data_t.done adr: ', Seg (pt), ':', Ofs (pt) );
  Dispose (pt); *)
  WriteLn ('L”sche Node #', _index);
End;
Procedure data_T. write_adr;
Begin (* Write (Seg (pt), ':', Ofs (pt) ) *) End;
Procedure data_T. write_arr;
Var i, j: Integer;
Begin
  (*  For j := 0 To 2 Do
  Begin
  For i := 1 To 10 Do Write (pt^. X [i + j * 10] : 3, ' ');
  WriteLn;
  End; *)
  WriteLn ('Node        #', _index);
End;

Function data_liste. get_actual: data_p;
Begin
  get_actual := data_p (liste_t. get_actual)
End;
Function data_liste. pop: data_p;
Begin
  pop := data_p (liste_t. pop)
End;
Procedure data_liste. write_list;
Var
  actual_save: data_p;
Begin
  actual_save := data_liste. get_actual;
  
  WriteLn;
  setfirst;
  While (actual <> Nil) Do
  Begin
    If actual^. prev = Nil Then
      Write ('NIL')
    Else
      Write (data_p (get_actual^. prev)^. _index);
    WriteLn;
    
    Write ('[', get_actual^. _index: 3, ']');
    If actual = first Then
      Write (' <----- FIRST')
    Else If actual = last Then
      Write (' <----- LAST')
    Else If actual = node_p (actual_save) Then
      Write (' <----- ACTUAL');
    WriteLn;
    
    If actual^. next = Nil Then
      Write ('    NIL')
    Else
      Write ('   ', data_p (get_actual^. next)^. _index: 3);
    WriteLn;
    actual := actual^. next;
  End;
  
  actual := actual_save;
End;

Var
  dlp: data_liste_p;
  D: data_p;
  i: Integer;
Begin
  TextMode (c80 + Font8X8);
  ClrScr;
  WriteLn ('Teste append/remove/setfirst/setlast/isfirst/islast:');
  WriteLn;
  
  dlp := New (data_liste_p, init);
  
  For i := 1 To 10 Do
  Begin
    dlp^. Append (New (data_p, init (i) ) );
  End;
  
  dlp^. setfirst;
  WriteLn ('isfirst liefert ', dlp^. isfirst);
  dlp^. setlast;
  WriteLn ('islast liefert ', dlp^. islast);
  dlp^. setfirst;
  dlp^. get_actual^. write_adr; WriteLn (' ist erster.');
  dlp^. setlast;
  dlp^. get_actual^. write_adr; WriteLn (' ist letzter.');
  
  dlp^. setfirst;
  dlp^. next;
  
  dlp^. write_list;
  
  dlp^. done;
  
  WriteLn;
  WriteLn ('taste drcken...');
  ReadLn;
  
  ClrScr;
  WriteLn ('Teste push/pop:');
  WriteLn;
  
  dlp := New (data_liste_p, init);
  
  For i := 1 To 3 Do
  Begin
    dlp^. push (New (data_p, init (i) ) );
  End;
  dlp^. write_list;
  For i := 1 To 3 Do
  Begin
    D := dlp^. pop;
    D^. write_arr;
    D^. done;
  End;
  
  dlp^. done;
  
  WriteLn;
  WriteLn ('taste drcken...');
  ReadLn;
  
  ClrScr;
  WriteLn ('Teste insert/delete:');
  WriteLn;
  
  dlp := New (data_liste_p, init);
  dlp^. Append (New (data_p, init (1) ) );
  dlp^. Append (New (data_p, init (2) ) );
  dlp^. Append (New (data_p, init (3) ) );
  dlp^. Append (New (data_p, init (4) ) );
  dlp^. setfirst;
  {  dlp^. next; }
  D := dlp^. get_actual;
  dlp^. Delete (D);
  D^. done;
	dlp^.write_list;
  readln;
  dlp^. Insert (New (data_p, init (9) ) );
	dlp^.write_list;
	readln;
  dlp^. setfirst;
(*  Repeat
    dlp^. get_actual^. write_arr;
    dlp^. next;
  Until dlp^. islast;
*)
  dlp^. done;

  WriteLn;
  WriteLn ('taste drcken...');
  ReadLn;
End.