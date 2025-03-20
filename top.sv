`include "test.sv"
`include "interface.sv"


module top;
  
  //Interface instance
  intf vif();                     

  initial begin
    uvm_config_db#(virtual intf)::set(null, "*", "vif", vif);
    run_test("random_test");
    //run_test("error_mosi_test");
   // run_test("error_miso_test");
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end

endmodule
