program SimLog;
uses crt,liste, logik_04;
var
	s0,s1:schalter_t;
  or0,or1:OR_t;
  c0,c1,c2,c3,c4,c5:connection_t;
  not0,not1:not_t;
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
  c0.init('C0',LOW); c1.init('C1',LOW); c2.init('C2',LOW);
	c3.init('C3',LOW); c4.init('C4',LOW); c5.init('C5',LOW);
  { Schalter }
	s0.init('S0',HIGH); s1.init('S1',LOW);
  { OR }
  or0.init('OR0',LOW);
  or1.init('OR1',LOW);
  { NOT }
  not0.init('NOT0',LOW);
  not1.init('NOT1',LOW);

  { Netz-Container }
  netz.init(0.001); { delta t = 1ms }
  {
		netz aufbauen ;
  }

  s0.connect_a(@c0);
 	s0.set_zustand(LOW);
  s1.connect_a(@c1);
 	s1.set_zustand(HIGH);

  or0.connect_e(@c0);
  or0.connect_e(@c5);
  or0.connect_a(@c2);

  or1.connect_e(@c4);
  or1.connect_e(@c1);
  or1.connect_a(@c3);

  not0.connect_e(@c2);
  not0.connect_a(@c4);

  not1.connect_e(@c3);
  not1.connect_a(@c5);


  {
  	netz speichern
  }
	netz.push(@s0); netz.push(@s1); {netz.push(@s2);}
  netz.push(@c0); netz.push(@c1); netz.push(@c2); netz.push(@c3);
  netz.push(@c4);  netz.push(@c5);
  netz.push(@or0);
	netz.push(@or1);
  netz.push(@not0);
	netz.push(@not1);
  writeln('n-1:');
  netz.show_all;

  {
  	1 Schritt berechnen
  }

  netz.update_all;
  clrscr; writeln('S:');
	netz.show_all; writeln('<taste>'); readln;
  netz.step;
  clrscr; writeln('S:');
	netz.show_all; writeln('<taste>'); readln;
  netz.update_all;
  clrscr; writeln('U:');
	netz.show_all; writeln('<taste>'); readln;
  netz.step;
  clrscr; writeln('S:');
	netz.show_all; writeln('<taste>'); readln;
  netz.update_all;
  clrscr; writeln('U:');
	netz.show_all; writeln('<taste>'); readln;
  netz.step;
  clrscr; writeln('S:');
	netz.show_all; writeln('<taste>'); readln;
  netz.update_all;
  clrscr; writeln('U:');
	netz.show_all; writeln('<taste>'); readln;
  netz.step;
  clrscr; writeln('S:');
	netz.show_all; writeln('<taste>'); readln;
  netz.update_all;
  clrscr; writeln('U:');
	netz.show_all; writeln('<taste>'); readln;
  netz.step;
  clrscr; writeln('S:');
	netz.show_all; writeln('<taste>'); readln;
  netz.update_all;
  clrscr; writeln('U:');
	netz.show_all; writeln('<taste>'); readln;
  netz.step;
  clrscr; writeln('S:');
	netz.show_all; writeln('<taste>'); readln;
  netz.update_all;
  clrscr; writeln('U:');
	netz.show_all; writeln('<taste>'); readln;
  netz.step;
  clrscr; writeln('S:');
	netz.show_all; writeln('<taste>'); readln;
  netz.update_all;
  clrscr; writeln('U:');
  writeln('n+1:');
	netz.show_all; writeln('<taste>'); readln;

  {
  	Speicher freigeben
  }

  netz.done;

  hmem_1:=memavail;

  if hmem_0<>hmem_1 then
  	writeln('Heap Memory error: vorher ',hmem_0,' bytes, nachher ',hmem_1,' bytes,',$13,$10,'      differenz :',hmem_0-hmem_1);

  writeln; writeln('<taste>'); readln;
end.