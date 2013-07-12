{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 247 of 267
From : Salim Samaha                        1:167/110.0          14 Apr 93  16:28
To   : Tyson Brown
Subj : Pop-Up menus.
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
If I remember right, you wanted to know how to open and close windows in text
mode, here is a unit I wrote a while ago. I hope it helps. }

Unit Windows;
Interface
Uses Crt;
 
Const
   Max = 3;
 
Type
   ScreenImage = Array[0..1999] of word;
   FrameRec    = Record
                    Upperleft    : Word;
                    LowerRight   : Word;
                    ScreenMemory : ScreenImage;
                 End;
 
VAR
   SnapShot     : ^ScreenImage;
   FrameStore   : Array [1..10] of ^FrameRec;
   WindowNum    : Byte;
 
Procedure OpenWindow(UpLeftX,UpLeftY,LoRightX,LoRightY : Byte);
Procedure CloseWindow;
 
Implementation
 
Procedure OpenWindow(UpLeftX,UpLeftY,LoRightX,LoRightY : Byte);
Begin
   SnapShot := Ptr( $B800, $0000);
   Inc(WindowNum);
   New(FrameStore[WindowNum]);
   WITH Framestore[WindowNum]^ do
   Begin
      ScreenMemory := SnapShot^;
      UpperLeft    := WindMin;
      LowerRight   := WindMax;
   end;
   Window(UpLeftX,UpLeftY,LoRightX,LoRightY);
end;

Procedure CloseWindow;
Begin
   With Framestore[WindowNum]^ do
   Begin
      Snapshot^ := ScreenMemory;
      Window ( (Lo(UpperLeft)+1), (Hi(UpperLeft)+1),
             (Lo(LowerRight)+1), (Hi(LowerRight)+1) );
   end;
   Dispose( Framestore[WindowNum]);
   Dec(WindowNum);
End;
 
Begin
End.


If you have any questions on this unit, feel free to ask.

                                SAL