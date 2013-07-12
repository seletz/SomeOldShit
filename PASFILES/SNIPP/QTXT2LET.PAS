{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 246 of 298
From : David Solly                         1:163/215.0          12 Apr 93  10:56
To   : Moshe Harel
Subj : Q-Text to Letrix File 1/
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
From Israel Moshe Harel was heard to say to David Solly

Thank you for taking the time to answer my many questions.  I have to
tell you, though, that I was lucky to have received your letter because
it was addressed to David SALLY and not David SOLLY.

MH>David,

MH> DS>    Are you familiar with a Hebrew text processor program called QTEXT?
  > DS> I have been able to obtain version 2.10 as public domain software but I
  > DS> am wondering if there has been an update.  Have you ever heard of a

MH>Current version of QTEXT is 5.0 and it is commercial :-(
  >It comes now with a full set of utilities, including FAX support.

Did you know that Q-Text version 2.10 was written in Turbo Pascal 3?  I
wonder if Itschak Maynts (Isaac Mainz?) has continued to use it in his
later versions.  Anyway, I would be interested in obtaining the latest
version of Q-Text.  Can you give me the distributor's address and the
approximate price?  Thank you.

MH>Most Israeli printers have a special ROM. You may use downloadable character
  >sets or even graphic printing if needed. I once used LETTRIX for this purpos
  >on a Hebrew-less printer, and it worked fine (but S L O W . . .).


I have Letrix 3.6.  This was what I was trying to use to print the
Q-Text files I was writing.  I wrote a program in Turbo Pascal to
convert the Q-Text files into Letrix files.  The printing is slow but
the results are favourable. Another advantage to Letrix Hebrew files is
that they are written completely in low-ASCII and almost readable
without transliteration if one is at all familiar with Hebrew. It is a
good format for posting Hebrew text on the Multi-Lingual echo not only
because it is low-ASCII but also because the method of transliteration
is consistent.

Below is my Q-Text file to Letrix file conversion program.  I hope you
will find it useful.

David Solly

==================== Cut Here ============================== }


Program QtextLetrix;

{$D-}

Uses CRT, DOS;


VAR

  Infile, Transfile : Text;
  Infilenm, Transfilenm : PathStr;
  Letter, Ans : Char;
  Printable, Hebrew, Niqud, Roman : Set of Char;
  Nkdm, Rom : Boolean;



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
  Writeln ('QTLT (Version 1.0)');
  Writeln ('Hebrew Text File Conversion');
  Writeln ('Q-Text 2.10 file to Letrix(R) 3.6 Hebrew file');
  Writeln;
  Writeln;
  Writeln ('QTLT converts Q-Text files to Letrix Hebrew format files.');
  Writeln;
  Writeln ('QTLT expects two parameters on the command line.');
  Writeln ('The first parameter is the name of the file to convert,');
  Writeln ('the second is the name of the new file.');
  Writeln;
  Writeln ('Example:  QTLT  HKVTL.HEB HKVTL.TXT');
  Writeln;
  Writeln ('If no parameters are found, QTLT will display this message.');
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





Procedure UseOfRoman;

Begin

  Writeln ('QTLT has detected Roman letters in the source text.');
  Writeln;
  Writeln ('Letrix expects access to a Roman font to print these characters');
  Writeln ('otherwise Letrix will report an error condition of fail to perform.');
  Writeln;
  Writeln ('Sample Letrix load instruction:  LX Hebrew Roman');
  Writeln;
  Writeln ('Be sure that these instances are enclosed within the proper');
  Writeln ('Letrix font switch codes so they are not printed as Hebrew characters');
  Writeln;

End; {Procedure UseOfRoman}


Procedure Niqudim (VAR Letter : Char);

  {
     Letrix uses some standard characters to represent niqudim
     while Q-Text does not.

     This table ensures that certain characters do not become
     niqudim when translated to Letrix by inserting the tokens
     which instruct the Letrix program to use the alternate
     alphabet -- which by default is number 2.
  }


BEGIN

  If Not Nkdm then
    Begin
      Writeln;
      Writeln ('QTLT has detected Q-Text characters which Letrix normally uses and');
      Writeln ('has transcribed them to print as normal characters.');
      Writeln;
      Writeln ('Letrix expects access a Roman font to print these characters');
      Writeln ('otherwise Letrix will report an error condition of fail to perform.');
      Writeln;
      Writeln ('Sample Letrix load instruction:  LX Hebrew Roman');
      Writeln;
      Nkdm := True;
    End; {if not Nkdm}

  CASE Letter of

    '!' : Write (Transfile, '\2!\1');
    '@' : Write (Transfile, '\2@\1');
    '#' : Write (Transfile, '\2#\1');
    '$' : Write (Transfile, '\2$\1');
    '%' : Write (Transfile, '\2%\1');
    '^' : Write (Transfile, '\2^\1');
    '&' : Write (Transfile, '\2&\1');
    '*' : Write (Transfile, '\2*\1');
    '(' : Write (Transfile, '\2(\1');
    ')' : Write (Transfile, '\2)\1');
    '+' : Write (Transfile, '\2+\1');
    '=' : Write (Transfile, '\2=\1');

  End; {Case}

End; {Procedure Nikudim}





Procedure QT_Table (VAR Letter : Char);

  {
    This section reviews each QText letter and matches it with a
    Letrix equivalent where possible
  }

BEGIN

  CASE Letter of

    #128 : Write (Transfile, 'a');  {Alef}
    #129 : Write (Transfile, 'b');  {Bet }
    #130 : Write (Transfile, 'g');  {Gimmel etc. }
    #131 : Write (Transfile, 'd');
    #132 : Write (Transfile, 'h');
    #133 : Write (Transfile, 'w');
    #134 : Write (Transfile, 'z');
    #135 : Write (Transfile, 'H');
    #136 : Write (Transfile, 'T');
    #137 : Write (Transfile, 'y');
    #138 : Write (Transfile, 'C');
    #139 : Write (Transfile, 'c');
    #140 : Write (Transfile, 'l');
    #141 : Write (Transfile, 'M');
    #142 : Write (Transfile, 'm');
    #143 : Write (Transfile, 'N');
    #144 : Write (Transfile, 'n');
    #145 : Write (Transfile, 'S');
    #146 : Write (Transfile, 'i');
    #147 : Write (Transfile, 'F');
    #148 : Write (Transfile, 'p');
    #149 : Write (Transfile, 'X');
    #150 : Write (Transfile, 'x');
    #151 : Write (Transfile, 'k');
    #152 : Write (Transfile, 'r');
    #153 : Write (Transfile, 's');
    #154 : Write (Transfile, 't');

  End; {Case of}

End; {Procedure QT_Table}


Procedure DoIt;


  {
    Special commands requred by Letrix.
    Proportional spacing off, line justification off,
    double-strike on, pitch set to 12 characters per inch.
  }

BEGIN

  Writeln(transfile,'\p\j\D\#12');

  {Transcription loop}

  While not eof(Infile) do

    Begin
      Read(Infile, Letter);

      If (Letter in Printable) then
        Write(Transfile, Letter);

      If (Letter in Niqud) then
        Niqudim(Letter);

      If (Letter in Hebrew) then
        QT_Table(Letter);

      If (Letter in Roman) and (Rom = False) then
        Begin
          UseOfRoman;
          Rom := True;
      End; {Roman Detection}
  End; {while}

{Close files}

Close (Transfile);
Close (Infile);

{Final message}

Writeln;
Writeln;
Writeln('QTLT (Version 1.0)');
Writeln('Hebrew Text File Conversion');
Writeln('Q-Text 2.10 files to Letrix(R) 3.6 Hebrew file');
Writeln;
Writeln ('Task Complete');
Writeln;
Writeln ('QTLT was written and released to the public domain by David Solly');
Writeln ('Bibliotheca Sagittarii, Ottawa, Canada (2 December 1992).');
Writeln;

End; {Procedure DoIt}


BEGIN

  {Initialize Variables}
  Printable := [#10,#12,#13,#32..#127];
  Roman     := ['A'..'Z','a'..'z'];
  Niqud     := ['!','@','#','$','%','^','&','*','(',')','+','='];
  Printable := Printable - Niqud;
  Hebrew    := [#128..#154];
  Rom       := False;
  Nkdm      := False;

ParseCommandLine;
OpenFiles;
DoIt;

End.


 * QMPro 1.0 42-0714 * Bibliotheca Sagittarii, Ottawa, Canada

--- Maximus 2.01wb
 * Origin: BitByters BBS, Rockland ON, 446-6234, HST, (1:163/215)

