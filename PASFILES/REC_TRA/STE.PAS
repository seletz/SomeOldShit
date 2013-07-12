unit ste;
INTERFACE
uses crt,graph;
type view_p =^view;
     view = object
                  alt:viewporttype;
                  xorg,yorg,xmax,ymax:integer;
                  constructor init( ixorg,iyorg,ixmax,iymax:integer);
                  destructor done;
                  procedure line(x1,y1,x2,y2:real);
            end;

procedure fehler(s:string);
procedure write1r(s:string; x:real);
procedure waittast;
procedure write_d(s:string; x:real);
function grafikein:boolean;
procedure grafikaus;


IMPLEMENTATION
{
*****************************************************************************
*****************************************************************************
************************         ********************************************
***********************  V I E W  *******************************************
************************         ********************************************
*****************************************************************************
*****************************************************************************
*****************************************************************************
}
constructor view.init;
begin
     xorg:=ixorg; yorg:=iyorg; xmax:=ixmax; ymax:=iymax;

     if ((xorg+xmax)>getmaxx) or ((yorg+ymax)>getmaxy) then begin
        grafikaus;
        fehler('view.init: bereichsÅberschreitung!');
     end;

     getviewsettings(alt);
     rectangle(xorg,yorg,xorg+xmax,yorg+ymax);
     setviewport(xorg,yorg,xorg+xmax,yorg+ymax,ClipOn);

end;
destructor view.done;
begin
     with alt do setviewport(x1,y1,x2,y2,clip);
end;
procedure view.line;
var xmh,ymh:integer;
begin
     xmh:=xmax div 2;
     ymh:=ymax div 2;
     line( round(x1)+xmh, round(y1)+ymh,
           round(x2)+xmh, round(y2)+ymh);
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
function grafikein:boolean;
var gd,gm:integer;
begin
     gd:=ibm8514; gm:=ibm8514hi;
     initgraph(gd,gm,'c:\tp70\bgi\');
     grafikein:= graphresult=grOk;
end;
procedure grafikaus;
begin closegraph end;
procedure fehler;
begin writeln(s); halt(255) end;
procedure write1r(s:string; x:real);
begin writeln(s,x:3:3) end;
procedure waittast;
begin repeat until keypressed; readln end;
procedure write_d(s:string; x:real);
begin grafikaus; write1r(s,x); waittast; grafikein end;
{
*****************************************************************************
*****************************************************************************
************************           ******************************************
***********************  HAUPTTEIL  *****************************************
************************           ******************************************
*****************************************************************************
*****************************************************************************
*****************************************************************************
}
var exitsave:pointer;

procedure myExit;
begin
     ExitProc:=exitsave;

     closegraph;
end;

begin
     exitsave:=ExitProc;
     ExitProc:=@myExit;
end.