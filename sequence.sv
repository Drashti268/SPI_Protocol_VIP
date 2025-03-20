// ---------------------------------------------------------------------------
// ----------------------------Master Sequence--------------------------------
// ---------------------------------------------------------------------------
class seq extends uvm_sequence #(transaction); 
  `uvm_object_utils(seq)
   function new(string name="seq");
     super.new(name);
   endfunction
 
   transaction trans;

    task body();
      trans = transaction::type_id::create("trans");
      begin
         start_item(trans);
         trans.randomize();
         `uvm_info(get_type_name(),$sformatf("Packet from sequence %s", trans.sprint()),UVM_NONE)
         finish_item(trans);
      end
    endtask
endclass

// ---------------------------------------------------------------------------
// ----------------------------Slave Sequence---------------------------------
// ---------------------------------------------------------------------------

class s_seq extends uvm_sequence #(transaction);
  `uvm_object_utils(s_seq)
   function new(string name="s_seq");
     super.new(name);
   endfunction
 
   transaction trans;

   task body();
     trans = transaction::type_id::create("trans");
     begin
       start_item(trans);
       trans.randomize(miso);
       `uvm_info(get_type_name(),$sformatf("Packet from sequence %s", trans.sprint()),UVM_NONE)
       finish_item(trans);
     end
   endtask
endclass

