unit rt_tga;
INTERFACE
uses crt,sgraph,rt_output;
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
     TGAfile = Object(output)
                     filename:string;
                     tgah:tgaheader;
                     first:boolean;
                     zeile : array [0..2,0..1024] of byte;
                     f:text;
                     destructor done;
                     constructor init(fn:string; mode,breite,hoehe:integer);
                     procedure WriteHeader;
                     procedure flush;
                     procedure output(x,y:integer; r,g,b:double);
               end;
IMPLEMENTATION
destructor TGAfile.done;
begin
     inherited done;
     flush;
     close(f);
end;
constructor TGAfile.init(fn:string; mode,breite,hoehe:integer);
begin
     inherited init(mode,breite,hoehe);;

     first:=true;

     filename:=fn;
     with tgah do
          begin
               indent_len:=0;
               cmap_type:=0;
               image_type:=2;
               cmap_orgin:=0;
               cmap_len:=0;
               centry_size:=24;
               image_xorg:=0;
               image_yorg:=0;
               image_width:=breite;
               image_height:=hoehe;
               pixel_size:=24;
               image_discr:=32;
          end; { 18 byte }

     WriteHeader;
end;
procedure TGAfile.WriteHeader;
var ft:file of tgaheader;
begin
     assign(ft,filename);
     rewrite(ft);
     write(ft,tgah);
     close(ft);
     assign(f,filename);
     append(f);
end;

procedure TGAfile.output(x,y:integer; r,g,b:double);
begin

     if m<> no_graphic then put(x,y,r,g,b);

     if (x=0) and not first then begin
        flush;
     end;

     first:=false;

     zeile[0,x]:=round(r * 255);
     zeile[1,x]:=round(g * 255);
     zeile[2,x]:=round(b * 255);
end;

procedure tgafile.flush;
var i:integer;
begin
     for i:=0 to tgah.image_width-1 do begin
         write(f,chr(zeile[2,i]),chr(zeile[1,i]),chr(zeile[0,i]));
     end;
end;
begin
end.