{ LzhV.Pas: Unit to view contents of .LZH files.  By Steve Wierenga. Released
  to the Public Domain.                                                      }
Unit Lzhv;
(**) INTERFACE (**)
Uses Dos,Crt;
Type
  Fileheadertype = record  { Lzh file header }
    Headsize,Headchk : byte;
    HeadID : packed array[1..5] of char;
    Packsize,Origsize,Filetime : longint;
    Attr : word;
    filename : String[12];
    f32 : PathStr;
    dt : DateTime;
  end;

var
  Fh : fileheadertype;
  Fha: array[1..sizeof(fileheadertype)] of byte absolute fh;
  crc: word;   { CRC value }
  crcbuf : array[1..2] of byte absolute CRC;
  crc_table : array[0..255] of word; { Table of CRC's }
  infile : file; { File to be processed }
  registered : boolean; { Is registered? }

Procedure Make_crc_table; { Create table of CRC's }
Function Mksum: byte;     { Get CheckSum }
Procedure ViewLzh(LZHfile : string);  { View the file }
Function GAN(LZHfile: String): string;  { Get the LZH filename }


(**) IMPLEMENTATION (**)
Procedure Terminate; { Exit the program }
Begin
  Write('ARCHPEEK could not find specified file.  Aborting...');
  Halt;
End;

Procedure Make_crc_table;
var
  i,index,ax : word;
  carry : boolean;
begin
  index := 0;
  repeat
    ax := index;
    for i := 1 to 8 do
      begin
        carry := odd(ax);
        ax := ax shr 1;
        if carry then ax := ax xor $A001;
      end;
    crc_table[index] := ax;
    inc(index);
  until index > 255;
end;

{ use this to calculate the CRC value of the original file }
{ call this function afer reading every byte from the file }
Procedure calccrc(data : byte);
var
  index : integer;
begin
  crcbuf[1] := crcbuf[1] xor data;
  index := crcbuf[1];
  crc := crc shr 8;
  crc := crc xor crc_table[index];
end;


Function Mksum : byte;  {calculate check sum for file header }
var
  i : integer;
  b : byte;
begin
  b := 0;
  for i := 3 to fh.headsize+2 do
    b := b+fha[i];
  mksum := b;
end;


Procedure viewlzh(LZHfile : string); { View the LZH file }
var
  l1,l2,oldfilepos,a,b,a1,b1,totalorig,totalpack : longint;
  count,z : integer;
  numread,i,year1,month1,day1,hour1,min1,sec1 : word;
  s1 : string[50];
  s2 : string[20];
   l : string[80];
  sss  :  string;
begin
  registered  :=  false; { Unregistered }
  if not registered then { Registered? }
  begin
    Writeln('ArchPeek 0.01Alpha [UNREGISTERED] Copyright 1993 Steve Wierenga');
    Delay(200);
  end;
  assign(infile,LZHfile);
  {$I-}
  reset(infile,1);   { Open LZH file }
  {$I+}
  If IOResult <> 0 then Terminate;   { Specified file exists? }
  sss  :=  GAN(LZHFile);  { Get filename of LZH file }
  Writeln( 'Lzh FileName: ',sss);
  WriteLn( '    Name           Length      Size  Saved',
          '    Date      Time    ');
  WriteLn( '   ____________________________________________________',
         '______');
  oldfilepos := 0;       { Init variables }
  count := 1;
  z  :=  0; a1  :=  0;
  repeat
    z  :=  z + 1;
    seek(infile,oldfilepos);                              { Goto start of file}
    blockread(infile,fha,sizeof(fileheadertype),numread); { Read fileheader}
    oldfilepos := oldfilepos+fh.headsize+2+fh.packsize;   { Where are we? }
   i := Mksum; { Get the checksum }
   if fh.headsize <> 0 then
     begin
       if i <> fh.headchk then
         begin
           Writeln('Error in file. Unable to read. Aborting...');
           Close(infile);
           Exit;
         end;
       Case Length(Fh.FileName) Of          { Straigthen out string }
         1  : Fh.FileName  :=  Fh.FileName + '           ';
         2  : Fh.FileName  :=  Fh.FileName + '          ';
         3  : Fh.FileName  :=  Fh.FileName + '         ';
         4  : Fh.FileName  :=  Fh.FileName + '        ';
         5  : Fh.FileName  :=  Fh.FileName + '       ';
         6  : Fh.FileName  :=  Fh.FileName + '      ';
         7  : Fh.FileName  :=  Fh.FileName + '     ';
         8  : Fh.FileName  :=  Fh.FileName + '    ';
         9  : Fh.FileName  :=  Fh.FileName + '   ';
         10 : Fh.FileName  :=  Fh.FileName + '  ';
         11 : Fh.FileName  :=  Fh.FileName + ' ';
         12 : Fh.FileName  :=  Fh.FileName + '';
       End;
       UnPackTime(Fh.FileTime,Fh.DT);
       a1 := a1 + Fh.OrigSize;            { Increase Uncompressed Size }
       Write( '   ',fh.filename:2,fh.origsize:9,fh.packSize:10,
                    (100-fh.packSize/fh.origSize*100):5:0,'%');
       { Display info }
    Case fh.dt.month of  { Get date and time }
     1..9   : Write( '0':4,fh.dt.month);
     10..12 : Write( ' ',fh.dt.month:4);
    End;
    Write( '/');
    Case fh.dt.day of
     1..9   : Write( '0',fh.dt.day);
     10..31 : Write( fh.dt.day);
    End;
    Write( '/');
    Case fh.dt.year of
     1980 : Write( '80');
     1981 : Write( '81');
     1982 : Write( '82');
     1983 : Write( '83');
     1984 : Write( '84');
     1985 : Write( '85');
     1986 : Write( '86');
     1987 : Write( '87');
     1988 : Write( '88');
     1989 : Write( '89');
     1990 : Write( '90');
     1991 : Write( '91');
     1992 : Write( '92');
     1993 : Write( '93');
     1994 : Write( '94');
     1995 : Write( '95');
     1996 : Write( '96');
    End;
    Case fh.dt.hour of
     0..9   : Write( '0':3,fh.dt.hour,':');
     10..23 : Write( ' ',fh.dt.hour:3,':');
    End;
    Case fh.dt.min of
     0..9   : Write( '0',fh.dt.min,':');
     10..59 : Write( fh.dt.min,':');
    End;
    Case fh.dt.sec of
     0..9   : Writeln( '0',fh.dt.sec);
     10..59 : Writeln( fh.dt.sec);
    End;
      end;
  until   (fh.headsize=0);
  Writeln( '  ======================================================',
          '=====');
  GetFTime(infile,l1);
  UnPackTime(l1,fh.dt);
  Write( '  ',z,' Files  ',a1:12,FileSize(infile):10,
          (100-FileSize(infile)/a1*100):5:0,'%');
  Case fh.dt.month of
     1..9   : Write( '0':4,fh.dt.month);
     10..12 : Write( ' ',fh.dt.month:4);
    End;
    Write( '/');
    Case fh.dt.day of
     1..9   : Write( '0',fh.dt.day);
     10..31 : Write( fh.dt.day);
    End;
    Write( '/');
    Case fh.dt.year of
     1980 : Write( '80');
     1981 : Write( '81');
     1982 : Write( '82');
     1983 : Write( '83');
     1984 : Write( '84');
     1985 : Write( '85');
     1986 : Write( '86');
     1987 : Write( '87');
     1988 : Write( '88');
     1989 : Write( '89');
     1990 : Write( '90');
     1991 : Write( '91');
     1992 : Write( '92');
     1993 : Write( '93');
     1994 : Write( '94');
     1995 : Write( '95');
     1996 : Write( '96');
    End;
    Case fh.dt.hour of
     0..9   : Write( '0':3,fh.dt.hour,':');
     10..23 : Write( ' ',fh.dt.hour:3,':');
    End;
    Case fh.dt.min of
     0..9   : Write( '0',fh.dt.min,':');
     10..59 : Write( fh.dt.min,':');
    End;
    Case fh.dt.sec of
     0..9   : Writeln( '0',fh.dt.sec);
     10..59 : Writeln( fh.dt.sec);
    End;
   End;

FUNCTION GAN(LZHfile : String): string;
  Var
    Dir  : DirStr;
    Name : NameStr;
    Exts : ExtStr;
  Begin
    FSplit(LZHFile,Dir,Name,Exts);
    GAN := Name + Exts;
  End;


End.