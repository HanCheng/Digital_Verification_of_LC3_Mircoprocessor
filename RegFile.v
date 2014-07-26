module RegFile (VSR1, VSR2, sr1, sr2, dr, DR_in, state, clock, reset);

 output [15:0] VSR1;        // to Decode and Execute
 output [15:0] VSR2;        // to Decode and Execute
 input [2:0] sr1;        // from Decode
 input [2:0] sr2;        // from Decode
 input [2:0] dr;        // from Decode
 input [15:0] DR_in;        // from Memory
 input [3:0] state;        // from Controller
 input clock, reset;        // from Testbench

 reg [15:0] VSR1, VSR2;
 wire [15:0] R0, R1, R2, R3, R4, R5, R6, R7;
 reg [15:0] RegFile [0:7];

	assign R0 = RegFile[0];        // Create wires that can be seen on SimVision
	assign R1 = RegFile[1];
	assign R2 = RegFile[2];
	assign R3 = RegFile[3];
	assign R4 = RegFile[4];
	assign R5 = RegFile[5];
	assign R6 = RegFile[6];
	assign R7 = RegFile[7];

always@ (posedge clock)        // Set all Registers to 0
	if (reset) 
	begin
		 RegFile[0] = 16'h0000;
		 RegFile[1] = 16'h0000;
		 RegFile[2] = 16'h0000;
		 RegFile[3] = 16'h0000;
		 RegFile[4] = 16'h0000;
		 RegFile[5] = 16'h0000;
		 RegFile[6] = 16'h0000;
		 RegFile[7] = 16'h0000;
	end
	else if (state == 4'b1001) 
	begin    // Update Register based on ID of dr
		 case (dr[2:0]) //DR_in
		 3'b000 : RegFile[0] = DR_in;
		 3'b001 : RegFile[1] = DR_in;
		 3'b010 : RegFile[2] = DR_in;
		 3'b011 : RegFile[3] = DR_in;
		 3'b100 : RegFile[4] = DR_in;
		 3'b101 : RegFile[5] = DR_in;
		 3'b110 : RegFile[6] = DR_in;
		 3'b111 : RegFile[7] = DR_in;
		 endcase
	end

always@ (sr1 or sr2) 
begin
 case (sr1[2:0]) //VSR1
	 3'b000 : VSR1 = RegFile[0];        // Set Variable Source Register 1
	 3'b001 : VSR1 = RegFile[1];        // based on ID of sr1
	 3'b010 : VSR1 = RegFile[2];
	 3'b011 : VSR1 = RegFile[3];
	 3'b100 : VSR1 = RegFile[4];
	 3'b101 : VSR1 = RegFile[5];
	 3'b110 : VSR1 = RegFile[6];
	 3'b111 : VSR1 = RegFile[7];
	 default : VSR1 = 16'h0000;
 endcase

 case (sr2[2:0]) //VSR2
	 3'b000 : VSR2 = RegFile[0];        // Set Variable Source Register 2
	 3'b001 : VSR2 = RegFile[1];        // based on ID of sr2
	 3'b010 : VSR2 = RegFile[2];
	 3'b011 : VSR2 = RegFile[3];
	 3'b100 : VSR2 = RegFile[4];
	 3'b101 : VSR2 = RegFile[5];
	 3'b110 : VSR2 = RegFile[6];
	 3'b111 : VSR2 = RegFile[7];
	 default : VSR2 = 16'h0000;
 endcase
end
endmodule
