{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 393 of 473
From : Hagen Lehmann                       2:244/59.1           12 Apr 93  14:00
To   : Timothy Glenn
Subj : Search procedure
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Hi Timothy,

> TG> Can someone help me make a search procedure that will read
> TG> from a record format, from the disk!!!

The easiest way to search a record in a file is to read the records from file
and compare them with the record that is to be searched.

If you simply want to search for a string then I've got something for you. ;-)
Look at this function: }
 
        Function Search(SearchFor : String;
                        FileName  : String) : LongInt;
        Var F               : File;
            Pos,Dummy       : LongInt;
            BufSize,ReadNum : Word;
            Buffer          : ^Byte;
            Found           : Boolean;
 
         Function SearchString(Var Data;
                               Size : Word;
                               Str  : String) : LongInt;
         Var S     : String;
             Loop  : LongInt;
             Found : Boolean;
             L     : Byte ABSOLUTE Str;
         Begin
           Loop  := -1;
           Found := False;
           If L>0 Then   { I don't search for empty strings, I'm not crazy }
            Repeat
              Inc(Loop);
              Move(Mem[Seg(Data):Loop],       { convert buffer into string }
                   Mem[Seg(S):Ofs(S)+1],L+1);
              S[0] := Char(L);
              If S=Str Then Found := True;             { search for string }
            Until Found Or (Loop=Size-L);
           If Found Then SearchString := Loop   { that's the file position }
           Else          SearchString := -1;    { I couldn't find anything }
         End;
 
        Begin
          Search := -1;
          If MaxAvail>65535 Then BufSize := 65535   { check available heap }
          Else                   BufSize := MaxAvail;
          If (BufSize>0) And (BufSize>Length(SearchFor)) Then
         Begin
           GetMem(Buffer,BufSize);               { reserve heap for buffer }
           Assign(F,FileName);
           Reset(F,1);                                         { open file }
           If IOResult=0 Then
          Begin
            Pos   := 0;
            Found := False;
            Repeat
              BlockRead(F,Buffer^,BufSize,ReadNum);          { read buffer }
              If ReadNum>0 Then                             { anything ok? }
             Begin
               Dummy := SearchString(Buffer^,ReadNum,SearchFor);
               If Dummy<>-1 Then                   { string has been found }
              Begin
                Found := True;                            { set found flag }
                Inc(Pos,Dummy);
              End
              Else
              Begin
                Inc(Pos,ReadNum-Length(SearchFor));
                Seek(F,Pos);                       { set new file position }
              End;
             End;
            Until Found Or (ReadNum<>BufSize);
            If Found Then Search := Pos            { string has been found }
            Else          Search := -1;         { string hasn't been found }
            Close(F);
          End;
           Release(Buffer);                        { release reserved heap }
         End;
        End;