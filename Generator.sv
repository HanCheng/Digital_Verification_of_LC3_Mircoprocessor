class Generator;
  
  Packet pkt2send;
  typedef mailbox #(Packet) out_box_type;
  out_box_type gen_mail;
  
  int packet_number;
  int number_packets;
  
  string name;
  extern function new(string name = "Generator", int number_packets = 0);
  extern task gen();
  extern task start();
endclass

function Generator::new(string name = "Generator", int number_packets = 0);
  this.name = name; 
  this.pkt2send = new();
  this.gen_mail = new;
  this.packet_number = 0;
  this.number_packets = number_packets;
endfunction


task Generator::gen();
//  $display($time,"ns : [GENERATOR] Generate the random number");
 // pkt2send.name = $sprintf("Packet[%0d]", packet_number ++);
//  $display($time, "ns: [GENERATOR]  %d of Packtes Generated", packet_number++);
  if(!pkt2send.randomize()) begin
    $display("[Generator] FAILURE to Generate random numbers!!!");
    $finish;
  end
 // pkt2send.complete = $urandom_range(0, 1);
endtask


task Generator::start();
   $display($time,"ns : [GENERATOR] Generator Started");
  
    fork
      for(int i=0; i<number_packets; i++) 
      begin
        gen();
        begin
          Packet pkt = new pkt2send;
          gen_mail.put(pkt);
         end
      end
     $display($time,"ns : [GENERATOR] Finish Generating numbers ", number_packets);
    join_none
endtask
