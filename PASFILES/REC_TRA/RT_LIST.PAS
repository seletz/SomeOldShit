unit rt_lists;
{ Letzte Žnderung: xx.xx.1994 }
INTERFACE
uses rt_types;
type
     rt_node_p =^rt_node;
     rt_node = object (rt_obase)
                      prev,next:rt_node_p;
                      constructor init;
               end;

     rt_list_p=^rt_list;
     RT_List = OBJECT(rt_obase)
                      actual:rt_node_p;
                      first:rt_node_p;
                      length:longint;
                      constructor init;
                      destructor done; virtual;
                      function isempty:boolean;
                      function get:rt_node_p;
                      procedure insert(insnode:rt_node_p);
                      procedure delete(var delnode:rt_node_p);
                      procedure prev;
                      procedure next;
                      procedure setfirst;
                end;

IMPLEMENTATION
constructor rt_node.init;
begin
     next:=nil;
     prev:=nil
end;

constructor rt_List.init;
begin
     actual:=nil;
     length:=0;
end;
destructor rt_list.done;
var
   nodeptr:rt_node_p;
begin
     while not isempty do
           begin
                delete(nodeptr);
                dispose(nodeptr, done);
           end
end;
function rt_list.isempty:boolean;
begin
     isempty:= actual = nil;
end;
function rt_list.get:rt_node_p;
begin get:=actual end;
procedure rt_list.insert;
begin
     if insnode<>nil then begin
        if not isempty then
        begin
             insnode^.prev:=actual^.prev;
             insnode^.next:=actual;
             actual^.prev^.next:=insnode;
             actual^.prev:=insnode;
        end
        else begin
             insnode^.next:=insnode;
             insnode^.prev:=insnode;
             first:=insnode;
        end;
        actual:=insnode;
        inc(length);
     end;
end;
procedure rt_list.delete;
begin
     if not isempty then
     begin
          delnode:=actual;
          if actual^.next=actual then
             actual:=nil
          else begin
               actual:=actual^.next;
               delnode^.prev^.next:=delnode^.next;
               delnode^.next^.prev:=delnode^.prev;
          end;
          dec(length);
     end
end;
procedure rt_list.prev;
begin
     if not isempty then
        actual:=actual^.prev;

end;
procedure rt_list.next;
begin
     if not isempty then
        actual:=actual^.next;

end;
procedure rt_list.setfirst;
begin actual:=first end;
begin
end.