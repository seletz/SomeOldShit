Unit cwmem;
Interface
Uses
  cwtypes, cwdbg, cwdisp;
Const
	cwmem_dbg:boolean = false;
  cw_mem_size = 10000 - 1;
Type
  mem_p = ^mem_t;
  mem_t = Array [0..cw_mem_size] Of Byte;

  mmu_p = ^mmu_o;
  mmu_o = 	Object (cw_base_o)
             display: display_p;
             disp_flag: Boolean;
             memory: mem_p;
             Constructor init;
             Destructor done;

             Procedure disp_on;
             Procedure disp_off;

             Procedure Write (adr: adress_t; b: Byte);
             Function Read (adr: adress_t): Byte;
             Procedure Writew (adr: adress_t; w: Word);
             Function Readw (adr: adress_t): Word;
             Procedure Writel (adr: adress_t; l: long);
             Function Readl (adr: adress_t): long;
             Procedure dump ( adr1, adr2: adress_t);
             Private Function translate ( adr1: adress_t): adress_t;
           End;
Implementation
Uses
  util;
Constructor mmu_o. init;
Begin
	dbg_start( cwmem_dbg, 'mmu_o. init');
  disp_flag := False;
  New ( memory );
  FillChar (memory^, SizeOf (memory^) , 0);
  dbg( cwmem_dbg, sizeof(memory^), 'bytes allocated.' );
  display := Nil;
  dbg_end( cwmem_dbg );
End;
Destructor mmu_o. done;
Begin
	dbg_start( cwmem_dbg, 'mmu_o. done');
  Dispose ( memory );
End;
Procedure mmu_o. disp_on;
Var
  a: adress_t;
Begin
	dbg_start( cwmem_dbg, 'mmu_o. disp_on');
  New ( display, init);
  For a := 0 To cw_mem_size Do
    display^. disp_write (a, mmu_o. Read (a) );

  disp_flag := True;
  dbg_end( cwmem_dbg );
End;
Procedure mmu_o. disp_off;
Begin
	dbg_start( cwmem_dbg, 'mmu_o. disp_off');
  If disp_flag Then
    display^. done;
  disp_flag := False;
  dbg_end( cwmem_dbg );
End;
Function mmu_o. translate ( adr1: adress_t): adress_t;
Var
  temp: adress_t;
Begin
	dbg_start( cwmem_dbg, 'mmu_o. translate');
  temp := adr1;
  While temp < 0 Do
    Inc (temp, cw_mem_size);
  While temp > cw_mem_size Do
    Dec (temp, cw_mem_size);
  translate := temp;
  dbg_end( cwmem_dbg );
End;
Procedure mmu_o. dump;
Var
  a, a0, a1: adress_t;

Begin
	dbg_start( cwmem_dbg, 'mmu_o. dump');
  If disp_flag Then Exit;

  a := translate (adr1);
  a0 := translate (adr2);
  If a > a0 Then
  Begin
    a1 := a;
    a := a0;
    a0 := a1;
  End;
  While a <= a0 Do
  Begin
    system. Write (hex4 (a), ': ');
    For a1 := a To a + $e Do
      system. Write ( ' $', hex2 (mmu_o. Read ( a1) ) );
    system. WriteLn;
    Inc (a, $f);
  End;
  dbg_end( cwmem_dbg );
End;
Function mmu_o. Read (adr: adress_t): Byte;
Var
  b: Byte;
Begin
	dbg_start( cwmem_dbg, 'mmu_o. read');
  b := memory^ [ translate ( adr ) ];
  If disp_flag Then
    display^. disp_read ( translate (adr), b );
  Read := b;
  dbg_end( cwmem_dbg );
End;
Procedure mmu_o. Write;
Begin
	dbg_start( cwmem_dbg, 'mmu_o. write');
  memory^ [ translate ( adr ) ] := b;
  If disp_flag Then
    display^. disp_Write ( translate (adr), b );
  dbg_end( cwmem_dbg );
End;
Function mmu_o. Readw (adr: adress_t): Word;
Var
  wd: Word;
Begin
	dbg_start( cwmem_dbg, 'mmu_o. readw');
  wd := Word ( mmu_o. Read ( adr + 1) ) ShL 8 + mmu_o. Read (adr);
  dbg_end( cwmem_dbg );
End;
Procedure mmu_o. Writew;
Begin
	dbg_start( cwmem_dbg, 'mmu_o. writew');
  mmu_o. Write (adr, Lo (w) );
  mmu_o. Write (adr+1, hi (w) );
  dbg_end( cwmem_dbg );
End;
Function mmu_o. Readl (adr: adress_t): long;
Var
  ld: long;
Begin
	dbg_start( cwmem_dbg, 'mmu_o. readl');
  ld := long ( mmu_o. Read ( adr + 3) ) ShL 24 +
  long ( mmu_o. Read ( adr + 2) ) ShL 16 +
  long ( mmu_o. Read ( adr + 1) ) ShL 8 +
  mmu_o. Read (adr);
  dbg_end( cwmem_dbg );
End;
Procedure mmu_o. Writel;
Begin
	dbg_start( cwmem_dbg, 'mmu_o. writel');
  mmu_o. writew (adr, Word (l And $0000ffff) );
  mmu_o. writew (adr + 2, Word (l ShR 16) );
  dbg_end( cwmem_dbg );
End;

Begin
End.