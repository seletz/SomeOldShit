Unit listeun;

Interface

Type
  p_liste = ^o_liste;
  o_liste = Object
              actual: p_liste;
              first: p_liste;
              next: p_liste;

              data:pointer;

              number:integer;
              count:integer;

              Constructor init;
              Destructor done; virtual;

              Function insert_new(idata:pointer): p_liste;
              Function setfirst: p_liste;

              Function gimme_actual: pointer;
              Function gimme_next: pointer;
            End;

Implementation

Constructor o_liste. init;
Begin
  actual := @self;
  first := @self;
  next := Nil;
  number:=0;
  count:=0;
End;
Destructor o_liste. done;
Var
  temp: p_liste;
Begin
  If first^. next = Nil Then Exit;

  setfirst;

  actual:=actual^.next;

  while not (actual=nil) do
  begin
    temp := actual^.next;
    if temp<>nil then Dispose (actual);
    actual := temp;
  end
End;
Function o_liste. insert_new(idata:pointer): p_liste;
Var
  temp: p_liste;
Begin
  inc(count);
  If actual^. next = Nil Then
  Begin
    New (actual^. next, init );
  End Else Begin
    temp := actual^. next;
    New (actual^. next, init );
    actual^. next^. next := temp;
  End;
  actual:=actual^.next;
  actual^.count:=count;
  actual^.number:=count;
  actual^.data:=idata;
  insert_new:=actual;
End;
Function o_liste. setfirst: p_liste;
begin
     actual:=first;
     setfirst:=actual;
end;
Function o_liste. gimme_actual: pointer;
begin
  gimme_actual:=actual^.data;
end;
Function o_liste. gimme_next: pointer;
begin
    actual:=actual^.next;
    if actual<>nil then
    gimme_next:=actual^.data
    else
    gimme_next:=nil;
end;

Procedure list_error (s: String);
Begin
  WriteLn ('Fehler in Unit "liste" :' + chr($07));
  WriteLn;
  WriteLn (s);
  Halt (1);
end;

Begin

End.