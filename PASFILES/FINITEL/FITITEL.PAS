Program finitel;
Uses crt, graph;
Const
  g = 10; 			{ 10 m/s	}
  zeilen = 5;
  spalten = 5;
  
  epsilon: Real = 0.1;
  
Type
  teilchen = Record
               c: Real; 			{ Federkonstante }
               m: Real; 			{ Masse in kg    }
               xp, yp: Real; { Position       }
               fax: Real;   { Belastungskraft}
               fay: Real;   { -"-            }
               fx : Real;    { Innere F       }
               fy : Real;    { -"-            }
               frx, fry: Real;
               frei: Boolean; {Beweglich ?    }
             End;
Var
  l0_x, l0_y: Real;
  schritt_y, schritt_x: Real;
  verbund : Array [1..zeilen, 1..spalten] Of teilchen;
  
Procedure initgr;
Var
  grDriver: Integer;
  grMode: Integer;
  ErrCode: Integer;
Begin
  grDriver := VGA;
  grMode := VGAhi;
  InitGraph (grDriver, grMode, 'z:\tp70\bgi');
  ErrCode := GraphResult;
  If ErrCode <> grOk Then
  Begin
    WriteLn ('Graphics error:', GraphErrorMsg (ErrCode) );
    Halt (1);
  End;
End;


Procedure init;
Var i, j, k: Integer;
Begin
  For i := 1 To zeilen Do
    For j := 1 To spalten Do
    Begin
      With verbund [i, j] Do
      Begin
        c := 50; 	{ [ci]= N/m = 1000 N/mm }
        xp := j;
        yp := i;
        m := 1; 	  { masse [m]=kg }
        fx := 0; fy := 0;
        fax := 0; fay := 0;
        frx := 0; fry := 0;
        frei := True;
        If (j = 1) Or (j = spalten) Then frei := False;
        If (i = 1) Or (i = zeilen) Then frei := False;
      End;
    End;
  With verbund [2, 2] Do
  Begin
    fax := 0; 	{ Belastung }
    fay := 0;
  End;
  l0_x := 1; l0_y := 1;
  schritt_x := l0_x / 1000;
  schritt_y := l0_y / 1000;
End;

Function abstand (z1, s1, z2, s2: Integer): Real;
Begin
  abstand := Sqrt (Sqr (verbund [z1, s1].xp - verbund [z2, s2].xp) +
  Sqr (verbund [z1, s1].yp - verbund [z2, s2].yp) );
End;


Procedure approx;
Var
  z, s: Integer;
  DL: Real;
  
  alt_x, alt_y, alt_fr: Real;
Begin
  For z := 1 To zeilen Do
  Begin
    For s := 1 To spalten Do
    Begin
      If verbund [z, s].frei Then
      Begin
        With verbund [z, s] Do
        Begin
          fx := fax;
          fy := - m * g + fay;
          
          frx := fx + c * (abstand (z, s, z, s - 1) - abstand (z, s, z, s + 1) );
          fry := fy + c * (abstand (z, s, z - 1, s) - abstand (z, s, z + 1, s) );
          
          If Abs (frx) > epsilon Then
          Begin
            alt_fr := frx;
            alt_x := xp;
            
            xp := xp + schritt_x;
            frx := fx + c * (abstand (z, s, z - 1, s) - abstand (z, s, z + 1, s) );
            If Abs (alt_fr) < Abs (frx) Then
            Begin
              xp := xp - schritt_x;
              frx := fx + c * (abstand (z, s, z - 1, s) - abstand (z, s, z + 1, s) );
            End;
          End;
          
          If Abs (fry) > epsilon Then
          Begin
            alt_fr := fry;
            alt_y := yp;
            
            yp := yp + schritt_y;
            fry := fy + c * (abstand (z, s, z - 1, s) - abstand (z, s, z + 1, s) );
            If Abs (alt_fr) < Abs (fry) Then
            Begin
              yp := yp - schritt_y;
              fry := fy + c * (abstand (z, s, z - 1, s) - abstand (z, s, z + 1, s) );
            End;
          End;
        End;
      End;
    End;
  End;
End;

Procedure writepos (X, Y, z, s: Integer);
Begin
  GotoXY (X, Y);
  ClrEol; 	WriteLn ('Pos(', z, ',', s, ')=(', verbund [z, s].xp: 3: 3, ' | ', verbund [z, s].yp: 3: 3, ')');
End;
Procedure writefr (X, Y, z, s: Integer);
Begin
  GotoXY (X, Y);
  ClrEol; 	WriteLn ('Fr(', z, ',', s, ')=(', verbund [z, s].frx: 3: 3, ' | ', verbund [z, s].fry: 3: 3, ')');
End;

Procedure zeichne;
Var z, s: Integer;
Begin
  ClearDevice;
  For z := 1 To zeilen Do
  Begin
    For s := 1 To spalten Do
    Begin
      With verbund [z, s] Do
      Begin
        Circle (50 + Round (25 * xp), 400 - Round (25 * yp), 5);
        If s < spalten Then
          Line (50 + Round (25 * xp) + 6, 400 - Round (25 * yp), 50 + Round (25 * verbund [z, s + 1].xp - 6),
          400 - Round (25 * verbund [z, s + 1].yp) );
        If z < zeilen Then
          Line (50 + Round (25 * xp), 400 - Round (25 * yp + 6), 50 + Round (25 * verbund [z + 1, s].xp),
          400 - Round (25 * verbund [z + 1, s].yp - 6) );
      End;
    End;
  End;
End;

Var
  i, j: Integer;
  oldexit: pointer;
  
Procedure myexit; Far;
Begin
  ExitProc := oldexit;
  
  CloseGraph;
End;

Begin
  oldexit := ExitProc;
  ExitProc := @myexit;
  ClrScr;
  initgr;
  init;
  
  Repeat
    approx;
    zeichne;
  Until KeyPressed;
  
  CloseGraph;
  
End.
