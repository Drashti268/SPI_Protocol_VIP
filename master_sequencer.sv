class sequencer extends uvm_sequencer #(transaction);

  //Factory Registration
  `uvm_component_utils(sequencer)

  //New Constructor
  function new(string name="sequencer", uvm_component parent=null);
    super.new(name, parent);
  endfunction
 
endclass
