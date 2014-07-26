`timescale 1 ns/ 100 ps

module Decode(VSR1, VSR2, clock, state, dout, C_Control, E_Control, 
 M_Control, W_Control, F_Control, D_Data, DR_in, sr1, sr2, dr);
 
	 input [15:0] VSR1;       // Loopback from RegFile module
	 input [15:0] VSR2;       // Loopback from RegFile module
	 input clock;             // Global system clock
	 input [3:0] state;       // System state from Controller
	 input [15:0] dout;       // Data-out lines from memory
	 input [15:0] DR_in;      // Data to be written to registerfile
	 output M_Control;        // MemAccess control line
	 output [1:0] W_Control;  // Writeback control lines
	 output [5:0] C_Control;  // Controller control lines
	 output [5:0] E_Control;  // Execute control lines
	 output [47:0] D_Data;    // Data for Execute and MemAccess blocks
	 output F_Control;        // Fetch control line
	 output [2:0] sr1;       // Source Register 1 ID to RegFile
	 output [2:0] sr2;       // Source Register 2 ID to RegFile
	 output [2:0] dr;       // Destination Register ID to RegFile

	reg [2:0] PSR, newpsr;
	reg F_Control;
	reg M_Control;
	reg [1:0] W_Control;
	reg [5:0] C_Control, E_Control;
	reg [2:0] dr, sr1, sr2;
	reg [15:0] IR;

assign D_Data [47:0] = {IR, VSR1, VSR2}; // Create D_Data wire output

always@ (posedge clock)
begin
 if (state == 4'b0010) IR = dout; // Decode
 if ((state == 4'b1001) && (IR[15:12] != 4'b0100) && (IR[15:12] != 4'b0000)) PSR = newpsr;
end // update PSR if state = Update RegFile and not a JSR, JSRR or BR

always@ (DR_in) // combinational logic used to create newpsr from high bit of DR_in
 begin
 if(DR_in[15])
	newpsr = 3'b100; // if negative
 else if(|DR_in)
	newpsr = 3'b001; //if positive
 else
	newpsr = 3'b010; // zero
 end

always@ (dout)    // determine the type of instruction being used
	 case (dout[13:12])
	 2'b01 : C_Control[5:4] = 2'b00; // Arithmetic Operation
	 2'b00 : C_Control[5:4] = 2'b01; // GOTO Operation
	 2'b10 : C_Control[5:4] = 2'b10; // Load Operation
	 2'b11 : C_Control[5:4] = 2'b10; // Store Operation
	 default : C_Control[5:4] = 2'b11; // Bad Opcode
endcase

always@ (IR or PSR)
begin
 case(IR[15:12])
	 4'b0001: 
	 begin //ADD1 & ADD0 IR[5] = 1 = imm5
		 E_Control = (IR[5]) ? 6'b001000 : 6'b000000;
		 C_Control[3:0] = 4'b0000;
		 W_Control = 2'b00; // Writeback = aluout
		 F_Control = 1'b0;
		 M_Control = 1'b0;
		 dr  = IR[11:9];
		 sr1 = IR[8:6];
		 sr2 = IR[2:0];        
	 end
	 4'b0101: 
	 begin //AND1 & AND0 IR[5] = 1 = imm5
		 E_Control = (IR[5]) ? 6'b011000 : 6'b010000;
		 C_Control[3:0] = 4'b0000;
		 W_Control = 2'b00; // Writeback = aluout
		 F_Control = 1'b0;
		 M_Control = 1'b0;
		 dr  = IR[11:9];
		 sr1 = IR[8:6];
		 sr2 = IR[2:0];
	 end
	 4'b1001: 
	 begin //NOT
		 C_Control[3:0] = 4'b0000;
		 W_Control = 2'b00; // Writeback = aluout
		 F_Control = 1'b0;
		 E_Control = 6'b100000; // aluout = ~(VSR1)
		 M_Control = 1'b0;
		 dr  = IR[11:9];
		 sr1 = IR[8:6];
	 end
	 4'b0000:
	 begin //BR
		 C_Control[3:0] = 4'b0000;
		 W_Control = 2'b00; // Writeback = aluout
		 F_Control = |(IR[11:9] & PSR);
		 E_Control = 6'b000011; // pcout = npc + offset9
		 M_Control = 1'b0;
	 end
	 4'b1100: 
	 begin //JMP & RET
		 C_Control[3:0] = 4'b0000;
		 W_Control = 2'b00; // Writeback = aluout
		 F_Control = 1'b1; // Branch taken
		 E_Control = 6'b000100; // pcout = VSR1 + offset6
		 M_Control = 1'b0;
		 sr1 = IR[8:6];
	 end
	 4'b0100: 
	 begin //JSR and JSRR
		 E_Control = (IR[11]) ? 6'b000001 : 6'b000100;
		 C_Control[3:0] = 4'b1000;
		 W_Control = 2'b11;  // Writeback = npc
		 F_Control = 1'b1; // Branch taken
		 M_Control = 1'b0;
		 dr = 3'b111; // store return address in R7
		 sr1 = IR[8:6];
	 end     
	 4'b0010: 
	 begin //LD
		 C_Control[3:0] = 4'b0010;
		 W_Control = 2'b01; // Writeback = dout
		 F_Control = 1'b0;
		 E_Control = 6'b000011; // pcout = npc + offset9
		 M_Control = 1'b0;
		 dr = IR[11:9];
	 end         
	 4'b0110: 
	 begin //LDR
		 C_Control[3:0] = 4'b0010;
		 W_Control = 2'b01; // Writeback = dout
		 F_Control = 1'b0;
		 E_Control = 6'b000100; // pcout = VSR1 + offset6
		 M_Control = 1'b0;
		 dr = IR[11:9];
		 sr1 = IR[8:6];
	 end
	 4'b1010:
	 begin //LDI
		 C_Control[3:0] = 4'b0001;
		 W_Control = 2'b01; // Writeback = dout
		 F_Control = 1'b0;
		 E_Control = 6'b000011; // pcout = npc + offset9
		 M_Control = 1'b1; // Indirect Mode
		 dr = IR[11:9];
	 end
	 4'b1110:
	 begin //LEA
		 C_Control[3:0] = 4'b0110;
		 W_Control = 2'b10; // Writeback = pcout
		 F_Control = 1'b0;
		 E_Control = 6'b000011; // pcout = npc + offset9
		 M_Control = 1'b0;
		 dr = IR[11:9];
	 end
	 4'b0011: 
	 begin //ST
		 C_Control[3:0] = 4'b0100;
		 W_Control = 2'b00; // Writeback = aluout
		 F_Control = 1'b0;
		 E_Control = 6'b000011; // pcout = npc + offset9
		 M_Control = 1'b0;
		 sr2 = IR[11:9];
	 end
	 4'b0111: 
	 begin //STR
		 C_Control[3:0] = 4'b0100;
		 W_Control = 2'b00; // Writeback = aluout
		 F_Control = 1'b0;
		 E_Control = 6'b000100; // pcout = VSR1 + offset6
		 M_Control = 1'b0;
		 sr1 = IR[8:6];
		 sr2 = IR[11:9];
	 end
	 4'b1011: 
	 begin //STI
		 C_Control[3:0] = 4'b0000;
		 W_Control = 2'b00; // Writeback = aluout
		 F_Control = 1'b0;
		 E_Control = 6'b000011; // pcout = VSR1 + offset9
		 M_Control = 1'b1;
		 sr2  = IR[11:9];
	 end
	 default : 
	 begin // Bad Opcode
		 E_Control = 6'b111111;
		 C_Control[3:0] = 4'b1111;
		 W_Control = 2'b11;
		 F_Control = 1'b1;
		 M_Control = 1'b1;
		 sr1 = 3'b111;
		 sr2 = 3'b111;
		 dr = 3'b111;
	 end
	 endcase
end
endmodule
