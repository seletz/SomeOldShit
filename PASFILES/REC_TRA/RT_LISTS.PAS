unit rt_lists;
INTERFACE
uses rt_types;
type
     rt_list_p=^rt_list;
     RT_List = OBJECT(rt_obase)
                      actual:rt_obase_p;
                      first:rt_obase_p;
                      length:longint;
                      constructor init;
                      destructor done; virtual;
                      function isempty:boolean;
                      function get:rt_obase_p;
                      procedure insert(insnode:rt_obase_p);
                      procedure delete(var delnode:rt_obase_p);
                      procedure prev;
                      procedure next;
                      procedure setfirst;
                end;

IMPLEMENTATION

constructor rt_List.init;
begin
     actual:=nil;
     length:=0;
end;
destructor rt_list.done;
var
   nodeptr:rt_obase_p;
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
function rt_list.get:rt_obase_p;
begin get:=actual end;
procedure rt_list.insert;
begin
     if insnode<>nil then begin
        if not isempty then
        begin
             insnode^.prev_obj:=actual^.prev_obj;
             insnode^.next_obj:=actual;
             actual^.prev_obj^.next_obj:=insnode;
             actual^.prev_obj:=insnode;
        end
        else begin
             insnode^.next_obj:=insnode;
             insnode^.prev_obj:=insnode;
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
          if actual^.next_obj=actual then
             actual:=nil
          else begin
               actual:=actual^.next_obj;
               delnode^.prev_obj^.next_obj:=delnode^.next_obj;
               delnode^.next_obj^.prev_obj:=delnode^.prev_obj;
          end;
          dec(length);
     end
end;
procedure rt_list.prev;
begin
     if not isempty then
        actual:=actual^.prev_obj;

end;
procedure rt_list.next;
begin
     if not isempty then
        actual:=actual^.next_obj;

end;
procedure rt_list.setfirst;
begin actual:=first end;
begin
end.