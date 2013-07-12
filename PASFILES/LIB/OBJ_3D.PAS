unit obj_3d;
INTERFACE
uses crt, matrix44, liste, liste_3d;
type
	obj_3d_p= ^obj_3d_t;
  obj_3d_t = object (node_t)
  						name:string;
  						pl:punkteliste_t;
							ll:linienliste_t;
  						constructor init(iname:string);
              destructor done; virtual;
              procedure setfirst;
              procedure pushpunkt(p:punkt_p);
              procedure pushlinie(l:linie_p);
              function get_start:punkt_p;
              function get_end:punkt_p;
              function get_farbe:integer;
              procedure set_next;

              procedure print;
              procedure transformiere(M:p_matrix4);
  					 end;
IMPLEMENTATION
constructor obj_3d_t.init; begin inherited init; name:=iname; pl.init; ll.init end;
destructor obj_3d_t.done; begin ll.done; pl.done; inherited done end;
procedure obj_3d_t.setfirst; begin ll.setfirst; pl.setfirst end;
procedure obj_3d_t.pushpunkt(p:punkt_p); begin pl.push(p) end;
procedure obj_3d_t.pushlinie(l:linie_p); begin ll.push(l) end;
procedure obj_3d_t.set_next; begin ll.next end;
function obj_3d_t.get_start:punkt_p; begin get_start:=pl.get_n(ll.get_actual^.get_a) end;
function obj_3d_t.get_end:punkt_p; begin get_end:=pl.get_n(ll.get_actual^.get_b) end;
function obj_3d_t.get_farbe:integer; begin get_farbe:=ll.get_actual^.get_farbe end;
procedure obj_3d_t.transformiere;
begin
	pl.setfirst;
  repeat
  	mdotv(M,@pl.get_actual^.p,@pl.get_actual^.p);
    pl.next;
  until pl.actual^.next=nil;
end;
procedure obj_3d_t.print;
var
	p:punkt_p;
  l:linie_p;
begin
	writeln('OBJEKT: ',name);
	writeln('Punkte:');
	pl.setfirst;
	repeat
  	p:=pl.get_actual;
    p^.println;
  	pl.next;
  until	p^.next=nil;
  writeln('Linien');
	ll.setfirst;
	repeat
  	l:=ll.get_actual;
    l^.println;
  	ll.next;
  until	l^.next=nil;
end;
begin
end.