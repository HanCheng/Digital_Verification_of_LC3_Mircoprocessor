module Top(
  clk,
  reset,
  din_inst,
  write_inst,
  addr_inst,
  rd,
  din,
  addr,
  dr,
  dr_in
  );
  
  input clk, reset, write_inst;
  input [15:0] din_inst, addr_inst;
  output [15:0] din, addr, dr_in;
  output rd;
  output [2:0] dr;
  
  wire complete;
  wire [15:0] dout;
  
  Memory Memory(reset, write_inst, addr_inst, addr, din, din_inst, rd, dout, complete);
  SimpleLC3 SimpleLC3(clk, reset, addr, din, dout, rd, complete);  
  
  
endmodule