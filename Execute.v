module Execute (E_Control, D_Data, aluout, pcout, npc);

 input [5:0] E_Control;         // control signals from Decode
 input [47:0] D_Data;             // data from Decode
 output [15:0] aluout;             // output of ALU
 output [15:0] pcout;                // output of address computation module
 input [15:0] npc;             // next PC from Fetch

 wire [15:0] IR, VSR1, VSR2, offset6, offset9, offset11, imm5;
 reg [15:0] aluout, pcout;

 assign IR = D_Data[47:32];
 assign VSR1 = D_Data[31:16];
 assign VSR2 = D_Data[15:0];
 assign imm5 = ({{11{IR[4]}}, IR[4:0]});     // sign extended 5 bit operand
 assign offset6 = ({{10{IR[5]}}, IR[5:0]});     // sign extended 6 bit offset
 assign offset9 = ({{7{IR[8]}}, IR[8:0]});     // sign extended 9 bit offset
 assign offset11 = ({{5{IR[10]}}, IR[10:0]});    // sign extended 11 bit offset

always@(E_Control or VSR1 or VSR2 or imm5)    // ALU Function
 casex (E_Control [5:3])
	 3'b000: aluout = VSR1 + VSR2;    // ADD Mode 0
	 3'b001: aluout = VSR1 + imm5;    // ADD Mode 1
	 3'b010: aluout = VSR1 & VSR2;    // AND Mode 0
	 3'b011: aluout = VSR1 & imm5;    // AND Mode 1
	 3'b1xx: aluout = ~(VSR1);        // NOT
 endcase

always@(E_Control or npc or D_Data or VSR1 or offset11 or offset9 or offset6)    // Address Computer
 case (E_Control [2:0])
	 3'b000: pcout = VSR1 + offset11;    // Register + offset
	 3'b001: pcout = npc + offset11;    // Next PC + offset
	 3'b010: pcout = VSR1 + offset9;
	 3'b011: pcout = npc + offset9;
	 3'b100: pcout = VSR1 + offset6;
	 3'b101: pcout = npc + offset6;
	 3'b110: pcout = VSR1;
	 3'b111: pcout = npc;
 endcase
endmodule
