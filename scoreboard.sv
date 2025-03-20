class scoreboard extends uvm_scoreboard;
  
  //Factory Registration
  `uvm_component_utils(scoreboard)
  `uvm_blocking_put_imp_decl(_sl) 

  uvm_analysis_imp#(transaction,scoreboard) recv;
  uvm_blocking_put_imp #(transaction,scoreboard) master_recv;
  uvm_blocking_put_imp_sl #(transaction,scoreboard) slave_recv;

  transaction trans, trans_drv, trans_s_drv;
  virtual intf vif;

  bit [7:0] m_q[$];      //queue to store master trans
  bit [7:0] s_q[$];      //queue to store slave  trans
  bit [7:0] mon_q[$];    //queue to store monitor trans


  bit [7:0] act_mosi;
  bit [7:0] act_miso;

  bit [7:0] exp_mosi;
  bit [7:0] exp_miso;
  
  //New Constructor
  function new(string name="scoreboard", uvm_component parent=null);
    super.new(name,parent);
    recv     = new("recv", this);
    master_recv     = new("master_recv", this);
    slave_recv     = new("slave_recv", this);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    trans = transaction::type_id::create("trans");
    if(!uvm_config_db#(virtual intf)::get(this,"","vif",vif))
        `uvm_fatal(get_type_name(),"couldn't get virtual interface") 

  endfunction
  
  virtual function void write(transaction trans);
   // mon_q.push_back(trans.ss);

    
    mon_q.push_back(trans.mosi);
    mon_q.push_back(trans.miso);
  endfunction

  task put(transaction trans);
    m_q.push_back(trans.mosi);
   // m_q.push_back(trans.miso);
  endtask

  task put_sl(transaction trans);
 //   s_q.push_back(trans.mosi);
    s_q.push_back(trans.miso);
  endtask


   task run_phase(uvm_phase phase);

   forever begin
             @(vif.a);
              
            act_mosi = mon_q.pop_front();
            act_miso = mon_q.pop_front();

            exp_mosi = m_q.pop_front();
            exp_miso = s_q.pop_front();

            if(act_mosi == exp_mosi)
            begin
              `uvm_info(get_type_name(),$sformatf("PASS EXP MOSI=%b ACT MOSI=%b", exp_mosi, act_mosi),UVM_NONE)
            end
            else
            begin
              `uvm_error(get_type_name(),$sformatf("FAIL EXP MOSI=%b ACT MOSI=%b", exp_mosi, act_mosi))
            end

            if(act_miso == exp_miso)
            begin
              `uvm_info(get_type_name(),$sformatf("PASS EXP MISO=%b ACT MISO=%b", exp_miso, act_miso),UVM_NONE) 
            end
            else
            begin
              `uvm_error(get_type_name(),$sformatf("FAIL EXP MISO=%b ACT MISO=%b", exp_miso, act_miso)) 
            end
       
    end
  endtask

  endclass
     
