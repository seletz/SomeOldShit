program listtest;
uses crt;
type    listp = ^liste;
        liste = Object
                     data:integer;
                     first:listp;
                     last:listp;
                     next:listp;
                     prev:listp;
                     childs:listp;
                     vater:listp;
                     constructor init(idata:integer; vater:listp);
                     destructor done;
                     function addone(idata:integer; fflag:boolean):listp;
                     procedure addchilds(ichilds:listp);
                     function getnext : listp;
                     function getprev : listp;
                     function getdata : integer;
               end;
{

                *********************** liste


}
constructor liste.init(idata:integer; ivater:listp);
begin
     first:=self;
     last:=self;
     next:=nil;
     prev:=nil;
     child:=nil;
     vater:=ivater;
     data:=idata;
end;
destructor liste.done;
var p,t:listp;
begin
     t:=self.last;
     p:=t^.prev;
     while t<>nil do begin
           dispose(t,done);
           t:=p;
           p:=t^.prev;
     end;
end;
function addone(idata:integer; fflag:boolean):listp;
begin
     self.next:=new(listp,init(idata,false));
     next^.prev:=self;
     next^.vater:=self.vater;
     self.last:=next;
     next^.first:=first;
     next^.last:=last;
     addone:=next;
end;
procedure addchilds(ichilds:listp);
begin
     childs:=ichilds;
end;
function getnext : listp;
begin
     getnext:=next;
end;
function getprev : listp;
begin
     getprev:=prev;
end;
function getdata : integer;
begin
     getdata:=data;
end;
var i,d:integer;
    l:list;
    v,c:listp;
begin
     l.init(0,false);
     for i:=1000 to 1010 do begin
         v:=l.addone(i,false);
         for d:= 1 to 10 do begin

         end;
     end;
end.