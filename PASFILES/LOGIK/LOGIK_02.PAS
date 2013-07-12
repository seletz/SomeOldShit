unit logik_02;
INTERFACE
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
	box_p_liste_p = ^box_p_liste_t;
  box_p_liste_t = object (liste_t)
  								destructor done;
  								function get_actual:box_node_p;
  							end;

	box_t_liste_p = ^box_t_liste_t;
  box_t_liste_t = object (liste_t)
  								destructor done;
  								function get_actual:box_p;
  							end;
{
	NETZ-OBJEKT-DEKL
}
	logik_netz_t = object
                        box_liste:box_t_liste_p;
                        time:single;	{ in sekunden }
                        delta_t:single;	{ in sekunden }
                        constructor init(idt:single);
                        destructor done;
                        procedure push(bp:box_p);

                        procedure step;
                        procedure run(runtime:single);	{in sekunden }
  										end;
{
	LOGIKOBJEKT-DEKL
}
  box_t = object (node_t)
  					zustand:integer;
            zn:integer;
            E:box_p_liste_p;
            constructor init(z:integer);
            destructor done; virtual;

            procedure connect(bp:box_p);

            procedure set_zustand(z:integer);
            procedure update;
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
IMPLEMENTATION
(**********************************************************************)
(*********    LISTENMETHODEN          *********************************)
(**********************************************************************)
(*
 *  BOX-NODE_Object
 *
 *)
constructor box_node_t.init; begin inherited init; box_pointer:=bp end;
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
    dispose(pop, done);          { popen und l”schen }
  Until isempty; 				{ bis Liste leer }

  first := Nil;
  last := Nil;
  actual := Nil;
End;
function box_p_liste_t.get_actual:box_node_p; begin get_actual:=box_node_p(inherited get_actual) end;(*
 *  BOX-TYP-LISTE_Object
 *
 *)
Destructor box_t_liste_t. done;
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
function box_t_liste_t.get_actual:box_p; begin get_actual:=box_p(inherited get_actual) end;
(**********************************************************************)
(*********    LOGIK-METHODEN          *********************************)
(**********************************************************************)
(*
 *  NETZ-Object
 *
 *)
constructor logik_netz_t.init; begin box_liste:=new(box_t_liste_p, init); delta_t:=idt; time:=0 end;
destructor logik_netz_t.done; begin dispose(box_liste, done) end;
procedure logik_netz_t.push; begin box_liste^.push(bp) end;
procedure logik_netz_t.step; begin end;
procedure logik_netz_t.run; begin end;
(*
 *  BOX-Object
 *
 *)
constructor box_t.init(z:integer); begin e:=new(box_p_liste_p, init); set_zustand(z) end;
destructor box_t.done; begin dispose(e, done); end;
procedure box_t.set_zustand; begin zn:=z end;
procedure box_t.update; begin zustand:=zn end;
function box_t.gimme_zustand:integer; begin gimme_zustand:=zustand end;
procedure box_t.connect; begin e^.push(new(box_node_p,init(bp))) end;
(*
 *  NICHT-Object
 *
 *)
function nicht_t.gimme_zustand:integer;
begin
	E^.setfirst;
  if e^.get_actual^.box_pointer^.gimme_zustand<=LOW then
  	begin
    	set_zustand(HIGH); update;
  		gimme_zustand:=HIGH
    end
  else
  	begin
    	set_zustand(LOW); update;
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
  		set_zustand(LOW); update;
  		gimme_zustand:=LOW
    end
  else
  	begin
  		set_zustand(HIGH); update;
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
  		set_zustand(LOW); update;
  		gimme_zustand:=LOW
    end
  else
  	begin
  		set_zustand(HIGH); update;
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
begin
end.