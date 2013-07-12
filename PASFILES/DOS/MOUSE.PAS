{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X-}
(*===================================================================*)
(*                             MOUSE.PAS                             *)
(*            Copyright (C) 1993 te-wi Verlag, MÅnchen               *)
(*    Unit mit den wichtigsten Interface-Routinen zum Maustreiber    *)
(*===================================================================*)
UNIT Mouse;

INTERFACE

TYPE
  tButton = (None, Left, Right, Middle);        (* Namen der Buttons *)

PROCEDURE InitMouse;            (* Initialisierung der Maus          *)
FUNCTION  ButtonNum: BYTE;      (* Liefert die Anzahl der Mausknîpfe *)
PROCEDURE DisplayCursor;        (* Schaltet den Mauscursor ein       *)
PROCEDURE HideCursor;           (* Schaltet den Mauscursor ab        *)
FUNCTION  WhereX: INTEGER;      (* Liefert die aktuelle X-Koordinate *)
FUNCTION  WhereY: INTEGER;      (* Liefert die aktuelle Y-Koordinate *)
PROCEDURE SetPos(x, y: INTEGER); (* Setzt den Mauscursor nach X/Y    *)
PROCEDURE SetMickeys(x, y: INTEGER); (* Setzen der Mausgeschwindigk. *)
PROCEDURE GetMickeys(VAR x, y: INTEGER); (* Lesen der M.-Geschwind.  *)
FUNCTION  Pressed: tButton;     (* Liefert beliebigen Tastendruck    *)
PROCEDURE LeftXY(VAR x, y: INTEGER); (* Position bei Druck der li-Ta *)
PROCEDURE RightXY(VAR x, y: INTEGER);(* Position bei Druck der re-Ta *)
PROCEDURE MiddleXY(VAR x, y: INTEGER);(*Position bei Druck beider Ta *)
FUNCTION  ButtonUsed(Button: tButton): WORD; (* liefert die Zahl der *)
                (* TastendrÅcke seit dem letzten Aufruf der Funktion *)
FUNCTION  ButtonReleased(Button: tButton): WORD; (* wie oft wurde    *)
       (* seit dem letzten Aufruf der Funktion die Taste losgelassen *)

PROCEDURE GraphCursor(DivX, DivY: WORD; VAR BitMap); (* Softcursor   *)
                                       (* fÅr den Grafikmodus setzen *)
PROCEDURE GetMouseInfo(VAR MouseType, IRQ: BYTE; VAR Version: WORD);
                                (* liefert, welche Maus wo aktiv ist *)
PROCEDURE SetMouseWindow(x1, y1, x2, y2: INTEGER);
     (* setzt die Koordinaten fÅr ein Mausfenster auf dem Bildschirm *)
PROCEDURE GetMouseWindow(VAR x1, y1, x2, y2: INTEGER);
         (* liefert die Daten des akt. Mausfensters auf dem B-schirm *)

TYPE
  tCursorShape = ARRAY[0..1] OF ARRAY [1..4] OF ARRAY[1..4] OF WORD;

CONST
   DotCursor: tCursorShape =
{AND}    ((($FFFF, $FFFF, $FFFF, $FFFF),               (* So sieht eine *)
           ($FFFF, $FFFF, $FFFF, $FFFF),               (* Cursorbitmap  *)
           ($FFFF, $FFFF, $FFFF, $FFFF),               (* aus. Diese    *)
           ($FFFF, $FFFF, $FFFF, $FFFF)),              (* hier zeigt    *)
{XOR}     (($8000, $0000, $0000, $0000),               (* einen Punkt   *)
           ($0000, $0000, $0000, $0000),               (* auf dem BS an *)
           ($0000, $0000, $0000, $0000),
           ($0000, $0000, $0000, $0000)));

ArrowCursor: tCursorShape =
{AND}    ((($FFFF, $FFFF, $FFFF, $FFFF),               (* ... und diese *)
           ($FFFF, $FFFF, $FFFF, $FFFF),               (* implementiert *)
           ($FFFF, $FFFF, $FFFF, $FFFF),               (* softwaremÑ·ig *)
           ($FFFF, $FFFF, $FFFF, $FFFF)),              (* einen Pfeil   *)
{XOR}     (($8000, $E000, $F800, $FE00),
           ($D800, $0C00, $0600, $0300),
           ($0000, $0000, $0000, $0000),
           ($0000, $0000, $0000, $0000)));


IMPLEMENTATION

CONST
  Buttons: WORD = 0;

PROCEDURE DisplayCursor; ASSEMBLER;
ASM
  MOV AX, 0001h
  INT 33h
END;

PROCEDURE HideCursor; ASSEMBLER;
ASM 
  MOV AX, 0002h
  INT 33h
END;

PROCEDURE InitMouse; ASSEMBLER;
ASM
  XOR  AX, AX                                               { AX := 0 }
  INT  33h                                                  { AX = 0? }
  OR   AX, AX
  JZ   @out
  MOV Buttons, BX
 @out:
END;

FUNCTION ButtonNum: BYTE;
BEGIN
  ButtonNum := Lo(Buttons);
END;

FUNCTION WhereX: INTEGER; ASSEMBLER;
ASM
  MOV AX, 0003h
  INT 33h
  MOV AX, CX
END;

FUNCTION WhereY: INTEGER; ASSEMBLER;
ASM
  MOV AX, 0003h
  INT 33h
  MOV AX, DX;
END;

PROCEDURE SetPos(x, y: INTEGER); ASSEMBLER;
ASM
  MOV  AX, 0004h
  MOV  CX, x
  MOV  DX, y
  INT  33h
END;

FUNCTION Pressed: tButton; ASSEMBLER;
ASM
  MOV AX, 0003h
  INT 33h
  MOV AX, BX
END;

PROCEDURE LeftXY(VAR x, y: INTEGER);
VAR
  xt, yt: INTEGER;
BEGIN
  ASM
    MOV AX, 0005h
    XOR BX, BX
    INT 33h
    MOV xt, CX
    MOV yt, DX
  END;
  x := xt;
  y := yt;
END;

PROCEDURE RightXY(VAR x, y: INTEGER);
VAR
  xt, yt: INTEGER;
BEGIN
  ASM
    MOV AX, 0005h
    MOV BX, 0001h
    INT 33h
    MOV xt, CX
    MOV yt, DX
  END;
  x := xt;
  y := yt;
END;

PROCEDURE MiddleXY(VAR x, y: INTEGER);
VAR
  xt, yt: INTEGER;
BEGIN
  ASM
    MOV AX, 0005h
    MOV BX, 0002h
    INT 33h
    MOV xt, CX
    MOV yt, DX
  END;
  x := xt;
  y := yt;
END;

FUNCTION ButtonUsed(Button: tButton): WORD; ASSEMBLER;
ASM
  MOV AX, 0005h
  XOR BH, BH
  MOV BL, Button
  ADD BL, 0001h
  INT 33h
  MOV AX, BX
END;

FUNCTION ButtonReleased(Button: tButton): WORD; ASSEMBLER;
ASM
  MOV AX, 0006h
  XOR BH, BH
  MOV BL, Button
  ADD BL, 0001h
  INT 33h
  MOV AX, BX
END;

PROCEDURE MoveTo(x, y: WORD); ASSEMBLER;
ASM
  MOV  AX, 0004h
  MOV  CX, x
  MOV  DX, y
  INT  33h
END;

PROCEDURE GetMickeys(VAR x, y: INTEGER);
VAR
  xt, yt: INTEGER;
BEGIN
  ASM
    MOV AX, 001Bh
    INT 33h
    MOV xt, CX
    MOV yt, DX
  END;
  x := xt;
  y := yt;
END;

PROCEDURE SetMickeys(x, y: INTEGER); ASSEMBLER;
ASM
  MOV  AX, 000Fh
  MOV  CX, x
  MOV  DX, y
  INT  33h
END;

PROCEDURE GraphCursor(DivX, DivY: WORD; VAR BitMap);
VAR
  o, s: WORD;
BEGIN
  o := Ofs(BitMap);
  s := Seg(BitMap);
  ASM
    MOV AX, 0009h
    MOV BX, s
    MOV ES, BX
    MOV BX, DivX
    MOV CX, DivY
    MOV DX, o
    INT 33h
  END;
END;

PROCEDURE GetMouseInfo(VAR MouseType, IRQ: BYTE;
                       VAR Version:        WORD);
VAR
 m, i: BYTE;
 v   : WORD;
BEGIN
  ASM
    MOV AX, 0024h
    INT 33h
    MOV v, BX
    mov m, CH                     { 1 = Bus, 2 = seriell, 3 = InPort, }
                                  { 4 = PS/2, 5 = HP-Maus             }
    MOV i, CL;                    { 0 = PS/2, 2..7 = Nummer des IRQ   }
  END;
  MouseType := m;
  IRQ       := i;
  Version   := v;
END;

PROCEDURE SetMouseWindow(x1, y1, x2, y2: INTEGER); ASSEMBLER;
ASM
  MOV  AX, 0007h
  MOV  CX, x1 
  MOV  DX, x2 
  INT  33h
  MOV  AX, 0008h
  MOV  CX, y1 
  MOV  DX, y2 
  INT  33h
END;

PROCEDURE GetMouseWindow(VAR x1, y1, x2, y2: INTEGER);
VAR
  x1t, x2t, y1t, y2t: INTEGER;
BEGIN
  ASM
    MOV  AX,  31h
    INT  33h
    MOV  x1t, AX
    MOV  x2t, CX
    MOV  y1t, BX
    MOV  y2t, DX
  END;
  x1 := x1t; x2 := x2t;
  y1 := y1t; y2 := y2t;
END;

BEGIN
  InitMouse;
END.

(*===================================================================*)
