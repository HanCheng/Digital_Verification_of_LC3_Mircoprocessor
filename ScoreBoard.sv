class ScoreBoard;

Packet pkt2send = new();
OutPacket pkt_cmp = new();

typedef mailbox #(Packet) in_box_type;
in_box_type drvr_mail = new();

typedef mailbox #(OutPacket) out_box_type;
out_box_type rver_mail = new();

reg [15:0] din_chk;
reg rd_chk;
reg [15:0] dr_in_chk;
reg [2:0] dr_chk;
reg [15:0] addr_chk;

reg [15:0] vsr1_chk, vsr2_chk;
reg [3:0] state_chk;
reg [15:0] pcout_chk, aluout_chk, npc_chk, dout_chk;
reg [5:0] E_control_chk, C_control_chk;
reg [1:0] W_control_chk;
reg F_control_chk, M_control_chk;
reg rd_fecth_chk, rd_mema_chk;
reg [15:0] addr_mema_chk;
reg [15:0] pc_fetch_chk;
reg [2:0] psr_chk;

reg [15:0] regFile [0:7];
reg [15:0] mem[0:127];

reg complete_chk;

string name;
extern function new(string name = "ScoreBoard", in_box_type drvr_mail = null, out_box_type rver_mail = null);
extern task start();
extern task check();
extern task check_control();
extern task check_regFile();
extern task check_fsm();
extern task check_arith();
extern task check_memop();
extern task check_memory();
//extern task check_memwrite();
//extern task check_gotoinstr();
endclass

function ScoreBoard::new(string name = "ScoreBoard", in_box_type drvr_mail = null, out_box_type rver_mail = null);
  this.name = name; 
  if(drvr_mail == null)
     drvr_mail = new();
  if (rver_mail == null)
     rver_mail = new();
  this.drvr_mail = drvr_mail;
  this.rver_mail = rver_mail;
endfunction

task ScoreBoard::start();
  
   
  din_chk = 0;
  rd_chk = 0;
  dr_in_chk = 0;
  dr_chk = 0;

  vsr1_chk = 0; 
  vsr2_chk = 0;
  state_chk = 0;
  pcout_chk = 0; 
  aluout_chk = 0; 
  npc_chk = 0;
  dout_chk = 0;
  E_control_chk = 0;
  C_control_chk = 0;
  W_control_chk = 0;
  F_control_chk = 0; 
  M_control_chk = 0;
  rd_fecth_chk = 0;
  rd_mema_chk = 0;
  addr_mema_chk = 0;
  pc_fetch_chk = 0;
  psr_chk = 0;
  complete_chk = 1;

  /*
  regFile[0] = 0;
  regFile[1] = 1;
  regFile[2] = 2;
  regFile[3] = 3;
  regFile[4] = 4;
  regFile[5] = 5;
  regFile[6] = 6;
  regFile[7] = 7;
  */
  foreach(regFile[i])
    regFile[i] = i;
  
  foreach(mem[i])
    mem[i] = 0;
    
  $display($time,"ns : [ScoreBoard] ScoreBoard Started");
  fork
    forever
    begin
      while(rver_mail.num() == 0)
      begin
        $display($time, "ns : [ScoreBoard] Waiting for data coming from Receiver");
        #`CLK_PERIOD;
        $display($time, "ns: [ScoreBoard] Received %h packets", rver_mail.num());
      end 
      while(rver_mail.num())
      begin
        $display($time, "ns : [Scoreboard] Receving data from Receiver and Begining to check");
        drvr_mail.get(pkt2send);
        rver_mail.get(pkt_cmp);
        check();
      end
    end
  join_none
  $display($time, "ns : [ScoreBoard] Forking the thread finished");
endtask

task ScoreBoard::check();
 
  check_control();
  check_fsm();
  check_regFile();
  check_arith();
  check_memop();
  check_memory();
//  check_gotoinstr();

endtask

task ScoreBoard::check_regFile();

  $display($time, "ns : [Scoreboard] Check the register file output");
  
  vsr1_chk    = regFile[pkt2send.sr1];
  vsr2_chk    = regFile[pkt2send.sr2];
  dr_in_chk   = regFile[pkt2send.dr];
  
  $display($time, "ns:   [CHECK_REGFILE] vsr1: DUT = %h  & Golden Model = %h\n", pkt_cmp.vsr1, vsr1_chk);
  $display($time, "ns:   [CHECK_REGFILE] vsr2: DUT = %h  & Golden Model = %h\n", pkt_cmp.vsr2, vsr2_chk);
  $display($time, "ns:   [CHECK_REGFILE] dr_in: DUT = %h  & Golden Model = %h\n", pkt_cmp.dr_in, dr_in_chk);
  
endtask

task ScoreBoard::check_arith();
  $display($time, "ns : [ScoreBoard] Check the arithmatic results ");
  case(pkt2send.opcode)
    `ADD : begin
      if(pkt2send.mode == 0) begin
        aluout_chk = vsr1_chk + vsr2_chk;
      end
      else if(pkt2send.mode == 1) begin
        aluout_chk = vsr1_chk + pkt2send.imm5;
      end
    end
    `AND : begin
      if(pkt2send.mode == 0) begin
        aluout_chk = vsr1_chk & vsr2_chk;
      end
      else if(pkt2send.mode == 1) begin
        aluout_chk = vsr1_chk & pkt2send.imm5;
      end
    end
    `NOT : aluout_chk = ~vsr1_chk;
  endcase
  $display($time, "ns :   [CHECK_ARITH] aluout: DUT = %h  & Golden Model = %h\n", pkt_cmp.aluout, aluout_chk);
endtask


task ScoreBoard::check_control();
  $display($time, "ns : [ScoreBoard] Check the control signals cming from IR");
  
  case(pkt2send.opcode)
    4'b0001 : 
    begin                   // ADD &  ADDI
      if(pkt2send.mode == 0) begin
        E_control_chk = 6'b000000;
      end
      else if(pkt2send.mode == 1) begin
        E_control_chk = 6'b001000;
      end 
      C_control_chk = 6'b000000;
      F_control_chk = 1'b0;
      W_control_chk = 2'b00;
      M_control_chk = 1'b0;
    end
    4'b0101 : 
    begin                   // AND &  ANDI
      if(pkt2send.mode == 0) begin
        E_control_chk = 6'b010000;
      end
      else if(pkt2send.mode == 1) begin
        E_control_chk = 6'b011000;
      end 
      C_control_chk = 6'b000000;
      F_control_chk = 1'b0;
      W_control_chk = 2'b00;
      M_control_chk = 1'b0;
    end
    4'b1001 : 
    begin                   // NOT
      E_control_chk = 6'b100000;
      C_control_chk = 6'b000000;
      F_control_chk = 1'b0;
      W_control_chk = 2'b00;
      M_control_chk = 1'b0;
    end
    4'b0000 : 
    begin                   // BR   need to be considered!!!!!
      E_control_chk = 6'b000011;
      C_control_chk = 6'b010000;
      F_control_chk = 1'b0;
      W_control_chk = 2'b00;
      M_control_chk = 1'b0;
    end
    4'b1100 : 
    begin                   // JUMP
      E_control_chk = 6'b000100;
      C_control_chk = 6'b010000;
      F_control_chk = 1'b1;
      W_control_chk = 2'b00;
      M_control_chk = 1'b0;
    end
    4'b1001 : 
    begin                   // JSR need to be considered!!!!!!!!
      E_control_chk = 6'b100000;
      C_control_chk = 6'b000000;
      F_control_chk = 1'b0;
      W_control_chk = 2'b00;
      M_control_chk = 1'b0;
    end
    4'b0010 :
    begin                   // LD
      E_control_chk = 6'b000011;
      C_control_chk = 6'b100010;
      F_control_chk = 1'b0;
      W_control_chk = 2'b01;
      M_control_chk = 1'b0;
    end
    4'b0110 : 
    begin                   // LDR
      E_control_chk = 6'b000100;
      C_control_chk = 6'b100010;
      F_control_chk = 1'b0;
      W_control_chk = 2'b01;
      M_control_chk = 1'b0;
    end
    4'b1010 : 
    begin                   // LDI
      E_control_chk = 6'b000011;
      C_control_chk = 6'b100001;
      F_control_chk = 1'b0;
      W_control_chk = 2'b01;
      M_control_chk = 1'b1;
    end
    4'b1110 : 
    begin                   // LEA
      E_control_chk = 6'b000011;
      C_control_chk = 6'b100011;
      F_control_chk = 1'b0;
      W_control_chk = 2'b10;
      M_control_chk = 1'b0;
    end
    4'b0011 : 
    begin                   // ST
      E_control_chk = 6'b000011;
      C_control_chk = 6'b100100;
      F_control_chk = 1'b0;
      W_control_chk = 2'b00;
      M_control_chk = 1'b0;
    end
    4'b0111: 
    begin                   // STR
      E_control_chk = 6'b000100;
      C_control_chk = 6'b100100;
      F_control_chk = 1'b0;
      W_control_chk = 2'b00;
      M_control_chk = 1'b0;
    end
    4'b1011 : 
    begin                   // STI
      E_control_chk = 6'b000011;
      C_control_chk = 6'b100000;
      F_control_chk = 1'b0;
      W_control_chk = 2'b00;
      M_control_chk = 1'b1;
    end
  endcase
  
  $display($time, "ns:   [CHECK_CONTROL] E_control: DUT = %h  & Golden Model = %h\n", pkt_cmp.E_control, E_control_chk);
  $display($time, "ns:   [CHECK_CONTROL] C_control: DUT = %h  & Golden Model = %h\n", pkt_cmp.C_control, C_control_chk);
  $display($time, "ns:   [CHECK_CONTROL] F_control: DUT = %h  & Golden Model = %h\n", pkt_cmp.F_control, F_control_chk);
  $display($time, "ns:   [CHECK_CONTROL] W_control: DUT = %h  & Golden Model = %h\n", pkt_cmp.W_control, W_control_chk);
  $display($time, "ns:   [CHECK_CONTROL] M_control: DUT = %h  & Golden Model = %h\n", pkt_cmp.M_control, M_control_chk);
endtask

task ScoreBoard::check_fsm();
  $display($time, " :ns [ScoreBoard] check the correctness of finite state machine");
  
  if(pkt2send.reset)
    state_chk = 4'b0001;
  else if (complete_chk)  // use current state and C_Control to determine next state
	 casex ({state_chk, C_control_chk})
		 10'b0001xxxxxx : state_chk = 4'b0010;    // Fetch to Decode
		 10'b0110xxxxxx : state_chk = 4'b1001;    // Read Memory to Update Register File
		 10'b1001xxxxxx : state_chk = 4'b1010;    // Update Register File to Update PC
		 10'b1010xxxxxx : state_chk = 4'b0001;    // Update PC to Fetch
		 10'b0011xxxxxx : state_chk = 4'b1001;    // Execute to Update Register File
		 10'b1000xxxxxx : state_chk = 4'b1010;    // Write Memory to Update PC
		 10'b0111xxxxx0 : state_chk = 4'b1000;    // Indirect Read to Write Memory
		 10'b0111xxxxx1 : state_chk = 4'b0110;    // Indirect Read to Read Memory
		 10'b001000xxxx : state_chk = 4'b0011;    // Decode to Execute
		 10'b001001xxxx : state_chk = 4'b0100;    // Decode to Compute Target PC
		 10'b00101xxxxx : state_chk = 4'b0101;    // Decode to Compute Memory Address
		 10'b0100xx0xxx : state_chk = 4'b1010;    // Compute Target PC to Update PC
		 10'b0100xx1xxx : state_chk = 4'b1001;    // Compute Target PC to Update Register File
		 10'b0101xxx00x : state_chk = 4'b0111;    // Compute Memory Address to Indirect Read
		 10'b0101xxx01x : state_chk = 4'b0110;    // Compute Memory Address to Read Memory
		 10'b0101xxx10x : state_chk = 4'b1000;    // Compute Memory Address to Write Memory
		 10'b0101xxx11x : state_chk = 4'b1001;    // Compute Memory Address to Update Register File      
		 default : state_chk = 4'b1111;    // Invalid state or C_Control
	 endcase
	 
	 $display($time, "ns:   [CHECK_FSM] state: DUT = %h   & Golden Model = %h\n", pkt_cmp.state, state_chk);
endtask

task ScoreBoard::check_memop();
  reg [15:0] nodeA;
  
  case(E_control_chk[3:2])
   2'b00: nodeA = pkt2send.pc_offset6;
   2'b01: nodeA = pkt2send.pc_offset9;
   2'b10: nodeA = pkt2send.pc_offset11;
   default : nodeA = 16'h1111;
  endcase
  
  pcout_chk = nodeA + (E_control_chk[1]? vsr1_chk : npc_chk);
   
  casex({state_chk, M_control_chk})
    5'b01100 : 
    begin
      rd_mema_chk = 1'b1;
      addr_mema_chk = pcout_chk;
    end
    5'b01101 : 
	 begin  // Read Indirect
		 rd_mema_chk = 1'b1;
		 addr_mema_chk = dout_chk; 
	 end
	 5'b10000 : 
	 begin  // Write Direct
		 rd_mema_chk = 1'b0;
		 din_chk = vsr2_chk;
		 addr_mema_chk = pcout_chk; 
	 end
	 5'b10001 : 
	 begin  // Write Indirect
		 rd_mema_chk = 1'b0;
		 din_chk = vsr2_chk;
		 addr_mema_chk = dout_chk; 
	 end
	 5'b0111x : 
	 begin  // Indirect Memory Read
		 rd_mema_chk = 1'b1;
		 addr_mema_chk = pcout_chk; 
	 end
	 default : 
	 begin  // set all outputs to high z
		 rd_mema_chk = 1'bz;
		 addr_mema_chk = 16'hzzzz;
		 din_chk = 16'hzzzz;
	 end
  endcase
  
  
  $display($time, "ns:   [CHECK_MEM] rd_mema: DUT = %h   & Golden Model = %h\n", pkt_cmp.rd_mema, rd_mema_chk);
  $display($time, "ns:   [CHECK_MEM] addr_mema: DUT = %h   & Golden Model = %h\n", pkt_cmp.addr_mema, addr_mema_chk);
  $display($time, "ns:   [CHECK_MEM] din: DUT = %h   & Golden Model = %h\n", pkt_cmp.din, din_chk);
endtask

task ScoreBoard::check_memory();
  
  if(rd_chk == 1'b1)
    dout_chk = mem[addr_chk];
  else if (rd_chk == 1'b0)
    mem[addr_chk] = din_chk;
  $display($time, "ns:   [CHECK_MEM] dout: DUT = %h   & Golden Model = %h\n", pkt_cmp.dout, dout_chk);
  $display($time, "ns:   [CHECK_MEM] din: DUT = %h   & Golden Model = %h\n", pkt_cmp.din, din_chk);  
endtask

