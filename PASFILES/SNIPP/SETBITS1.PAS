{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 357 of 473
From : Rob Green                           1:363/166.0          12 Apr 93  12:24
To   : Dane Walther
Subj : ROTATING BITS
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
 -=>Obviously lying, Dane Walther said to Sean Palmer <=-

 DW> What if I want to just access a bit?  Say I have a byte, to store
 DW> various access levels (if it does/doesn't have this, that, or the
 DW> other).  How can I

 DW> 1)  Access, say, bit 4?
 DW> 2)  Give, say, bit 4, a value of 1?

Heres a procedure i wrote to handle all that.  If you need speed, then
i suggest to manually check each bit, rather than use the procedures.

(these procedures are based on 1, not 0.  thus each byte is like so:
87654321   instead of 76543210.  to change to 0 base, change the array to
[0..31] instead of [1..32].)}

to set a bit: (b is an integer type, BIT is which bit to set
   b:=b or BIT;   ex: b:=b or 128  (set bit 8)

to clear a bit:
   b:=b and not BIT;  ex:b:=b and not 8;  (clears bit 4)

to check a bit:
   if b and BIT<>0 then..  ex:if b and 64 then..  (check bit 7)

{ $tested+ }
-----------------------
const
{This const is used to convert the Bit value to the actual corresponding
 number}
   bit:array[1..32] of longint =
       (1,2,4,8,$10,$20,$40,$80,
        $100,$200,$400,$800,$1000,$2000,$4000,$8000,
        $10000,$20000,$40000,$80000,$100000,$200000,$400000,$800000,
        $1000000,$2000000,$4000000,$8000000,$10000000,$20000000,
        $40000000,$80000000
       );

{b is which bit to set(1-32), size is the size of temp.
Use  SIZEOF(TEMP) to get the value, and temp is the actuall integer based
number
returns true if bit set, false if not}

function checkbit(b:byte; size:byte; var temp):boolean; {1-32}
var c:boolean;
begin
   c:=false;
   case size of
      1:c:=byte(temp) and bit[b]<>0;     {byte,shortint}
      2:c:=word(temp) and bit[b]<>0;     {word,integer}
      4:c:=longint(temp) and bit[b]<>0;  {longint}
      else writeln('Invalid size');
   end;
   checkbit:=c;
end;

{b,size,and temp same as above.  if onoff =true the bit will be set,
else the bit will be cleared}

procedure setbit(b:byte; onoff:boolean; size:byte; var temp); {1-32}
begin
   if onoff then
   case size of
      1:byte(temp):=byte(temp) or bit[b];        {byte}
      2:word(temp):=word(temp) or bit[b];        {word}
      4:longint(temp):=longint(Temp) or bit[b];  {longint}
      else writeln('Invalid size');
   end
   else
   case size of
      1:byte(temp):=byte(temp) and not bit[b];   {byte}
      2:word(temp):=word(temp) and not bit[b];   {word}
      4:longint(temp):=longint(Temp) and not bit[b];{longint}
      else writeln('Invalid size');
   end;
end;

{this is a sample test program i wrote for you to see how to use the
stuff above}

var i:longint; j:byte;
begin
   i:=0;
   setbit(4,true,sizeof(i),i);  {8}
   writeln(i);
   setbit(9,true,sizeof(i),i);  {256+8 = 264}
   writeln(i);
   setbit(9,false,sizeof(i),i); {8}
   writeln(i);
   setbit(20,true,sizeof(i),i); { $80000+8 = $80008}
   writeln(i);
   for i:=65550 to 65575 do
   begin
      write(i:8,' = ');
      for j:=32 downto 1 do {to print right}
         if checkbit(j,sizeof(i),i) then write('1') else write('0');
      writeln;
   end;

end.
{ $tested- }