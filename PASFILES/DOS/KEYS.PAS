{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X-}
(*===================================================================*)
(*                               KEYS.PAS                            *)
(* Unit mit den wichtigsten Interface-Routinen zu den Sondertasten   *)
(* In dieser Unit sind nur Abfragen und kein Setzen der Tasten im-   *)
(* plementiert. Die Abfragen gehen davon aus, da· der Rechner ein    *)
(* AT ist. Alle Abfragen Åber das Statusbyte 2 klappen nÑmlich erst  *)
(* mit einem AT-BIOS. Der XT kennt das Statusbyte 2 nicht. Falls die *)
(* Unit auch mit einem XT verwendet werden soll, dÅrfen die Tasten-  *)
(* abfragen mit dem Statusbyte 2 nicht verwendet werden.             *)
(* Alle Abfragen nach dem Statusbyte 1 funktionieren natÅrlich auch  *)
(* ohne énderungen auf einem PC-XT.                                  *)
(*-------------------------------------------------------------------*)
(*            Copyright (C) 1993 te-wi Verlag, MÅnchen               *)
(*===================================================================*)

UNIT Keys;

INTERFACE

TYPE
   tLED = (LEDScrollLock, LEDNumLock, LEDCapsLock);
   tLEDSet = (ON, OFF, ignore);

FUNCTION TestMFKeyBoard: BOOLEAN;

PROCEDURE SetLockKey(ScrollLock, NumLock, CapsLock: tLEDSet);

FUNCTION AltPressed         : BOOLEAN;               { Statusbyte 1   }
FUNCTION AltLeftPressed     : BOOLEAN;               { Statusbyte 2   }
FUNCTION AltRightPressed    : BOOLEAN;               { VerknÅpfung    }

FUNCTION CtrlPressed        : BOOLEAN;               { Statusbyte 1   }
FUNCTION CtrlLeftPressed    : BOOLEAN;               { Statusbyte 2   }
FUNCTION CtrlRightPressed   : BOOLEAN;               { VerknÅpfung    }

FUNCTION ShiftPressed       : BOOLEAN;               { Statusbyte 1   }
FUNCTION ShiftLeftPressed   : BOOLEAN;               { Statusbyte 1   }
FUNCTION ShiftRightPressed  : BOOLEAN;               { VerknÅpfung    }
FUNCTION ShiftLockActive    : BOOLEAN;               { Statusbyte 1   }

FUNCTION NumLockActive      : BOOLEAN;               { Statusbyte 1   }
FUNCTION NumLockPressed     : BOOLEAN;               { Statusbyte 2   }

FUNCTION ScrollLockActive   : BOOLEAN;               { Statusbyte 1   }

FUNCTION InsActive          : BOOLEAN;               { Statusbyte 1   }
FUNCTION Insert             : BOOLEAN;               { Statusbyte 2   }
FUNCTION OverWrite          : BOOLEAN;               { Statusbyte 2   }

FUNCTION SysReqPressed      : BOOLEAN;               { Statusbyte 2   }

FUNCTION LEDState(LED: tLED): BOOLEAN;               { LED-Statusbyte }

IMPLEMENTATION

FUNCTION AltPressed : BOOLEAN;
BEGIN
  AltPressed := (BYTE(Ptr(Seg0040, $17)^) AND $08 = $08);
END;

FUNCTION AltLeftPressed: BOOLEAN;
BEGIN
  AltLeftPressed := BYTE(Ptr(Seg0040, $18)^) AND $02 = $02;
END;

FUNCTION AltRightPressed: BOOLEAN;
BEGIN
  AltRightPressed := AltPressed AND (NOT AltLeftPressed);
END;

FUNCTION CtrlPressed: BOOLEAN;
BEGIN
  CtrlPressed := BYTE(Ptr(Seg0040, $17)^) AND $04 = $04;
END;

FUNCTION CtrlLeftPressed: BOOLEAN;
BEGIN
  CtrlLeftPressed := BYTE(Ptr(Seg0040, $18)^) AND $01 = $01;
END;

FUNCTION CtrlRightPressed: BOOLEAN;
BEGIN
  IF CtrlPressed AND (NOT CtrlLeftPressed) THEN
     CtrlRightPressed := TRUE
  ELSE
     CtrlRightPressed := FALSE;
END;

FUNCTION ShiftLeftPressed: BOOLEAN;
BEGIN
  ShiftLeftPressed := BYTE(Ptr(Seg0040, $17)^) AND $02 = $02;
END;

FUNCTION ShiftRightPressed: BOOLEAN;
BEGIN
  ShiftRightPressed := BYTE(Ptr(Seg0040, $17)^) AND $01 = $01;
END;

FUNCTION ShiftPressed: BOOLEAN;
BEGIN
  IF ShiftRightPressed OR ShiftLeftPressed THEN
    ShiftPressed := TRUE
  ELSE
    ShiftPressed := FALSE;
END;

FUNCTION ScrollLockActive: BOOLEAN;
BEGIN
  ScrollLockActive := BYTE(Ptr(Seg0040, $17)^) AND $10 = $10;
END;

FUNCTION ShiftLockActive: BOOLEAN;
BEGIN
 ShiftLockActive := BYTE(Ptr(Seg0040, $17)^) AND $40 = $40;
END;

FUNCTION Insert: BOOLEAN;
BEGIN
  Insert := BYTE(Ptr(Seg0040, $18)^) AND $80 = $80;
END;

FUNCTION OverWrite: BOOLEAN;
BEGIN
  OverWrite := NOT Insert;
END;

FUNCTION InsActive: BOOLEAN;
BEGIN
  InsActive := BYTE(Ptr(Seg0040, $17)^) AND $80 = $80;
END;

FUNCTION NumLockActive: BOOLEAN;
BEGIN
  NumLockActive := BYTE(Ptr(Seg0040, $17)^) AND $20 = $20;
END;

FUNCTION NumLockPressed: BOOLEAN;
BEGIN
  NumLockPressed := BYTE(Ptr(Seg0040, $18)^) AND $20 = $20;
END;

FUNCTION SysReqPressed: BOOLEAN;
BEGIN
  SysReqPressed := BYTE(Ptr(Seg0040, $18)^) AND $04 = $04;
END;

FUNCTION LEDState(LED: tLED): BOOLEAN;
BEGIN
  ASM
    MOV AH, 2
    INT 16H
  END;
  CASE LED OF
    LEDScrollLock: LEDState := BYTE(Ptr(Seg0040, $97)^) AND 1 = 1;
    LEDNumLock   : LEDState := BYTE(Ptr(Seg0040, $97)^) AND 2 = 2;
    LEDCapsLock  : LEDState := BYTE(Ptr(Seg0040, $97)^) AND 4 = 4;
  END;
  ASM
    MOV AH, 2
    INT 16H
  END;
END;

PROCEDURE SetLockKey(ScrollLock, NumLock, CapsLock: tLEDSet);
BEGIN
  IF ScrollLock = ON THEN
    BYTE(Ptr(Seg0040, $17)^) := BYTE(Ptr(Seg0040, $17)^) OR $10
  ELSE IF ScrollLock = OFF THEN
    BYTE(Ptr(Seg0040, $17)^) := BYTE(Ptr(Seg0040, $17)^) AND (NOT $10)
  ELSE IF ScrollLock = ignore THEN ;
  IF NumLock = ON THEN
    BYTE(Ptr(Seg0040, $17)^) := BYTE(Ptr(Seg0040, $17)^) OR $20
  ELSE IF NumLock = OFF THEN
    BYTE(Ptr(Seg0040, $17)^) := BYTE(Ptr(Seg0040, $17)^) AND (NOT $20)
  ELSE IF NumLock = ignore THEN ;
  IF CapsLock = ON THEN
    BYTE(Ptr(Seg0040, $17)^) := BYTE(Ptr(Seg0040, $17)^) OR $40
  ELSE IF CapsLock = OFF THEN
    BYTE(Ptr(Seg0040, $17)^) := BYTE(Ptr(Seg0040, $17)^) AND (NOT $40)
  ELSE IF CapsLock = ignore THEN ;
  ASM
    MOV AH, 1
    INT 16H
  END;
END;

FUNCTION TestMFKeyBoard: BOOLEAN;
VAR
  got: BYTE;
BEGIN
  TestMFKeyBoard := FALSE;
  ASM
    MOV  AX, 1200H
    INT  16H
    CMP  AX, 1200H
    JE   @none
    MOV  got, 1
    JMP  @ready
   @none:
    MOV got, 0
    JMP @ready
   @ready:
  END;
  IF got = 1 THEN TestMFKeyBoard := TRUE;
END;

END.

(*===================================================================*)