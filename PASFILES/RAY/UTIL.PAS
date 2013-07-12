Unit util;
Interface
Uses crt;

Function max (a, b: Double): Double;
Function Min (a, b: Double): Double;

Implementation

Function max (a, b: Double): Double;
Begin
  If a > b Then max := a Else max := b
End;
Function Min (a, b: Double): Double;
Begin
	If a < b Then min := a Else min := b
End;

Begin
End.