unit rt_Lights;
INTERFACE
uses rt_types,rt_Lists,rt_math;
type
     rt_light_p=^rt_light;
     rt_llist = object (rt_list)
                       function get_light:rt_light_p;
                       procedure insert(insnode:rt_light_p);
                end;
     RT_light = object(rt_obase)
                      position:RT_point;
                      ambient_intensity:double;
                      diffuse_intensity:double;
                      Ia,Ip:RT_color;
                      point_at:rt_vector;
                      cos_alpha:double;
                      p:integer;
                      spot:boolean;
                      name:string;
                      constructor init( ipos,ipointat:rt_point; iia:double; iamb:rt_color; iid:double; idiff:rt_color;
                                        icosalpha:double; ipp:integer; ispot:boolean; iname:string);
                end;

IMPLEMENTATION
function rt_llist.get_light:rt_light_p;
begin
     get_light:=rt_light_p(rt_list.get);
end;
procedure rt_llist.insert;
begin
     rt_list.insert(insnode);
end;
constructor rt_light.init;
begin
     ia:=iamb;
     ip:=idiff;
     ambient_intensity:=iia;
     diffuse_intensity:=iid;
     p:=ipp;
     cos_alpha:=icosalpha;
     position:=ipos;
     p2vector(position,ipointat,point_at);
     vnorm(point_at,point_at);
     spot:=ispot;
     name:=iname;
end;

begin
end.
