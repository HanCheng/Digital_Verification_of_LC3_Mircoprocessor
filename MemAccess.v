module MemAccess (state, M_Control, VSR2, pcout, addr, din, dout, rd);

 input [3:0] state;       // System state from Controller
 input M_Control;         // Control signal indicating the source of memory address
 input [15:0] VSR2;       // Data for store operations
 input [15:0] pcout;      // Address for load/store operations
 output [15:0] addr;      // Address lines to memory
 output [15:0] din;       // Data-in lines to memory
 output rd;               // Signal to indicate memory read or write
 input [15:0] dout;       // Data-Out lines from Memory

 reg [15:0] addr, din;
 reg rd;

always@ (state or M_Control or VSR2 or pcout or dout)
 casex({state, M_Control})
	 5'b01100 : 
	 begin  // Read Direct Data
		 rd = 1'b1;
		 addr = pcout; 
	 end
	 5'b01101 : 
	 begin  // Read Indirect
		 rd = 1'b1;
		 addr = dout; 
	 end
	 5'b10000 : 
	 begin  // Write Direct
		 rd = 1'b0;
		 din = VSR2;
		 addr = pcout; 
	 end
	 5'b10001 : 
	 begin  // Write Indirect
		 rd = 1'b0;
		 din = VSR2;
		 addr = dout; 
	 end
	 5'b0111x : 
	 begin  // Indirect Memory Read
		 rd = 1'b1;
		 addr = pcout; 
	 end
	 default : 
	 begin  // set all outputs to high z
		 rd = 1'bz;
		 addr = 16'hzzzz;
		 din = 16'hzzzz;
	 end
 endcase
endmodule
