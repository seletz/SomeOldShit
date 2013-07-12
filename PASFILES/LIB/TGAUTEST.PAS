program tgaunittest;
uses crt,tgaunit;
var f:TGAFile;
    x,y:byte;
begin
     clrscr;
     f.init('C:\tp70\rec_tra\test.tga',199,199);
     f.writeheader;
     for y:=0 to 199 do begin
         write(y);
         for x:=0 to 199 do begin
             write('.');
             f.output(x,y  ,byte(round(sin(2*pi/100*y)*255))
                           ,byte(round(cos(2*pi/100*x)*255))
                           ,byte(round(-sin(2*pi/100*y)*255)));
         end;
         writeln;
     end;
     f.done;
end.
