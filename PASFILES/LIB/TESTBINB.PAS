program test_binbaum;
uses crt,binbaum;
type
	aknoten_p =	^aknoten_t;
  aknoten_t =	object(knoten_t)
		              function get_links:aknoten_p;
     			        function get_rechts:aknoten_p;
  								function berechne:aknoten_p; virtual;
                  function hat_wert:boolean; virtual;
                  function get_wert_string:string; virtual;
  						end;
	plus_p = ^plus_t;
	plus_t = object(aknoten_t)
             function get_links:plus_p;
             function get_rechts:plus_p;
             function berechne:aknoten_p; virtual;
             function get_wert_string:string; virtual;
           end;
	mal_p = ^mal_t;
	mal_t = object(aknoten_t)
             function get_links:mal_p;
             function get_rechts:mal_p;
             function berechne:aknoten_p; virtual;
             function get_wert_string:string; virtual;
           end;
  arg_p = ^arg_t;
	arg_t = object(aknoten_t)
  					wert:longint;
            constructor init;
            procedure set_wert(iw:longint);

            function get_links:arg_p;
            function get_rechts:arg_p;
            function get_wert:longint;
            function hat_wert:boolean; virtual;
            function berechne:aknoten_p; virtual;
            function get_wert_string:string; virtual;
  				end;
  var_p = ^var_t;
	var_t = object(aknoten_t)
  					wert:longint;
            definiert:boolean;
            name:string;
            constructor init(inam:string);
            procedure definiere(iw:longint);
            procedure set_name(inam:string);

            function get_links:var_p;
            function get_rechts:var_p;
            function get_wert:longint;
            function hat_wert:boolean; virtual;
            function berechne:aknoten_p; virtual;
            function get_wert_string:string; virtual;
  				end;
  algebra_baum_t =	object (binbaum_t)
  										function get_infix(kn:aknoten_p):string;
                      function get_postfix(kn:aknoten_p):string;
                      function get_prefix(kn:aknoten_p):string;
                    end;

(*
 *
 *
 *		Methodendefinitionen
 *
 *
 *
 *)
function aknoten_t.get_rechts:aknoten_p;
begin get_rechts:=aknoten_p(inherited get_rechts) end;
function aknoten_t.get_links:aknoten_p;
begin get_links:=aknoten_p(inherited get_links) end;
function aknoten_t.get_wert_string:string; begin get_wert_string:='??' end;
function aknoten_t.berechne:aknoten_p;
begin
	halt(1);
end;
function aknoten_t.hat_wert:boolean; begin hat_wert:=false end;
(*
 *  PLUS
 *
 *)
function plus_t.get_wert_string:string; begin get_wert_string:='+' end;
function plus_t.get_rechts:plus_p;
begin get_rechts:=plus_p(inherited get_rechts) end;
function plus_t.get_links:plus_p;
begin get_links:=plus_p(inherited get_links) end;
function plus_t.berechne:aknoten_p;
var erg_l,erg_r:aknoten_p;
		erg:arg_p;
begin
	erg_l:=aknoten_p(links)^.berechne;
  erg_r:=aknoten_p(rechts)^.berechne;
  if (erg_l^.hat_wert) and (erg_r^.hat_wert) then
	begin
    erg:=new(arg_p,init); { bl„tter haben keine nachkommen }
    erg^.set_wert	(
									arg_p(erg_l)^.get_wert + arg_p(erg_r)^.get_wert
									);
    erg_l^.done;
    erg_r^.done;
    berechne:=erg;
	end else
	begin
  	links^.done;
    rechts^.done;
    links:=erg_l;
    rechts:=erg_r;
    berechne:=@self;
	end;
end;
(*
 *  MAL
 *
 *)
function mal_t.get_wert_string:string; begin get_wert_string:='*' end;
function mal_t.get_links:mal_p;
begin get_links:=mal_p(inherited get_links) end;
function mal_t.get_rechts:mal_p;
begin get_rechts:=mal_p(inherited get_rechts) end;
function mal_t.berechne:aknoten_p;
var erg_l,erg_r:aknoten_p;
		erg:arg_p;
begin
	erg_l:=aknoten_p(links)^.berechne;
  erg_r:=aknoten_p(rechts)^.berechne;
  if (erg_l^.hat_wert) and (erg_r^.hat_wert) then
	begin
    erg:=new(arg_p,init); { bl„tter haben keine nachkommen }
    erg^.set_wert	(
									arg_p(erg_l)^.get_wert * arg_p(erg_r)^.get_wert
									);
    erg_l^.done;
    dispose(erg_l);
    erg_r^.done;
    dispose(erg_r);

    berechne:=erg;
	end else
	begin
  	links^.done;
    dispose(links);
    rechts^.done;
    dispose(rechts);
    links:=erg_l;
    rechts:=erg_r;
    berechne:=@self;
	end;
end;
(*
 *  ARG
 *
 *)
function arg_t.get_wert_string:string;
var out:string;
begin
	str(wert,out);
	get_wert_string:=out;
end;
function arg_t.get_links:arg_p;
begin get_links:=arg_p(inherited get_links) end;
function arg_t.get_rechts:arg_p;
begin get_rechts:=arg_p(inherited get_rechts) end;
constructor arg_t.init;
begin
	inherited init(NIL,NIL)
end;
procedure arg_t.set_wert;
begin wert:=iw; end;
function arg_t.get_wert:longint;
begin get_wert:=wert end;
function arg_t.hat_wert:boolean; begin hat_wert:=true end;
function arg_t.berechne:aknoten_p;
begin
	berechne:=@self;
end;
(*
 *  VAR
 *
 *)
function var_t.get_wert_string:string; begin get_wert_string:=name end;
function var_t.get_rechts:var_p;
begin get_rechts:=var_p(inherited get_rechts) end;
function var_t.get_links:var_p;
begin get_links:=var_p(inherited get_links) end;
constructor var_t.init;
begin
	inherited init(NIL,NIL);
  definiert:=false;
  set_name(inam)
end;
procedure var_t.definiere;
begin wert:=iw; definiert:=true end;
procedure var_t.set_name;
begin name:=inam; end;
function var_t.get_wert:longint;
begin get_wert:=wert end;
function var_t.hat_wert:boolean; begin hat_wert:=definiert end;
function var_t.berechne:aknoten_p;
begin
	berechne:=@self;
end;

function algebra_baum_t.get_infix(kn:aknoten_p):string;
var out:string;
begin
	{
  	Abarbeitungsfolge:
    	links - operator - rechts
  }

end;
function algebra_baum_t.get_postfix(kn:aknoten_p):string;
var out:string;
begin
	if kn^.ist_blatt then
  begin
  	out:=kn^.get_wert_string;
  end else
  begin
{  	out:= kn^.get_links^.get_wert_string + ' '+
					kn^.get_rechts^.get_wert_string + ' ' +
					kn^.get_wert_string;}
		out:= get_postfix(kn^.get_links) + ' ' +
    			get_postfix(kn^.get_rechts) + ' ' +
          kn^.get_wert_string;
  end;
  get_postfix:=out;
end;
function algebra_baum_t.get_prefix(kn:aknoten_p):string;
var out:string;
begin
end;
(*
 *
 * 	(8 + 4)*(3 + 2)*2
 *
 *        *                    WURZEL
 *       / \                  /     \
 *      /   \                /       \
 *     /     \              T1        T2
 *    +       *            / \        / \
 *   / \     / \          /   \      /   \
 *  8   4   +   2        A1   A2    T21   A5
 *         / \                     /   \
 *		    3   2                   A3   A4
 *)
var
	A1:var_p;
	A2,A3,A4,A5:arg_p;
	T1,T2,T11,T21,T22,wurzel:aknoten_p;

  ergebnis:aknoten_p;

  algb:algebra_baum_t;

begin
	clrscr;

	writeln('Mem:',memavail);
 	A1:=new(var_p,init('x')); {A1^.set_wert(8);}
 	A2:=new(arg_p,init); A2^.set_wert(4);
 	A3:=new(arg_p,init); A3^.set_wert(3);
 	A4:=new(arg_p,init); A4^.set_wert(2);
 	A5:=new(arg_p,init); A5^.set_wert(2);
 	T21:=new(plus_p,init( A3, A4 ));
 	T2:=new(mal_p,init( T21, A5 ));
 	T1:=new(plus_p,init( A1, A2 ));
 	wurzel:=new(mal_p,init( T1, T2 ));
	writeln('Mem:',memavail);

  algb.init(wurzel);

  writeln('Term=',algb.get_postfix(wurzel));

  ergebnis:=wurzel^.berechne;
  writeln('Term=',algb.get_postfix(ergebnis));
	writeln('Mem:',memavail);

  A1^.definiere(8);

  ergebnis:=ergebnis^.berechne;
	writeln('Term=',algb.get_postfix(ergebnis));
	writeln('Mem:',memavail);
  algb.done;
end.