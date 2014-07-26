interface lc3_io(input bit clk);

  logic [15:0] din_inst;
  logic [15:0] addr_inst;
  logic write_inst;
  logic reset;
  logic rd;
  logic [15:0] din;
  logic [15:0] addr;
  logic [2:0] dr;
  logic [15:0] dr_in;
  
  clocking cb @(posedge clk);
    default input #1 output #1;
    
    output din_inst;
    output write_inst;
    output addr_inst;
    input rd;
    input din;
    input addr;
    input dr;
    input dr_in;
    
  endclocking

  modport TB(clocking cb, output reset);
  
endinterface

interface inner_probe(
    input bit clk,
    input logic complete,
    input logic [5:0] E_control,
    input logic [5:0] C_control,
    input logic [1:0] W_control,
    input logic F_control,
    input logic M_control,
    input logic [3:0] state,
    input logic [15:0] aluout,
    input logic [15:0] pcout,
    input logic [15:0] npc,
    input logic [15:0] dout,
    input logic [15:0] vsr1,
    input logic [15:0] vsr2,
    input logic rd_fecth,
    input logic rd_mema,
    input logic [15:0] addr_mema,
    input logic [15:0] pc_fetch

);

  clocking cb @(posedge clk);
    default input #1 output #1;
    
    input complete;
    input E_control;
    input C_control;
    input W_control;
    input F_control;
    input M_control;
    input state;
    input aluout;
    input pcout;
    input npc;
    input dout;
    input vsr1;
    input vsr2;
    input rd_fecth;
    input rd_mema;
    input addr_mema;
    input pc_fetch;

  endclocking

  
endinterface


