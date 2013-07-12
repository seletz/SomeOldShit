program tga;
uses crt,graph,sgraph;
type tgaheader = RECORD
                       indent_len,
                       cmap_type,
                       image_type:byte;
                       cmap_orgin,
                       cmap_len:integer;
                       centry_size:byte;
                       image_xorg,
                       image_yorg,
                       image_width,
                       image_height:integer;
                       pixel_size,
                       image_discr:byte;
                 END;
var outfile:file of byte;
    b:byte;
    colors:integer;
    xlenght,ylenght:integer;
    mytga:tgaheader;
procedure makegfx;
var count,x,y,x1,y1,c:integer;
begin
(*

                Beispielgrafik erzeugen

 *)
     grafikein;
     count:=0;
     x1:=getmaxx div 2;
     y1:=getmaxy div 2;
     while count<100 do
           begin
                c:=random(255);
                x:=random(getmaxx);
                y:=random(getmaxy);
                setcolor(c);
                line(x,y,x1,y1);
                inc(count);
           end;
end;
procedure writetga(fn:string; tgah:tgaheader);
var f:file of tgaheader;
    f2:text;
    x,y,i:integer;
    xs,ys:real;
    r,b,g:byte;
begin
     assign(f,fn);
     rewrite(f);
     write(f,tgah);
     close(f);
     assign(f2,fn);
     append(f2);
with tgah do begin
     ys:=(image_height-1) / 255;
     xs:=(image_width-1) / 255;
     g:=0;
     b:=0;
     writeln(xs,' ',ys);
     for y:=0 to image_height-1 do
         begin
         r:=0;
         g:=round(g+ys) mod 255;
         for x:=0 to image_width-1 do
             begin
                  (*i:=(i+1) mod 1024;*)
                  if round(r+xs)>255 then
                     begin
                          r:=round(r+xs) mod 255;
                          b:=round(b+xs) mod 255;
                     end
                  else
                      begin
                           r:=round(r+xs) mod 255;
                      end;
                  write(f2,chr(b),chr(g),chr(r));
             end;
         end;
end; { with tgah}
end;
begin
     with mytga do
          begin
               indent_len:=0;
               cmap_type:=0;
               image_type:=2;
               cmap_orgin:=0;
               cmap_len:=0;
               centry_size:=24;
               image_xorg:=0;
               image_yorg:=0;
               image_width:=640;
               image_height:=480;
               pixel_size:=24;
               image_discr:=0;
          end;

     writetga('c:\temp\test.tga',mytga);
     writeln('Fertig!');
     readln;

end.