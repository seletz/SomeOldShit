unit binbaum;
interface
uses crt,liste;
type
  knoten_p = ^knoten_t;
  knoten_t =	object(node_t)
              	links,rechts:knoten_p;
                constructor init(il,ir:knoten_p);
                destructor done; virtual;
                procedure set_links(lk:knoten_p);
                procedure set_rechts(rk:knoten_p);

                function get_links:knoten_p;
                function get_rechts:knoten_p;
                function ist_blatt:boolean;
  						end;
  knoten_liste_t =	object(liste_t)
                    	function pop:knoten_p;
  									end;
  binbaum_t =	object
  							wurzel:knoten_p;
                vater_stack:knoten_liste_t;
                aktuell:knoten_p;
                constructor init(iw:knoten_p);
                destructor done;
                procedure auf;
                procedure ab_links;
                procedure ab_rechts;

                function get_aktuell:knoten_p;
              end;
implementation
(*
 *
 *
 * 	Methodendefinitionen
 *
 *
 *
 *)
constructor knoten_t.init;
begin
	inherited init;
	set_links(il);
	set_rechts(ir)
end;
destructor knoten_t.done;
begin
	if links<>NIL then
  begin
		links^.done;
  	dispose(links);
  end;
	if rechts<>NIL then
  begin
	  rechts^.done;
  	dispose(rechts);
  end;
  (*
  	selbst done ab hier
  *)
end;
procedure knoten_t.set_links;
begin links:=lk end;
procedure knoten_t.set_rechts;
begin rechts:=rk end;
function knoten_t.ist_blatt:boolean;
begin ist_blatt:=(links=NIL) and (rechts=NIL) end;
function knoten_t.get_links:knoten_p;
begin get_links:=links end;
function knoten_t.get_rechts:knoten_p;
begin get_rechts:=rechts end;

function knoten_liste_t.pop:knoten_p;
begin
	pop:=knoten_p(inherited pop)
end;

constructor binbaum_t.init;
begin
	vater_stack.init;
	wurzel:=iw;
	aktuell:=wurzel;
end;
destructor binbaum_t.done;
begin
	vater_stack.done;
  wurzel^.done;
end;
function binbaum_t.get_aktuell:knoten_p;
begin get_aktuell:=aktuell end;
procedure binbaum_t.auf;
begin
	if not (aktuell=wurzel) then
  begin
  	aktuell:=vater_stack.pop;
  end
end;
procedure binbaum_t.ab_links;
begin
	if not aktuell^.ist_blatt then
  begin
		vater_stack.push(aktuell);
    aktuell:=aktuell^.links;
  end;
end;
procedure binbaum_t.ab_rechts;
begin
	if not aktuell^.ist_blatt then
  begin
		vater_stack.push(aktuell);
    aktuell:=aktuell^.rechts;
  end;
end;

begin
end.