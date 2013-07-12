program listtest;
uses crt,ste,liste;
type neunodep =^neunodet;
     neunodet = object (nodet)
                       data:string;
                       procedure setdata(idata:string);
                       function getdata:string;
                end;

     neulistt = object (listt)
                        function get:neunodep;
                 end;

                procedure neunodet.setdata;
                begin
                     data:=idata;
                     writeln('Neue Daten:',data);
                end;
                function neunodet.getdata:string;
                begin
                     getdata:=data;
                     writeln('Daten     :',data);
                end;

                function neulistt.get:neunodep;
                var temp:neunodep;
                begin
                     { nodep jetzt ein anderer typ! }
                     temp:=neunodep(inherited get);
                     writeln('Get: #',temp^.number);
                     get:=temp;
                end;



var testliste:neulistt;
    temp:neunodep;
    i:integer;
begin
     clrscr;
     testliste.init;
     new(temp,init);
     temp^.setdata('Erste Node !');
     for i:=ord('A') to ord('C') do begin
         new(temp,init);
         temp^.setdata('Node '+chr(i));
         testliste.insert(temp);
     end;

     waittast;

     testliste.setfirst;
     repeat
           writeln(testliste.get^.getdata);
           testliste.next;
     until testliste.is_last;

     testliste.done;
end.