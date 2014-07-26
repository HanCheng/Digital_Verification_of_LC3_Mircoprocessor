class OutPacket;

reg [15:0] din;
reg rd;
reg [15:0] dr_in, addr;
reg [2:0] dr;

reg [15:0] vsr1, vsr2;
reg [3:0] state;
reg [15:0] pcout, aluout, npc, dout;
reg [5:0] E_control, C_control;
reg [1:0] W_control;
reg F_control, M_control;
reg rd_fecth, rd_mema;
reg [15:0] addr_mema;
reg [15:0] pc_fetch;
    
reg complete;


string name;
extern function new(string name = "OutPacket");
endclass

function OutPacket::new(string name = "OutPacket");
  this.name = name;  
endfunction

