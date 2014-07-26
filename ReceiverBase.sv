class ReceiverBase;
  virtual lc3_io.TB LC3;
  virtual inner_probe Prober;
  
  OutPacket pkt_cmp;
  
  
//  reg [15:0] din_inst_cmp, write_inst_cmp;
  reg rd_cmp;
  reg [15:0] din_cmp, addr_cmp, dr_in_cmp;
  reg [2:0] dr_cmp;
  
  reg [15:0] vsr1_cmp, vsr2_cmp;
  reg [3:0] state_cmp;
  reg [15:0] pcout_cmp, aluout_cmp, npc_cmp, dout_cmp;
  reg [5:0] E_control_cmp, C_control_cmp;
  reg [1:0] W_control_cmp;
  reg F_control_cmp, M_control_cmp;
  reg rd_fecth_cmp, rd_mema_cmp;
  reg [15:0] addr_mema_cmp;
  reg [15:0] pc_fetch_cmp;
  reg complete_cmp;
  
  int pkt_cnt = 0;
  string name;
  extern function new(string name = "ReceiverBase", virtual lc3_io.TB LC3, virtual inner_probe Prober);
  extern task getpayload();
  extern task rev();
endclass

function ReceiverBase::new(string name = "ReceiverBase", virtual lc3_io.TB LC3, virtual inner_probe Prober);
  this.name = name;
  this.LC3 = LC3;
  this.Prober = Prober;
  this.pkt_cmp = new();
endfunction

task ReceiverBase::getpayload();
  
//  pkt_cmp.name = $sprintf("reve OutPacket[%0d]", pkt_cnt++);
  $display($time, "ns : [Recevier] Packets received: %d", pkt_cnt++);
  rd_cmp        = LC3.cb.rd;
  din_cmp       = LC3.cb.din;
  addr_cmp      = LC3.cb.addr;
  dr_cmp        = LC3.cb.dr;
  dr_in_cmp     = LC3.cb.dr_in;
  
  state_cmp = Prober.cb.state;
  pcout_cmp = Prober.cb.pcout;
  vsr1_cmp  = Prober.cb.vsr1;
  vsr2_cmp  = Prober.cb.vsr2;
  E_control_cmp =  Prober.cb.E_control;
  C_control_cmp = Prober.cb.C_control;
  W_control_cmp = Prober.cb.W_control;
  F_control_cmp = Prober.cb.F_control;
  M_control_cmp = Prober.cb.M_control;
  aluout_cmp    = Prober.cb.aluout;
  npc_cmp       = Prober.cb.npc;
  dout_cmp      = Prober.cb.dout;
  rd_fecth_cmp  = Prober.cb.rd_fecth;
  rd_mema_cmp   = Prober.cb.rd_mema;
  addr_mema_cmp = Prober.cb.addr_mema;
  pc_fetch_cmp  = Prober.cb.pc_fetch;
  complete_cmp  = Prober.cb.complete;
  
endtask


task ReceiverBase::rev();
  getpayload();
  
  pkt_cmp.rd        = rd_cmp;
  pkt_cmp.din       = din_cmp;
  pkt_cmp.addr      = addr_cmp;
  pkt_cmp.dr_in     = dr_in_cmp;
  pkt_cmp.dr        = dr_cmp;
  
  pkt_cmp.state  =  state_cmp;
  pkt_cmp.pcout  =  pcout_cmp;
  pkt_cmp.vsr1  = vsr1_cmp;
  pkt_cmp.vsr2  = vsr2_cmp;
  pkt_cmp.E_control =  E_control_cmp;
  pkt_cmp.C_control =  C_control_cmp;
  pkt_cmp.W_control =  W_control_cmp;
  pkt_cmp.F_control =  F_control_cmp;
  pkt_cmp.M_control =  M_control_cmp;
  pkt_cmp.aluout    =  aluout_cmp ;
  pkt_cmp.npc       =  npc_cmp ;
  pkt_cmp.dout      =  dout_cmp;
  pkt_cmp.rd_fecth  =  rd_fecth_cmp;
  pkt_cmp.rd_mema   =  rd_mema_cmp ;
  pkt_cmp.addr_mema =  addr_mema_cmp;
  pkt_cmp.pc_fetch  =  pc_fetch_cmp ;
  pkt_cmp.complete  =  complete_cmp;
endtask

