unit rt_objects;
INTERFACE
uses crt,rt_math,rt_noisef;
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
     RT_object = OBJECT
                       ka,kd,ks:real;
                       color:RT_color;
                       specular_color:RT_color;
                       phong_value:real;
                       ior:real;
                       reflection_value,refraction_value:real;
                       colproc:RT_colorproc;
                       destructor done;
                       procedure initmat(c1,c2:RT_color; k1,k2,k3,p,refl,refr:real; iior:real);
                       procedure compute_normal( intersection:RT_point;
                                                 var normal:RT_normal)
                                                 ; virtual;
                       function intersect(ray:RT_ray; var p:RT_point; var t:real):boolean; virtual;
                       procedure transform(alpha,beta,gamma:real; d:rt_vector; s:real);
                 END;
     RT_obj_quadric_p = ^RT_obj_quadric;
     RT_obj_quadric = OBJECT (RT_object)
                             C:RT_coeff_type;
                             constructor init(ic:RT_coeff_type; c1,c2:RT_color; refl,refr,ika,ikd,iks,phongv,iior:real);
                             procedure compute_normal( intersection:RT_point;
                                                     var normal:RT_normal)
                                                     ; virtual;
                             function intersect(ray:RT_ray; var p:RT_point; var t:real):boolean; virtual;
                      end;
     RT_obj_kugel_p = ^RT_obj_kugel;
     RT_obj_Kugel = OBJECT (RT_object)
                           center:RT_point;
                           radius,square_radius:real;
                           destructor done;
                           constructor init(icentr:RT_point; r:real; c1,c2:RT_color; refl,refr,ika,ikd,iks,phongv,iior:real);
                           procedure compute_normal( intersection:RT_point;
                                                     var normal:RT_normal)
                                                     ; virtual;
                           function intersect(ray:RT_ray; var p:RT_point; var t:real):boolean; virtual;
                    end;
(*     RT_obj_zylz_p = ^RT_obj_zylz;
     RT_obj_zylz = OBJECT (RT_object)
                           center:RT_point;
                           radius,square_radius:real;
                           destructor done;
                           constructor init(icentr:RT_point; r:real; c1,c2:RT_color; refl,refr,ika,ikd,iks,phongv,iior:real);
                           procedure compute_normal( intersection:RT_point;
                                                     var normal:RT_normal)
                                                     ; virtual;
                           function intersect(ray:RT_ray; var p:RT_point; var t:real):boolean; virtual;
                    end;
     RT_obj_zyly_p = ^RT_obj_zyly;
     RT_obj_zyly = OBJECT (RT_object)
                           center:RT_point;
                           radius,square_radius:real;
                           destructor done;
                           constructor init(icentr:RT_point; r:real; c1,c2:RT_color; refl,refr,ika,ikd,iks,phongv,iior:real);
                           procedure compute_normal( intersection:RT_point;
                                                     var normal:RT_normal)
                                                     ; virtual;
                           function intersect(ray:RT_ray; var p:RT_point; var t:real):boolean; virtual;
                    end;
     RT_obj_zylx_p = ^RT_obj_zylx;
     RT_obj_zylx = OBJECT (RT_object)
                           center:RT_point;
                           radius,square_radius:real;
                           destructor done;
                           constructor init(icentr:RT_point; r:real; c1,c2:RT_color; refl,refr,ika,ikd,iks,phongv,iior:real);
                           procedure compute_normal( intersection:RT_point;
                                                     var normal:RT_normal)
                                                     ; virtual;
                           function intersect(ray:RT_ray; var p:RT_point; var t:real):boolean; virtual;
                    end;
*)
(*     RT_obj_cube_p = ^RT_obj_cube;
     RT_obj_cube = OBJECT (RT_object)
                           a:real;
                           destructor done;
                           constructor init(ia:real; c1,c2:RT_color; refl,refr,ika,ikd,iks,phongv,iior:real);
                           procedure compute_normal( intersection:RT_point;
                                                     var normal:RT_normal)
                                                     ; virtual;
                           function intersect(ray:RT_ray; var p:RT_point; var t:real):boolean; virtual;
                    end;*)
     RT_obj_plane_p =^rt_obj_plane;
     RT_obj_plane = OBJECT (RT_Object)
                           point:RT_point;
                           normale:RT_vector;
                           constructor init(p:rt_point; n:rt_vector; c1,c2:RT_color; refl,refr,ika,ikd,iks,phongv,iior:real);
                           procedure compute_normal( intersection:RT_point;
                                                     var normal:RT_normal)
                                                     ; virtual;
                           function intersect(ray:RT_ray; var p:RT_point; var t:real):boolean; virtual;
                    end;
     RT_obj_plane2_p =^rt_obj_plane2;
     RT_obj_plane2 = OBJECT (RT_Object)
                           a,b,c,d:real;
                           pa,pb,pc:RT_point;
                           normale:RT_vector;
                           constructor init(ia,ib,ic:rt_point; c1,c2:RT_color; refl,refr,ika,ikd,iks,phongv,iior:real);
                           procedure compute_normal( intersection:RT_point;
                                                     var normal:RT_normal)
                                                     ; virtual;
                           function intersect(ray:RT_ray; var p:RT_point; var t:real):boolean; virtual;
                    end;
     RT_obj_plane4_p =^rt_obj_plane4;
     RT_obj_plane4 = OBJECT (RT_Object)
                           hilf1,hilf2,hilf3:real;
                           a,b,c:rt_vector;
                           normale:RT_vector;
                           constructor init(ia,ib,ic:rt_vector; c1,c2:RT_color; refl,refr,ika,ikd,iks,phongv,iior:real);
                           procedure compute_normal( intersection:RT_point;
                                                     var normal:RT_normal)
                                                     ; virtual;
                           function intersect(ray:RT_ray; var p:RT_point; var t:real):boolean; virtual;
                    end;
     RT_obj_plane3_p =^rt_obj_plane3;
     RT_obj_plane3 = OBJECT (RT_Object)
                           normale:RT_vector;
                           d:real;
                           constructor init(id:real; c1,c2:RT_color; refl,refr,ika,ikd,iks,phongv,iior:real);
                           procedure compute_normal( intersection:RT_point;
                                                     var normal:RT_normal)
                                                     ; virtual;
                           function intersect(ray:RT_ray; var p:RT_point; var t:real):boolean; virtual;
                    end;
IMPLEMENTATION
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
procedure rt_object.initmat(c1,c2:RT_color; k1,k2,k3,p,refl,refr:real; iior:real);
begin
     color:=c1;
     specular_color:=c2;
     ka:=k1; kd:=k2; ks:=k3; phong_value:=p;
     refraction_value:=refr;
     reflection_value:=refl;
     ior:=iior;
end;
procedure RT_object.compute_normal( intersection:RT_point;
                                    var normal:RT_normal);
begin
end;
function RT_object.intersect(ray:RT_ray; var p:RT_point; var t:real):boolean;
begin
end;
procedure rt_object.transform;
begin
end;
{

                KUGEL

}
constructor RT_obj_kugel.init(icentr:RT_point; r:real; c1,c2:RT_color; refl,refr,ika,ikd,iks,phongv,iior:real);
begin
     center:=icentr;
     radius:=r;
     square_radius:=radius*radius;
     initmat(c1,c2,ika,ikd,iks,phongv,refl,refr,iior);
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
function RT_obj_kugel.intersect(ray:RT_ray; var p:RT_point; var t:real):boolean;
var t1,t2:real;
    hilf:RT_vector;
    a,b,c:real;
begin
     vsub(RT_vector(ray.q),RT_vector(center),hilf);

{
     a:=vdot(ray.v,ray.v);
     b:=2*vdot(ray.v,hilf);
     c:=vdot(hilf,hilf)-square_radius;
}
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

{

                Zylinder z

}
(*
constructor RT_obj_zylz.init(icentr:RT_point; r:real; c1,c2:RT_color; refl,refr,ika,ikd,iks,phongv,iior:real);
begin
     center:=icentr;
     radius:=r;
     square_radius:=radius*radius;
     initmat(c1,c2,ika,ikd,iks,phongv,refl,refr,iior);
end;
destructor RT_obj_zylz.done;
begin
end;
procedure RT_obj_zylz.compute_normal( intersection:RT_point;
                                    var normal:RT_normal);
var hilf:rt_point;
begin
     hilf:=center;
     hilf.z:=intersection.z;
     p2vector(center,intersection,normal);
     vnorm(normal,normal);
end;
function RT_obj_zylz.intersect(ray:RT_ray; var p:RT_point; var t:real):boolean;
var t1,t2:real;
    hilf:RT_vector;
    a,b,c:real;
begin
     a:=sqr(ray.v.x)+sqr(ray.v.y);
     b:=2*(ray.v.x*(ray.q.x-center.x)+
           ray.v.y*(ray.q.y-center.y));
     c:=sqr(ray.q.x-center.y)+
        sqr(ray.q.y-center.y)-
        square_radius;
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

constructor RT_obj_zylx.init(icentr:RT_point; r:real; c1,c2:RT_color; refl,refr,ika,ikd,iks,phongv,iior:real);
begin
     center:=icentr;
     radius:=r;
     square_radius:=radius*radius;
     initmat(c1,c2,ika,ikd,iks,phongv,refl,refr,iior);
end;
destructor RT_obj_zylx.done;
begin
end;
procedure RT_obj_zylx.compute_normal( intersection:RT_point;
                                    var normal:RT_normal);
var hilf:rt_point;
begin
     hilf:=center;
     hilf.x:=intersection.x;
     p2vector(center,intersection,normal);
     vnorm(normal,normal);
end;
function RT_obj_zylx.intersect(ray:RT_ray; var p:RT_point; var t:real):boolean;
var t1,t2:real;
    hilf:RT_vector;
    a,b,c:real;
begin
     a:=sqr(ray.v.z)+sqr(ray.v.y);
     b:=2*(ray.v.z*(ray.q.z-center.z)+
           ray.v.y*(ray.q.y-center.y));
     c:=sqr(ray.q.z-center.y)+
        sqr(ray.q.y-center.y)-
        square_radius;
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

constructor RT_obj_zyly.init(icentr:RT_point; r:real; c1,c2:RT_color; refl,refr,ika,ikd,iks,phongv,iior:real);
begin
     center:=icentr;
     radius:=r;
     square_radius:=radius*radius;
     initmat(c1,c2,ika,ikd,iks,phongv,refl,refr,iior);
end;
destructor RT_obj_zyly.done;
begin
end;
procedure RT_obj_zyly.compute_normal( intersection:RT_point;
                                    var normal:RT_normal);
var hilf:rt_point;
begin
     hilf:=center;
     hilf.y:=intersection.y;
     p2vector(center,intersection,normal);
     vnorm(normal,normal);
end;
function RT_obj_zyly.intersect(ray:RT_ray; var p:RT_point; var t:real):boolean;
var t1,t2:real;
    hilf:RT_vector;
    a,b,c:real;
begin
     a:=sqr(ray.v.x)+sqr(ray.v.z);
     b:=2*(ray.v.x*(ray.q.x-center.x)+
           ray.v.z*(ray.q.z-center.z));
     c:=sqr(ray.q.x-center.z)+
        sqr(ray.q.y-center.z)-
        square_radius;
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
*)
{

                EBENE

}
constructor rt_obj_plane.init(p:RT_point; n:RT_vector; c1,c2:RT_color; refl,refr,ika,ikd,iks,phongv,iior:real);
begin
     point:=p;
     vnorm(n,normale);
     initmat(c1,c2,ika,ikd,iks,phongv,refl,refr,iior);
end;
procedure rt_obj_plane.compute_normal( intersection:RT_point;
                                       var normal:RT_normal);
begin
     normal:=normale;
end;
function rt_obj_plane.intersect(ray:RT_ray; var p:RT_point; var t:real):boolean;
var hilf:rt_vector;
begin
     { t:=( (point-Q) x ray.v) / (normale x ray.v);   => seite 1101 }
     vsub(RT_vector(point),RT_vector(ray.q),hilf);
     t:=vdot(hilf,normale)/vdot(normale,ray.v);
     if errepsilon(t)=0 then begin
        intersect:=false;
     end else begin
         intersect:=true;
         vmul(t,ray.v,hilf);
         vadd(RT_vector(ray.q),hilf,RT_vector(p));
     end;

end;

{                              b
                               ^      a...ortsvektor
                           a   |      b...spannt ebene auf
                EBENE2   ----->*-->c  c...  -- " --

}

constructor rt_obj_plane2.init(ia,ib,ic:RT_point; c1,c2:RT_color; refl,refr,ika,ikd,iks,phongv,iior:real);
var h1,h2:RT_Vector;
begin
     normale:=NULL;
     pa:=ia; pb:=ib; pc:=ic;
     p2vector(pa,pb,h1);
     p2vector(pa,pc,h2);
     vcross(h1,h2,normale);
     a:=normale.x;
     b:=normale.y;
     c:=normale.z;
     d:=-pa.x*a-pa.y*b-pa.z*c;
     writeln(a:3:3,' ',b:3:3,' ',c:3:3,' ',d:3:3);
     repeat until keypressed;
     initmat(c1,c2,ika,ikd,iks,phongv,refl,refr,iior);
end;
procedure rt_obj_plane2.compute_normal( intersection:RT_point;
                                       var normal:RT_normal);
begin
     vnorm(normale,normal);
end;
function rt_obj_plane2.intersect(ray:RT_ray; var p:RT_point; var t:real):boolean;
var hilf:rt_vector;
begin
     t:=-(A*ray.q.x+B*ray.q.y+C*ray.q.z+D)/(a*ray.v.x+b*ray.v.y+c*ray.v.z);
     intersect:=true;
     vmul(t,ray.v,hilf);
     vadd(RT_vector(ray.q),hilf,RT_vector(p));
     t:=errepsilon(t);
     if t=0 then begin
        p:=rt_point(NULL);
        intersect:=false;
     end;
end;

{                              b
                               ^      a...ortsvektor
                           a   |      b...spannt ebene auf
                EBENE4   ----->*-->c  c...  -- " --

                laut buch
}

constructor rt_obj_plane4.init(ia,ib,ic:RT_vector; c1,c2:RT_color; refl,refr,ika,ikd,iks,phongv,iior:real);
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
     vnorm(normale,normale);
     initmat(c1,c2,ika,ikd,iks,phongv,refl,refr,iior);
end;
procedure rt_obj_plane4.compute_normal( intersection:RT_point;
                                       var normal:RT_normal);
begin
     normal:=normale;
end;
function rt_obj_plane4.intersect(ray:RT_ray; var p:RT_point; var t:real):boolean;
var d:real;
begin
     intersect:=false;
     d:=ray.v.y*hilf2-ray.v.x*hilf1-ray.v.z*hilf3;
     d:=errepsilon(d);
     if d<>0 then begin
        t:=((ray.q.x-a.x)*hilf1-(ray.q.y-a.y)*hilf2+(ray.q.z-a.z)*hilf3)/d;
        t:=errepsilon(t);
        intersect:=true;
        ray2point(ray,t,p);
     end else begin
         t:=-1;
     end;
end;

{

                                         -   -         d-Qy
                EBENE3          y:=d; 0:=Q+t*V; => t:= ----;
                                                        Vy
}

constructor rt_obj_plane3.init(id:real; c1,c2:RT_color; refl,refr,ika,ikd,iks,phongv,iior:real);
begin
     d:=id;
     vinit(0,d,0,normale);
     vnorm(normale,normale);
     initmat(c1,c2,ika,ikd,iks,phongv,refl,refr,iior);
end;

procedure rt_obj_plane3.compute_normal( intersection:RT_point;                                       var normal:RT_normal);
begin
     normal:=normale;
end;

function rt_obj_plane3.intersect(ray:RT_ray; var p:RT_point; var t:real):boolean;
begin

     if ray.v.y=0 then begin
        t:=-INFINITY_HIGH;
     end else begin
         t:=(d-ray.q.y)/(ray.v.y);
     end;
     ray2point(ray,t,p);
     intersect:=(p.y-d)<EPSILON;
end;

{

        QUADRIC

}

constructor RT_obj_quadric.init;
begin
     c:=ic;
     initmat(c1,c2,ika,ikd,iks,phongv,refl,refr,iior);
end;
procedure RT_obj_quadric.compute_normal;
begin

end;
function RT_obj_quadric.intersect;
begin

end;
{
        ende OBJECT_prozeduren
}
begin
end.