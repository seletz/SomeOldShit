unit liste;
{******************************
 ******************************
 ******                  ******
 *****  Verkettete Liste  *****
 ******                  ******
 ******************************
 ******************************
}
INTERFACE
type nodep =^nodet;
     nodet = object
                   number:longint;
                   next,prev:nodep;
                   constructor init;
                   destructor done;
             end;

     listp =^listt;
     listt = object
                   anzahl,laufende_nr:longint;
                   actual,first,last:nodep;
                   constructor init;
                   destructor done;
                   procedure insert(insnode:nodep);
                   procedure delete;
                   procedure next;
                   procedure prev;
                   procedure setfirst;
                   procedure setlast;
                   function get:nodep;
                   function is_last:boolean;
                   function is_first:boolean;
             end;

IMPLEMENTATION

     constructor nodet.init;
     begin
          number:=0;
          next:=nil;
          prev:=nil;
     end;
     destructor nodet.done;
     begin
     end;

     constructor listt.init;
     begin
          new(actual, init);
          actual^.next:=actual;
          actual^.prev:=actual;

          first:=actual;
          last:=actual;

          anzahl:=1;
          laufende_nr:=1;
          actual^.number:=laufende_nr;
     end;
     destructor listt.done;
     var temp:nodep;
     begin
          actual:=last;
          while not (last=first) do
          begin
               temp:=actual^.prev;
               temp^.next:=temp;
               actual^.done;
               dispose(actual);
               actual:=temp;
               last:=actual;
          end;
          first^.done;
          dispose(first);
     end;
     procedure listt.delete;
     var temp:nodep;
     begin
          if actual<>first then begin
             temp:=actual^.next;
             actual^.prev^.next:=temp;
             temp^.prev:=actual^.prev;
             actual^.done;
             dispose(actual);
             actual:=temp;
          end;
          dec(anzahl);
     end;
     procedure listt.insert(insnode:nodep);
     begin
          if first=last then begin

          end else if last=actual then begin
              writelN('oink');
              last:=insnode;
              actual^.next:=insnode;
              insnode^.prev:=actual;
              insnode^.next:=insnode;
          end else begin
              insnode^.prev:=actual;
              insnode^.next:=actual^.next;
              insnode^.next^.prev:=insnode;
              actual^.next:=insnode;
          end;
          inc(anzahl);
          inc(laufende_nr);
          actual^.number:=laufende_nr;
          actual:=insnode;
     end;
     procedure listt.next;
     begin actual:=actual^.next end;
     procedure listt.prev;
     begin actual:=actual^.prev end;
     procedure listt.setfirst;
     begin actual:=first end;
     procedure listt.setlast;
     begin actual:=last end;
     function listt.get:nodep;
     begin get:=actual end;
     function listt.is_first:boolean;
     begin is_first:=first=actual end;
     function listt.is_last:boolean;
     begin is_last:=last=actual end;

begin
end.