program tgaunittest;
uses crt,tgaun;
var f:TGAFile;
    x,y:byte;
    sx,sy:double;
begin
     textmode(co80+font8x8);
     clrscr;
     f.init('C:\tp70\ray\test.tga',199,199);
     f.writeheader;
     sx:=1/(f.tgah.image_width);
     sy:=1/(f.tgah.image_height);
     for y:=0 to f.tgah.image_height do begin
         for x:=0 to f.tgah.image_width do begin
             if x>0 then f.output(x,y,x*sx
                           ,y*sy
                           ,1)
             else
               f.output(x,y,0,0,0);
         end;
         writeln;
     end;
     f.done;
end.
