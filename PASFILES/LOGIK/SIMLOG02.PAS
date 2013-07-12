program logiksim;
uses crt,liste, logik_02;
var
	s0,s1,s2,s3:schalter_t;
  and0,and1:und_t;
  or0:oder_t;

  i,j,k,l:integer;
  hmem_0,hmem_1:longint;
begin
	clrscr;
  writeln('SimLogic V0.1');
  writeln('-------------');
  writeln('');
  writeln(' F:= s0 s1  +  s2 s3 + s0;');
  writeln('');

  hmem_0:=memavail;

	s0.init(LOW); s1.init(LOW); s2.init(LOW); s3.init(LOW);
  and0.init(LOW); and1.init(LOW);
  or0.init(LOW);

  { netz aufbauen ; von hinten;

  	f:=s0 s1  +  s2 s3 + s0;

	}

  or0.connect(@and0);
  or0.connect(@and1);
  or0.connect(@s0);

  and0.connect(@s0);
  and0.connect(@s1);

  and1.connect(@s2);
  and1.connect(@s3);


  { funktionstabelle durchlaufen: }
  writeln('S3 | S2 | S1 | S0 ||  F');
  writeln('------------------------');
  for l:=LOW to HIGH do
  for k:=LOW to HIGH do
  	for j:=LOW to HIGH do
    	for i:=LOW to HIGH do
      	begin
        	s0.set_zustand(i); s0.update;
        	s1.set_zustand(j); s1.update;
        	s2.set_zustand(k); s2.update;
        	s3.set_zustand(l); s3.update;

          write(s3.gimme_zustand:2,' | ',s2.gimme_zustand:2,' | ',s1.gimme_zustand:2,' | ',s0.gimme_zustand:2,' || ');
          writeln(or0.gimme_zustand:2);
        end;
  or0.done; and0.done; and1.done; s0.done; s1.done; s2.done; s3.done;
  hmem_1:=memavail;

  if hmem_0<>hmem_1 then
  	writeln('Heap Memory error: vorher ',hmem_0,' bytes, nachher ',hmem_1,' bytes,',$13,$10,'      differenz :',hmem_0-hmem_1);
end.