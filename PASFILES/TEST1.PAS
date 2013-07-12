program teilbereichstyp;
uses crt;
type
	myInt=1..9999;
var
	i:integer;
	j:myInt;
begin
	for i:=1 to 3 do
  begin
  	j:=i*5000;
    writeln(i,j);
  end;
end.