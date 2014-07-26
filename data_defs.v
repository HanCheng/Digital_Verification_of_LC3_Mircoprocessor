`define 	CLK_PERIOD			10

`define     REGISTER_WIDTH      32  
`define     INSTR_WIDTH         32
`define     IMMEDIATE_WIDTH     16

`define     MEM_READ            3'b101
`define     MEM_WRITE           3'b100
`define     ARITH_LOGIC     	   3'b001
`define     GOTO_LOGIC		        3'b000

// ARITHMETIC
`define     ADD		            4'b0001
//`define     ADDI            	4'b0001
`define     AND		            4'b0101
//`define     ANDI	            4'b0101
`define     NOT        	     4'b1001

// GOTO 
`define     BR      		         4'b0000
`define     JUMP         	     4'b1100
`define     JSR         	      4'b0100


// DATA TRANSFER 
`define     LD                 	4'b0010
`define     LDR                 4'b0110
`define     LDI                	4'b1010
`define     LEA                	4'b1110
`define     ST                 	4'b0011
`define     STR                 4'b0111
`define     STI                	4'b1011
