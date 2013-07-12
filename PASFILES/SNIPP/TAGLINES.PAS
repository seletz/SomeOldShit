{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 415 of 535
From : Bob Swart                           2:281/256.12         18 Apr 93  16:14
To   : Travis Griggs                       1:3807/8.0
Subj : Find Dupes
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Hi Travis!

 > Here's the code.  Don't worry about the structure of it.  I know it is
 > bad but this was a quick and dirty little util I wrote up that I needed.
 > Have fun with it and try to speed it up.
Here it is, all new and much faster. I used an internal binary tree to manage
the taglines. You can store up to the available RAM in taglines:}


{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S+,T-,V-,X-}
{$M 16384,0,655360}
uses Crt;
Type TBuffer  = Array[0..$4000] of Char;

Const
  Title = 'TagLines 0.2 by Bob Swart for Travis Griggs'#13#10;
  Usage = 'Usage: TagLines infile outfile'#13#10#13#10+
          '       Taglines will remove dupicate lines from infile.'#13#10+
          '       Resulting text is placed in outfile.'#13#10;

  NumLines: LongInt = 0; { total number of lines in InFile }
  NmLdiv80: LongInt = 0; { NumLines div 80, for 'progress' }
  CurrentL: LongInt = 0; { current lineno read from InFile }

Type
  String80 = String[80];

  PBinTree = ^TBinTree;
  TBinTree = record
               Info: String80;
               left,right: PBinTree
             end;

var InBuf,OutBuf: TBuffer;
    InFile, OutFile: Text;
    TagLine: String80;
    Root,Current,Prev: PBinTree;
    i: Integer;
    SaveExit: pointer;


    function CompStr(var Name1,Name2: String): Integer; Assembler;
    { Author: drs. Robert E. Swart
    }
    ASM
          push  DS
          lds   SI,Name1               { ds:si pts to Name1       }
          les   DI,Name2               { es:di pts to Name2       }
          cld
          lodsb                        { get String1 length in AL }
          mov   AH,ES:[DI]             { get String2 length in AH }
          inc   DI
          mov   BX,AX                  { save both lengths in BX  }
          xor   CX,CX                  { clear cx                 }
          mov   CL,AL                  { get String1 length in CX }
          cmp   CL,AH                  { equal to String2 length? }
          jb    @Len                   { CX stores minimum length }
          mov   CL,AH                  { of string1 and string2   }
    @Len: jcxz  @Exit                  { quit if null             }

   @Loop: lodsb                        { String1[i] in AL         }
          mov   AH,ES:[DI]             { String2[i] in AH         }
          cmp   AL,AH                  { compare Str1 to Str2     }
          jne   @Not                   { loop if equal            }
          inc   DI
          loop  @Loop                  { go do next char          }
          jmp   @Exit                  { Strings OK, Length also? }

    @Not: mov   BX,AX                  { BL = AL = String1[i],
                                         BH = AH = String2[i]     }
   @Exit: xor   AX,AX
          cmp   BL,BH                  { length or contents comp  }
          je    @Equal                 { 1 = 2: return  0         }
          jb    @Lower                 { 1 < 2: return -1         }
          inc   AX                     { 1 > 2: return  1         }
          inc   AX
  @Lower: dec   AX
  @Equal: pop   DS
    end {CompStr};


    procedure Stop; far;
    begin
      ExitProc := SaveExit;
      Close(InFile);
      Close(OutFile);
    end {Stop};

begin
  writeln(Title);
  if Paramcount <> 2 then
  begin
    writeln(Usage);
    Halt
  end;

  Assign(InFile,ParamStr(1));
  SetTextBuf(InFile,InBuf);
  Reset(InFile);
  if IOResult <> 0 then
  begin
    writeLn('Error: could not open ', ParamStr(1));
    Halt(1)
  end;

  Assign(OutFile,ParamStr(2));
  SetTextBuf(OutFile,OutBuf);
  Reset(OutFile);
  if IOResult = 0 then
  begin
    writeLn('Error: file ', ParamStr(2),' already exists');
    Halt(2)
  end;

  Rewrite(OutFile);
  if IOResult <> 0 then
  begin
    writeLn('Error: could not create ', ParamStr(2));
    Halt(3)
  end;

  SaveExit := ExitProc;
  ExitProc := @Stop;

  while not eof(InFile) do
  begin
    readln(InFile);
    Inc(NumLines);
  end;
  writeln('There are ',NumLines,' lines in this file.'#13#10);
  writeln('Press any key to stop the search for duplicate lines');
  NmLdiv80 := NumLines div 80;

  Root := nil;
  reset(InFile);
  while CurrentL <> NumLines do
  begin
    if KeyPressed then Halt { calls Stop };
    Inc(CurrentL);
    if (CurrentL AND NmLdiv80) = 0 then write('#');
    readln(InFile,TagLine);

    if root = nil then { first TagLine }
    begin
      New(Root);
      Root^.left := nil;
      Root^.right := nil;
      Root^.Info := TagLine;
      writeln(OutFile,tagLine)
    end
    else { binary search for TagLine }
    begin
      Current := Root;
      repeat
        Prev := Current;
        i := CompStr(Current^.Info,TagLine);
        if i > 0 then Current := Current^.left
        else
          if i < 0 then Current := Current^.right
      until (i = 0) or (Current = nil);

      if i <> 0 then { TagLine not found }
      begin
        New(Current);
        Current^.left := nil;
        Current^.right := nil;
        Current^.Info := TagLine;

        if i > 0 then Prev^.left := Current { Current before Prev }
                 else Prev^.right := Current { Current after Prev };
        writeln(OutFile,TagLine)
      end
    end
  end;
  writeln(#13#10'100% Completed, result is in file ',ParamStr(2))
  { close is done by Stop }
end.

 > I hope this compiles I took out some stuff that would display a little
 > picture of a sword and show the version and product name.
I put something like thta just in, again.

 > I also tried DJ's idea of the buffer of 65535 but it said the structure
 > was too large. So I used 64512.
Always try to use a multiple of 4K, because the hard disk 'eats' space in these
chunks. Reading/Writing in these chunks goes a lot faster that way.

Let me know if it isn't fast enough, or you want some more or something else.

Groetjes,
          Bob