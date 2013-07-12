Program test_cwmem;
Uses
  crt, cwtypes, cwmem, util;
Var
  memory: mmu_o;
  a: adress_t;
  X: Byte;
Begin
  ClrScr;
  memory. init;
  For a := $00 To $01ff Do
    memory. Write ( a, $8f);
  For X := $00 To $ff Do
    memory. Read ( adress_t ( X ) );
  memory. dump ($0000, $00ff);
  ReadLn;
  memory. disp_on;
  ReadLn;
  For a := $0200 To $03ff Do
    memory. Write ( a, $4f);
  For a := $00ff To $02ff Do
    memory. Write ( a, $ff);
  For a := $00 To $03ff Do
    memory. Read ( a );
  ReadLn;
  memory. disp_off;
  For a := $0200 To $03ff Do
    memory. Write ( a, $4f);
  ReadLn;
  memory. disp_off;
  ReadLn;
  ClrScr;
  memory. writel($0000,$1234567);
  memory. dump ($0000, $00ff);
  ReadLn;
  ClrScr;
  memory. writew($0000,$9876);
  memory. dump ($0000, $00ff);
  ReadLn;

  memory. done;
End.