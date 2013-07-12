{********************************************************************
*********************************************************************

        LISTE.PAS: (C) 1995 by Stefan Eletzhofer


*********************************************************************
*********************************************************************


function MEIN_LISTENTYP.get_actual:MEIN_POINTER_AUF_NODETYP;
begin get_actual:=MEIN_POINTER_AUF_NODETYP(inherited get_actual) end;



}
Unit liste;
Interface
Type
	node_p = ^node_t;
  node_t = Object
             next, prev: node_p;
             Constructor init;
             Destructor done; Virtual;
           End;
  liste_P = ^liste_t;
  liste_t = Object
              first, last, actual: node_p;
              Constructor init;
              Destructor done;
              Procedure Insert (insnode: node_p);
              Procedure Delete (delnode: node_p);
              Procedure push (pushnode: node_p);
              Function pop: node_p; 					{*****************}
              Procedure Append (appnode: node_p);
              Function remove: node_p;             {*****************}
              Procedure next;
              Procedure prev;
              Procedure setfirst;
              Procedure setlast;
              Function isfirst: Boolean;
              Function islast: Boolean;
              Function isempty: Boolean;
              Function get_actual: node_p; 			{*****************}
            End;
Implementation
(*
 *
 *
 *
 *
 *
 *)
Constructor node_t. init;
Begin
  next := Nil; prev := Nil
End;
Destructor node_t. done;
Begin
End;
     (*
      *
      *
      *
      *
      *
                        *)
Constructor liste_t. init;
Begin
  actual := Nil;
  last := actual;
  first := actual;
End;
(*
 *
 *
 *
 *
 *
 *)
Destructor liste_t. done;
Var temp: node_p;
Begin
  If isempty Then Exit; { liste ist leer }
  
  setfirst; 							{ wir fangen vorne an }
  Repeat
    pop^. done;          { popen und lîschen }
  Until isempty; 				{ bis Liste leer }
  
  first := Nil;
  last := Nil;
  actual := Nil;
End;
     (* 	INSERT:
      *      o  fÅgt die Åbergebene node VOR der aktuellen ein
      *
      *
      *
      *
      *)
Procedure liste_t. Insert;
Begin
  If isempty Then
  Begin
    first := insnode;
    last := insnode;
    actual := first;
    first^. prev := Nil;
    last^. next := Nil;
    Exit
  End;
  insnode^. prev := actual^. prev;
  insnode^. next := actual;
  If actual <> first Then actual^. prev^. next := insnode Else first := insnode;
  actual^. prev := insnode;
  actual := insnode;
  
End;
(* 	DELETE:
 *      o entfernt die Åbergebene node aus der liste
 *      o node wird NICHT gelîscht, nur entfernt d.h. delnode^.done wird
 *			   nicht ausgefÅhrt.
 *      o die erste node kann nicht gelîscht werden.
 *		  o lîscht wie die entf-Taste
 *)
Procedure liste_t. Delete;
Begin
  If isempty Then Exit;
  
  If (actual = first) and (actual=delnode) Then actual := actual^. next
  Else If actual = delnode Then actual := delnode^. prev;

  If delnode <> last Then
    delnode^. next^. prev := delnode^. prev
  Else
    last := last^. prev;
  If delnode <> first Then
    delnode^. prev^. next := delnode^. next
  Else
    first := first^. next;
  delnode^. prev := Nil;
  delnode^. next := Nil;
End;
(*   PUSH:
 *     o fÅgt am am Anfang der Liste eine Node ein
 *
 *
 *
 *
 *)
Procedure liste_t. push;
Begin
  If isempty Then
  Begin
    first := pushnode;
    last := pushnode;
    actual := first;
    first^. prev := Nil;
    last^. next := Nil;
    Exit
  End;
  first^. prev := pushnode; { der alte FIRST hat einen vorgÑnger }
  pushnode^. next := first; { der neue -"- hat den alten als Nachfolger }
  first := pushnode; 				{ neuer FIRST }
  first^. prev := Nil;      { FIRST hat keinen VorgÑnger }
End;
(*		POP:
 *     o entfernt eine Node vom Anfang
 *
 *
 *
 *
 *)
Function liste_t. pop: node_p;
Begin
  If isempty Then Exit;
  
  pop := first;
  If first = last Then
  Begin
    first := Nil;
    last := Nil;
    actual := Nil;
    Exit
  End;
  
  If actual = first Then actual := first^. next;
  first := first^. next;  { neuer FIRST }
  first^. prev := Nil;   { FIRST hat keinen vorgÑnger }
  pop^. next := Nil;     { abschneiden }
  pop^. prev := Nil;
  
End;
(*		APPEND:
 *			o fÅgt eine Node am Ende ein
 *
 *
 *
 *
 *)
Procedure liste_t. Append;
Begin
  If isempty Then
  Begin
    first := appnode;
    last := appnode;
    actual := first;
    first^. prev := Nil;
    last^. next := Nil;
    Exit
  End;
  last^. next := appnode;
  appnode^. prev := last;
  last := appnode;
  last^. next := Nil;
End;
(*		REMOVE:
 *		  o entfernt eine Node vom Ende
 *
 *
 *
 *
 *)
Function liste_t. remove: node_p;
Begin
  If isempty Then Exit;
  
  remove := last;
  
  If first = last Then
  Begin
    first := Nil;
    last := Nil;
    actual := Nil;
    Exit
  End;
  
  If actual = last Then actual := last^. prev;
  last := last^. prev;
  remove^. next := Nil;
  remove^. prev := Nil;
End;
(*
 *
 *
 *
 *
 *
 *)
Procedure liste_t. next;
Begin
  If isempty Then Exit;
  If actual <> last Then actual := actual^. next;
End;
Procedure liste_t. prev;
Begin
  If isempty Then	Exit;
  If actual <> first Then actual := actual^. prev;
End;
Procedure liste_t. setfirst;
Begin actual := first End;
Procedure liste_t. setlast;
Begin actual := last End;
Function liste_t. islast: Boolean;
Begin islast := actual = last End;
Function liste_t. isfirst: Boolean;
Begin isfirst := actual = first End;
Function liste_t. isempty: Boolean;
Begin isempty := (last = Nil) And (first = Nil) End;
Function liste_t. get_actual: node_P;
Begin get_actual := actual End;
Begin
End.