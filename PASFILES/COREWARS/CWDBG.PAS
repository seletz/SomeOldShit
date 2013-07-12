unit cwdbg;
interface
uses
	crt, cwtypes;
const
	max_dbg = 50;
var
	dbg_tab:integer;
  dbg_msg: array [1 .. max_dbg] of string;
procedure dbg_start( flag:boolean; msg:string);
procedure dbg(flag:boolean; code:word; msg:string);
procedure dbg_end( flag:boolean);
implementation
procedure tab_it;
begin
	gotoxy(dbg_tab, wherey);
end;
procedure dbg_start;
begin
	if not flag then exit;

	if dbg_tab <max_dbg then inc(dbg_tab);
	dbg_msg[dbg_tab]:=msg;
	writeln( '>> ',dbg_msg[dbg_tab]);
end;
procedure dbg_end;
begin
	if not flag then exit;
 	tab_it;
	writeln( '<< ',dbg_msg[dbg_tab]);
	if dbg_tab >0 then dec(dbg_tab);
end;
procedure dbg;
begin
	if not flag then exit;
  tab_it;
	writeln( code,' : ',msg );
end;
begin
	dbg_tab:=0;
  dbg_msg[1]:='no message';
end.