program rec_tra_ofl;
uses app;
type rec_tra_ofl_p = ^rec_tra_ofl_typ;
     rec_tra_ofl_typ = OBJECT(TApplication)
     end;
var ofl:rec_tra_ofl_typ;
begin
     ofl.init;
     ofl.run;
     ofl.done;
end.