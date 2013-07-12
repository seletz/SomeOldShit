unit liste_3d;
INTERFACE
uses crt, matrix44, liste;
type
  punkt_p = ^punkt_t;
  punkt_t = object (node_t)
  						nummer:integer;
  						p:vektor4;
              constructor init;
              procedure set_k(x,y,z:double);
              procedure set_p(ip:p_vektor4);
              procedure get_p(ip:p_vektor4);
              procedure set_nummer(n:integer);
              function get_nummer:integer;
              procedure print;
              procedure println;
  				  end;
  linie_p = ^linie_t;
  linie_t = object (node_t)
  						a,b:integer;
              farbe:integer;
              constructor init;
              procedure set_ab(ia,ib:integer);
              procedure set_farbe(ifa:integer);
              function get_a:integer;
              function get_b:integer;
              function get_farbe:integer;
              procedure print;
              procedure println;
  					end;
  punkteliste_t = object (liste_t)
  								function get_actual:punkt_p;
                  function get_n(n:integer):punkt_p;
  							end;
  linienliste_t = object (liste_t)
  								function get_actual:linie_p;
  						 	 end;

IMPLEMENTATION
(*
 *
 * 	Punkt
 *
 *
 *)
constructor punkt_t.init; begin inherited init; nummer:=-1; vzero(@p) end;
procedure punkt_t.set_k; begin	p[1]:=x; p[2]:=y; p[3]:=z; p[4]:=1 end;
procedure punkt_t.set_p; begin	copy_vektor(ip,@p) end;
procedure punkt_t.get_p; begin	copy_vektor(@p,ip) end;
procedure punkt_t.set_nummer; begin nummer:=n end;
function punkt_t.get_nummer:integer; begin get_nummer:=nummer end;
procedure punkt_t.print;
begin
	write('#',nummer,'=(',p[1]:3:3,',',p[2]:3:3,',',p[3]:3:3,')');
end;
procedure punkt_t.println; begin print; writeln end;
(*
 *
 * 	Linie
 *
 *
 *)
constructor linie_t.init; begin inherited init; a:=-1; b:=-1 end;
procedure linie_t.set_ab; begin a:=ia; b:=ib end;
procedure linie_t.set_farbe; begin farbe:=ifa end;
function linie_t.get_a:integer; begin get_a:=a end;
function linie_t.get_b:integer; begin get_b:=b end;
function linie_t.get_farbe:integer; begin get_farbe:=farbe end;
procedure linie_t.print;
begin
	write('#',a,'->#',b);
end;
procedure linie_t.println; begin print; writeln end;
(*
 *
 * 	Punkteliste
 *
 *
 *)
function punkteliste_t.get_actual:punkt_p; begin get_actual:=punkt_p(inherited get_actual) end;
function punkteliste_t.get_n(n:integer):punkt_p;
var
	asave:punkt_p;
  found:boolean;
  punkt:punkt_P;
begin
	asave:=get_actual;
  setfirst;
  found:=false;
  punkt:=nil;
  repeat
    punkt:=get_actual;
  	found:=(punkt^.get_nummer=n);
    next;
  until (found or (punkt^.next=nil));
  actual:=asave;
  get_n:=punkt;
end;
(*
 *
 * 	Linienliste
 *
 *
 *)
function linienliste_t.get_actual:linie_p; begin get_actual:=linie_p(inherited get_actual) end;
begin
end.
