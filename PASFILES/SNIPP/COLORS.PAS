{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 333 of 474
From : John Guillory                       1:3807/4.4           14 Apr 93  11:59
To   : Rand Nowell
Subj : SHL - SHR
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
->
> Greetings..... Using Shl Shr (I assume) what is the best way to do the
> following?
>
> I have some predefined, or read from config file colors, that are
> stored as attributes, 48 black_on_cyan etc.
> These are in variable names, the above being NORM.
>

Try:  }

FUNCTION ForeColor(Attrib : BYTE):BYTE;

BEGIN
   ForeColor := (Attrib AND $8F);
END;

FUNCTION BackColor(Attrib : BYTE):BYTE;

BEGIN
  BackColor := (Attrib AND $70) Shr 4;
END;

The SHR 4 should work, if not, I Know that DIV 16 will..., The SHR Should be
quicker than Div 16 as well...