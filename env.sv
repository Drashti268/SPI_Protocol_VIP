class env extends uvm_env;

  //Factory Registration
  `uvm_component_utils(env)
 
  //New Constructor
  function new(string name = "env", uvm_component parent=null);
    super.new(name,parent);
  endfunction
 
  agent   agt;
  scoreboard scb;


  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agt = agent::type_id::create("agt", this);
    scb = scoreboard::type_id::create("scb", this);
  endfunction
 
  virtual function void connect_phase( uvm_phase phase );
    super.connect_phase(phase);
    //Connecting the monitor to scoreboard using tlm ports
    agt.driv.master_send.connect(scb.master_recv);   
    agt.s_driv.slave_send.connect(scb.slave_recv);   
    agt.mon.send.connect(scb.recv);   
    
    `uvm_info("ENV",$sformatf("connected mon to scb"),UVM_NONE)
  endfunction
  
  
endclass           
