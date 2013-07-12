{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 417 of 441
From : Terry Grant                         1:210/20.0           11 Apr 93  08:27
To   : All
Subj :
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Hello All!

Here is a unit I posted some time ago for use with EMSI Sessions. Hope it
helps some of you out. You will require a fossil OR Async Interface for
this to compile!
-----------------------------------------------------------------------------}
Program Emsi;

Uses
  Dos , Crt, Fossil;

Type
  HexString = String[4];

Const
  FingerPrint          = '{EMSI}';
  System_Address       = '1:210/20.0';      { Your address }
  Password             = 'PASSWORD';        { Session password }
  Link_Codes           = '{8N1}';           { Modem setup }
  Compatibility_Codes  = '{JAN}';           { Janis }
  Mailer_Product_Code  = '{00}';
  Mailer_Name          = 'MagicMail';
  Mailer_Version       = '1.00';
  Mailer_Serial_Number = '{Alpha}';
  EMSI_INQ : String = '**EMSI_INQC816';
  EMSI_REQ : String = '**EMSI_REQA77E';
  EMSI_ACK : String = '**EMSI_ACKA490';
  EMSI_NAK : String = '**EMSI_NAKEEC3';
  EMSI_CLI : String = '**EMSI_CLIFA8C';
  EMSI_ICI : String = '**EMSI_ICI2D73';
  EMSI_HBT : String = '**EMSI_HBTEAEE';
  EMSI_IRQ : String = '**EMSI_IRQ8E08';

Var
  EMSI_DAT : String;            { NOTE : EMSI_DAT has no maximum length }
  Length_EMSI_DAT : HexString;  { Expressed in Hexidecimal }
  Packet : String;
  Rec_EMSI_DAT : String;        { EMSI_DAT sent by the answering system }
  Len_Rec_EMSI_DAT : Word;

  Len,
  CRC : HexString;

  R : Registers;
  C : Char;
  Loop,ComPort,TimeOut,Tries : Byte;
  Temp : String;

Function Up_Case(St : String) : String;
Begin
  For Loop := 1 to Length(St) do
    St[Loop] := Upcase(St[Loop]);

  Up_Case := St;
End;

function Hex(i : Word) : HexString;
const
  hc : array[0..15] of Char = '0123456789ABCDEF';
var
  l, h : Byte;
begin
  l := Lo(i);
  h := Hi(i);
  Hex[0] := #4;          { Length of String = 4 }
  Hex[1] := hc[h shr 4];
  Hex[2] := hc[h and $F];
  Hex[3] := hc[l shr 4];
  Hex[4] := hc[l and $F];
end {Hex} ;

Function Power(Base,E : Byte) : Longint;
Begin
  Power := Round(Exp(E * Ln(Base) ));
End;

Function Hex2Dec(HexStr : String) : Longint;

Var
  I,HexBit : Byte;
  Temp : Longint;
  Code : integer;

Begin
  Temp := 0;
  For I := Length(HexStr) downto 1 do
  Begin
    If HexStr[I] in ['A','a','B','b','C','c','D','d','E','e','F','f'] then
      Val('$' + HexStr[I],HexBit,Code)
        else
          Val(HexStr[I],HexBit,Code);
    Temp := Temp + HexBit * Power(16,Length(HexStr) - I);
  End;
  Hex2Dec := Temp;
End;

Function Bin2Dec(BinStr : String) : Longint;

{ Maximum is 16 bits, though a requirement for more would be   }
{ easy to accomodate.  Leading zeroes are not required. There  }
{ is no error handling - any non-'1's are taken as being zero. }

Var
  I : Byte;
  Temp : Longint;
  BinArray : Array[0..15] of char;

Begin
  For I := 0 to 15 do
    BinArray[I] := '0';
  For I := 0 to Pred(Length(BinStr)) do
    BinArray[I] := BinStr[Length(BinStr) - I];
  Temp := 0;
  For I := 0 to 15 do
    If BinArray[I] = '1' then inc(Temp,Round(Exp(I * Ln(2))));
  Bin2Dec := Temp;
End;

function CRC16(s:string):word;  { By Kevin Cooney }
var
  crc : longint;
  t,r : byte;
begin
  crc:=0;
  for t:=1 to length(s) do
  begin
    crc:=(crc xor (ord(s[t]) shl 8));
    for r:=1 to 8 do
      if (crc and $8000)>0 then
        crc:=((crc shl 1) xor $1021)
          else
            crc:=(crc shl 1);
  end;
  CRC16:=(crc and $FFFF);
end;

{**** FOSSIL Routines ****}
{**** Removed from Code ***}

Procedure Hangup;
Begin
    Write2Port('+++'+#13);
End;

{**** EMSI Handshake Routines ****}

Procedure Create_EMSI_DAT;
Begin
  FillChar(EMSI_DAT,255,' ');

  EMSI_DAT := FingerPrint + '{' + System_Address + '}{'+ Password + '}' +
              Link_Codes + Compatibility_Codes + Mailer_Product_Code +
              '{' + Mailer_Name + '}{' + Mailer_Version + '}' +
              Mailer_Serial_Number;

  Length_EMSI_DAT := Hex(Length(EMSI_DAT));
End;

Function Carrier_Detected : Boolean;
Begin
  TimeOut := 20;   { Wait approximately 20 seconds }
  Repeat
    Delay(1000);
    Dec(TimeOut);
  Until (TimeOut = 0) or (Lo(StatusReq) and $80 = $80);

  If Timeout = 0 then
    Carrier_Detected := FALSE
      else
        Carrier_Detected := TRUE;
End;

Function Get_EMSI_REQ : Boolean;
Begin
  Temp := '';
  Purge_Input;

  Repeat
    C := ReadKeyfromPort;
    If (C <> #10) and (C <> #13) then Temp := Temp + C;
  Until Length(Temp) = Length(EMSI_REQ);

  If Up_Case(Temp) = EMSI_REQ then
    get_EMSI_REQ := TRUE
      else
        get_EMSI_REQ := FALSE;
End;

Procedure Send_EMSI_DAT;
Begin
  CRC := Hex(CRC16('EMSI_DAT' + Length_EMSI_DAT + EMSI_DAT));
  Write2Port('**EMSI_DAT' + Length_EMSI_DAT + EMSI_DAT + CRC);
End;

Function Get_EMSI_ACK : Boolean;
Begin
  Temp := '';

  Repeat
    C := ReadKeyfromPort;
    If (C <> #10) and (C <> #13) then Temp := Temp + C;
  Until Length(Temp) = Length(EMSI_ACK);

  If Up_Case(Temp) = EMSI_ACK then
    get_EMSI_ACK := TRUE
      else
        get_EMSI_ACK := FALSE;
End;

Procedure Get_EMSI_DAT;
Begin
  Temp := '';
  For Loop := 1 to 10 do                  { Read in '**EMSI_DAT' }
    Temp := Temp + ReadKeyfromPort;

  Delete(Temp,1,2);                       { Remove the '**'      }

  Len := '';
  For Loop := 1 to 4 do                   { Read in the length   }
    Len := Len + ReadKeyFromPort;

  Temp := Temp + Len;

  Len_Rec_EMSI_DAT := Hex2Dec(Len);

  Packet := '';
  For Loop := 1 to Len_Rec_EMSI_DAT do    { Read in the packet   }
    Packet := Packet + ReadKeyfromPort;

  Temp := Temp + Packet;

  CRC := '';
  For Loop := 1 to 4 do                   { Read in the CRC      }
    CRC := CRC + ReadKeyFromPort;

  Rec_EMSI_DAT := Packet;

  Writeln('Rec_EMSI_DAT = ',Rec_EMSI_DAT);

  If Hex(CRC16(Temp)) <> CRC then
    Writeln('The recieved EMSI_DAT is corrupt!!!!');
End;

Begin
  { Assumes connection has been made at this point }

  Tries := 0;
  Repeat
    Write2Port(EMSI_INQ);
    Delay(1000);
    Inc(Tries);
  Until (Get_EMSI_REQ = TRUE) or (Tries = 5);

  If Tries = 5 then
  Begin
    Writeln('Host system failed to acknowledge the inquiry sequence.');
    Hangup;
    Halt;
  End;

  { Used for debugging }
  Writeln('Boss has acknowledged receipt of EMSI_INQ');

  Send_EMSI_DAT;

  Tries := 0;
  Repeat
    Inc(Tries);
  Until (Get_EMSI_ACK = True) or (Tries = 5);

  If Tries = 5 then
  Begin
    Writeln('Host system failed to acknowledge the EMSI_DAT packet.');
    Hangup;
    halt;
  End;

  Writeln('Boss has acknowledged receipt of EMSI_DAT');

  Get_EMSI_DAT;
  Write2Port(EMSI_ACK);

  { Normally the file transfers would start at this point }
  Hangup;
End.


---------------------------------------------------------------------------
 This DOES NOT include all the possibilities in an EMSI Session, And JoHo is
Revising most of them right now. When I get further information on the
changes I will repost adding the NEW Features.