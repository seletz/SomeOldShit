{***************************************}
{  ORC256 BGI driver   unit interface   }
{       Thomas Design                   }
{       August 5,  1989                 }
{***************************************}

unit ORCDET;
interface

const
  DVGA320x200 = 0;                     { Standard VGA mode 13h }
  DVGA320x240 = 1;                     { Special non-int 10h mode }
  DVGA360x480 = 2;                     { Special non-int 10h mode }
  DVGA640x350 = 3;                     { Designer VGA graphics modes }
  DVGA640x480 = 4;
  DVGA800x600 = 5;

procedure _ORCDriverProc;
function  _DetectORC256:integer;

implementation
procedure _ORCDRIVERPROC; external;
{$L ORC256.OBJ }
function  _DetectORC256;  external;
{$L ORCDE2.OBJ }
end.
