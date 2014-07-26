module Memory(
    reset,
    write_inst,
    addr_inst,
    addr, 
    din,
    din_inst,
    rd,
    dout,
    complete
  );
  
  input reset, write_inst, rd;
  input [15:0] addr, din, din_inst, addr_inst;
  output [15:0] dout;
  output complete;
  
  reg [15:0] dout;
  reg complete;
  
  reg [15:0] mem [0:127];
  
  always@(write_inst, rd, addr, addr_inst, din, din_inst)
  begin
    if(write_inst == 1)
    begin
      mem[addr_inst] <= din_inst;
      complete <= 1'b0;
    end
    else
      begin
        complete <= 1'b1;
        if(rd == 1'b1)
        begin
          dout <= mem[addr];
        end
        else if(rd == 1'b0)
        begin
          mem[addr] <= din;
        end 
      end
  end
  
  
  
endmodule