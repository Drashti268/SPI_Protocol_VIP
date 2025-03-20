class spi_callback extends uvm_callback;

  //Factory Registration
  `uvm_object_utils(spi_callback)

  //New Constructor
  function new(string name="aci_callback");
    super.new(name);
  endfunction
  

  virtual task update_trans(transaction trans);
  endtask


endclass

class user_callback extends spi_callback;

  //Factory Registration
  `uvm_object_utils(user_callback)

  //New Constructor
  function new(string name="user_callback");
    super.new(name);
  endfunction

  task update_trans(transaction trans);
    trans.mosi = 8'ha0;
    trans.miso = 8'h10;

    `uvm_info(get_type_name(),$sformatf("Packet from Callback %s", trans.sprint()),UVM_NONE)
  endtask

endclass
