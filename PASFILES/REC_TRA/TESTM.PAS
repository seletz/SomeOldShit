program testm;
uses crt,ste,matrix,graph;
const d=100;
      mper:m4x4 = ( (1,0,0,0),
                    (0,1,0,0),
                    (0,0,1,0),
                    (0,0,1/d,1));
      w:array [1..8,1..3] of double = ( (0,0,0),
                                        (1,0,0),
                                        (0,1,0),
                                        (1,1,0),
                                        (0,0,1),
                                        (1,0,1),
                                        (0,1,1),
                                        (1,1,1));
      l:array [1..12,1..2] of integer = ( (1,2),(2,3),(3,4),(4,1),
                                          (1,5),(2,6),(3,7),(4,8),
                                          (5,6),(6,7),(7,8),(8,5));
var vp:view;
    M,p1,p2:m4x4;
    P,pt: array[1..8] of m4x4;
    i,j,k:integer;
begin
     clrscr;
     grafikein;
     vp.init(10,10,700,700);

     m:=e;
     init_trans(0.5,0.5,0.5,M);
     init_roty(1*pi/180,M);
     for i:=1 to 8 do begin
         init_point(w[i,1],w[i,2],w[i,3],P[i]);
     end;

     repeat
           for i:=1 to 8 do begin
               m_mul(M,p[i])
           end;
           for i:=1 to 12 do begin
               p1:=p[l[i,1]];
               p2:=p[l[i,1]];
               m_mul(mper,p1);
{               m_mul(mper,p2);      }
               m_scale(1/p1[4,1],p1);
               m_scale(1/p2[4,1],p2);
               vp.line(p1[1,1],p1[3,1],
                    p2[1,1],p2[3,1]);
           end;
     until keypressed;
     grafikaus;
end.