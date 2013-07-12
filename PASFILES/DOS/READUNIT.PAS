{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X-,Y-}
(*===================================================================*)
(*                            READUNIT.PAS                           *)
(*             Copyright (C) 1993 te-wi Verlag, Mnchen              *)
(*-------------------------------------------------------------------*)
(*      Implementation einer komfortablen ReadString-Routine         *)
(*===================================================================*)

UNIT ReadUnit;

INTERFACE

FUNCTION ReadString(EntryLength: BYTE; VAR LastChar: INTEGER): STRING;

IMPLEMENTATION

USES
  Dos, Cursor, Crt;

FUNCTION ReadString;
VAR
  ch            : CHAR;
  Insert, Ready : BOOLEAN;
  CursorStart   : WORD;
  CurPoint,
  x, y          : WORD;
  counter       : BYTE;
  Entry         : STRING;

  PROCEDURE Errorbeep;
  BEGIN
    Sound(900);
    Delay(20);
    NoSound;
  END;

BEGIN
  CursorStart := StartCursor;
  CheckBreak  := FALSE;
  x           := WhereX;
  y           := WhereY;
  Entry       := '';
  GotoXY(x, y);
  CurPoint    := 0;
  Insert      := TRUE;
  Ready       := FALSE;
  REPEAT
    ch := ReadKey;
    CASE ch OF
    Chr(10), Chr(13):                                      (* LF, CR *)
      BEGIN
        LastChar := Ord(ch);
        Ready    := TRUE;
      END;
    Chr(3), Chr(27):                                      (* ^C, ESC *)
      BEGIN
        LastChar := Ord(ch);
        Entry    := '';
        CurPoint := 0;
        Ready    := TRUE;
      END;
    Chr(7):                                (* -> Del bei PC1512/1640 *)
      BEGIN
        IF CurPoint <> Length(Entry) THEN
        BEGIN
         FOR counter := CurPoint + 1 TO Length(Entry) - 1 DO
           Entry[counter] := Entry[counter + 1];
           Entry := Copy(Entry, 1, Length(Entry) - 1);
           GotoXY(x, y);
           Write(Entry, Chr(22));
           GotoXY(x + CurPoint, y);
         END;
       END;
    Chr(32)..Chr(126), Chr(128)..Chr(255):      (* erlaubtes Zeichen *)
      BEGIN
        IF (Length(Entry) < EntryLength) OR NOT Insert THEN
        BEGIN
          IF CurPoint = Length(Entry) THEN
          BEGIN
            Entry := Entry + ch;
            GotoXY(x + CurPoint, y);
            Inc(CurPoint);
            Write(ch);
          END
          ELSE
          BEGIN
            IF Insert THEN
            BEGIN
              Entry := Entry + Chr(32);
              FOR counter := Length(Entry) - 1 DOWNTO CurPoint + 1 DO
                Entry[counter+1] := Entry[counter];
            END;
            Inc(CurPoint);
            Entry[CurPoint] := ch;
            GotoXY(x, y);
            Write(Entry);
            GotoXY(x + CurPoint, y);
          END;
        END;
      END;
    Chr(8), Chr(127):                                     (* BS, ^BS *)
      BEGIN
        IF CurPoint <> 0 THEN
        BEGIN
          FOR counter := CurPoint TO Length(Entry) - 1 DO
            Entry[counter] := Entry[counter + 1];
          Entry := Copy(Entry, 1, Length(Entry) - 1);
          Dec(CurPoint);
          GotoXY(x, y);
          Write(Entry, Chr(22));
          GotoXY(x + CurPoint, y);
        END;
      END;
    Chr(0):                                      (* erweiterte Taste *)
      BEGIN
        ch := ReadKey;
        CASE ch OF
        Chr(82):                                              (* Ins *)
          BEGIN
            Insert := NOT Insert;
            IF Insert THEN SetCursor(StartCursor)
                      ELSE Blockcursor;
          END;
        Chr(71):                                             (* Home *)
          BEGIN
            CurPoint := 0;
            GotoXY(x, y);
            Write(Entry);
            GotoXY(x + CurPoint, y);
          END;
        Chr(79):                                              (* End *)
          BEGIN
            CurPoint := Length(Entry);
            GotoXY(x, y);
            Write(Entry);
            GotoXY(x + CurPoint, y);
          END;
        Chr(83):                                              (* Del *)
          BEGIN
            IF CurPoint <> Length(Entry) THEN
            BEGIN
              FOR counter := CurPoint + 1 TO Length(Entry) - 1 DO
                Entry[counter] := Entry[counter + 1];
              Entry := Copy(Entry, 1, Length(Entry) - 1);
              GotoXY(x, y);
              Write(Entry, Chr(22));
              GotoXY(x + CurPoint, y);
            END;
          END;
        Chr(75):                                               (* <- *)
          BEGIN
            IF CurPoint <> 0 THEN
            BEGIN
              Dec(CurPoint);
              GotoXY(x + CurPoint, y);
            END;
          END;
        Chr(77):                                               (* -> *)
          BEGIN
            IF CurPoint <> Length(Entry) THEN
            BEGIN
              Inc(CurPoint);
              GotoXY(x + CurPoint, y);
              END;
            END;
          ELSE Errorbeep;
        END;
      END
      ELSE Errorbeep;
    END;
  UNTIL Ready;
  SetCursor(CursorStart);            (* Original-Cursor restaurieren *)
  ReadString := Entry;
END;

END.
(*===================================================================*)
