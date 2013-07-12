unit liste;
INTERFACE
type nodep = ^nodetyp;
     nodetyp = object
                     next,prev:nodep;
                     constructor init;
                     destructor done;
               end;
     listentyp = object
                       first,last,actual:nodep;
                       constructor init;
                       destructor done;
                       procedure insert(insnode:nodep);
                       procedure delete(delnode:nodep);
                       procedure push(pushnode:nodep);
                       function pop:nodep;
                       procedure append(appnode:nodep);
                       function remove:nodep;
                       procedure next;
                       procedure prev;
                       procedure setfirst;
                       procedure setlast;
                       function isfirst:boolean;
                       function islast:boolean;
                 end;
IMPLEMENTATION

     constructor nodetyp.init;
     begin next:=nil; prev:=nil end;
     destructor nodetyp.done;
     begin end;

     constructor listentyp.init;
     begin
          actual:=nil;
          last:=actual;
          first:=actual;
     end;
     destructor listentyp.done;
     var temp:nodep;
     begin
          actual:=last;
          while not (first=last) do begin
                delete(actual);
          end;
          delete(first);
     end;
     procedure listentyp.insert;
     begin
          if first=last then begin
             insnode^.prev:=actual;
             actual^.next:=insnode;
             last:=insnode;
             first:=insnode;
             actual:=insnode;
          end else if last=actual then begin
              actual^.next:=insnode;
              insnode^.prev:=actual;
              actual:=insnode;
              last:=actual;
          end else begin
              insnode^.next:=actual^.next;
              insnode^.prev:=actual;
              actual^.next:=insnode;
              insnode^.next^.prev:=insnode;
              actual:=insnode;
          end;
     end;
     procedure listentyp.delete;
     begin
          if first=last then begin
             {
                Erste Node nixta l”schta!!
             }
          end else if last=delnode then begin
              if actual=delnode then actual:=delnode^.prev;
              last:=delnode^.prev;
              delnode^.prev^.next:=nil;
              delnode^.done;
              dispose(delnode);
          end else begin
              if actual=delnode then actual:=delnode^.prev;
              delnode^.prev^.next:=delnode^.next;
              delnode^.next^.prev:=delnode^.prev;
              delnode^.done;
              dispose(delnode);
          end;
     end;
     procedure listentyp.push;
     begin
          pushnode^.next:=first;
          first^.prev:=pushnode;
          first:=pushnode;
     end;
     function listentyp.pop:nodep;
     begin
          pop:=first;
          first:=first^.next;
          first^.prev^.next:=nil;
          first^.prev:=nil;
     end;
     procedure listentyp.append;
     begin
          last^.next:=appnode;
          appnode^.prev:=last;
          last:=appnode;
     end;
     function listentyp.remove:nodep;
     begin
          remove:=last;
          last:=last^.prev;
          last^.next^.prev:=nil;
          last^.next:=nil;
     end;
     procedure listentyp.next;
     begin
          if actual<>last then actual:=actual^.next;
     end;
     procedure listentyp.prev;
     begin
          if actual<>first then actual:=actual^.prev;
     end;
     procedure listentyp.setfirst;
     begin actual:=first end;
     procedure listentyp.setlast;
     begin actual:=last end;
     function listentyp.islast:boolean;
     begin islast:=actual=last end;
     function listentyp.isfirst:boolean;
     begin isfirst:=actual=first end;
begin
end.