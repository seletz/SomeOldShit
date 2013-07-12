program vptst;
uses crt,ste;
type vp = ^v;
     v = record x,y,z:double end;

     procedure vadd_p(v1,v2:vp);
     begin
          v2^.x:=v1^.x+v2^.x;
          v2^.y:=v1^.y+v2^.y;
          v2^.z:=v1^.z+v2^.z;
     end;
     procedure vadd  ( var v1,v2:v);
     begin
          v2.x:=v1.x+v2.x;
          v2.y:=v1.y+v2.y;
          v2.z:=v1.z+v2.z;
     end;

var i:longint;
    v1,v2:v;
begin
     clrscr;
     write('Normal...');
     for i:=1 to 100000 do begin
         v1.x:=5.4; v1.y:=5; v1.z:=5.2;
         v2.x:=5; v2.y:=5.6; v2.z:=5.01;
         vadd(v1,v2);
     end;
     writeln('done.');
     write('Mit Zeigern...');
     for i:=1 to 100000 do begin
         v1.x:=5.4; v1.y:=5; v1.z:=5.2;
         v2.x:=5; v2.y:=5.6; v2.z:=5.01;
         vadd_p(@v1,@v2);
     end;
     writeln('done.');
end.