class transaction extends uvm_sequence_item;

  bit sck;
  bit ss=1;
  
  rand bit [1:0] mode; //= {cpol,cpha};   
  rand bit [7:0] mosi;
  rand bit [7:0] miso;
  
  function new(string name="transaction");
    super.new(name);
  endfunction

  `uvm_object_utils_begin(transaction)
    `uvm_field_int(sck, UVM_ALL_ON + UVM_BIN)
    `uvm_field_int(ss, UVM_ALL_ON + UVM_BIN)
    `uvm_field_int(mode, UVM_ALL_ON + UVM_HEX)
    `uvm_field_int(mosi, UVM_ALL_ON + UVM_HEX)
    `uvm_field_int(miso, UVM_ALL_ON + UVM_HEX)
  `uvm_object_utils_end

endclass

