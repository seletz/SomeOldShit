program list;
uses crt,dos,printer;
const smax=60;
var zz,z:integer;
    zeile:string;
    f:text;
    znr:boolean;
    slen,err:integer;
procedure usage;
begin
        writeln('usage: listp -z[0/1] ## textfile');
        writeln('Example: listp -z0 60 large_file.txt');
        writeln('         Druckt mit Zeilennummern');
        writeln('         und 60 zeilen pro Blatt');
        halt(10);
end;
begin
     writeln(' ListPrinter              ');
     writeln(' ~~~~~~~~~~~              ');
     writeln(' Druckt Doppelseitige Listings / Texte. ');
     writeln('                          ');
     writeln(' (c) 1993 by StE          ');
     writeln('                          ');

     if (paramcount<>3) then begin
        usage;
     end;
     if (paramstr(1)<>'-z1') and (paramstr(1)<>'-z0') then usage;
     if (paramstr(1)='-z0') then znr := false else znr := true;

     val(paramstr(2),slen,err);
     if err<>0 then usage;

     assign(f,paramstr(3));

     if znr then writeln('Zeilenummern an.') else writeln('Zeilennummern aus.');
     writeln('Datei "',paramstr(3),'"');

     writeln('Drucker bitte einschalten und auf COMPRESSED schalten!');
     repeat until keypressed;
     readln;
     writeln('Drucke gerade seiten.....');
     reset(f);
     zz:=0;
     while not eof(f) do
           begin
                for z:=1 to slen do
                    begin
                         inc(zz);
                         readln(f,zeile);
                    end;
                for z:=1 to slen do
                    begin
                         inc(zz);
                         readln(f,zeile);
                    end;
           end;

     writeln(zz,' Zeilen gesamt, das sind ',zz div 60,' Seiten (',zz div 120,' Bl„tter).');
     writeln;

     write('Drucken (j/n) ?'); readln(zeile);
     if (zeile<>'j') and (zeile<>'J') then usage;

     reset(f);
     zz:=0;
     while not eof(f) do
           begin
                for z:=1 to slen do
                    begin
                         inc(zz);
                         readln(f,zeile);
                         if znr then write(lst,zz,':');
                         writeln(lst,zeile);
                    end;
                for z:=1 to slen do
                    begin
                         inc(zz);
                         readln(f,zeile);
                    end;
                for z:=slen+1 to smax do writeln(lst);
           end;

     writeln('Warten bis Drucker fertig gedruckt hat dann');
     writeln('Papier in umgekehrter reihenfolge mit der ');
     writeln('ersten Zeile nach hinten in den Einzugsschacht legen.');
     reset(f);
     repeat until keypressed;
     writeln('Drucke ungerade seiten...');
     zz:=0;
     while not eof(f) do
           begin
                for z:=1 to slen do
                    begin
                         inc(zz);
                         readln(f,zeile);
                    end;
                for z:=1 to slen do
                    begin
                         inc(zz);
                         readln(f,zeile);
                         if znr then write(lst,zz,':');
                         writeln(lst,zeile);
                    end;
                for z:=slen+1 to smax do writeln(lst);
           end;
     writeln('Fertig.');
     close(f);
end.