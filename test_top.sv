module test_top;

  reg sysclk;
  
  lc3_io lc3_io(sysclk);
  inner_probe inner_probe(
    .clk(sysclk),
    .complete(dut.Memory.complete),
    .E_control(dut.SimpleLC3.Decode.E_Control),
    .C_control(dut.SimpleLC3.Decode.C_Control),
    .W_control(dut.SimpleLC3.Decode.W_Control),
    .F_control(dut.SimpleLC3.Decode.F_Control),
    .M_control(dut.SimpleLC3.Decode.M_Control),
    .state(dut.SimpleLC3.Controller.state),
    .aluout(dut.SimpleLC3.Execute.aluout),
    .pcout(dut.SimpleLC3.Execute.pcout),
    .npc(dut.SimpleLC3.Fetch.npc),
    .dout(dut.Memory.dout),
    .vsr1(dut.SimpleLC3.RegFile.VSR1),
    .vsr2(dut.SimpleLC3.RegFile.VSR2),
    .rd_fecth(dut.SimpleLC3.Fetch.rd),
    .rd_mema(dut.SimpleLC3.MemAccess.rd),   //memaccess
    .addr_mema(dut.SimpleLC3.MemAccess.addr),
    .pc_fetch(dut.SimpleLC3.Fetch.pc)
    );
    
    LC3_test testbench(lc3_io, inner_probe);
    
    Top dut(
      lc3_io.clk,
      lc3_io.reset,
      lc3_io.din_inst,
      lc3_io.write_inst,
      lc3_io.addr_inst,
      lc3_io.rd,
      lc3_io.din,
      lc3_io.addr,
      lc3_io.dr,
      lc3_io.dr_in
    );
    
    initial begin
      sysclk = 0;
		    forever 
		    begin
			   #(10/2)
			   sysclk = ~sysclk;
		    end
      
    end
endmodule