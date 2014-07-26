class DriverBase;
  virtual lc3_io.TB LC3;
  //packet pkt2send;
  reg [15:0] payload_din_inst;
  reg payload_write_inst;
  reg payload_reset;
  reg payload_addr_inst;
   
  string name;
  extern function new(string name = "DriverBase", virtual lc3_io.TB LC3);
  extern task send_payload();
  extern task send();
endclass

function DriverBase::new(string name = "DriverBase", virtual lc3_io.TB LC3);
  this.name = name;
  this.LC3 = LC3;
 // this.pkt2send = new;
endfunction

task DriverBase::send();
  send_payload();
endtask

task DriverBase::send_payload();
  $display($time, "ns : [Driver] Sending Payload to [Interface] Begin");
  LC3.cb.din_inst      <= payload_din_inst;
  LC3.cb.addr_inst     <= payload_addr_inst;
endtask

