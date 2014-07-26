`include "ReceiverBase.sv"
class Receiver extends ReceiverBase;

typedef mailbox #(OutPacket) out_box_type;
out_box_type rver_mail = new();
string name;

extern function new(string name = "Receiver", out_box_type rver_mail, virtual lc3_io.TB LC3, 
                                                    virtual inner_probe Prober);
extern task start();
endclass

function Receiver::new(string name = "Receiver", out_box_type rver_mail, virtual lc3_io.TB LC3, 
                                                    virtual inner_probe Prober);
  super.new(name, LC3, Prober);
  this.rver_mail = rver_mail;
endfunction

task Receiver::start();
  $display($time, "ns : [Receiver] Recevier Started ");
  @(LC3.cb);
  fork
    forever
    begin
      @(LC3.cb)         // Waiting for the instructions to be stored
      rev();
      rver_mail.put(pkt_cmp);
      $display($time, "ns : [Receiver] Received the number of Packets %d", rver_mail.num());
    end
  join_none
endtask