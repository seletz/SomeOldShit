� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 284 of 354                                                               
From : Mark Lewis                          1:3634/12.0          14 Apr 93  17:07 
To   : Matt Alberts                        1:2210/7956.0                         
Subj : Too Many Open Files..                                                  
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
 > But it errors out (number 4: too many open files) when it really
 > gets into the middle of it.. It works but cannot complete the job..
 > IS there anything I can do to stop this..?

there are a couple of ways to handle this...

1. increase your FILES= entry in your CONFIG.SYS -=B-)

2. trap for the error 4 and handle it in one of the following ways...

  a. use bits to track open files.
       ie: as you open each file, toggle a bit in a var on for
           =THAT= file. when you get the error 4, close a file,
           toggle it's bit off, open the one you are trying to
           write to and toggle it's bit on.
     keep doing this until the job is done. this method really takes
     a lot more work but you will be able to handle most situations
     where there are not enough file handles to go around.

  b. close all open files, clean up, log the error, go home.

3. this one is like 2a... you know how many files you'll need open at one time,
so you can use something like the following routine to see how many are
available. once you know how many are available, you can then decide whether to
abort before the error has a chance to happen, continue on in a modified
operation that doesn't open all the files at once, or do another procedure like
2a...

the following routine (posted in here back in 1991 [hi mike!]) prints the open 
files. i would probably modify it to be a FUNCTION instead of a procedure like 
it is now and also remove the printing part. then you could do something
like...

{read CONFIG.SYS to get FILES= number into FILES_IN_CONFIG}
if (FILES_IN_CONFIG - Number_Of_Open_Files) < Number_Open_Files_Needed
  then begin
         writeln('not enough file handles to work with!');
         writeln('please adjust FILES entry in CONFIG.SYS');
         halt; end;

there may be another way but this is what i came up with real quickly...

{
(244)   Sun 20 Oct 91  1:56p
By: mike janke
To: Michael Reece
Re: files open
----------------------------------------------------------------------
 > Is there any way to list, and even possibly close, all
 > files currently open (ie in an exitproc)?

The following code will list (in readable text form) all open files
(including CON, PRN, etc.).  I don't recall where I got this..
might have been right here in the Pascal conference.

As for closing, I don't know of a simple way like BASIC's global
"CLOSE" :-).

  -mike

{---------------------------------------------------}

Procedure WriteOpenFiles;
type
  openfilerec = record
    numtimes : word;
    junk1 : array[2..$1f] of byte;
    filename : array[$20..$2a] of char;
    junk2 : array[$2b..$34] of byte;
  end;

  filelistptr = ^filelistrec;
  filelistrec = record
    next : filelistptr;
    numfiles : word;
    files : array[1..1] of openfilerec;
  end;

var
  r : registers;
  list : filelistptr;
  i : word;

begin
  if lo(dosversion) <> 3 then
   exit;
  with r do
  begin
    ah := $52;
    msdos(r);                {Get the list of lists in ES:BX}
    list := Pointer (MemL[es:bx+4]);    {Get the first open file list }
    while ofs(list^) <> $FFFF do
    begin
      with list^ do
        for i:=1 to numfiles do   { Print each of its files }
          with files[i] do
            if numtimes > 0 then  { but only if they're open }
              writeln(filename);
      list := list^.next;         { Go to the next file list }
    end;
  end;
end; {procedure WriteOpenFiles}


this will definitly need modification... as written, it will only work with DOS
3.xx... also, don't forget to account for CON, PRN, and the others like it
mentions in the quoted text...

you might be able to get away with checking LIST^.NUMFILES instead of doing the
while loop and incrementing a counter. i don't know right now and can't try it 
to see... have fun and play with it...

)\/(ark

--- FastEcho 1.25
 * Origin:  (1:3634/12)

