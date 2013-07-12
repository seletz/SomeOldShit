{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 458 of 535
From : Ken Burrows                         1:249/201.21         19 Apr 93  18:33
To   : All
Subj : Collecting Objects
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

Well, here I go again. There have been a few messages here and there regarding
collections and objects and streams. I've been trying to grapple with how
things work, and sometimes I win and sometimes I lose. The following code is my
rendition of a useful TObject Descendent. It is completely collectable and
streamable. Feel free to dismiss it offhand if you like.}

Unit TBase3;  {BP 7.0}
              {released to the public domain by ken burrows}
interface
Uses objects,memory;
Type
    TBase = object(TObject)
              Data : Pointer;
              constructor Init(Var Buf;n:longint);
              Constructor Load(Var S:TStream);
              Procedure Store(Var S:TStream); virtual;
              Destructor Done; virtual;
              Private
              Size : LongInt;
            end;
   PBase = ^TBase;
Const
  RBaseRec : TStreamRec = (ObjType : 19560;
                           VMTLink : Ofs(TypeOf(TBase)^);
                           Load    : @TBase.Load;
                           Store   : @TBase.Store);

Procedure RegisterTBase;
implementation

Constructor TBase.Init(Var Buf;n:longint);
   Begin
     Data := MemAlloc(n);
     if   Data <> Nil
     then begin
            size := n;
            move(Buf,Data^,size);
          end
     else size := 0;
   End;
Constructor TBase.Load(Var S:TStream);
   Begin
     size := 0;
     S.Read(size,4);
     if   (S.Status = StOk) and (size <> 0)
     then begin
            Data := MemAlloc(size);
            if   Data <> Nil 
            then Begin
                   S.read(Data^,size);
                   if   S.Status <> StOk
                   then begin
                          FreeMem(Data,size);
                          size := 0;
                        end;
                 End
            else size := 0; 
          end 
     else Data := Nil;
   End;
Procedure TBase.Store(Var S:TStream);
   begin
     S.write(size,4);
     if Data <> Nil
     then S.Write(Data^,Size);
   End;
Destructor TBase.Done;
   begin
     if Data <> Nil then FreeMem(Data,size);
   end;

Procedure RegisterTBase;
   Begin
     RegisterType(RBaseRec);
   End;
End.



Program TestTBase3; {bare bones make/store/load/display a collection}
                    {collected type defined locally to the program}

uses objects,tbase3;

Procedure ShowStuff(P:PCollection);
   Procedure ShowIt(Pb:PBase); far;
      begin
        if Pb^.Data <> Nil then Writeln(PString(Pb^.Data)^);
      end;
   Begin
     P^.ForEach(@ShowIt);
   End;

Var
A_Collection : PCollection;
A_Stream     : TDosStream;
S            : String;
m            : longint;

Begin
  m := memavail; RegisterTBase;
  New(A_Collection,init(5,2));
  Repeat
    writeln; write('enter some string : '); Readln(S);
    if   S <> ''
    then A_Collection^.insert(New(PBase,init(S,Length(S)+1)));
  Until S = '';
  writeln; writeln('Storing the collection...');
  A_Stream.init('Test.TB3',stCreate);
  A_Collection^.Store(A_Stream);
  writeln; writeln('Storing Done. ');
  dispose(A_Collection,done); A_Stream.done;
  writeln; writeln('Disposing of Stream and Collection ...');
  if   m = memavail
  then writeln('memory fully released')
  else writeln('memory not fully released');
  write('Press [ENTER] to [continue] ...'); readln;
  writeln;
  writeln('Constructing a new collection using the LOAD constructor');
  A_Stream.init('Test.TB3',stOpenRead);
  New(A_Collection,Load(A_Stream));
  A_Stream.done;
  Writeln; ShowStuff(A_Collection);
  writeln; writeln('Disposing of Stream and Collection ...');
  dispose(A_Collection,done);
  if   m = memavail
  then writeln('memory fully released')
  else writeln('memory not fully released');
  write('Press [ENTER] to [EXIT] ...'); readln;
End.

The above code has been tested and works just fine. By defining what I put into
the object and typecasting it when I take it out, I can collect and store and
load just about anything without ever haveing to descend either the
TCollection, TBase or the TDosStream objects. In the case of the above program,
I elected to collect simple strings. It might just as well have been any other 
type of complex record structure. 

This program was written solely for the purpose of discovering how the objects 
behave and possibly to even learn something. Any comments, discussions or
flames are always welcome.

...ken