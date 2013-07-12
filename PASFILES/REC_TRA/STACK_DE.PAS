program stack_demo;
uses crt,ste,liste;
type stackp = ^stacktyp;
     stacktyp = object (nodetyp)
                       data:longint;
                       constructor init(idata:longint);
                       procedure setdata(idata:longint);
                       function gimmedata:longint;
                end;
     constructor stacktyp.init;
     begin inherited init; data:=idata end;
     procedure stacktyp.setdata;
     begin data:=idata end;
     function stacktyp.gimmedata:longint;
     begin gimmedata:=data end;

type stackltyp = object (listentyp)
                        function pop:stackp;
                 end;
     function stackltyp.pop:stackp;
     begin pop:=stackp(inherited pop) end;

var stack:stackltyp;
    data:stackp;
    i:integer;
begin
     stack.init;
     for i:=1 to 10 do
         stack.push(new(stackp, init(i)));

     repeat
           data:=stack.pop;
           writeln(data^.gimmedata);
           data^.done;
           dispose(data);
     until stack.get=nil;

end.