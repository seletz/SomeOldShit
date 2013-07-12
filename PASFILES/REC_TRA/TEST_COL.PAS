program test_colors;
uses crt,colors;
var r,g,b,h,s,v:real;
begin
     rgb_to_hsv(0.3,0.3,0.3,h,s,v);
     writeln('H=',h:3:3,'S=',s:3:3,'V=',v:3:3);

     hsv_to_rgb(312,0.5,1,r,g,b);
     writeln('R=',r:3:3,'G=',g:3:3,'B=',b:3:3);
end.