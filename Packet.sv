class Packet;
  rand reg [3:0] opcode;
  rand reg [1:0] opselect;
  
  rand reg [2:0] dr;
  rand reg [2:0] sr;
  rand reg [2:0] sr1;
  rand reg [2:0] sr2;
  rand reg [4:0] imm5;
  rand reg [10:0] pc_offset11;
  rand reg [8:0] pc_offset9;
  rand reg [5:0] pc_offset6;
  rand reg mode;
  
  
  rand reg [2:0] BaseR;
  
  reg complete;
  reg write_inst;
  reg reset;
  string name;
  
  constraint limit{
    sr1 inside {[0:7]};  
    sr2 inside {[0:7]};
    dr  inside {[0:7]};
    sr  inside {[0:7]};
    imm5 inside {[0:31]};
    BaseR inside {[0:7]};
    pc_offset11 inside {[0:2047]};
    pc_offset9 inside {[0:511]};
    pc_offset6 inside {[0:63]};
    
 //   opselect inside {[0:1], [4:5]};
    opselect inside {1, 4, 5};
//    opcode inside {1, 5, 9, 0, 12, 4, 2, 6, 10, 14, 3, 7, 11};
//    opcode inside {[0:7], [9:12]};
    if(opselect == `ARITH_LOGIC)
    {
      opcode inside {1, 5, 9};  
      mode inside {0, 1};
    }
    /*
    else if(opselect == `GOTO_LOGIC)
    {
      opcode inside {0, 12, 4};  
    }
    */
    else if(opselect == `MEM_READ) {
      opcode inside {2, 6, 10, 14};
    }
    else if (opselect == `MEM_WRITE) {
      opcode inside {3, 7, 11};
    }
  }
  
  extern function new(string name = "Packet");
  
endclass

function Packet::new(string name = "Packet");
   this.name = name;
endfunction