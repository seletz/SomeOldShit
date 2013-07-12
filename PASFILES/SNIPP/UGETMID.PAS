{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 568 of 570
From : John Reid                           1:150/170.0          24 Apr 93  14:16
To   : Mark Gryn
Subj : Diskette Serial Numbers
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

MG>        If anyone happens to know how to find the serial number of a
MG>        diskette, please let me know, code is nice :)

This should probably have code added to check for early DOS versions
that do not support media id.  }

unit ugetmid; {Get media ID}
INTERFACE
uses dos;
type
  TMID = record
           InfoLevel : word;
           SN : array[0..1] of word;
           Labl : array[1..11] of byte;
           Typ : array[1..8] of byte;
         end;

procedure GetMediaID(Drive : byte; {0=default, 1=A:, 2=B:, 3=C:, etc.}
                     var MID : TMID);

IMPLEMENTATION
procedure GetMediaID(Drive : byte; var MID : TMID) ;
  var
    Regs : registers;
  begin
    Regs.bx := Drive;
    Regs.ch := $08;
    Regs.cl := $66;
    Regs.ds := Seg(MID);
    Regs.dx := Ofs(MID);
    Regs.ax := $440D;
    MsDos(Regs)
  end;

END.