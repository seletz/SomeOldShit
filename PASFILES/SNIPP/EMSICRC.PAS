{� Fido Pascal Conference 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴 PASCAL �
Msg  : 302 of 318
From : Bo Bendtsen                         2:231/111.0          09 Apr 93  12:44
To   : Tom Lawrence                        1:2613/210.0
Subj : IEMSI Sessions...
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
Hello Tom!

Monday April 05 1993, Steve Wierenga writes to Tom Lawrence:

 TL>> hard-coded the CRC's into the packets.  I would
 TL>> appreciate knowing how you got the correct CRC's for
 TL>> EMSI packets.. I couldn't even get A77E from (star, star)EMSI_REQ...

Just for your information, it's much faster than calculating every time. }

Const
  EMS   = '**EMSI_';

  E_REQ = EMS+'REQA77E'+#13;
  E_INQ = EMS+'INQC816'+#13;

  E_ACK = EMS+'ACKA490'+#13;
  E_NAK = EMS+'NAKEEC3'+#13;
  E_IRQ = EMS+'IRQ8E08'+#13;
  E_IIR = EMS+'IIR61E2'+#13;
  E_ISM = EMS+'ISM6E84'+#13;
  E_CHT = EMS+'CHTF5D4'+#13;
  E_TCH = EMS+'TCH3C60'+#13;