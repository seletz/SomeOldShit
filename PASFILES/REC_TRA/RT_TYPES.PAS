unit rt_types;
{
**************************************************************************
**************************************************************************
**************************************************************************
*********************         * ***** ***    ***    * **** ***************
************************* ****** *** **** *** ** ****  *** ***************
************************* ******* * ***** *** **    * * ** ***************
************************* ******** ******    *** **** ** * ***************
************************* ******** ****** ****** **** ***  ***************
************************* ******** ****** ******    * **** ***************
**************************************************************************
**************************************************************************
}
INTERFACE
type
     RT_color = record
                      r,g,b:double;
                end;
     RT_point = record
                      x,y,z:double;
                end;
     RT_rect = record
                     p1,p2:RT_point;
               end;
     RT_vector = record
                      x,y,z:double;
                end;
     RT_coeff_type
               = record
                       a,b,c,
                       d,e,f,
                       g,h,j,
                       k:double;
                 end;
     RT_ray = record
                    Q:RT_point;
                    v:RT_vector;
              end;
     RT_light = record
                      position:RT_point;
                      ambient_intensity:double;
                      diffuse_intensity:double;
                      Ia,Ip:RT_color;
                      point_at:rt_vector;
                      cos_alpha:double;
                      p:integer;
                      spot:boolean;
                end;

     RT_normal = RT_vector;
     ct=rt_color;
     v3t=rt_vector;

const INFINITY_HIGH:double=1.7e38;
      INFINITY_LOW:double=1.7e-38;
      NULL:rt_vector=(x:0; y:0; z:0);
      INFINITE_VECTOR:rt_vector=(x:1e38; y:1e38; z:1e38);
      E:rt_vector=(x:1; y:1; z:1);
      RAD:double=pi/180;


      EPSILON:double=0.01;
type
      rt_obase_p = ^rt_obase;
      rt_obase = object
              next_obj,prev_obj:rt_obase_p;
              constructor init;
              destructor done; virtual;
              end;

procedure doerror(is:string);

IMPLEMENTATION
procedure doerror(is:string);
begin writeln(is); halt; end;
{



        BASIS_OBJEKT



}
constructor rt_obase.init;
begin
     next_obj:=nil;
     prev_obj:=nil
end;
destructor rt_obase.done;
begin end;
begin
end.