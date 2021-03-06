{� Fido Pascal Conference ���������������������������������������������� PASCAL �
Msg  : 299 of 318                                                               
From : Bo Bendtsen                         2:231/111.0          09 Apr 93  12:28 
To   : All                                                                       
Subj : International characters                                               
��������������������������������������������������������������������������������
Hello All!          


  Upper/lower changing of strings are always a difficult problem,
  but as a person living in Denmark i must normally care about
  danish characters, i know a lot of developers does not care about
  international character and just use the normal UPCASE routines.
  I advise you to use these routines or make some that has the
  same effect, so we will not have any problems when searching for
  uppercased strings.

  Made available to everyone 1993 by Bo Bendtsen 2:231/111 +4542643827

     Lowcase   Upper/high/capital letters
     �         �
     �         �
     �         �
     �         �
     �         �
     �         �
     �         �
     �         �
     �         �

}
Unit IntChar;
(**) INTERFACE (**)
Function UpChar(Ch : Char) : Char;
Function StUpCase(S : String) : String;
Function LowChar(Ch : Char) : Char;
Function StLowCase(S : String) : String;
Function StToggleCase(S : String) : String;
Function StSmartCase(S : String) : String;

(**) IMPLEMENTATION (**)
Function UpChar(Ch : Char) : Char;
{ Uppercase a char }
Begin
  If Ord(Ch) In [97..122] Then Ch := Chr(Ord(Ch) - 32)
  Else If Ord(Ch) > 90 Then
    If Ch='�' Then Ch:='�'
    Else If Ch='�' Then Ch:='�' Else If Ch='�' Then Ch:='�'
    Else If Ch='�' Then Ch:='�' Else If Ch='�' Then Ch:='�'
    Else If Ch='�' Then Ch:='�' Else If Ch='�' Then Ch:='�'
    Else If Ch='�' Then Ch:='�' Else If Ch='�' Then Ch:='�';
  UpChar:=Ch;
End;

Function StUpCase(S : String) : String;
{ Uppercase a string }
Var
  SLen : Byte Absolute S;
  x    : Integer;
Begin
  For x := 1 To SLen Do S[x]:=UpChar(S[x]);
  StUpCase := S;
End;

Function LowChar(Ch : Char) : Char;
{ lowercase a char }
Begin
  If Ord(Ch) In [65..90] Then Ch := Chr(Ord(Ch) + 32)
  Else If Ord(Ch) > 122 Then
    If Ch='�' Then Ch:='�'
    Else If Ch='�' Then Ch:='�' Else If Ch='�' Then Ch:='�'
    Else If Ch='�' Then Ch:='�' Else If Ch='�' Then Ch:='�'
    Else If Ch='�' Then Ch:='�' Else If Ch='�' Then Ch:='�'
    Else If Ch='�' Then Ch:='�' Else If Ch='�' Then Ch:='�';
  LowChar := Ch;
End;

Function StLowCase(S : String) : String;
{ Lowercase a string }
Var
  SLen : Byte Absolute S;
  i    : Integer;
Begin
  For i := 1 To SLen Do S[i]:=LowChar(S[i]);
  StLowCase := S;
End;

Function StToggleCase(S : String) : String;
{ lower = upper and upper = lower }
Var
  SLen : Byte Absolute S;
  i    : Integer;
Begin
  For i := 1 To SLen Do
  Begin
    If Ord(S[i]) In [65..90] Then S[i] := Chr(Ord(S[i]) + 32)
    Else If Ord(S[i]) In [97..122] Then S[i] := Chr(Ord(S[i]) - 32)
    Else If Pos(S[i],'���������') <> 0 Then S[i]:=UpChar(S[i])
    Else If Pos(S[i],'���������')<> 0 Then S[i]:=LowChar(S[i]);
  End;
  StToggleCase := S;
End;

Function StSmartCase(S : String) : String;
{ bO bEnDTSen will be converted into : Bo Bendtsen }
Var
  SLen : Byte Absolute S;
  i    : Integer;
Begin
  s:=StLowCase(s);
  For i := 1 To SLen Do
  Begin
    If i=1 Then S[1]:=UpChar(S[1])
    Else if S[i-1]=' ' Then S[i]:=UpChar(S[i])
    Else if (Ord(S[i-1]) In [32..64]) And (S[i-1]<>'''') Then
S[i]:=UpChar(S[i]);
  End;
  StSmartCase := S;
End;



End.