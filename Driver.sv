`include "DriverBase.sv"

class Driver extends DriverBase;
  
  Packet pkt2send;
  
  typedef mailbox #(Packet) out_box_type;
  out_box_type drvr_mail = new();
  
  typedef mailbox #(Packet) in_box_type;
  in_box_type gen_mail = new();
  
  reg [15:0] din_inst_temp;
  
  string name;
  extern function new(string  name = "Driver", in_box_type gen_mail, out_box_type drvr_mail, virtual lc3_io.TB LC3);
  extern task start();
  extern task getInst();
endclass

function Driver::new(string  name = "Driver", in_box_type gen_mail, out_box_type drvr_mail, virtual lc3_io.TB LC3);
  super.new(name, LC3);
  this.drvr_mail = drvr_mail;
  this.gen_mail = gen_mail;
  this.pkt2send = new();
endfunction

task Driver::start();

  int packet_sent = 0;
  $display($time, "ns : [Driver] Driver Statred");
  fork
    forever
    begin
      gen_mail.get(pkt2send);
      packet_sent ++;
      getInst();
      $display($time, "ns : [Driver] Sending the new Packet Begin");
      $display($time, "ns : [Driver] Packets Left in Generator mailbox %0d", gen_mail.num());
      
      
      this.payload_din_inst          =  din_inst_temp;
      this.payload_addr_inst         =  packet_sent + 12288;   //store the instruction starts at 0X3000 
      $display("address %h", payload_addr_inst);
      send();
      
      $display($time, "ns : [Driver] Sending the new Packets END");
      $display($time, "ns : [Driver] number of packets sent to [ScoreBoard] %0d", packet_sent);
      drvr_mail.put(pkt2send);
      
      if(gen_mail.num() == 0)
      begin
        break;
      end  
      @(LC3.cb);    
    end
  join_none
  
endtask

task Driver::getInst();
  
      if(pkt2send.opselect == `ARITH_LOGIC) begin
          $display($time, "ns : [Driver] The instruction is arithmetic");
          if(pkt2send.mode == 1) begin          // instant arith   instr
            $display($time, ":ns [Driver] The instruction is arithmetic and instant");
            din_inst_temp  = {pkt2send.opcode, pkt2send.dr, pkt2send.sr1, pkt2send.mode, pkt2send.imm5};
          end
          else if(pkt2send.mode == 0) begin     // not an instant arith instr
            $display($time, "ns : [Driver] The instruction is arithmetic and not an instant");
            din_inst_temp  = {pkt2send.opcode, pkt2send.dr, pkt2send.sr1, pkt2send.mode, 2'b00, pkt2send.sr2};
          end
      end
      else if(pkt2send.opselect == `GOTO_LOGIC) begin
        $display($time, "ns : [Driver] The instruction is Branch or Jump");
        if(pkt2send.opcode == `BR) begin     //if branch instr
          din_inst_temp  = {pkt2send.opcode, 12'h000};
        end
      end
      else if(pkt2send.opselect == `MEM_READ) begin           // if it is read memory instruction
        $display($time, "ns : [Driver] The instruction is Load");
        if(pkt2send.opcode == `LD || pkt2send.opcode == `LDI) begin
          $display($time, "ns : [Driver] The instruction is Load or Load instant");
          din_inst_temp  = {pkt2send.opcode, pkt2send.dr, pkt2send.pc_offset9};
        end
        else if(pkt2send.opcode == `LDR) begin          
          $display($time, "ns : [Driver] The instruction is Load from register");
          din_inst_temp  = {pkt2send.opcode, pkt2send.dr, pkt2send.BaseR, pkt2send.pc_offset6};
        end
      end
      else if(pkt2send.opselect == `MEM_WRITE) begin        // if it is write memory instruction
        $display($time, "ns : [Driver] The instruction is Write");
        if(pkt2send.opcode == `ST || pkt2send.opcode == `STI) begin
          $display($time, "ns : [Driver] The instruction is Write and Write instant");
          din_inst_temp  = {pkt2send.opcode, pkt2send.sr, pkt2send.pc_offset9};
        end
        else if(pkt2send.opcode == `STR) begin
          $display($time, "ns : [Driver] The instruction is Write from register");
          din_inst_temp  = {pkt2send.opcode, pkt2send.sr, pkt2send.BaseR, pkt2send.pc_offset6};
        end
      end
  
endtask

