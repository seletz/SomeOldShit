program logiksim;
uses crt,liste;
const
	high:integer=1;
  low:integer=0;
type

	box_p = ^box_t;
{
	LISTENZEUGS-TYPENDEKL
}
  box_node_p = ^box_node_t;
  box_node_t = object (node_t)
  								box_pointer:box_p;
  								constructor init(bp:box_p);
  						 end;
	box_liste_p = ^box_liste_t;
  box_liste_t = object (liste_t)
  								destructor done;
  								function get_actual:box_node_p;
  							end;
{
	LOGIKOBJEKT-DEKL
}
  box_t = object
  					zustand:integer;
            E:box_liste_p;
            constructor init(z:integer);
            destructor done; virtual;

            procedure connect(bp:box_p);

            procedure set_zustand(z:integer);
            function gimme_zustand:integer; virtual;
  				end;

  nicht_p = ^und_t;
  nicht_t = object (box_t)
  					function gimme_zustand:integer; virtual;
  				end;


  und_p = ^und_t;
  und_t = object (box_t)
  					function gimme_zustand:integer; virtual;
  				end;

  oder_p = ^und_t;
  oder_t = object (box_t)
  					function gimme_zustand:integer; virtual;
  				end;

  schalter_p = ^und_t;
  schalter_t = object (box_t)
  					procedure ein;
            procedure aus;
  					function gimme_zustand:integer; virtual;
  				end;

(*
 *  BOX-Object
 *
 *)
constructor box_t.init(z:integer); begin e:=new(box_liste_p, init); set_zustand(z) end;
destructor box_t.done; begin dispose(e, done); end;
procedure box_t.set_zustand; begin zustand:=z; end;
function box_t.gimme_zustand:integer; begin gimme_zustand:=zustand end;
procedure box_t.connect; begin e^.push(new(box_node_p,init(bp))) end;
(*
 *  BOX-NODE_Object
 *
 *)
constructor box_node_t.init; begin inherited init; box_pointer:=bp end;
(*
 *  BOX-LISTE_Object
 *
 *)
Destructor box_liste_t. done;
Var temp: node_p;
Begin
  If isempty Then Exit; { liste ist leer }

  setfirst; 							{ wir fangen vorne an }
  Repeat
    dispose(pop, done);          { popen und l”schen }
  Until isempty; 				{ bis Liste leer }
  
  first := Nil;
  last := Nil;
  actual := Nil;
End;

function box_liste_t.get_actual:box_node_p; begin get_actual:=box_node_p(inherited get_actual) end;
(*
 *  NICHT-Object
 *
 *)
function nicht_t.gimme_zustand:integer;
begin
	E^.setfirst;
  if e^.get_actual^.box_pointer^.gimme_zustand<=LOW then
  	begin
    	set_zustand(HIGH);
  		gimme_zustand:=HIGH
    end
  else
  	begin
    	set_zustand(LOW);
  		gimme_zustand:=LOW
    end;
end;
(*
 *  UND-Object
 *
 *)
function und_t.gimme_zustand:integer;
var
	produkt:integer;
  ep:box_node_p;
begin
	PRODUKT:=high;

	E^.setfirst;
  repeat
  	ep:=e^.get_actual;
  	PRODUKT:=PRODUKT*ep^.box_pointer^.gimme_zustand;
    e^.next;
  until ep^.next=nil;

  if produkt<=low then
  	begin
  		set_zustand(LOW);
  		gimme_zustand:=LOW
    end
  else
  	begin
  		set_zustand(HIGH);
  		gimme_zustand:=HIGH
    end;
end;
(*
 *  ODER-Object
 *
 *)
function oder_t.gimme_zustand:integer;
var
	SUMME:integer;
  ep:box_node_p;
begin
	SUMME:=LOW;

	E^.setfirst;
	repeat
    ep:=e^.get_actual;
  	SUMME:=SUMME + ep^.box_pointer^.gimme_zustand;
    e^.next;
  until ep^.next=nil;

  if SUMME<=low then
  	begin
  		set_zustand(LOW);
  		gimme_zustand:=LOW
    end
  else
  	begin
  		set_zustand(HIGH);
  		gimme_zustand:=HIGH
    end;
end;
(*
 *  SCHALTER-Object
 *
 *)
procedure schalter_t.ein; begin set_zustand(HIGH) end;
procedure schalter_t.aus; begin set_zustand(LOW) end;
function schalter_t.gimme_zustand:integer; begin gimme_zustand:=zustand; end;

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
        	s0.set_zustand(i);
        	s1.set_zustand(j);
        	s2.set_zustand(k);
        	s3.set_zustand(l);

          write(s3.gimme_zustand:2,' | ',s2.gimme_zustand:2,' | ',s1.gimme_zustand:2,' | ',s0.gimme_zustand:2,' || ');
          writeln(or0.gimme_zustand:2);
        end;
  or0.done; and0.done; and1.done; s0.done; s1.done; s2.done; s3.done;
  hmem_1:=memavail;

  if hmem_0<>hmem_1 then
  	writeln('Heap Memory error: vorher ',hmem_0,' bytes, nachher ',hmem_1,' bytes,',$13,$10,'      differenz :',hmem_0-hmem_1);
end.