Program hexdump;
Uses
  crt, DOS;
Const
  hx: Array [0..15] Of Char = '0123456789ABCDEF';
  
Function hex2 (w: Word): String;
Begin
  hex2 := hx [ (w ShR 4) And 15] + hx [w And 15];
End;
Function hex4 (w: Word): String;
Begin
  hex4 := hex2 (Hi (w) ) + hex2 (Lo (w) );
End;
Procedure show (Buffer: Array Of Byte);
Var
  i: Integer;
Begin
  For i := 0 To 15 Do
  begin
    if (i mod 4) =0 then write(' ');
    Write ('$', hex2 (Buffer [i] ), ' ');
  end;
  WriteLn;
End;
Var
  FromF: File;
  count, NumRead: Word;
  Buf: Array [1..16] Of Byte;
Begin
  If ParamStr (1) <> '' Then
  Begin
    Assign (FromF, ParamStr (1) ); { Open input file }
    Reset (FromF, 1);  { Record size = 1 }
    count := 1;
    Repeat
      BlockRead (FromF, Buf, SizeOf (Buf), NumRead);
      If (count Mod 20) = 0 Then begin
				Repeat Until KeyPressed;
        readln;
      end;
      Write ( '$', hex4 (count), ' | ');
      show (buf);
      Inc (count);
    Until (NumRead = 0) ;
    Close (FromF);
  End
End.
