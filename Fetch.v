module Fetch (clock, reset, state, addr, npc, rd, pcout, F_Control);

 input clock;            // system clock
 input reset;            // system reset
 input F_Control;        // signal from Decode, 1 means branch taken
 input [15:0] pcout;        // target address of control instructions
 input [3:0] state;        // system state from Controller
 output [15:0] addr, npc;    // current PC and next PC, i.e., pc+1
 output rd;            // memory read control signal

 wire [15:0] addr, node_A, node_B, node_C;
 reg [15:0] pc;

assign npc = pc+1;        // assures that npc is always pc+1
assign node_A = (F_Control) ? pcout : npc;
assign node_B = (state == 4'b1010) ? node_A : pc;
assign node_C = (reset) ? 16'h3000 : node_B;
assign addr = (state !=4'b0110 && state != 4'b1000 && state !=4'b0111) ? pc : 16'hzzzz;
assign rd = (state !=4'b0110 && state != 4'b1000 && state !=4'b0111) ? 1 : 1'bz;

always@(posedge clock)
 pc <= node_C;            // update pc on each rising clock edge
endmodule
