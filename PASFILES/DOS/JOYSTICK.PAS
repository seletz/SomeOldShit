{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X-,Y-}
(*===================================================================*)
(*                            JOYSTICK.PAS                           *)
(*            Copyright (C) 1993 te-wi Verlag, MÅnchen               *)
(*-------------------------------------------------------------------*)
(*      Unit mit den wichtigsten Interface-Routinen zum Joystick     *)
(*    Diese Version arbeitet mit dem Interrupt 15h bei ATs und der   *)
(*     direkten Portabfrage bei XTs und somit hardware-unabhÑngig    *)
(*   Falls bei einem AT Timerprobleme auftreten, sollten auch hier   *)
(*        die direkten Abfragen (XT-Routinen) verwendet werden.      *)
(*   Hierzu mu· nur die Routine FUNCTION ATFunktions durch eine      *)
(*        Routine ersetzt werden, die immer FALSE zurÅckgibt.        *)
(*  Wegen der Hardware-AbhÑngigkeit der direkten Hardwareabfrage     *)
(*           sollte dies aber nur im Notfall gemacht werden.         *)
(*===================================================================*)

UNIT Joystick;

INTERFACE

(*-------------------------------------------------------------------*)
(* Installationstest auf Joystick. Bei AT wird hierzu das Carry-Flag *)
(* verwendet, bei XT der Int 11h und dann die PrÅfung auf X und Y    *)
FUNCTION  IsInstalled: BOOLEAN;

(*-------------------------------------------------------------------*)
(* öberprÅfung und Meldung, ob die AT- oder die XT-Funktionen        *)
(* verwendet werden sollen. Bei ATs kînnen beide Routinen verwendet  *)
(* werden, die Funktionen den Int 15h stehen bei XTs aber nicht zur  *)
(* VerfÅgung. Die XT-Funktionen sind allerdings komplizierter und    *)
(* stîrungsanfÑlliger weshalb bei ATs immer auf die Interrupt-Auf-   *)
(* rufe zurÅckgegriffen werden sollte. Falls die Routinen auf einem  *)
(* PC-XT nicht arbeiten, Taktfrequenz erniedrigen (falls mîglich)    *)
(* und au·erdem ÅberprÅfen, ob die Portadresse stimmt.               *)
FUNCTION ATFunctions: BOOLEAN;

(*-------------------------------------------------------------------*)
(* Ermittlung,ob ein Feuerknopf gedrÅckt ist: f1: Knopf 1 an Stick 1 *)
(*                                            f2: Knopf 2 an Stick 1 *)
(*                                            f3: Knopf 1 an Stick 2 *)
(*                                            f2: Knopf 2 an Stick 2 *)
PROCEDURE FireButton(VAR f1, f2, f3, f4: BOOLEAN);

(*-------------------------------------------------------------------*)
(* liefert den relativen X- und Y-Wert von Joystick 1 zurÅck:        *)
PROCEDURE WhereXY1(VAR x, y: INTEGER);

(*-------------------------------------------------------------------*)
(* liefert den relativen X- und Y-Wert von Joystick 2 zurÅck:        *)
PROCEDURE WhereXY2(VAR x, y: INTEGER);

IMPLEMENTATION

USES
  Dos;

CONST
  GamePort = $201; (* Dieser Wert kann bei XTs unter UmstÑnden auch  *)
                 (* im Bereich $200 bis $20F abweichen. Im Zweifels- *)
                 (* fall testen. Bei ATs gibt es keine Probleme, da  *)
                 (* der Int 15h den Port im Griff hat.               *)

FUNCTION ATFunctions: BOOLEAN;
{$IFDEF DPMI}
BEGIN
  ATFunctions := TRUE;
                  (* wie soll ein XT in den Protected Mode schalten? *)
END;
{$ELSE}
ASSEMBLER;
ASM
  PUSHF
  XOR   AX, AX
  POPF
  PUSHF
  POP   AX
  AND   AX, 0F000H     (* Flag-Check *)
  JZ    @xt
  MOV   AL, TRUE
  JMP   @out            (* Pech gehabt haben alle mit einem XT286. *)
@xt:                    (* Kennen Sie jemanden mit so einer Kiste? *)
  MOV   AL, FALSE
@out:
END;
{$ENDIF}

FUNCTION XTGeneric(num, Direction: BYTE): INTEGER;
VAR
  SelectBit, SelectStick: BYTE;
  JoyCount,  counter    : INTEGER;
BEGIN
  IF Direction <= 1 THEN
  BEGIN
    SelectBit := $01;
    IF num > 1 THEN SelectBit := $04;
  END
  ELSE
  BEGIN
    SelectBit := $02;
    IF num > 1 THEN SelectBit := $08;
  END;
  SelectStick := $03;
  IF num > 1 THEN SelectStick := $0C;
  counter := 0;
  REPEAT
    JoyCount := Port[GamePort];
    Inc(counter);
  UNTIL (JoyCount AND SelectStick = 0) OR (counter = 500);
  Port[GamePort] := JoyCount;
  counter := 0;
  REPEAT
    JoyCount := Port[GamePort];
    Inc(counter);
  UNTIL (JoyCount AND SelectBit = 0) OR (counter = 500);
  IF counter <> 500 THEN XTGeneric := counter
                    ELSE XTGeneric := 0
END;

FUNCTION IsInstalled: BOOLEAN;
VAR
  Regs: Registers;
BEGIN
  IF ATFunctions THEN
  BEGIN
    Regs.AH := $84;
    Regs.DX := 0;
    Intr($15, Regs);
    IsInstalled := (NOT Odd(Regs.Flags));
   END
   ELSE
   BEGIN
     IsInstalled := TRUE;
     Intr($11, Regs);     (* Check bei PC-XT Åber Konfigurationsbyte *)
     IF (Regs.AH AND $80) = $80 THEN
     BEGIN
       IF (XTGeneric(1, 1) = 0) AND (XTGeneric(1, 2) = 0) AND
          (XTGeneric(2, 1) = 0) AND (XTGeneric(2, 2) = 0) THEN
          IsInstalled := FALSE
        ELSE
          IsInstalled := TRUE;
    END
    ELSE
      IsInstalled := FALSE;
  END;
END;

PROCEDURE FireButton(VAR f1, f2, f3, f4: BOOLEAN);
VAR
  Regs  : Registers;
  button: BYTE;
BEGIN
  f1 := TRUE; f2 := TRUE; f3 := TRUE; f4 := TRUE;
  IF ATFunctions THEN
  BEGIN
    Regs.AH := $84;
    Regs.DX := 0;
    Intr($15, Regs);
    IF NOT Odd(Regs.Flags) THEN
    BEGIN
      f1 := (Regs.AL AND $10) <> $10;
      f2 := (Regs.AL AND $20) <> $20;
      f3 := (Regs.AL AND $40) <> $40;
      f4 := (Regs.AL AND $80) <> $80;
    END;
   END
   ELSE
   BEGIN
     f1 := (Port[GamePort] AND $10) <> $10;
     f2 := (Port[GamePort] AND $20) <> $20;
     f3 := (Port[GamePort] AND $40) <> $40;
     f4 := (Port[GamePort] AND $80) <> $80;
  END;
END;

PROCEDURE WhereXY1(VAR x, y: INTEGER);
VAR
  Regs: Registers;
BEGIN
  IF ATFunctions THEN
  BEGIN
    Regs.AH := $84;
    Regs.DX := 1;
    Intr($15, Regs);
    IF NOT Odd(Regs.Flags) THEN
    BEGIN
      x := Regs.AX;
      y := Regs.BX
    END
    ELSE
    BEGIN
      x := 0;
      y := 0;
    END;
  END
  ELSE
  BEGIN
    x := XTGeneric(1, 1);
    y := XTGeneric(1, 2);
  END;
END;


PROCEDURE WhereXY2(VAR x, y: INTEGER);
VAR
  Regs: Registers;
BEGIN
  IF ATFunctions THEN
  BEGIN
    Regs.AH := $84;
    Regs.DX := 1;
    Intr($15, Regs);
    IF NOT Odd(Regs.Flags) THEN
    BEGIN
      x := Regs.CX;
      y := Regs.DX
    END
    ELSE
    BEGIN
      x := 0;
      y := 0;
    END;
  END
  ELSE
  BEGIN
    x := XTGeneric(2, 1); y := XTGeneric(2, 2);
  END;
END;

END.

(*===================================================================*)
