{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 285 of 354
From : Mark Lewis                          1:3634/12.0          14 Apr 93  17:12
To   : Kelly Small
Subj : Redirection of output...
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
 >  BC> Still need a bit of help here.  I can't redirect output from a
 >  BC> program when executing it from a Pascal program!  Is there any
 >  BC> this from Pascal? Any help would be greatly appreciated.
 > If I understand you, you are using the Exec procedure to run a
 > program.  IF that is the case you won't be ablr to redirect since
 > this is a function of Dos and not the program you exec.  You will
 > need to run the program through a child process in order to
 > perform the redirect, something like:
 > Exec(GetEnv('COMSPEC'),'/C MyProg.exe>redirect');

one could also utilize duplicate file handles -=B-)

ie: this source posted in here a year or so ago<<smile>>...}

{=============================================================}
Unit Execute;

Interface

Procedure Exec(Path,CmdLine : String);

Implementation

Uses Dos;

Function ExtractFileName(Var Line : String;Index : Integer) : String;

Var
  Temp : String;

Begin
  Delete(Line,Index,1);
  While (Index <= Length(Line)) AND (Line[Index] = ' ')
    Do Delete(Line,Index,1);
  Temp := '';
  While (Index <= Length(Line)) AND (Line[Index] <> ' ') Do
  Begin
    Temp := Temp + Line[Index];
    Delete(Line,Index,1);
  End;
  ExtractFileName := Temp;
End;

Procedure CloseHandle(Handle : Word);

Var
  Regs : Registers;

Begin
  With Regs Do
  Begin
    AH := $3E;
    BX := Handle;
    MsDos(Regs);
  End;
End;

Procedure Duplicate(SourceHandle : Word;Var TargetHandle : Word);

Var
  Regs : Registers;

Begin
  With Regs Do
  Begin
    AH := $45;
    BX := SourceHandle;
    MsDos(Regs);
    TargetHandle := AX;
  End;
End;

Procedure ForceDuplicate(SourceHandle : Word;Var TargetHandle : Word);

Var
  Regs : Registers;

Begin
  With Regs Do
  Begin
    AH := $46;
    BX := SourceHandle;
    CX := TargetHandle;
    MsDos(Regs);
    TargetHandle := AX;
  End;
End;

Procedure Exec(Path,CmdLine : String);

Var
  StdIn   : Word;
  Stdout  : Word;
  Index   : Integer;
  FName   : String[80];
  InFile  : Text;
  OutFile : Text;

  InHandle  : Word;
  OutHandle : Word;
         { ===============>>>> }   { change below for STDERR }
Begin
  StdIn := 0;
  StdOut := 1;                    { change to 2 for StdErr       }
  Duplicate(StdIn,InHandle);      { duplicate standard input     }
  Duplicate(StdOut,OutHandle);    { duplicate standard output    }
  Index := Pos('>',CmdLine);
  If Index > 0 Then               { check for output redirection }
  Begin
    FName := ExtractFileName(CmdLine,Index);  { get output file name  }
    Assign(OutFile,FName);                    { open a text file      }
    Rewrite(OutFile);                         { .. for output         }
    ForceDuplicate(TextRec(OutFile).Handle,StdOut);{ make output same }
  End;
  Index := Pos('<',CmdLine);
  If Index > 0 Then               { check for input redirection }
  Begin
    FName := ExtractFileName(CmdLine,Index);  { get input file name  }
    Assign(InFile,FName);                     { open a text file     }
    Reset(InFile);                            { for input            }
    ForceDuplicate(TextRec(InFile).Handle,StdIn);  { make input same }
  End;
  DOS.Exec(Path,CmdLine);           { run EXEC }
  ForceDuplicate(InHandle,StdIn);   { put standard input back to keyboard }
  ForceDuplicate(OutHandle,StdOut); { put standard output back to screen  }
  CloseHandle(InHandle);            { close the redirected input file     }
  CloseHandle(OutHandle);           { close the redirected output file    }
End;

End.

{===============================================================}
{
Use it exactly as you would the normal EXEC procedure:

  Exec('MASM.EXE','mystuff.asm');

To activate redirection simply add the redirection symbols, etc:

  Exec('MASM.EXE','mystuff.asm >err.lst');


One note of caution.  This routine temporarily uses extra handles. It's
either two or four more.  The various books I have are not clear as to
whether duplicated handles 'count' or not. My guess is yes.  If you don't
plan on redirecting STDIN then remove all the code for duplicating it to
cut your handle overhead in half.
}

i wish i could remember who posted it originally but i can't. if they happen to
be reading this, THANKS!