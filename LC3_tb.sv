program LC3_test(lc3_io.TB LC3, inner_probe Prober);
  
  Generator gen;
  Driver drv;
  Receiver rver;
  ScoreBoard sb;
  
  Packet pkt2send = new();
  int number_packets;
  
  initial begin
    number_packets = 50;
    gen = new("Generator", number_packets);
    sb = new();
    
    drv = new("drvr[0]", gen.gen_mail, sb.drvr_mail, LC3);
    rver = new("rver[0]", sb.rver_mail, LC3, Prober);
    
    reset();

    LC3.cb.write_inst  <= 1'b1;
    gen.start();
    drv.start();
    repeat(3) @(LC3.cb);
    LC3.cb.write_inst  <= 1'b0;
    
    sb.start();
    rver.start();
    
    repeat(number_packets + 1) @(LC3.cb);
    
    $display($time, "ns : Are we done yet!? YES!");
  end 
  
  task reset();
    
    $display($time, "ns : [RESET] Design reset start");
    LC3.reset         <= 1'b1;
//    LC3.cb.complete   <= 1'b0;
    repeat(5) @(LC3.cb);
    LC3.reset         <= 1'b0;
//    LC3.cb.complete   <= 1'b1;
    $display ($time, "ns :  [RESET]  Design Reset End");
  endtask
  
endprogram