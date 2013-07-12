program listtest;
uses crt,ste,liste;
type datap = ^datatyp;
     datatyp = object (nodetyp)
                   data:string;
                   constructor init(idata:string);
                   procedure setdata(idata:string);
                   function gimmedata:string;
            end;
     constructor datatyp.init;
     begin
          inherited init;
          data:=idata;
     end;
     procedure datatyp.setdata;
     begin data:=idata; end;
     function datatyp.gimmedata:string;
     begin gimmedata:=data; end;

type stringlisttyp = object (listentyp)
                         (* constructor init(firstnode:datap);
                         procedure insert(insdata:datap);
                         procedure delete(deldata:datap);*)
                         function get:datap;
                  end;
     function stringlisttyp.get:datap;
     begin
          get:=datap ( actual );
     end;

var  sl:stringlisttyp;
     np:datap;
     i:integer;
begin
     clrscr;
     writeln('Testprogram zur Unit ''LISTE.TPU''');
     writeln;
     write('Init...');
     sl.init(new(datap,init('Erste Node')));
     for i:=ord('A') to ord('F') do begin
         sl.insert(new(datap, init(chr(i))));
         if i=ord('B') then np:=sl.get;
     end;
     writeln('done.');
     writeln; write('Ausgabe:');
     sl.setfirst;
     repeat
           write(sl.get^.gimmedata);
           sl.next;
     until sl.islast;
     sl.setlast;
     repeat
           write(sl.get^.gimmedata);
           sl.prev;
     until sl.isfirst;
     writeln('..Ok.');

     writeln; write('Node B l”schen...');
     writeln('Ok.');
     sl.delete(np);
     writeln; write('Ausgabe:');
     sl.setfirst;
     repeat
           write(sl.get^.gimmedata);
           sl.next;
     until sl.islast;
     sl.setlast;
     repeat
           write(sl.get^.gimmedata);
           sl.prev;
     until sl.isfirst;
     writeln('..Ok.');

     writeln; write('Letze Node l”schen...');
     writeln('Ok.');
     sl.setlast;
     sl.delete(sl.get);
     writeln; write('Ausgabe:');
     sl.setfirst;
     repeat
           write(sl.get^.gimmedata);
           sl.next;
     until sl.islast;
     sl.setlast;
     repeat
           write(sl.get^.gimmedata);
           sl.prev;
     until sl.isfirst;
     writeln('..Ok.');
     writeln; write('Speicher freigeben...');
     sl.done;
     writeln('Ok.');
     waittast;
end.