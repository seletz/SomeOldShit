program turmiten;
{
 zweidimensionale Touringmaschine

 letzte Žnderung: xx.xx.1994
}
uses crt,ste,graph,rt_lists;
const

     li   = 1;
     re   = 2;
     vw   = 3;



     {
        Turmite 'U'
     }

     farbe    : array [1..2,1..2] of integer = ( (2, 2),
                                                 (1, 2));

     bewegung : array [1..2,1..2] of integer = ( (li, re),
                                                 (vw, re));

     zustand  : array [1..2,1..2] of integer = ( (2 , 1),
                                                 (2 , 1));

     debug = false;

type
     turmite_t = object
                  xp,yp:integer;
                  b,z,f:integer;
                  richtung:integer;
                  vp,vp2:view_p;
                  constructor init(ivp1,ivp2:view_p);
                  destructor done;
                  procedure step;
                  procedure rechts;
                  procedure links;
                  procedure vorwaerts;
            end;
{
*****************************************************************************
*****************************************************************************
************************                       ******************************
***********************  TURMITEN - PROCEDUREN  *****************************
************************                       ******************************
*****************************************************************************
*****************************************************************************
*****************************************************************************
}
constructor turmite_t.init;
begin
     vp:=ivp1;
     vp^.rahmen;

     vp2:=ivp2;
     vp2^.rahmen;

     xp:=vp^.get_xmax div 2;
     yp:=vp^.get_ymax div 2;

     richtung:=0;

     z:=1;
end;
destructor turmite_t.done;
begin
     vp^.done;
     dispose(vp);
end;

procedure turmite_t.step;
var c:integer;
begin

     c:=getpixel(vp^.cx(xp),vp^.cy(yp));
     if c=0 then c:=1;
     f:=farbe[z,c];
     putpixel(vp^.cx(xp),vp^.cy(yp),f);
     putpixel(vp2^.cx(xp),vp2^.cy(yp),0);

     b:=bewegung[z,c];


     if debug then begin
        grafikaus;


        write1r('xp         :',xp);
        write1r('yp         :',yp);

        write1r('Pixel      :',c);
        write1r('Zustand n  :',z);
        write1r('Farbe      :',f);
        write1r('Bewegung   :',b);
        write1r('Richtung   :',richtung);
     end;

     case b of
          re: rechts;
          li: links;
          vw: vorwaerts;
     end;
        z:=zustand[z,c];
     if debug then begin

        write1r('Zustand n+1:',z);
        write1r('xp      n+1:',xp);
        write1r('yp      n+1:',yp);

        waittast;
        grafikein;
     end;
     putpixel(vp2^.cx(xp),vp2^.cy(yp),255);
end;

procedure turmite_t.rechts;
begin
     richtung:=richtung - 90;
     if richtung<0 then richtung:=richtung + 360;

     vorwaerts;
end;

procedure turmite_t.links;
begin
     richtung:=(richtung + 90) mod 360;

     vorwaerts;
end;
procedure turmite_t.vorwaerts;
begin
     {
     grafikaus;
     write1r('xx:',xp);
     write1r('yy:',yp);
     grafikein;
     }

     xp:=xp + round(cos(richtung*pi/180));
     yp:=yp + round(sin(richtung*pi/180));
end;

{
*****************************************************************************
*****************************************************************************
************************                       ******************************
***********************  ALLGEMEINE PROCEDUREN  *****************************
************************                       ******************************
*****************************************************************************
*****************************************************************************
*****************************************************************************
}
var
   t:turmite_t;
   v:view;
   i,j,k:integer;

begin
     grafikein;
     setrgbpalette(1,0,0,0);
     setrgbpalette(2,255,0,0);
     setrgbpalette(3,0,255,0);
     setrgbpalette(4,0,0,255);
     setrgbpalette(5,255,0,255);


     t.init( new(view_p,init(100,100,300,300)),
             new(view_p,init(400,100,300,300)));

     repeat
           t.step;
     until keypressed;

     grafikaus;
     t.done;
end.

