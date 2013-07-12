{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 250 of 298
From : David Solly                         1:163/215.0          12 Apr 93  11:20
To   : Moshe Harel
Subj : Letrix to Q-Text file 1/
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Moshe...

   Please find below the Turbo Pascal source code for the conversion
program for making Letrix Hebrew files into Q-Text 2.10 files.  I could
not find a way to make this conversion program convert embedded Roman
text without making it into a monster.  If you have any suggestions, I
would be thankful to the input.

========================= Cut Here ========================  }


Program LetrixQText;

{$D-}

Uses CRT, DOS;



VAR

  Infile, Transfile : Text;
  Infilenm, Transfilenm : PathStr;
  Letter, Ans : Char;
  Printable, HiASCII : Set of Char;



{
   "UpItsCase" is a function that takes a sting of any length and
   sets all of the characters in the string to upper case.  It is handy
   for comparing strings.
}

function UpItsCase (SourceStr : PathStr): PathStr;
var
  i  : integer;

begin
  for i := 1 to length(SourceStr) do
    SourceStr[i] := UpCase(SourceStr[i]);
  UpItsCase := SourceStr
end; {function UpItsCase}


Function Exist(fname : PathStr) : Boolean;

Var f : File;

BEGIN

{$F-,I-}
  Assign(f, fname);
  Reset(f);
  Close(f);
{$I+}

Exist := (IOResult = 0) AND (fname <> '')

END; {Function exist}

Procedure Help;

Begin
  Writeln;
  Writeln ('LTQT (Version 1.0)');
  Writeln ('Hebrew Text File Conversion');
  Writeln ('Letrix(R) 3.6 file to Q-Text 2.10 file');
  Writeln;
  Writeln;
  Writeln ('LTQT converts Letrix Hebrew format files to  Q-Text format files.');
  Writeln;
  Writeln ('LTQT expects two parameters on the command line.');
  Writeln ('The first parameter is the name of the file to convert,');
  Writeln ('the second is the name of the new file.');
  Writeln;
  Writeln ('Example:  LTQT  HKVTL.TXT HKVTL.HEB');
  Writeln;
  Writeln ('If no parameters are found, LTQT will display this message.');
  Writeln;
  Halt;

End; {Procedure Help}


{
  "ParseCommandLine" is a procedure that checks if any data was input
  at the DOS command line.  If no data is there, then the "Help"
  procedure is executed and the program is halted.  Otherwise, the
  Mode strig variable is set equal to the text on the command line.
}


procedure ParseCommandLine;
begin
  if (ParamCount = 0) or (ParamCount <> 2)
    then Help
    else
      begin
        Infilenm := ParamStr(1);
        Infilenm := UpItsCase(Infilenm);
        Transfilenm := ParamStr(2);
        Transfilenm := UpItsCase(Transfilenm);
      end;
end; {procedure ParseCommandLine}

Procedure OpenFiles;

BEGIN

  {Open input/output files}

  If not exist(Infilenm) then
    Begin
      Writeln;
      Writeln (Infilenm, ' not found');
      Halt;
    End
    Else
      Begin
        Assign (Infile, Infilenm);
        Reset (Infile);
      End;

  If exist (Transfilenm) then
    Begin
      Writeln;
      Writeln (Transfilenm, ' already exists!');
      Write ('Overwrite it?  (Y/N) > ');
      Repeat
        Ans := Readkey;
        Ans := Upcase(Ans);
        If Ans = 'N' then Halt;
      Until Ans = 'Y';
    End;

  Assign (Transfile, Transfilenm);
  Rewrite (Transfile);
  Writeln;

End; {Procedure OpenFiles}



Procedure LT_Table (VAR Letter : Char);

  {
    This section reviews each Letrix letter and matches it with a
    Q-Text equivalent where possible
  }

BEGIN

  CASE Letter of

    'a' : Write (Transfile, #128);
    'b', 'B','v' : Write (Transfile, #129);  {Vet, Bet}
    'g' : Write (Transfile, #130);
    'd' : Write (Transfile, #131);
    'h' : Write (Transfile, #132);
    'V', 'o', 'u', 'w' : Write (Transfile, #133); {Vav, Holem male, Shuruq}
    'z' : Write (Transfile, #134);
    'H' : Write (Transfile, #135);
    'T' : Write (Transfile, #136);
    'y', 'e' : Write (Transfile, #137); {Yod}
    'C', 'Q', 'W' : Write (Transfile, #138); {Khaf-Sofit}
    'c', 'K' : Write (Transfile, #139); {Khaf, Kaf}
    'l' : Write (Transfile, #140);
    'M' : Write (Transfile, #141);
    'm' : Write (Transfile, #142);
    'N' : Write (Transfile, #143);
    'n' : Write (Transfile, #144);
    'S' : Write (Transfile, #145);
    'i' : Write (Transfile, #146);
    'F' : Write (Transfile, #147);
    'p', 'P', 'f' : Write (Transfile, #148); {Fe, Pe}
    'X' : Write (Transfile, #149);
    'x' : Write (Transfile, #150);
    'k' : Write (Transfile, #151);
    'r' : Write (Transfile, #152);
    's' : Write (Transfile, #153);
    't' : Write (Transfile, #154);
    'A' : Write (Transfile, '-');

    {Niqudim and unused letters}

    'D','E', 'G', 'I', 'J', 'j', 'O', 'q', 'R', 'U', 'Y', 'Z' :
       Write(Transfile, '');
  else
    Write(Transfile, Letter);

  End; {Case of}

End; {Procedure LT_Table}


Procedure DoIt;


BEGIN


  {Transcription loop}

  While not eof(Infile) do

    Begin
      Read(Infile, Letter);


      If (Letter in Printable) then
        LT_Table(Letter);

      If (Letter in HiASCII) then
        Write(Transfile, Letter);


  End; {while}

{Close files}

Close (Transfile);
Close (Infile);

{Final message}

Writeln;
Writeln;
Writeln('LTQT Version 1.0');
Writeln('Hebrew Text File Conversion');
Writeln('Letrix(R) 3.6 file to Q-Text 2.10 file');
Writeln;
Writeln;
Writeln ('Letrix Hebrew file to Q-Text file conversion complete.');
Writeln;
Writeln('Special Note:');
Writeln;
Writeln ('Q-Text does not support either dagesh or niqudim (vowels).');
Writeln ('Letters containing a dagesh-qol are reduced to their simple form.');
Writeln ('Holam male and shuruq are transcribed as vav.  Roman letters used');
Writeln ('to represent niqudim are ignored.  All other symbols are transcribed');
Writeln ('without change.');
Writeln;
Writeln ('There is no foreign language check -- Anything that can be transcribed');
Writeln ('into Hebrew characters will be.');
Writeln;
Writeln ('LTQT was written and released to the public domain by David Solly');
Writeln ('Bibliotheca Sagittarii, Ottawa, Canada (8 December 1992).');
Writeln;

End; {Procedure DoIt}


BEGIN

  {Initialize Variables}
  Printable := [#10,#12,#13,#32..#127];
  HiASCII   := [#128..#154];

ParseCommandLine;
OpenFiles;
DoIt;

End.