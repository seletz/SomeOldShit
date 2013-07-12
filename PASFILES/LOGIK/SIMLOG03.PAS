program SimLog;
uses crt,liste, logik_03;
var
	s0,s1,s2:schalter_t;
  and0,and1:AND_t;
  or0:OR_t;
  c0,c1,c2,c3,c4:connection_t;
  netz:logik_netz_t;
  hmem_0,hmem_1:longint;
begin
	clrscr;
  writeln('SimLogic V0.3');
  writeln('-------------');
  writeln('');
  writeln('');

  hmem_0:=memavail;
	{ Verbindungen }
  c0.init(LOW); c1.init(LOW); c2.init(LOW); c3.init(LOW); c4.init(LOW);
  { Schalter }
	s0.init(LOW); s1.init(LOW); s2.init(LOW);
  { AND's }
  and0.init(LOW); and1.init(LOW);
  { OR }
  or0.init(LOW);
  { Netz-Container }
  netz.init(1); { delta t = 1s }
  {
		netz aufbauen ; von hinten;
  }

  or0.connect_e(@c3);
  or0.connect_e(@c4);
  or0.connect_e(@c0);

  and0.connect_a(@c3);
  and0.connect_e(@c0);
  and0.connect_e(@c4);

  and1.connect_a(@c4);
  and1.connect_e(@c2);
  and1.connect_e(@c3);

  s0.connect_a(@c0);
 	s0.set_zustand(LOW);
  s1.connect_a(@c1);
 	s1.set_zustand(LOW);
  s2.connect_a(@c2);
 	s2.set_zustand(HIGH);

  {
  	netz speichern
  }
  netz.push(@c0); netz.push(@c1); netz.push(@c2); netz.push(@c3);
  netz.push(@c4);
	netz.push(@s0); netz.push(@s1); netz.push(@s2);
  netz.push(@and0); netz.push(@and1);
	netz.push(@or0);

  {
  	1 Schritt berechnen
  }

  netz.step;

  writeln('C0   = ',c0.gimme_zustand:2);
  writeln('C1   = ',c1.gimme_zustand:2);
  writeln('C2   = ',c2.gimme_zustand:2);
  writeln('C3   = ',c3.gimme_zustand:2);
  writeln('C4   = ',c4.gimme_zustand:2);
  writeln('AND0 = ',and0.gimme_zustand:2);
  writeln('AND1 = ',and1.gimme_zustand:2);
  writeln('OR0  = ',or0.gimme_zustand:2);

  {
  	Speicher freigeben
  }

  netz.done;

  hmem_1:=memavail;

  if hmem_0<>hmem_1 then
  	writeln('Heap Memory error: vorher ',hmem_0,' bytes, nachher ',hmem_1,' bytes,',$13,$10,'      differenz :',hmem_0-hmem_1);

  readln;
end.