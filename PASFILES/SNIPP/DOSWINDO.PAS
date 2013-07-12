{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 453 of 473
From : Tim Phillips                        1:370/20.0           13 Apr 93  22:03
To   : Sean Palmer
Subj : Dos Windows...
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
->  TP> Awhile back someone was asking about a DOS window... I dunno if
->  TP> that was ever answered, but you can create a simple DOS window b
->  TP> a SETINTVEC command and interrupt $29.  If this is above you, le
->  TP> know, I can write code.
->
-> WHAT??? Post away!
-> I'm clueless.

Ahh, ok, well, this is from nothing but my head, so I don't guarantee it
to be flawless, but here goes (oh, and my programmings not that great,
only been doing it less than a year, and it's just me and the books, so
don't expect much)

My code: }

Program Simple_DOS_Window;

{$M $8000, 0, 16384}  { Not sure if we need all that, but hey... }

Uses DOS, CRT;

VAR

  P1, P2 : Pointer;  {these may not get used}

{$F+}

  Procedure Intercept_Int29(F, CS, IP, AX, BX, CX, DX, SI, DI, DS, ES,
                            BP : Word); Interrupt;

    Begin

      Write(chr(AX));

    end;

  {$F+}

  Begin

    GetIntVec($29, P1); {Remember that other interrupt}
    TextColor(14);
    TextBackground(1);
    Window(10, 5, 70, 15);
    CLRSCR;  {make a nice blue window on the screen}
    SetIntVec($29, Addr(Intercept_Int29)); {Set up our own interrupt}
    Exec(GetEnv('COMSPEC'), ''); {run DOS in our window}
    SetIntVec($29, P1); {Restore that old interrupt}

 end.