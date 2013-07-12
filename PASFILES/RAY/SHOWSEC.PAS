Program ShowSecret;

Uses
{$IFDEF WINDOWS}
  WinCrt,WinTypes,WinProcs;
{$ELSE}
  Crt;
{$ENDIF}
Var
  i,z : Word;
  c   : Char;
Const
 Data0 : Array[0..4,0..68] of Char =
  ('CQX0CQ0UQ!usbotmbujpo!ufbn!nfncfst!boe!ifmq!tmbwft///]]Bmfyb!Lsvh]Cjs',
   'hju!Gvdit]Disjtujbo!Ckpfsotfo]Ebhnbs!Tdivm{]Ejfufs!Tusfimf]Gsbo{!Cjtt',
   'johfs]Gsfeez!Fsum]Johsje!Uplbs]Jov!Gpfstufs]Kvejui!Gvdit]Lbj!Kpvttfo]',
   'Lmbsb!Ptjboefs]Nbogsfe!Lptulb]Nbsujo!Sjdiufs]Nbuuijbt!Xjuipqg]Sbmqi!N',
   'bdiipm{]Tufmjpt!Utbpvtjejt]Vmj!Lpdi]Xjmgsjfe!Hjslfot]!!!!!!!...!!!!!!');
 Data1 : Array[1..32] of Char =
   'TipxTfdsfu]cz!Nbuuijbt!Xjuipqg/]';
Var
  Data2 : Array[1..SizeOf(Data0)] of Char Absolute Data0;

{$IFDEF WINDOWS}
  Procedure Delay(ms : LongInt);
  Var
    TickCount : LongInt;
    M         : TMsg;
  Begin
    TickCount := GetTickCount;
    While GetTickCount - TickCount < ms do
      If PeekMessage(M,0,0,0,pm_Remove) then
        Begin
          TranslateMessage(M); DispatchMessage(M);
        End;
  End;
{$ENDIF}

Begin
{$IFDEF WINDOWS}
  With ScreenSize do
    Begin
      x := 22; y := 10;
    End;
{$ENDIF}
  For i := 1 to SizeOf(Data2) do
    Begin
      c := Data2[i];
      If c = ']' then WriteLn else Write(Pred(c));
      Delay(100);
    End;
End.
