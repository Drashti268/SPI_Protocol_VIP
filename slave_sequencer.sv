class s_sequencer extends uvm_sequencer #(transaction);

  //Factory Registration
  `uvm_component_utils(s_sequencer)

  //New Constructor
  function new(string name="s_sequencer", uvm_component parent=null);
    super.new(name, parent);
  endfunction
 
endclass
