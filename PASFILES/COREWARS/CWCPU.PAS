Unit cwcpu;
Interface
Uses
  util, cwtypes, cwdbg, cwerror, cwmem;
Type
  mnemonic_t = Record
                 Name: String [6];
                 opcode: Byte;
               End;
Const
  cwcpu_dbg: Boolean = True;
  
  opc_push = $01;
  opc_pop = $02;
  opc_move = $03;
  opc_add = $04;
  opc_sub = $05;
  opc_div = $06;
  opc_mul = $07;
  opc_cmp = $08;
  opc_jmpz = $09;
  opc_jmpc = $0a;
  opc_jmpn = $0b;
  opc_djnz = $0c;
  opc_call = $0D;
  opc_ret = $0e;
  opc_lda = $0f;
  opc_jmp = $10;
  
  cw_cpu_maxopcode = 31;
  mnemonics : Array [0..cw_cpu_maxopcode] Of mnemonic_t =
  (
  ( Name:'push'; opcode:$01),
  ( Name:'pop'; opcode:$02),
  ( Name:'move'; opcode:$03),
  ( Name:'add'; opcode:$04),
  ( Name:'sub'; opcode:$05),
  ( Name:'div'; opcode:$06),
  ( Name:'mul'; opcode:$07),
  ( Name:'cmp'; opcode:$08),
  ( Name:'jmpz'; opcode:$09),
  ( Name:'jmpc'; opcode:$0a),
  ( Name:'jmpn'; opcode:$0b),
  ( Name:'djnz'; opcode:$0c),
  ( Name:'call'; opcode:$0D),
  ( Name:'ret'; opcode:$0e),
  ( Name:'lda'; opcode:$0f),
  ( Name:'jmp'; opcode:$10),
  ( Name:''; opcode:$11),
  ( Name:''; opcode:$12),
  ( Name:''; opcode:$13),
  ( Name:''; opcode:$14),
  ( Name:''; opcode:$15),
  ( Name:''; opcode:$16),
  ( Name:''; opcode:$17),
  ( Name:''; opcode:$18),
  ( Name:''; opcode:$19),
  ( Name:''; opcode:$1a),
  ( Name:''; opcode:$1b),
  ( Name:''; opcode:$1c),
  ( Name:''; opcode:$1D),
  ( Name:''; opcode:$1e),
  ( Name:''; opcode:$1f),
  ( Name:''; opcode:$20)
  );
Type
  status_t =  ( stop, run, Halt, error);
  
  command_t = Record
                opcode: long;
                op1: long;
                op2: long;
                amode : ( constant, direct, indirect);
                mmode : ( mbyte, mword, mlong );
                r1, r2: Byte;
              End;
  
  register_t = 	Record
                  Dr: Array [0..7] Of LongInt; { Data registers }
                  ar: Array [0..7] Of LongInt; { Adress Registers }
                  Flags: Set Of ( carry, zero, negative, overflow );
                  PC: adress_t; 	{ Program counter }
                  sp: adress_t; 	{ Stack Pointer }
                  ir: command_t; 	{ Instruction Register }
                End;
  
  cpu_p = ^cpu_o;
  cpu_o = Object (cw_base_o)
            id: Word; 							{ CPU-ID }
            mmu: mmu_p; 						{ pointer to MMU }
            regs: register_t; 			{ Register }
            status: status_t; 			{ CPU status Flags }
            
            Constructor init ( iregs: register_t; immu: mmu_p);
            Destructor done;
            
            Procedure run;
            Procedure stop;
            Procedure step;
            
            Function get_status: status_t;
            
            Private Procedure fetch;
            Private Procedure decode;
            Private Procedure execute;
            
            Private Function get_op: long;
            
            Private Procedure put_op ( l: long);
            
            Private Procedure c_push;
            Private Procedure c_pop;
            Private Procedure c_move;
            Private Procedure c_add;
            Private Procedure c_sub;
            Private Procedure c_div;
            Private Procedure c_mul;
            Private Procedure c_cmp;
            Private Procedure c_jmp;
            Private Procedure c_jmpz;
            Private Procedure c_jmpc;
            Private Procedure c_jmpn;
            Private Procedure c_djnz;
            Private Procedure c_call;
            Private Procedure c_ret;
            Private Procedure c_lda;
          End;
  
Implementation
Constructor cpu_o. init;
Begin
  regs := iregs;
End;
Destructor cpu_o. done;
Begin
End;
Function cpu_o. get_status: status_t; Begin get_status := status End;
Procedure cpu_o. run;
Begin
End;
Procedure cpu_o. step;
Begin
  dbg_start (cwcpu_dbg, 'cpu_o. step' );
  fetch;
  dbg ( cwcpu_dbg, 0, 'opcode: ' + hex4 (regs. ir. opcode) );
  decode;
  dbg ( cwcpu_dbg, 1, 'opcode: ' + hex4 (regs. ir. opcode) );
  dbg ( cwcpu_dbg, Ord (regs. ir. mmode), ' = mmode');
  dbg ( cwcpu_dbg, Ord (regs. ir. amode), ' = amode');
  dbg ( cwcpu_dbg, regs. ir. r1, ' = r1');
  dbg ( cwcpu_dbg, regs. ir. r2, ' = r2');
  execute;
  dbg (cwcpu_dbg, Ord (status), ' = status' );
  dbg_end ( cwcpu_dbg );
End;
Procedure cpu_o. stop;
Begin
End;
(*
 *  Private Proceduren und Funktionen
 *)
Procedure cpu_o. fetch;
Begin
  If status In [ error, Halt ] Then Exit;
  With regs Do
  Begin
    ir. opcode := mmu^. Readl (PC);
    Inc (PC, 4);
  End;
End;
Procedure cpu_o. decode;
Var
  t: long;
Begin
  If status In [ error, Halt ] Then Exit;
  If (regs. ir. opcode > cw_cpu_maxopcode) Or (regs. ir. opcode = 0) Then
  Begin
    status := error;
  End;
  With regs Do
  Begin
    ir. r1 := 0;
    ir. r2 := 0;
    (*
    * 	Adressierungsmodus dekodieren
    *)
    t := ir. opcode;
    t := t And long (1 + 2 + 4); 		{ bits 0-2 maskieren }
    Case t Of
      0: ir. amode := constant;
      1: ir. amode := direct;
      2: ir. amode := indirect;
      Else
        panic ( cw_err_unknown_amode, 'unknown Adressmode');
    End;
    (*
    * 	Speicherzugriffsmodus dekodieren
    *)
    t := ir. opcode;
    t := t And long ( 8 + 16 + 32 ); 		{ bits 3-5 maskieren }
    t := t ShR 3;
    Case t Of
      0: ir. mmode := mbyte; 	{ Byte-Zugriff }
      1: ir. mmode := mword;  { Word-Zugriff }
      2: ir. mmode := mlong;  { Long-Zugriff }
      Else
        panic ( cw_err_unknown_mmode, 'unknown Memorymode');
    End;
    (*
    * 	Operand1 dekodieren u. ggf holen
    *)
    t := ir. opcode;
    t := (t And long ( $03c0 ) ) ShR 6; 		{ bits 6-10 maskieren }
    Case t Of
      0..17: ir. r1 := t;
      18: Case ir. mmode Of
        mbyte:
              Begin
                ir. op1 := ir. op1 And ( $ffffff00 );
                ir. op1 := ir. op1 Or  mmu^. Read (PC);
                Inc (PC);
              End;
        mword:
              Begin
                ir. op1 := ir. op1 And ( $ffff0000 );
                ir. op1 := ir. op1 Or  mmu^. readw (PC);
                Inc (PC, 2);
              End;
        mlong:
              Begin
                ir. op1 := mmu^. readl (PC);
                Inc (PC, 4);
              End;
      End;
      Else
    End;
    (*
    * 	Operand2 dekodieren u. ggf holen
    *)
    t := ir. opcode;
    t := (t And ( $f8000000 ) ) ShR 11; 		{ bits 11-15 maskieren }
    Case t Of
      0..17: ir. r2 := t;
      18: Case ir. mmode Of
        mbyte:
              Begin
                ir. op1 := ir. op1 And ( $ffffff00 );
                ir. op1 := ir. op1 Or  mmu^. Read (PC);
                Inc (PC);
              End;
        mword:
              Begin
                ir. op1 := ir. op1 And ( $ffff0000 );
                ir. op1 := ir. op1 Or  mmu^. readw (PC);
                Inc (PC, 2);
              End;
        mlong:
              Begin
                ir. op1 := mmu^. readl (PC);
                Inc (PC, 4);
              End;
      End;
      Else
    End;
    (*
    * 	Wirklicher Opcode nur die oberen 16 Bit
    *)
    ir. opcode := long (ir. opcode ShR 16);
  End;
End;
Procedure cpu_o. execute;
Begin
  If status In [ error, Halt ] Then Exit;
  Case Byte (regs. ir. opcode) Of
    opc_push:
             Begin
               c_push;
             End;
    opc_pop:
            Begin
              c_pop;
            End;
    opc_move:
             Begin
               c_move;
             End;
    opc_add:
            Begin
              c_add;
            End;
    opc_sub:
            Begin
              c_sub;
            End;
    opc_div:
            Begin
              c_div;
            End;
    opc_mul:
            Begin
              c_mul;
            End;
    opc_cmp:
            Begin
              c_cmp;
            End;
    opc_jmp:
            Begin
              c_jmp;
            End;
    opc_jmpz:
             Begin
               c_jmpz;
             End;
    opc_jmpc:
             Begin
               c_jmpc;
             End;
    opc_jmpn:
             Begin
               c_jmpn;
             End;
    opc_djnz:
             Begin
               c_djnz;
             End;
    opc_call:
             Begin
               c_call;
             End;
    opc_ret:
            Begin
              c_ret;
            End;
    opc_lda:
            Begin
              c_lda;
            End;
    Else
      panic ( cw_err_unknown_opcode + regs. ir. opcode, 'unknown Opcode' );
  End;
End;
Function cpu_o. get_op: long;
Begin
  If regs. ir. r1 = 0 Then
    get_op := regs. ir. op1
  Else
  Begin
    Case regs. ir. amode Of
      constant:
                 Case regs. ir .r1 Of
                   0..17:	panic ( cw_err_unknown_amode, ' constant register not allowed.' );
                   18: get_op := regs. ir. op1;
                 End;
      
      direct:
               Case regs. ir. r1 Of
                 0..7:	get_op := regs. dr [ regs. ir. r1 ];
                 8..15: get_op := regs. dr [ regs. ir. r1 - 8 ];
                 16:	get_op := regs. sp;
                 17:	get_op := regs. PC;
                 18:  get_op := mmu^. ReadL ( regs. ir. op1 );
               End;
      indirect:
                 Case regs. ir. r1 Of
                   0..7:	get_op := mmu^. ReadL ( regs. dr [ regs. ir. r1 ] );
                   8..15: get_op := mmu^. ReadL ( regs. dr [ regs. ir. r1 - 8 ] );
                   16:	get_op := mmu^. ReadL (regs. sp );
                   17:	get_op := mmu^. ReadL (regs. PC );
                   18:  get_op := mmu^. ReadL ( mmu^. ReadL ( regs. ir. op1 ) );
                 End;
    End;
  End;
End;
Procedure cpu_o. put_op;
Begin
End;
Procedure cpu_o. c_push;
Begin
  If regs. ir. r2 <> 0 Then
    panic ( 98, 'push: too many arguments.' );
  Case regs. ir. mmode Of
    mbyte:
          Begin
            mmu^. Write ( regs. SP, get_op );
            Dec ( regs. SP);
          End;
    mword:
          Begin
            mmu^. WriteW ( regs. SP, get_op );
            Dec ( regs. SP, 2);
          End;
    mlong:
          Begin
            mmu^. WriteL ( regs. SP, get_op );
            Dec ( regs. SP, 4);
          End;
  End;
End;
Procedure cpu_o. c_pop;
Begin
End;
Procedure cpu_o. c_move;
Begin
End;
Procedure cpu_o. c_add;
Begin
End;
Procedure cpu_o. c_sub;
Begin
End;
Procedure cpu_o. c_mul;
Begin
End;
Procedure cpu_o. c_div;
Begin
End;
Procedure cpu_o. c_cmp;
Begin
End;
Procedure cpu_o. c_jmp;
Begin
End;
Procedure cpu_o. c_jmpc;
Begin
End;
Procedure cpu_o. c_jmpz;
Begin
End;
Procedure cpu_o. c_jmpn;
Begin
End;
Procedure cpu_o. c_djnz;
Begin
End;
Procedure cpu_o. c_call;
Begin
End;
Procedure cpu_o. c_ret;
Begin
End;
Procedure cpu_o. c_lda;
Begin
End;
Begin
End.