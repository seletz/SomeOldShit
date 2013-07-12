Program SimLog;
Uses crt, liste, logik_06;
Var
  s0, s1: schalter_t;
  Or0, Or1: OR_t;
  c0, c1, c2, c3, c4, c5: connection_t;
  Not0, Not1: not_t;
  netz: logik_netz_t;
  hmem_0, hmem_1: LongInt;
Begin
  TextMode (Font8X8 + co80);
  ClrScr;
  WriteLn ('SimLogic V0.3');
  WriteLn ('-------------');
  WriteLn ('');
  WriteLn ('');

  hmem_0 := MemAvail;
  { Verbindungen }
  c0.init ('C0', Low, 0.002); c1.init ('C1', Low, 0.002); c2.init ('C2', Low, 0.002);
  c3.init ('C3', Low, 0.002); c4.init ('C4', Low, 0.002); c5.init ('C5', Low, 0.002);
  c0. set_show (false);
  c1. set_show (false);
  c2. set_show (false);
  c3. set_show (false);
  c4. set_show (true);
  c4.show_gr_init( 100, 4);
  c5. set_show (true);
  c5.show_gr_init( 120, 4);
  { Schalter }
  s0.init ('S0', High, 0.002); s1.init ('S1', Low, 0.002);
  s0. set_show (false);
  s1. set_show (false);
  { OR }
  Or0.init ('OR0', Low, 0.006);
  Or0.show_gr_init ( 20, 4 );
  Or1.init ('OR1', Low, 0.0065);
  Or1.show_gr_init ( 40, 4 );
  { NOT }
  Not0.init ('NOT0', Low, 0.05);
  Not0.show_gr_init ( 60, 4 );
  Not1.init ('NOT1', Low, 0.04);
  Not1.show_gr_init ( 80, 4 );

  { Netz-Container }
  netz. init (0.01); { delta t = 1ms }
  {
  netz aufbauen ;
  }

  s0.connect_a (@c0);
  s0.set_zustand (Low, 0);
  s1.connect_a (@c1);
  s1.set_zustand (High, 0);

  Or0.connect_e (@c0);
  Or0.connect_e (@c5);
  Or0.connect_a (@c2);

  Or1.connect_e (@c4);
  Or1.connect_e (@c1);
  Or1.connect_a (@c3);

  Not0.connect_e (@c2);
  Not0.connect_a (@c4);

  Not1.connect_e (@c3);
  Not1.connect_a (@c5);
  {
  netz speichern
  }

  netz. push (@s0); netz. push (@s1); {netz.push(@s2);}
  netz. push (@c0); netz. push (@c1); netz. push (@c2); netz. push (@c3);
  netz. push (@c4);  netz. push (@c5);
  netz. push (@Or0);
  netz. push (@Or1);
  netz. push (@Not0);
  netz. push (@Not1);
  {
  Start; 1 sekunde laufen lassen;
  }
  netz. run ( 1, mode_graphic);
  {
  Speicher freigeben
  }

  netz. done;
  
  hmem_1 := MemAvail;

  If hmem_0 <> hmem_1 Then
    WriteLn (	'Heap Memory error: vorher ', hmem_0, ' bytes, nachher ', hmem_1, ' bytes,', $13, $10,
							'      differenz :', hmem_0 - hmem_1);

  WriteLn; WriteLn ('<taste>'); ReadLn;
End.