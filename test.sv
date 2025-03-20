// ---------------------------------------------------------------------------
// ----------------------------Base Test--------------------------------------
// ---------------------------------------------------------------------------
class base_test extends uvm_test;  

  //Factory Registration
  `uvm_component_utils(base_test)
 
  //New Construction
  function new(string name = "base_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
  env envi; 
  seq sq;
  s_seq ssq;
  int count;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    envi = env::type_id::create("envi",this);
    sq   = seq::type_id::create("sq");
    ssq   = s_seq::type_id::create("ssq");
  endfunction
   
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction
 
endclass   

// ---------------------------------------------------------------------------
// ----------------------------Random_test-------------------------------------
// ---------------------------------------------------------------------------
class random_test extends base_test;

  //Factory Registration
  `uvm_component_utils(random_test)
 
  //New Construction
  function new(string name = "random_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
      //Start Sequence
     repeat(10)
     begin
       #10;
       fork
        sq.start(envi.agt.seqr);   
        ssq.start(envi.agt.s_seqr);   
       join
     end
    
      #10;
    phase.drop_objection(this);
  endtask

endclass    

class error_mosi_test extends base_test;

  //Factory Registration
  `uvm_component_utils(error_mosi_test)
   
   user_callback cb;

  //New Construction
  function new(string name = "error_mosi_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    cb = user_callback::type_id::create("cb",this);
  endfunction

   virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);

      uvm_callbacks#(driver,spi_callback)::add(envi.agt.driv,cb); 

      //Start Sequence
      count = 2;
    
      repeat(count)
      begin
         #10;
       fork
        sq.start(envi.agt.seqr);   
        ssq.start(envi.agt.s_seqr);   
       join

      end
    
      #10;
    phase.drop_objection(this);
  endtask
endclass

class error_miso_test extends base_test;

  //Factory Registration
  `uvm_component_utils(error_miso_test)
   
   user_callback cb;

  //New Construction
  function new(string name = "error_miso_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    cb = user_callback::type_id::create("cb",this);
  endfunction

   virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);

      uvm_callbacks#(s_driver,spi_callback)::add(envi.agt.s_driv,cb); 

      //Start Sequence
      count = 2;
    
      repeat(count)
      begin
         #10;
       fork
        sq.start(envi.agt.seqr);   
        ssq.start(envi.agt.s_seqr);   
       join

      end
    
      #10;
    phase.drop_objection(this);
  endtask
endclass
