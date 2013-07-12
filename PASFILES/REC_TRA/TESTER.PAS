program tester;
uses crt,graph,sgraph,rt_types,rt_math,rt_objects,rt_lists,rt_textures;
var r:rt_ray;
    k:rt_obj_kugel_p;
    e:rt_obj_plane_p;
    p:rt_obj_XYPlane_p;

    m:rt_mlist;

    mittelpunkt,s:rt_point;
    n:rt_normal;

    t:double;

    hit:boolean;
begin
     clrscr;
     pinit(0,10,10,r.q);
     vinit(0,-1,-1,r.v);
     writeray('r:',r);

     init_std_text(m);

     pinit(0,10,0,mittelpunkt);
     k:=new(rt_obj_kugel_p,init(mittelpunkt,1,m.getbyname('sp'),'Kugel'));
{     e:=new(rt_obj_kugel_p,init(mittelpunkt,1,m.getbyname('sp'),'Kugel'));}
     p:=new(rt_obj_XYplane_p,init(0,m.getbyname('sp'),'Plane'));

     hit:=k^.intersect(r,1,s,t);
     k^.compute_normal(s,n);

     if hit then begin
        writeln('KUGEL');
        writeln('hit:=',hit);
        write1r('t:=',t);
        writepoint('S',s);
        writevector('Normale',n);
     end else begin
        writeln('KUGEL');
        writeln('hit:=',hit);
     end;
     writeln;

     hit:=p^.intersect(r,1,s,t);
     p^.compute_normal(s,n);

     if hit then begin
        writeln(p^.obj_name);
        writeln('hit:=',hit);
        write1r('t:=',t);
        writepoint('S',s);
        writevector('Normale',n);
     end else begin
        writeln(p^.obj_name);
        writeln('hit:=',hit);
     end;

     if k<>nil then dispose(k);
     if e<>nil then dispose(e);
     if p<>nil then dispose(p);

     readln;
end.