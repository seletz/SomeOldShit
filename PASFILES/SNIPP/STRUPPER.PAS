{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 365 of 367
From : Peter Beeftink                      1:163/307.25         11 Apr 93  16:03
To   : Bo Bendtsen                         2:231/111.0
Subj : International characters
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Hello Bo!

Friday April 09 1993 12:28, Bo Bendtsen wrote to All:

 BB>   Upper/lower changing of strings are always a difficult problem,
 BB>   but as a person living in Denmark i must normally care about
 BB>   danish characters,

Possibly you like the method as shown underneath Bo!  I picked this up in this
echo I believe.  You can modify the 'special changes' as required.

Peter      }

function StrUpper(Str: String): String; Assembler;
 ASM
      jmp   @Start { Jump over Table declared in the Code Segment }

  @Table:
    { characters from ASCII 0 --> ASCII 96 stay the same }
  DB 00,01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21
  DB 22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43
  DB 44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65
  DB 66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87
  DB 88,89,90,91,92,93,94,95,96
    { characters from ASCII 97 "a" --> ASCII 122 "z" get translated }
    { to characters ASCII 65 "A" --> ASCII 90 "Z" }
  DB 65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86
  DB 87,88,89,90
    { characters from ASCII 123 --> ASCII 127 stay the same }
  DB 123,124,125,126,127
    { characters from ASCII 128 --> ASCII 165 some changes
     #129 --> #154, #130 --> #144, #132 --> #142, #134 --> #143
      #135 --> #128, #145 --> #146, #148 --> #153, #164 --> #165}

  DB 128,154,144,131,142,133,143,128,136,137,138,139,140,141,142,143
  DB 144,146,146,147,153,149,150,151,152,153,154,155,156,157,158,159
  DB 160,161,162,163,165,165
    { characters from ASCII 166 --> ASCII 255 stay the same }
  DB 166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181
  DB 182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197
  DB 198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213
  DB 214,215,216,217,218,219,220,221,222,223,224,225,226,227,228,229
  DB 230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245
  DB 246,247,248,249,250,251,252,253,254,255

  @Start:
      push  DS                { Save Turbo's Data Segment address    }
      lds   SI,Str            { DS:SI points to Str[0]               }
      les   DI,@Result        { ES:DI points to StrUpper[0]          }
      cld                     { Set direction to forward             }
      xor   CX,CX             { CX = 0                               }
      mov   BX,OFFSET @Table  { BX = Offset address of LookUpTable   }
      lodsb                   { AL = Length(Str); SI -> Str[1]       }
      mov   CL,AL             { CL = Length(Str)                     }
      stosb                   { Move Length(Str) to Length(StrUpper) }
      jcxz  @Exit             { Get out if Length(Str) is zero       }

  @GetNext:
      lodsb                   { Load next character into AL          }
      segcs XLAT              { Translate char using the LookupTable }
                              { located in Code Segment at offset BX }
      stosb                   { Save next translated char in StrUpper}
      loop  @GetNext          { Get next character                   }

  @Exit:
      pop   DS                { Restore Turbo's Data Segment address }
 end {StrUpper};