Unit logik_06;
Interface
Uses crt, liste, graph, sgraph2;
Const
  High: Integer = 1;
  Low: Integer = 0;
  mode_none: Integer = 0;
  mode_text: Integer = 1;
  mode_graphic: Integer = 2;
Type
  time_t = Single;
  
  box_p = ^box_t;
  {
  LISTENZEUGS-TYPENDEKL
  }
  box_node_p = ^box_node_t;
  box_node_t = Object (node_t)
                 box_pointer: box_p;
                 Constructor init (BP: box_p);
               End;
  box_p_liste_p = ^box_p_liste_t;
  box_p_liste_t = Object (liste_t)
                    Destructor done;
                    Procedure push (bnp: box_node_p);
                    Function get_actual: box_node_p;
                  End;
  
  box_t_liste_p = ^box_t_liste_t;
  box_t_liste_t = Object (liste_t)
                    Function get_actual: box_p;
                  End;
  {
  LOGIKOBJEKT-DEKL
  }
  connection_p = ^connection_t;
  
  box_t = Object (node_t)
            Name: String;
            zustand, Color, yp: Integer;
            zn: Integer;
            changed, show_me: Boolean;
            schaltzeit, start: Time_t;
            e, a: box_p_liste_p;
            Constructor init (iname: String; z: Integer; sz: time_t);
            Destructor done; Virtual;

            Procedure connect_e (connection: connection_p);
            Procedure connect_a (connection: connection_p);
            
            Procedure set_zustand (z: Integer; t: time_t); Virtual;
            Procedure set_name (iname: String);
            
            Procedure show;
            Procedure show_gr_init ( Y, c: Integer);
            Procedure show_gr;
            Procedure set_show ( flag: Boolean );
            Function get_name: String;

            Procedure update (t: time_t); 	Virtual; { Ausgangspuffer updaten }
            Procedure step (t: time_t); Virtual; 	{ neu berechnen }
            
            Function gimme_zustand: Integer; Virtual;
            Function has_changed: Boolean;
          End;
  
  connection_t = Object (box_t)
                   Procedure update (t: time_t); Virtual;
                   Procedure set_zustand (z: Integer; t: time_t); Virtual;
                 End;
  
  NOT_p = ^NOT_t;
  NOT_t = Object (box_t)
            Procedure step (t: time_t); Virtual; 	{ neu berechnen }
          End;
  
  
  AND_p = ^AND_t;
  AND_t = Object (box_t)
            Procedure step (t: time_t); Virtual; 	{ neu berechnen }
          End;
  
  NAND_p = ^NAND_t;
  NAND_t = Object (box_t)
             Procedure step (t: time_t); Virtual; 	{ neu berechnen }
           End;
  
  OR_p = ^OR_t;
  OR_t = Object (box_t)
           Procedure step (t: time_t); Virtual; 	{ neu berechnen }
         End;

  NOR_p = ^NOR_t;
  NOR_t = Object (box_t)
            Procedure step (t: time_t); Virtual; 	{ neu berechnen }
          End;
  
  schalter_p = ^AND_t;
  schalter_t = Object (box_t)
                 Procedure ein;
                 Procedure aus;
               End;
  {
  NETZ-OBJEKT-DEKL
  }
  logik_netz_t = Object
                   box_liste: box_t_liste_p;
                   Time: Single; 	{ in sekunden }
                   delta_t: Single; 	{ in sekunden }
                   Constructor init (idt: Single);
                   Destructor done;
                   Procedure push (BP: box_p);

                   Procedure step;
                   Procedure update_all;
                   Procedure show_all;
                   Procedure show_all_gr;
                   Procedure run (runtime: time_t; Mode: Integer); 	{in sekunden }
                 End;
Implementation
(**********************************************************************)
(*********    LISTENMETHODEN          *********************************)
(**********************************************************************)
(*
 *  BOX-NODE_Object
 *
 *)
Constructor box_node_t. init; Begin Inherited init; box_pointer := BP End;
(*
 *  BOX-POINTER-LISTE_Object
 *
 *)
Destructor box_p_liste_t. done;
Var temp: node_p;
Begin
  If isempty Then Exit; { liste ist leer }

  setfirst; 							{ wir fangen vorne an }
  Repeat
    Dispose (pop, done);          { popen und lîschen }
  Until isempty; 				{ bis Liste leer }
  
  first := Nil;
  last := Nil;
  actual := Nil;
End;
Function box_p_liste_t. get_actual: box_node_p; Begin get_actual := box_node_p (Inherited get_actual) End;
Procedure box_p_liste_t. push (bnp: box_node_p);
Begin
  Inherited push (bnp)
End;
(*
 *  BOX-TYP-LISTE_Object
 *
 *)
Function box_t_liste_t. get_actual: box_p; Begin get_actual := box_p (Inherited get_actual) End;
(**********************************************************************)
(*********    LOGIK-METHODEN          *********************************)
(**********************************************************************)
(*
 *  NETZ-Object
 *
 *)
Constructor logik_netz_t. init;
Begin
  box_liste := New (box_t_liste_p, init);
  delta_t := idt;
  Time := 0
End;
Destructor logik_netz_t. done; Begin Dispose (box_liste, done) End;
Procedure logik_netz_t. push (BP: box_p);
Begin
  box_liste^. push (BP)
End;
Procedure logik_netz_t. step;
Var
  BP: box_p;
Begin
  {
  alles neuberechnen
  }
  box_liste^. setfirst;
  Repeat
    BP := box_liste^. get_actual;
    BP^. step (Time);
    box_liste^. next;
  Until BP^. next = Nil;
End;
Procedure logik_netz_t. update_all;
Var
  BP: box_p;
Begin
  {
  und updaten
  }
  box_liste^. setfirst;
  Repeat
    BP := box_liste^. get_actual;
    BP^. update (Time);
    box_liste^. next;
  Until BP^. next = Nil;
End;
Procedure logik_netz_t. run;
Var
  c: LongInt;
Begin
  If (Mode = mode_graphic) Then
  Begin
    grafikein;
  End;
  c := 0;
  Repeat
    update_all;
    {ClrScr;}
    Case Mode Of
      { mode_none }
      0:
        Begin
        End;
      { mode_text }
      1:
        Begin
          WriteLn ('Step #', c);
          show_all;
          Delay (50);
        End;
      { mode_graphic }
      2:
        Begin
          show_all_gr;
        End;
    End;

    step;
    Time := Time + delta_t; Inc (c);

    If KeyPressed Then Time := runtime; { Abbruch }
  Until (Time >= runtime);
  If Mode = mode_graphic Then grafikaus;
End;
Procedure logik_netz_t. show_all;
Var
  BP: box_p;
Begin
  {
  alle anzeigen
  }
  WriteLn ('Zeit: ', Time: 3: 6, ' s');
  WriteLn;
  box_liste^. setfirst;
  Repeat
    BP := box_liste^. get_actual;
    BP^. show;
    box_liste^. next;
  Until BP^. next = Nil;
End;
Procedure logik_netz_t. show_all_gr;
Var
  BP: box_p;
Begin
  {
  alle anzeigen
  }
  box_liste^. setfirst;
  Repeat
    BP := box_liste^. get_actual;
    BP^. show_gr;
    box_liste^. next;
  Until BP^. next = Nil;
  If ( GetX = GetMaxX ) Then
    ClearDevice
  Else
    MoveTo ( GetX + 1, 0 );
End;
(*
 *  BOX-Object
 *
 *)
Constructor box_t. init;
Begin
  e := New (box_p_liste_p, init);
  a := New (box_p_liste_p, init);
  set_zustand (z, 0);
  set_name (iname);
  set_show (True );
  schaltzeit := sz;
  start := 0;
  zustand := 0;
  changed := True;
End;
Destructor box_t. done;
Begin
  Dispose (a, done);
  Dispose (e, done);
End;
Function box_t. has_changed: Boolean; Begin has_changed := changed End;
Procedure box_t. set_show; Begin show_me := flag; End;
Procedure box_t. show;
Begin
  If show_me Then
  Begin
    Write (Name, ' :'); GotoXY (10, WhereY);
    Write ('Z=', zustand); GotoXY (20, WhereY);
    Write ('Z(n+1)=', zn); GotoXY (30, WhereY);
    Write ('énderung:');
    If has_changed Then WriteLn (' Ja') Else WriteLn (' Nein');
  End;
End;
Procedure box_t. show_gr_init; Begin
  Color := c; yp := Y;
End;
Procedure box_t. show_gr;
Begin
  If show_me = True Then
  Begin
	  SetColor ( 1);
  	Line (0, yp, GetMaxX, yp);
    outtextxy( 10, yp - 15, name );

    putpixel( GetX, yp - 1 - zustand * 5 , color);
    
  End;
End;
Procedure box_t. set_zustand;
Begin
  If z <> zn Then
  Begin
    zn := z;
    start := t
  End
End;
Procedure box_t. set_name; Begin Name := iname End;
Function box_t. get_name: String; Begin get_name := Name End;
Procedure box_t. update;
Var
  Ap: box_node_p;
Begin
  {
  Update nur wenn Ñnderung und delaytime verstrichen
  }
  If (zn <> zustand) And ( (start + schaltzeit) <= t) Then
  Begin
    zustand := zn; 	{ sich selbst updaten }
    changed := True; 	{ Zustand hat sich geÑndert }
  End Else changed := False;
  A^. setfirst;
  If a^. get_actual <> Nil Then {sind Åberhaupt ausgÑnge da ? }
    Repeat
      Ap := a^. get_actual;
      AP^. box_pointer^. set_zustand (zustand, t); 	{ und alle anderen AusgÑnge auch }
      A^. next;
    Until Ap^. next = Nil;
End;
Procedure box_t. step; Begin End; 	{ tut nix }
Function box_t. gimme_zustand: Integer; Begin gimme_zustand := zustand End;
Procedure box_t. connect_a;
Begin
  a^. push (New (box_node_p, init (connection) ) )
End;
Procedure box_t. connect_e;
Begin
  e^. push (New (box_node_p, init (connection) ) )
End;
(*
 *  CONNECTION-Object
 *
 *)
Procedure connection_t. update;
Begin
  If zustand <> zn Then
  Begin
    zustand := zn;
    changed := True	{ énderung anzeigen }
  End
End;
Procedure connection_t. set_zustand; Begin zustand := z; zn := zustand End;
(*
 *  NOT-Object
 *
 *)
Procedure NOT_t. step;
Begin
  E^. setfirst;
  With e^. get_actual^. box_pointer^ Do
  Begin
    If (has_changed) And (gimme_zustand <= Low) Then
      self. set_zustand (High, t)
    Else
      self. set_zustand (Low, t);
  End
End;
(*
 *  AND-Object
 *
 *)
Procedure AND_t. step;
Var
  produkt: Integer;
  ep: box_node_p;
Begin
  PRODUKT := High;
  
  E^. setfirst;
  Repeat
    ep := e^. get_actual;
    PRODUKT := PRODUKT * ep^. box_pointer^. gimme_zustand;
    e^. next;
  Until ep^. next = Nil;
  
  If produkt <= Low Then
  Begin
    set_zustand (Low, t);
  End
  Else
  Begin
    set_zustand (High, t);
  End;
End;
(*
 *  OR-Object
 *
 *)
Procedure OR_t. step;
Var
  SUMME: Integer;
  ep: box_node_p;
Begin
  SUMME := Low;
  
  E^. setfirst;
  Repeat
    ep := e^. get_actual;
    SUMME := SUMME + ep^. box_pointer^. gimme_zustand;
    e^. next;
  Until ep^. next = Nil;
  
  If SUMME <= Low Then
  Begin
    set_zustand (Low, t);
  End Else
  Begin
    set_zustand (High, t);
  End
End;
(*
 *  NAND-Object
 *
 *)
Procedure NAND_t. step;
Var
  produkt: Integer;
  ep: box_node_p;
Begin
  PRODUKT := High;
  
  E^. setfirst;
  Repeat
    ep := e^. get_actual;
    PRODUKT := PRODUKT * ep^. box_pointer^. gimme_zustand;
    e^. next;
  Until ep^. next = Nil;
  
  If produkt <= Low Then
  Begin
    set_zustand (High, t);
  End
  Else
  Begin
    set_zustand (Low, t);
  End;
End;
(*
 *  NOR-Object
 *
 *)
Procedure NOR_t. step;
Var
  SUMME: Integer;
  ep: box_node_p;
Begin
  SUMME := Low;
  
  E^. setfirst;
  Repeat
    ep := e^. get_actual;
    SUMME := SUMME + ep^. box_pointer^. gimme_zustand;
    e^. next;
  Until ep^. next = Nil;
  
  If SUMME <= Low Then
  Begin
    set_zustand (High, t);
  End Else
  Begin
    set_zustand (Low, t);
  End;
End;
(*
 *  SCHALTER-Object
 *
 *)
Procedure schalter_t. ein;
Begin
  set_zustand (High, 0);
End;
Procedure schalter_t. aus; Begin
  set_zustand (Low, 0);
End;
Begin
End.