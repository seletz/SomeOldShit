{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 117 of 150
From : Sean Palmer                         1:104/123.0          08 Apr 93  15:36
To   : All
Subj : G:uInput unit
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
{uInput}
{Copyright (C)1993 Sean Palmer}
   {^ This is just to cover my butt so none of you
      copyright it and sue me for using my own stuff!}
 {2237 Lincoln St.}
 {Longmont, CO 80501}
{Alms gladly accepted! 8) }
{This unit has been released to the public domain}

unit uInput;
{$B-,I-,N-,O-,R-,S-,V-,X-}
interface

uses keys;
{tCharSet is used to specify function keys to the input routine}
type tCharSet=set of char;

function input(default:string;maxCh:byte;cs:tCharSet):string;

implementation

function input(default:string;maxCh:byte;cs:tCharSet):string;
  var c:char; s:string[255]; p:byte absolute s; const bs=^H' '^H;
begin
 s:=default; write(default);
 repeat
  c:=readKey; if c=#0 then c:=char(byte(readKey)or $80);
  case c of
   ^H:if p<>0 then begin write(bs); dec(p);end;
   #127:while p>0 do begin write(bs); dec(p);end;    
   ^M:; {don't beep}    
   ' '..'~':if length(s)<maxCh then begin write(c);inc(p);s[p]:=c; end        
            else write(^G);    
   else if c in cs then begin s[1]:=c; p:=255; c:=^M; end         
        else write(^G);
   end;
  until (c=^M)or(c=^[);
 if c=^[ then input:=default else input:=s;
 end;

end.