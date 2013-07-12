program SimLog;
uses crt,liste, logik_03;
var
	s0,s1:schalter_t;
  and0:AND_t;
  or0:OR_t;
  c0,c1,c2:connection_t;
  netz:logik_netz_t;
  hmem_0,hmem_1:longint;
begin
	textmode(font8x8+co80);
	clrscr;
  writeln('SimLogic V0.3');
  writeln('-------------');
  writeln('');
  writeln('');

  hmem_0:=memavail;
	{ Verbindungen }
  c0.init('C0',LOW); c1.init('C1',LOW); c2.init('C2',LOW); {c3.init(LOW); c4.init(LOW);}
  { Schalter }
	s0.init('S0',LOW); s1.init('S1',LOW); {s2.init(LOW);}
  { AND's }
  and0.init('AND0',LOW); {and1.init(LOW);}
  { OR }
  or0.init('OR0',LOW);
  { Netz-Container }
  netz.init(1); { delta t = 1s }
  {
		netz aufbauen ; von hinten;
  }

  or0.connect_e(@c0);
  or0.connect_e(@c2);

  and0.connect_e(@c0);
  and0.connect_e(@c1);
  and0.connect_a(@c2);

  s0.connect_a(@c0);
 	s0.set_zustand(HIGH);
  s1.connect_a(@c1);
 	s1.set_zustand(HIGH);

  {
  	netz speichern
  }
  netz.push(@c0); netz.push(@c1); netz.push(@c2);{ netz.push(@c3);
  netz.push(@c4);}
	netz.push(@s0); netz.push(@s1); {netz.push(@s2);}
  netz.push(@and0); {netz.push(@and1);}
	netz.push(@or0);
  writeln('n-1:');
  netz.show_all;

  {
  	1 Schritt berechnen
  }

  netz.update_all;
  netz.step;
  netz.update_all;

  writeln('n+1:');
  netz.show_all;

  {
  	Speicher freigeben
  }

  netz.done;

  hmem_1:=memavail;

  if hmem_0<>hmem_1 then
  	writeln('Heap Memory error: vorher ',hmem_0,' bytes, nachher ',hmem_1,' bytes,',$13,$10,'      differenz :',hmem_0-hmem_1);

  writeln; writeln('<taste>'); readln;
end.