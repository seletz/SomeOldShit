unit rt_objects;
INTERFACE
uses crt,rt_math;
type RT_colorproc = procedure (obnr:integer; p:rt_point; var c:RT_color);
     RT_camera = OBJECT
                       cop:RT_point;
                       vrz:RT_point;
                       view:RT_rect;
                       minmax:RT_rect;
                       xs,ys,xh,yh:real;
                       ca,sa,cb,sb,alpha,beta:real;
                       destructor done;
                       constructor init(icop,ivrz:RT_point;
                                        ia,ib:real;
                                        ivp:RT_rect;
                                        imm:RT_rect);
                       procedure compute_ray(x,y:integer; var ray:RT_ray);

                 end;
     RT_object_pointer = ^RT_object;
     rt_OList_p = ^rt_olist;
     RT_OList = OBJECT
                      next:rt_olist_p;
                      prev:rt_olist_p;
                      nr:integer;
                      o:rt_object_pointer;
                      constructor init;
                      destructor done;
                      procedure setobj(io:rt_object_pointer);
                      procedure setnr(inr:integer);
                      function addnext : rt_olist_p;
                      function getnext:rt_olist_p;
                      function getit:rt_object_pointer;
                end;
     RT_object = OBJECT
                       ka,kd,ks:real;
                       color:RT_color;
                       specular_color:RT_color;
                       phong_value:real;
                       ior:real;
                       reflection_value,refraction_value:real;
                       texture:integer;
                       destructor done;
                       procedure initmat(c1,c2:RT_color; k1,k2,k3,p,refl,refr:real; iior:real; itext:integer);
                       procedure compute_normal( intersection:RT_point;
                                                 var normal:RT_normal)
                                                 ; virtual;
                       function intersect(ray:RT_ray; tiefe:integer; var p:RT_point; var t:real):boolean; virtual;
                       procedure transform(alpha,beta,gamma:real; d:rt_vector; s:real); virtual;
                 END;
     RT_obj_kugel_p = ^RT_obj_kugel;
     RT_obj_Kugel = OBJECT (RT_object)
                           center:RT_point;
                           radius,square_radius:real;
                           destructor done;
                           constructor init(icentr:RT_point; r:real; c1,c2:RT_color; refl,refr,ika,ikd,iks,phongv,iior:real;
                                            itext:integer);
                           procedure compute_normal( intersection:RT_point;
                                                     var normal:RT_normal)
                                                     ; virtual;
                           function intersect(ray:RT_ray; tiefe:integer; var p:RT_point; var t:real):boolean; virtual;
                           procedure transform(alpha,beta,gamma:real; d:rt_vector; s:real); virtual;

                    end;

     RT_obj_plane4_p =^rt_obj_plane4;
     RT_obj_plane4 = OBJECT (RT_Object)
                           hilf1,hilf2,hilf3:real;
                           a,b,c:rt_vector;
                           normale:RT_vector;
                           constructor init(ia,ib,ic:rt_vector; c1,c2:RT_color; refl,refr,ika,ikd,iks,phongv,iior:real;
                                            itext:integer);
                           procedure compute_normal( intersection:RT_point;
                                                     var normal:RT_normal)
                                                     ; virtual;
                           function intersect(ray:RT_ray; tiefe:integer; var p:RT_point; var t:real):boolean; virtual;
                           procedure transform(alpha,beta,gamma:real; d:rt_vector; s:real); virtual;
                    end;
     RT_obj_para_p =^rt_obj_para;
     RT_obj_para = OBJECT (RT_obj_plane4)
                           function intersect(ray:RT_ray; tiefe:integer; var p:RT_point; var t:real):boolean; virtual;
                    end;
     RT_obj_dreieck_p =^rt_obj_dreieck;
     RT_obj_dreieck = OBJECT (RT_obj_plane4)
                           function intersect(ray:RT_ray; tiefe:integer; var p:RT_point; var t:real):boolean; virtual;
                    end;
     RT_obj_kreis_p =^rt_obj_kreis;
     RT_obj_kreis = OBJECT (RT_obj_plane4)
                           function intersect(ray:RT_ray; tiefe:integer; var p:RT_point; var t:real):boolean; virtual;
                    end;
IMPLEMENTATION
{



        LISTEN_prozeduren



}
constructor rt_OList.init;
begin
     prev:=nil;
     next:=nil;
     o:=nil;
     nr:=-1;
end;
destructor rt_OList.done;
begin
     if next<>nil then
        begin
             writeln('->');
             next^.done;
             writeln('KILL next');
             dispose(next);
        end;
     writeln('KILL obj');
     dispose(o);
end;
function rt_OList.addnext: rt_olist_p;
begin
     next:=new(rt_olist_p,init);
     next^.prev:=@self;
     addnext:=next;
end;
procedure rt_OList.setnr(inr:integer);
begin nr:=inr end;
procedure rt_OList.setobj(io:rt_object_pointer);
begin o:=io end;
function rt_OList.getnext:rt_OList_p;
begin
     getnext:=next;
end;
function rt_OList.getit:rt_object_pointer;
begin
     getit:=o;
end;
{



        OBJECT_prozeduren



}
destructor RT_camera.done;
begin end;
constructor RT_camera.init( icop,ivrz:RT_point;
                  ia,ib:real;
                  ivp:RT_rect;
                  imm:RT_rect);
begin
     alpha:=ia; beta:=ib;
     ca:=cos(alpha*RAD); sa:=sin(alpha*RAD);
     sb:=sin(beta*RAD);  cb:=cos(beta*RAD);
     cop:=icop; vrz:=ivrz; view:=ivp; minmax:=imm;
     xs:=(view.p2.x-view.p1.x)/(minmax.p2.x-minmax.p1.x);
     ys:=(view.p2.y-view.p1.y)/(minmax.p2.y-minmax.p1.y);
     xh:=xs*(minmax.p2.x-minmax.p1.x)/2;
     yh:=ys*(minmax.p2.y-minmax.p1.y)/2;
end;
procedure rt_camera.compute_ray(x,y:integer; var ray:RT_ray);
var p:RT_point;
begin
     p.x:=(x*xs-xh)+vrz.x;
     p.y:=(y*ys-yh)+vrz.y;
     p.z:=vrz.z;

     p2ray(cop,p,ray);
end;

destructor RT_object.done;
begin
     Writeln('Fehler: RT_object.done(); wurde aufgerufen!');
     halt(10);
end;
procedure rt_object.initmat;
begin
     color:=c1;
     specular_color:=c2;
     ka:=k1; kd:=k2; ks:=k3; phong_value:=p;
     refraction_value:=refr;
     reflection_value:=refl;
     ior:=iior;
     texture:=itext;
end;
procedure RT_object.compute_normal( intersection:RT_point;
                                    var normal:RT_normal);
begin
end;
function RT_object.intersect(ray:RT_ray; tiefe:integer; var p:RT_point; var t:real):boolean;
begin
end;
procedure rt_object.transform;
begin
end;

{

                KUGEL

}
constructor RT_obj_kugel.init;
begin
     center:=icentr;
     radius:=r;
     square_radius:=radius*radius;
     initmat(c1,c2,ika,ikd,iks,phongv,refl,refr,iior,itext);
end;
destructor RT_obj_kugel.done;
begin
end;
procedure RT_obj_kugel.compute_normal( intersection:RT_point;
                                    var normal:RT_normal);
begin
     p2vector(center,intersection,normal);
     vnorm(normal,normal);
end;
procedure rt_obj_kugel.transform;
begin
     trans(center,alpha,beta,gamma,center);

     vadd(d,rt_vector(center),rt_vector(center));

     square_radius:=sqr(sqrt(square_radius)*s);
end;
function RT_obj_kugel.intersect(ray:RT_ray; tiefe:integer; var p:RT_point; var t:real):boolean;
var t1,t2:real;
    hilf:RT_vector;
    a,b,c:real;
begin
     vsub(RT_vector(ray.q),RT_vector(center),hilf);
     a:=sqr(ray.v.x)+sqr(ray.v.y)+sqr(ray.v.z);
     b:=2*(ray.v.x*(ray.q.x-center.x)+
            ray.v.y*(ray.q.y-center.y)+
            ray.v.z*(ray.q.z-center.z));;
     c:= sqr(ray.q.x-center.x)+
         sqr(ray.q.y-center.y)+
         sqr(ray.q.z-center.z)- square_radius;;

     if RT_solve_qglabc(a,b,c,t1,t2) then
        begin
             t1:=min3real(t1,t2,INFINITY_HIGH);
             intersect:=true;
             vmul(t1,ray.v,hilf);
             vadd(RT_vector(ray.q),hilf,RT_vector(p));
             t:=errepsilon(t1);
             if t=0 then begin
                intersect:=false;
             end;
        end
     else
        begin
             intersect:=false;
             t:=0;
        end;

end;


{                              b
                               ^      a...ortsvektor
                           a   |      b...spannt ebene auf
                EBENE4   ----->*-->c  c...  -- " --

                laut buch
}

constructor rt_obj_plane4.init;
var h1,h2:RT_Vector;
begin
     hilf1:=det2( ib.y,ic.y,
                  ib.z,ic.z);
     hilf2:=det2( ib.x,ic.x,
                  ib.z,ic.z);
     hilf3:=det2( ib.x,ic.x,
                  ib.y,ic.y);
     a:=ia; b:=ib; c:=ic;
     vcross(b,c,normale);
     (*vnorm(inorm,normale);*)
     initmat(c1,c2,ika,ikd,iks,phongv,refl,refr,iior,itext);
end;
procedure rt_obj_plane4.transform;
begin
     trans(rt_point(a),alpha,beta,gamma,rt_point(a));
     trans(rt_point(b),alpha,beta,gamma,rt_point(b));
     trans(rt_point(c),alpha,beta,gamma,rt_point(c));

     vadd (d,a,a);
     vmul (s,a,a);
     vcross(b,c,normale);
     vnorm(normale,normale);
end;
procedure rt_obj_plane4.compute_normal( intersection:RT_point;
                                       var normal:RT_normal);
begin
     normal:=normale;
end;
function rt_obj_plane4.intersect(ray:RT_ray; tiefe:integer; var p:RT_point; var t:real):boolean;
var d:real;
begin
     intersect:=false;
     d:=ray.v.y*hilf2-ray.v.x*hilf1-ray.v.z*hilf3;
     d:=errepsilon(d);
     if d<>0 then begin
        t:=((ray.q.x-a.x)*hilf1-(ray.q.y-a.y)*hilf2+(ray.q.z-a.z)*hilf3)/d;
        t:=errepsilon(t);
        intersect:=(t>0);
        ray2point(ray,t,p);
     end else begin
         t:=-1;
     end;
end;
function rt_obj_para.intersect(ray:RT_ray; tiefe:integer; var p:RT_point; var t:real):boolean;
var d:real;
    r,s:real;
    Q,V:rt_vector;
begin
     q:=rt_vector(ray.q);
     v:=rt_vector(ray.v);
     intersect:=false;
     d:=v.y*hilf2-v.x*hilf1-v.z*hilf3;
     d:=errepsilon(d);
     if d<>0 then begin
        t:=((q.x-a.x)*hilf1-(q.y-a.y)*hilf2+(q.z-a.z)*hilf3)/d;
        t:=errepsilon(t);
        intersect:=(t>0);
        ray2point(ray,t,p);
        r:=det3( q.x-a.x,c.x,-v.x,
                 q.y-a.y,c.y,-v.y,
                 q.y-a.y,c.y,-v.y)/d;
        s:=det3( c.x,q.x-a.x,-v.x,
                 c.y,q.y-a.y,-v.y,
                 c.z,q.z-a.z,-v.z)/d;

        if (r<0) or (s<0) or (r>1) or (s>1) then
           intersect:=false;
     end else begin
         t:=-1;
     end;
end;
function rt_obj_dreieck.intersect(ray:RT_ray; tiefe:integer; var p:RT_point; var t:real):boolean;
var d:real;
    r,s:real;
    Q,V:rt_vector;
begin
     q:=rt_vector(ray.q);
     v:=rt_vector(ray.v);
     intersect:=false;
     d:=v.y*hilf2-v.x*hilf1-v.z*hilf3;
     d:=errepsilon(d);
     if d<>0 then begin
        t:=((q.x-a.x)*hilf1-(q.y-a.y)*hilf2+(q.z-a.z)*hilf3)/d;
        t:=errepsilon(t);
        intersect:=(t>0);
        ray2point(ray,t,p);
        r:=det3( q.x-a.x,c.x,-v.x,
                 q.y-a.y,c.y,-v.y,
                 q.y-a.y,c.y,-v.y)/d;
        s:=det3( c.x,q.x-a.x,-v.x,
                 c.y,q.y-a.y,-v.y,
                 c.z,q.z-a.z,-v.z)/d;

        if (r<0) or (s<0) or (r>1) or (s>1) or (r+s>1) then
           intersect:=false;
     end else begin
         t:=-1;
     end;
end;
function rt_obj_kreis.intersect(ray:RT_ray; tiefe:integer; var p:RT_point; var t:real):boolean;
var d:real;
    r,s:real;
    Q,V:rt_vector;
begin
     q:=rt_vector(ray.q);
     v:=rt_vector(ray.v);
     intersect:=false;
     d:=v.y*hilf2-v.x*hilf1-v.z*hilf3;
     d:=errepsilon(d);
     if d<>0 then begin
        t:=((q.x-a.x)*hilf1-(q.y-a.y)*hilf2+(q.z-a.z)*hilf3)/d;
        t:=errepsilon(t);
        intersect:=(t>0);
        ray2point(ray,t,p);
        r:=det3( q.x-a.x,c.x,-v.x,
                 q.y-a.y,c.y,-v.y,
                 q.y-a.y,c.y,-v.y)/d;
        s:=det3( c.x,q.x-a.x,-v.x,
                 c.y,q.y-a.y,-v.y,
                 c.z,q.z-a.z,-v.z)/d;

        if (r*r+s*s>1) then
           intersect:=false;
     end else begin
         t:=-1;
     end;
end;

begin
end.