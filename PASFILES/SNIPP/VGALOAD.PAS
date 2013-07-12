� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 582 of 702                                                               
From : Alex Summers                        1:103/714.0          22 Apr 93  02:05 
To   : All                                                                       
Subj : VGA Loaders                                                            
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
{      
     I'm assuming that you don't understand the concept of video memory, so  
I'll start off from the basics then.  Video memory is defined (for our own  
purposes) as the memory that the video board scans in determining what signals 
(analog) to send to the monitor.  In graphics mode, the segment of the location

of this is determined by what type of video mode you are on - 
VGA/EGA modes = $A000 ($=hex), CGA modes = $B800, and Herc = $B000.  The 
offsets always start off at $0. 
 
     Now, what type of organization are the pixels (since we're in graphics  
mode) stored in?  Because of the simplicity of Mode $13 (320x200x256), most 
VGA intros are written using this.  I'm not about to go ahead and explain to 
you the other VGA modes dealing in the color planes, EGA/VGA registers,etc in 
the higher resolution modes, there are a couple of good books out there that 
can handle those of you interested in that.  Try your local bookstores and look
for Power Graphics Programming by Michael Abrash, which contains his articles  
about higher resolution VGA programming from Programmer's Journal.  HIGHLY  
recommendable.  In any case, in this mode, each pixel on the screen  
corresponds to exactly 1 byte on the video memory.  For example, location 
(0,0) = Mem[$A000:0], (1,0) = Mem[$A000:1], (2,0) = Mem[A000:2], and so on. 
Fairly easy eh?  Because the memory map is linear, the next line would just be 
the next byte AFTER the previous line's last pixel.  For example, location 
(0,319) = Mem[$A000:319], AND THEN location (1,0) = Mem[$A000:320].  And the  
formula for determining the video memory location is 
 
     Video Mem Offset = YPos*320 + XPos 
 
     The actual color of the byte values stored in the video memory is 
flexible and can be changed to any color of the 256,000 palette of the VGA. 
This can be accomplished by altering the VGA Video DAC registers at port 
addresses $3C6 through $3C9.  To read the current settings, set the Table 
Read Index (port $3C7) to the color value you want, and then read the three 
values from the Table Data Register (port $3C9) (one each for Red, Green, and 
Blue).  Once three values have been read from that port, the current read 
index is incremented by one and the next three 6 bit (range of 2, or 0 to 63) 
values read are for the next color value.  Writing the to the Video DAC is 
similar, except the Table Write Index is port $3C8.  Again, after writing 
three successive 6 bit values to the Table Data Registers increments the Write 
Index by one.  By the way, all the reference information about the Video DAC's 
can be obtained from any EGA/VGA reference book.  I recommend getting 
Advanced Programmer's Guide to the EGA/VGA by George Sutty and Steve Blair. 
 
     Waiting for the vertical retrace start signal before updating the video 
memory is the key to smooth animation (with a quick memory update too of 
course).  The idea is to have the screen changes "pop up" before your eyes, and

to do this, you need to make your changes just before the the screen trace 
of the video memory occurs.  For this reason, updating the video memory had 
better fast enough, and generally this is the part done in assembly.  The 
important port and bit locations, and a sample implementation are as follows: 
 
       In Pascal: 
 
         Repeat Until (Port[$3DA] And $08) = 0; 
         Repeat Until (Port[$3DA] And $08) <> 0; 
 
       And in Assembly: 
 
                   MOV   DX,3DAh 
         Wait:     IN    AL,DX 
                   TEST  AL,08h 
                   JZ    Wait 
         Retr:     IN    AL,DX 
                   TEST  AL,08h 
                   JNZ   Retr 
 
 
     And finally, how to get the characters on the screen.  I used the old 
character set that's stored in BIOS because it saves time and space (instead 
of capturing a graphical message).  The memory address for this is 
$F000:$FA6E.  Because the character set is 8 bits by 8 bits, each character 
takes up 8 bytes, each byte representing a horizontal slice of the character. 
It's really not that confusing after fiddling around with it. 
} 
 
Program PaletteTricks; 
 
  Uses Crt; 
 
 
  Const CGA_CharSet_Seg = $0F000; 
        CGA_CharSet_Ofs = $0FA6E; 
        CharLength      = 8; 
        NumChars        = 256; 
        VGA_Segment     = $0A000; 
        NumCycles       = 200; 
        Radius          = 80; 
 
        DispStr         : String = 
'Loader by THG'; 
 
        Colors : Array[1..15*3] Of Byte = 
                 (  7,  7, 63, 
                   15, 15, 63, 
                   23, 23, 63, 
                   31, 31, 63, 
                   39, 39, 63, 
                   47, 47, 63, 
                   55, 55, 63, 
                   63, 63, 63, 
                   55, 55, 63, 
                   47, 47, 63, 
                   39, 39, 63, 
                   31, 31, 63, 
                   23, 23, 63, 
                   15, 15, 63, 
                    7,  7, 63  ); 
 
 
Type  OneChar =Array[1..CharLength] Of Byte; 
 
 
Var   CharSet : Array[1..NumChars] Of OneChar; 
      Locs    : Array[1..NumCycles] Of Integer; 
      BarLocs : Array[1..4] Of Integer; 
 
 
  Procedure GetChars; 
 
    Var NumCounter, 
        ByteCounter, 
        MemCounter   :Integer; 
   
    Begin { GetChars } 
      MemCounter:=0; 
      For NumCounter:=1 To NumChars Do 
        For ByteCounter:=1 To CharLength Do 
          Begin 
           
CharSet[NumCounter][ByteCounter]:=Mem[CGA_CharSet_Seg:CGA_CharSet_Ofs          
Inc(MemCounter); 
          End; 
    End;  { GetChars } 
 
 
  Procedure VideoMode ( Mode : Byte ); 
 
    Begin { VideoMode } 
      Asm 
        Mov  AH,00 
        Mov  AL,Mode 
        Int  10h 
      End; 
    End;  { VideoMode } 
 
 
  Procedure SetColor ( Color, Red, Green, Blue : Byte ); 
 
    Begin { SetColor } 
      Port[$3C8] := Color; 
      Port[$3C9] := Red; 
      Port[$3C9] := Green; 
      Port[$3C9] := Blue; 
    End;  { SetColor } 
 
 
  Procedure DispVert ( Var CurrLine : Integer ); 
 
    Var Letter : OneChar; 
        VertLine, 
        Count  : Integer; 
 
    Begin { DispVert }

      Letter := CharSet[Ord(DispStr[(CurrLine Div 8)+1])+1]; 
      VertLine := (CurrLine-1) Mod 8; 
      For Count := 1 To 8 Do 
        If Letter[Count] And ($80 Shr VertLine) = 0 
          Then Mem[VGA_Segment:185*320+(Count-1)*320+319] := 0 
          Else Mem[VGa_Segment:185*320+(Count-1)*320+319] := 181; 
    End;  { DispVert } 
 
 
  Procedure CalcLocs; 
 
    Var Count : Integer; 
 
    Begin { CalcLocs } 
      For Count := 1 To NumCycles Do 
        Locs[Count] := Round(Radius*Sin((2*Pi/NumCycles)*Count))+Radius+1; 
    End;  { CalcLocs } 
 
 
    Procedure DoCycle; 
 
      Label Wait,Retr,BarLoop,PrevIsLast,Continue1,Continue2,Rep1,Rep2; 
 
      Begin { DoCycle } 
        Asm 
 
          MOV   DX,3DAh 
Wait:     IN    AL,DX 
          TEST  AL,08h 
          JZ    Wait 
Retr:     IN    AL,DX 
          TEST  AL,08h 
          JNZ   Retr 
 
{ Do Bars... } 
 
           MOV   BX,0 
BarLoop: 
           PUSH  BX 
           MOV   AX,Word Ptr BarLocs[BX] 
           MOV   BX,AX 
           DEC   BX 
           SHL   BX,1 
           MOV   AX,Word Ptr Locs[BX] 
           PUSH  AX 
           CMP   BX,0 
           JE    PrevIsLast 
           DEC   BX 
           DEC   BX 
           MOV   AX,Word Ptr Locs[BX] 
           JMP   Continue1 
 
PrevIsLast: 
           MOV   AX,Word Ptr Locs[(NumCycles-1)*2] 
 
Continue1: 
           MOV   DX,03C8h 
           OUT   DX,AL 
           INC   DX 
           MOV   CX,15*3 
           MOV   AL,0 
Rep1: 
           OUT   DX,AL 
           LOOP  Rep1 
 
           DEC   DX 
           POP   AX 
           OUT   DX,AL 
           INC   DX 
           MOV   CX,15*3 
           XOR   BX,BX 
Rep2: 
           MOV   AL,Byte Ptr Colors[BX] 
           OUT   DX,AL 
           INC   BX 
           LOOP  Rep2 
 
           POP   BX 
           INC   Word Ptr BarLocs[BX] 
           CMP   Word Ptr BarLocs[BX],NumCycles 
           JNG   Continue2 
 
           Mov   Word Ptr BarLocs[BX],1 
Continue2: 
           INC   BX 
           INC   BX 
           CMP   BX,8 
           JNE   BarLoop 
 
        End; 
      End;  { DoCycle } 
 
 
  Var CurrVert, 
      Count     : Integer; 
      Key       : Char; 
      MemPos    : Word; 
 
  Begin { PaletteTricks } 
 
    VideoMode($13); 
    Port[$3C8] := 1; 
    For Count := 1 To 180 Do 
      SetColor(Count,0,0,0); 
    MemPos := 0; 
    For Count := 1 To 180 Do 
      Begin 
        FillChar(Mem[VGA_Segment:MemPos],320,Chr(Count)); 
        MemPos := MemPos + 320; 
      End; 
    SetColor(181,63,63,0); 
    CalcLocs; 
    For Count := 1 To 4 Do 
      BarLocs[Count] := Count*10; 
 
    GetChars; 
    CurrVert := 1; 
    Repeat 
      DoCycle; 
      For Count := 1 To 8 Do 
        Move(Mem[VGA_Segment:185*320+(Count-1)*320+1], 
             Mem[VGA_Segment:185*320+(Count-1)*320],319); 
      DispVert(CurrVert); 
      Inc(CurrVert); 
      If CurrVert > Length(DispStr) * 8 
        Then CurrVert := 1; 
 
    Until Keypressed; 
    Key := ReadKey; 
    VideoMode(3); 
  End.  { PaletteTricks } 
 
... OFFLINE 1.41 

--- Squish v1.01
 * Origin: Starbase Atlantis (1:103/714)

