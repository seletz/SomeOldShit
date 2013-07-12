Unit objektun;
(*==========================================================================*
 *                                                                          *
 *                                                                          *
 *   ObjektUN: erstellt am 18-19.7.1994                                     *
 *                                                                          *
 *                                                                          *
 *   o_objekt: 3D-Objekt aus Punkten und Linien.                            *
 *                                                                          *
 * o Arbeitet mit Punkten- und Linienlisten                                 *
 *                                                                          *
 * o mit disk-funktion Laden                                                *
 *                                                                          *
 * Fileformat:                                                              *
 *                                                                          *
 *  . extension ".3d"                                                       *
 *  . 1.zeile: Kennwort "3D-Objekt"                                         *
 *                                                                          *
 *  . Kommandos beginnen mit # (Gro·/Klein beachten!)                       *
 *  . "#Name": es folgt der Objektname (nÑchste Zeile)                      *
 *  . "#Nummer": Objekt-Nummer                                              *
 *  . "#Punkte": es folgt eine liste Punkte; 3 Koordinaten pro zeile durch  *
 *               Spaces getrennt; z.b "0 3 -4.5"                            *
 *  . "#Linien": Linienliste: dito, nur 2 integer-werte (von-nach) der      *
 *               Punktnummern; z.b "1 2" -> Linie Punkt 1 nach Punkt 2      *
 *  . "#Ende"  : Ende-markierung (immer erforderlich);                      *
 *  . "##"     : kommentar; z.b "## dies wird ignoriert"                    *
 *                                                                          *
 *==========================================================================*)
{debug_objektun}

Interface
Uses DOS, crt, matrix44, sgraph2;

Type
  p_pliste = ^t_pliste;
  t_pliste = Record
               v: p_vektor4;
               next: p_pliste;
             End;
  p_lliste = ^t_lliste;
  t_lliste = Record
               p1, p2: p_vektor4;
               next: p_lliste;
             End;
  
  p_objekt = ^o_objekt;
  o_objekt = Object
               objekt_name: String;
               objekt_nummer: Integer;
               punkte: p_pliste;
               actual_point: p_pliste;
               linien: p_lliste;
               actual_line: p_lliste;
               anzahl_punkte, anzahl_linien: Integer;
               index: Integer;
               Constructor init (iname: String; inum: Integer);
               Destructor done;
               
               Function add_point_k (X, Y, z: Double): p_vektor4;
               Function add_point_p (p: p_vektor4): p_vektor4;
               
               Procedure add_line (a, b: Integer);
               
               Function load_from_file (fname: String): Boolean;
               
               Function setfirst: p_vektor4;
               Function gimme_actual: p_vektor4;
               Function gimme_next: p_vektor4;
               
               Function seek_point (nr: Integer): p_vektor4;
               
               Function gimme_objekt_name: String;
               Function gimme_objekt_num: Integer;
               Function gimme_index: Integer;
               Function gimme_num_points: Integer;
               Function gimme_num_lines: Integer;
             End;
  
Implementation
(*=========================================*
 *                                         *
 *  Init des Objekts.                      *
 *  iname...Name                           *
 *  inum....Nummer                         *
 *                                         *
 *=========================================*)
Constructor o_objekt. init (iname: String; inum: Integer);
Begin
  objekt_name := iname;
  objekt_nummer := inum;
  anzahl_punkte := 0;
  anzahl_linien := 0;
  
  index := 1;
  
  actual_point := Nil;
  actual_line := Nil;
End;
(*=========================================*
 *                                         *
 *  Speicher Freigeben                     *
 *                                         *
 *                                         *
 *                                         *
 *=========================================*)
Destructor o_objekt. done;
Var
  temp_p: p_pliste;
  temp_l: p_lliste;
  i: Integer;
Begin
  setfirst;
  
  For i := 1 To anzahl_linien Do
  Begin
    temp_l := actual_line^. next;
    
    Dispose (actual_line);

    actual_line := temp_l;
  End;
  
  For i := 1 To anzahl_punkte Do
  Begin
    temp_p := actual_point^. next;
    
    Dispose (actual_point^. v);
    Dispose (actual_point);
    
    actual_point := temp_p;
  End;
End;
(*=========================================*
 *                                         *
 *  Neuen punkt speichern;                 *
 *                                         *
 *  x,y,z..Koordinaten vom Punkt           *
 *                                         *
 *  Achtung: nach o_objekt.done            *
 *           ist er freigegeben !!!        *
 *                                         *
 *                                         *
 *                                         *
 *=========================================*)
Function o_objekt. add_point_k (X, Y, z: Double): p_vektor4;
Var
  p: p_vektor4;
Begin
  If anzahl_punkte = 0 Then
  Begin
    Inc (anzahl_punkte);
    
    New (punkte);
    
    punkte^. next := Nil;
    
    New (punkte^. v);
    
    p := put_vektor (X, Y, z, punkte^. v);
    
    actual_point := punkte;
  End Else Begin
    Inc (anzahl_punkte);

    New (actual_point^. next);
    
    actual_point := actual_point^. next;
    
    actual_point^. next := Nil;
    
    New (actual_point^. v);
    
    p := put_vektor (X, Y, z, actual_point^. v);
  End;
  
  add_point_k := p;
End;
(*=========================================*
 *                                         *
 *  Neuen punkt speichern;                 *
 *                                         *
 *  p...Zeiger auf den zu speichernden     *
 *                                         *
 *  Achtung: nach o_objekt.done            *
 *           ist p freigegeben !!!         *
 *                                         *
 *                                         *
 *                                         *
 *=========================================*)
Function o_objekt. add_point_p (p: p_vektor4): p_vektor4;
Begin
  If anzahl_punkte = 0 Then
  Begin
    Inc (anzahl_punkte);
    
    New (punkte);
    
    punkte^. next := Nil;
    
    New (punkte^. v);
    
    punkte^. v := p;
    
    actual_point := punkte;
  End Else Begin
    Inc (anzahl_punkte);
    
    New (actual_point^. next);

    actual_point := actual_point^. next;
    
    actual_point^. next := Nil;
    
    New (actual_point^. v);
    
    actual_point^. v := p;
  End;
  add_point_p := p;
End;
(*=========================================*
 *                                         *
 *  Speichert eine neue Linie von a nach b.*
 *                                         *
 *  a,b...Punktnummern.                    *
 *                                         *
 *=========================================*)
Procedure o_objekt. add_line (a, b: Integer);
Begin
  If anzahl_linien = 0 Then
  Begin
    Inc (anzahl_linien);
    
    New (linien);
    
    linien^. next := Nil;

    linien^. p1 := seek_point (a);
    linien^. p2 := seek_point (b);
    
    actual_line := linien;
  End Else Begin
    Inc (anzahl_linien);
    
    New (actual_line^. next);
    
    actual_line := actual_line^. next;
    
    actual_line^. next := Nil;
    
    actual_line^. p1 := seek_point (a);
    actual_line^. p2 := seek_point (b);
  End;
  {$ifdef debug_objektun}
  WriteLn ('Linie #', anzahl_linien, ' von ', make_vektor_string ('', actual_line^. p1) );
  WriteLn ('         nach ', make_vektor_string ('', actual_line^. p2) );
  {$endif}
End;
(*=========================================*
 *                                         *
 *  LÑdt Objektdaten aus externem File.    *
 *  Gibt True zurÅck wenn ok.              *
 *                                         *
 *  fname...Filename                       *
 *                                         *
 *=========================================*)
Function o_objekt. load_from_file (fname: String): Boolean;
Const
  k_comment = 0;
  k_punkte = 1;
  k_linien = 2;
  k_name = 3;
  k_number = 4;
  k_ende=99;
Var
  f: Text;
  zeile, line_s,zahl: String;
  i,kommando, Line_i, code: Integer;
  x,y,z:real;
  a,b:integer;
Begin
  Writeln('Loading file "',fname,'"..');

  init('UNNAMED',0);

  If fname = '' Then
    graphics_error ('o_Objekt.Load_from_File: filename ?');
  Assign (f, fname);
  {$I-}
  Reset (f);
  If IOResult <> 0 Then
    graphics_error ('o_Objekt.Load_from_File: file does not exist: "' + fname + '"');
  {$I+}

  ReadLn (f, zeile);
  If Pos ('3D-OBJEKT', zeile) = 0 Then
    graphics_error ('o_Objekt.Load_from_File: bad file format: "' + fname + '"');

  Line_i := 1;
  kommando := - 1;
  While Not EoF (f) Do
  Begin
    Inc (Line_i);
    Str (Line_i, line_s);
    ReadLn (f, zeile);

    If (zeile [1] = '#') Or (kommando = k_comment) Then
    Begin
      kommando := - 1;
      If Pos ('##', zeile) <> 0 Then kommando := k_comment;
      If Pos ('#Name', zeile) <> 0 Then kommando := k_name;
      If Pos ('#Nummer', zeile) <> 0 Then kommando := k_number;
      If Pos ('#Punkte', zeile) <> 0 Then kommando := k_punkte;
      If Pos ('#Linien', zeile) <> 0 Then kommando := k_linien;
      If Pos ('#Ende', zeile) <> 0 Then kommando := k_ende;

      If kommando = - 1 Then
        graphics_error ('o_Objekt.Load_from_File: bad command at line ' + line_s);

    End Else Begin

      Case kommando Of
        k_ende: ;
        k_name: begin
                     objekt_name := zeile;
                     writeln('objekt_name=',objekt_name);
                end;
        k_number:
                 Begin
                   Val (zeile, objekt_nummer, code);
                   If code <> 0 Then
                     graphics_error ('o_Objekt.Load_from_File: bad number format at line' + line_s);
                   writeln('Nummer=',objekt_nummer);
                 End;
        k_punkte:
                 Begin
                   i:=pos(' ',zeile);
                   if i=0 then
                     graphics_error ('o_Objekt.Load_from_File: bad number format at line' + line_s);
                   zahl:=copy(zeile,0,i-1);
                   val(zahl,x,code);
                   If code <> 0 Then
                     graphics_error ('o_Objekt.Load_from_File: bad number format at line' + line_s);

                   i:=length(zahl);
                   zeile:=copy(Zeile,i+2,length(zeile)-i);

                   i:=pos(' ',zeile);
                   if i=0 then
                     graphics_error ('o_Objekt.Load_from_File: bad number format at line' + line_s);
                   zahl:=copy(zeile,0,i-1);
                   val(zahl,y,code);
                   If code <> 0 Then
                     graphics_error ('o_Objekt.Load_from_File: bad number format at line' + line_s);

                   i:=length(zahl);
                   zeile:=copy(Zeile,i+2,length(zeile)-i);
                   val(zeile,z,code);
                   If code <> 0 Then
                     graphics_error ('o_Objekt.Load_from_File: bad number format at line' + line_s);

                   add_point_k(x,y,z);
                 End;
        k_linien:
                 Begin
                   i:=pos(' ',zeile);
                   if i=0 then
                     graphics_error ('o_Objekt.Load_from_File: bad number format at line' + line_s);
                   zahl:=copy(zeile,0,i-1);
                   val(zahl,a,code);
                   If code <> 0 Then
                     graphics_error ('o_Objekt.Load_from_File: bad number format at line' + line_s);

                   i:=length(zahl);
                   zeile:=copy(Zeile,i+2,length(zeile)-i);
                   val(zeile,b,code);
                   If code <> 0 Then
                     graphics_error ('o_Objekt.Load_from_File: bad number format at line' + line_s);

                   add_line(a,b);
                 End;
        Else
          graphics_error ('o_Objekt.Load_from_File: command expectet at line ' + line_s)
      End;
    End;
  End;

  If Not kommando=k_ende Then
    graphics_error ('o_Objekt.Load_from_File: unexpected End of File in file "' + fname + '"');

  Close (f);
  Writeln('Punkte:',anzahl_punkte,' Linien:',anzahl_linien);
  writeln('Done.');
  Load_from_File := True;
End;
(*=========================================*
 *                                         *
 *  Setzt auf ersten Punkt (->a)           *
 *  der ersten Linie.                      *
 *                                         *
 *                                         *
 *=========================================*)

Function o_objekt. setfirst: p_vektor4;
Begin
  actual_line := linien;
  actual_point := punkte;
End;
(*=========================================*
 *                                         *
 *  Liefert aktuellen Punkt                *
 *                                         *
 *                                         *
 *                                         *
 *=========================================*)

Function o_objekt. gimme_actual: p_vektor4;
Begin
  If actual_line <> Nil Then
    If index = 1 Then Begin
      gimme_actual := actual_line^. p1;
    End
  Else Begin
    gimme_actual := actual_line^. p2;
  End
  Else
    graphics_error ('t_Objekt.gimme_next: actual_line=NIL!');
End;
(*=========================================*
 *                                         *
 *  liefert ersten punkt der aktuellen     *
 *  Linie oder zweiten und schaltet        *
 *  gegebenenfalls zur nÑchsten.           *
 *                                         *
 *  d.h.: immer sequentiell  (linie.punkt) *
 *        1.a-1.b-2.a-2.b-usw              *
 *                                         *
 *=========================================*)

Function o_objekt. gimme_next: p_vektor4;
Begin
  If actual_line <> Nil Then
    If index = 1 Then Begin
      index := 2;
      gimme_next := actual_line^. p1;
    End
  Else Begin
    index := 1;
    gimme_next := actual_line^. p2;
    actual_line := actual_line^. next;
  End
  Else
    graphics_error ('t_Objekt.gimme_next: actual_line=NIL!');
End;
(*=========================================*
 *                                         *
 *  Sucht Punkt nummer (nr) in der Liste,  *
 *  unabh. von index.                      *
 *                                         *
 *                                         *
 *=========================================*)
Function o_objekt. seek_point (nr: Integer): p_vektor4;
Var
  actual_save: p_pliste;
  p: p_vektor4;
  i: Integer;
  s: String;
Begin
  actual_save := actual_point;
  
  actual_point := punkte;
  
  i := 0;
  For i := 1 To nr Do
  Begin
    p := actual_point^. v;
    
    If actual_point = Nil Then Exit;
    
    actual_point := actual_point^. next
  End;

  If i <> nr Then Begin Str (nr, s); graphics_error ('t_Objekt.seek_point: #' + s + ' not found.') End;
  actual_point := actual_save;
  
  seek_point := p;
End;
(*=========================================*
 *                                         *
 *  Variablenzugriff                       *
 *                                         *
 *                                         *
 *                                         *
 *=========================================*)
Function o_objekt. gimme_num_points: Integer;
Begin gimme_num_points := anzahl_punkte End;
Function o_objekt. gimme_num_lines: Integer;
Begin gimme_num_lines := anzahl_linien End;
Function o_objekt. gimme_objekt_name: String;
Begin gimme_objekt_name := objekt_name End;
Function o_objekt. gimme_objekt_num: Integer;
Begin gimme_objekt_num := objekt_nummer End;
Function o_objekt. gimme_index: Integer;
Begin gimme_index := index End;
Begin
End.