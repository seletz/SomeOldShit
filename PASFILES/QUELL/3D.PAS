program dreid0101;
uses crt,graph;
{label}
const pi=3.1415932; pd2=pi/2; pm2=pi*2;
type
    vector = RECORD
           x,y,z:real;
    end;
    kamera = RECORD
           p:vector;        {standort}
           h:vector;        {hauptpunkt}
           dph:real;        {p-h distanz}
           alpha,beta,gamma:real;        {winkel}
    end;
var
    k:kamera;
    sintab : array [0..360] of real;
    costab : array [0..360] of real;


procedure initgfx;
var gd,gm:integer;
begin
     gd:=IBM8514;
     gm:=IBM8514HI;
     initgraph(gd,gm,'c:\tp\bgi\');
     setfillstyle(1,0);
end;
function rad(deg:real):real;
begin
     rad:=(pi/180)*(deg);
end;

function deg(radians:real):real;
begin
     deg:=(radians)*180/pi;
end;

procedure initsico;
var i:integer;
begin
     write('Initsico...');
     for i:=0 to 360 do
         begin
              sintab[i]:=sin(rad(i));
              costab[i]:=cos(rad(i));
         end;
     writeln('ok.');
end;
function tsin(w:real) :real;
begin
     if abs(w)<>w then
        tsin:=-1*sintab[round(abs(w))]
     else
        tsin:=sintab[round(w)];
end;
function tcos(w:real) :real;
begin
     tcos:=costab[round(w)];
end;

procedure initialp;
var d1,sina,cosa,sinb,cosb,sinc,cosc:real;
begin
     writeln('InitialP...');
     writeln(k.p.x,' ',k.p.y,' ',k.p.z);
     d1:=sqrt(sqr(k.p.x-k.h.x)+sqr(k.p.y-k.h.y));
     k.dph:=sqrt(sqr(k.p.x-k.h.x)+sqr(k.p.y-k.h.y)+sqr(k.p.z-k.h.z));

     if d1=0 then
        begin
             sina:=0;
             cosa:=1
        end
     else
         begin
              sina:=(k.p.y-k.h.y)/d1;
              cosa:=(k.p.x-k.h.x)/d1
         end;

     if k.dph=0 then
        begin
             sinb:=0;
             cosb:=1
        end
     else
         begin
              sinb:=(k.p.z-k.h.z)/k.dph;
              cosb:=d1/k.dph;
         end;

     sinc:=0; cosc:=1;

     if cosa=0 then
        k.alpha:=pd2
     else
        k.alpha:=arctan(sina/cosa);

     if cosa<0 then
        k.alpha:=k.alpha+pi;

     if cosb=0 then
        k.beta:=pd2
     else
        k.beta:=arctan(sinb/cosb);

     if cosb<0 then
        k.beta:=k.beta+pi;

     k.gamma:=0;

     writeln('ok.');
end;

procedure initial;
begin
     {initgfx;}
     initsico;
     initialp;
end;

begin
     k.p.x:=100;
     k.p.y:=130;
     k.p.z:=-50;
     initial;
     writeln(deg(1.5));
     writeln((k.dph),' ',deg(k.alpha),' ',deg(k.beta),deg(k.gamma));

     closegraph;
end.