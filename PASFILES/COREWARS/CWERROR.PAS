unit cwerror;
interface
uses
	cwtypes;
const
	cw_err_fatal = 99;
  cw_err_unknown_opcode = 100;
  cw_err_unknown_amode = 101;
  cw_err_unknown_mmode = 102;
procedure panic(code:word; msg:string);
implementation
procedure panic;
begin
	writeln( 'cw panic:');
  writeln;
  writeln( code,' : ',msg );
  halt( code );
end;
begin
end.