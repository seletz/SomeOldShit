{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 357 of 367
From : Tom Lawrence                        1:2605/606.0         11 Apr 93  23:56
To   : Andrew Fort
Subj : Data structures
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
 > Yep, you people out there may notice that in fact this is an extended
 > fidonet type-2 mail packet packed message header.. I know you cannot
 > just blockread this, since the DateTime/ToName/FromName/Subject
 > fields are null-terminated, so how do I do it?

    I usually Blockread the header up to the To field (the Date is null
terminated, but it's always 20 characters).  Then, Blockread in the 36
characters for the To field, look for the #0, and move the file pointer back..
for example, suppose you blockread in 36 bytes, and the 0 was at the 17th
cell...  36-17=19, so you'd move the file pointer back 19 bytes
(Seek(F),FilePos(F)-19), then do the same thing with the From field, then the
subject.  Or, if you want, Blockread 144 bytes into a buffer, extract each
string, and seek back in the file only once.  StrTok is a handy function to use
for this, taken from C's StrTok function...  here's some sample code: }

{********************************************************************}
Function StrTok(Var S:String;Tokens:String):String;
Var X,
    Y,
    Min:Byte;
    T:String;
Begin
    While Pos(S[1],Tokens)>0 Do
    Begin
        Delete(S,1,1);
        If S='' Then Exit;
    End;
    Min:=Length(S);
    For X:=1 to Length(Tokens) Do
    Begin
        Y:=Pos(Tokens[X],S);
        If (Y>0) and (Y<Min) Then Min:=Y;
    End;

    If Min<Length(S) Then T:=Copy(S,1,Min-1)
        Else T:=Copy(S,1,Min);
    Delete(S,1,Min);
    If Pos(T[Length(T)],Tokens)>0 Then Dec(T[0]);
    StrTok:=T;
End;
{********************************************************************}
Var F:File;
    S:String;
    BytesRead:Word;
Begin
    {* Assuming F is assigned to the message, opened, and you've
       already read up to and including the Data field *}
    BlockRead(F,S[1],144,BytesRead);
    S[0]:=Char(Lo(BytesRead));
    Message_To:=StrTok(S,#0);
    Message_From:=StrTok(S,#0);
    Message_Subject:=StrTok(S,#0);
    Seek(F,FilePos(F)-(BytesRead-(Length(Message_To)+Length(Message_From)
         +Length(Message_Subject))));
End.