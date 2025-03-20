class agent extends uvm_agent;

  //Factory Registration
  `uvm_component_utils(agent)

  //New Constructor
  function new(string name="agent", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  driver driv;
  s_driver s_driv;
  sequencer seqr; 
  s_sequencer s_seqr; 
  monitor mon;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon = monitor::type_id::create("mon",this);
    driv = driver::type_id::create("driv",this);
    s_driv = s_driver::type_id::create("s_driv",this);
    seqr = sequencer::type_id::create("seqr", this);
    s_seqr = s_sequencer::type_id::create("s_seqr", this);
  endfunction
 
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase); 
    //Connecting driver to sequencer using tlm ports
    driv.seq_item_port.connect(seqr.seq_item_export);
    s_driv.seq_item_port.connect(s_seqr.seq_item_export);
  endfunction

endclass
