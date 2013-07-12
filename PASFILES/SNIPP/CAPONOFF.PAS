{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 289 of 354
From : David Drzyzga                       1:3612/220.0         14 Apr 93  16:42
To   : Ian Nordby                          1:101/106.0
Subj : Help?
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
 IN>         I'm hoping someone out there might be able to
 IN> assist me...  I working on a project in Turbo and I'm
 IN> looking for a way to toggle the keyboard CAPS LOCK
 IN> status from within the program -- presumably with some
 IN> INLINE code or an interrupt or something (neither of
 IN> which I know anything about -- I'm not what you'd call
 IN> a very "advanced" programmer).  If anyone has some
 IN> ideas towards this end that they wouldn't mind sharing,

Here's how you do just that!: }

Program CapsONandOFF;

const
  CapsLockOn   = $40;
  {and for an added bonus here's some more values to use:}
  InsertOn     = $80;
  NumLockOn    = $20;
  ScrollLockOn = $10;

var
  KeyFlag : byte absolute $0040:$0017;
Begin
  KeyFlag := KeyFlag or CapsLockOn;
  readln;
  KeyFlag := KeyFlag and (not CapsLockOn);
End.