`timescale 1 ns/ 100 ps

module Controller(clock, reset, state, C_Control, complete);
 input clock, reset;         // system clock and reset
 output [3:0] state;        // system state
 input [5:0] C_Control;    // control from Decode module
 input complete;        // complete from memory

 reg [3:0] state;

always@ (posedge clock)
 if (reset) 
	state = 4'b0001;
 else if (complete)  // use current state and C_Control to determine next state
	 casex ({state, C_Control})
		 10'b0001xxxxxx : state = 4'b0010;    // Fetch to Decode
		 10'b0110xxxxxx : state = 4'b1001;    // Read Memory to Update Register File
		 10'b1001xxxxxx : state = 4'b1010;    // Update Register File to Update PC
		 10'b1010xxxxxx : state = 4'b0001; // Update PC to Fetch
		 10'b0011xxxxxx : state = 4'b1001;    // Execute to Update Register File
		 10'b1000xxxxxx : state = 4'b1010;    // Write Memory to Update PC
		 10'b0111xxxxx0 : state = 4'b1000;    // Indirect Read to Write Memory
		 10'b0111xxxxx1 : state = 4'b0110;    // Indirect Read to Read Memory
		 10'b001000xxxx : state = 4'b0011;    // Decode to Execute
		 10'b001001xxxx : state = 4'b0100;    // Decode to Compute Target PC
		 10'b00101xxxxx : state = 4'b0101;    // Decode to Compute Memory Address
		 10'b0100xx0xxx : state = 4'b1010;    // Compute Target PC to Update PC
		 10'b0100xx1xxx : state = 4'b1001;    // Compute Target PC to Update Register File
		 10'b0101xxx00x : state = 4'b0111;    // Compute Memory Address to Indirect Read
		 10'b0101xxx01x : state = 4'b0110;    // Compute Memory Address to Read Memory
		 10'b0101xxx10x : state = 4'b1000;    // Compute Memory Address to Write Memory
		 10'b0101xxx11x : state = 4'b1001;    // Compute Memory Address to Update Register File      
		 default : state = 4'b1111;    // Invalid state or C_Control
	 endcase
endmodule

