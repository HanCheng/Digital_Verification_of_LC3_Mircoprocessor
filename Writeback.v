
module Writeback (W_Control, aluout, dout, pcout, npc, DR_in);

 input [15:0] aluout, dout, pcout, npc;      // Possible data to store
 input [1:0] W_Control;               // Control signal to choose what will be written
 output [15:0] DR_in;                   // Data that will be stored in the registerfile

 reg [15:0] DR_in;

 always @( W_Control or aluout or dout or pcout or npc )
 case(W_Control)
	 2'b00 : DR_in = aluout;
	 2'b01 : DR_in = dout;
	 2'b10 : DR_in = pcout;
	 2'b11 : DR_in = npc;
	 default : DR_in = 16'hFFFF;
 endcase
endmodule


