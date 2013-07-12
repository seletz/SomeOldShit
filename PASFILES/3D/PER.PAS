program per;
uses crt,rt_types,matrix,graph,sgraph;
type
        view = object
                     t:tm4x4;
                     vpn,vup,cop:tv1x3;
                     constructor init(ivup,ivpn,icop:tv1x3);
               end;

constructor view.init;
var rx,ry,rz:tv1x4;
begin
     vup:=ivup;
     vpn:=ivpn;
     cop:=icop;

     vnorm(vpn,rz);
     vcross(vup,rz,rx);
     vnorm(rx,rx);
     vcross(rz,rx,ry);
     t:=e4;

end;
begin
end.
