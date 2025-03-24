class monitor extends uvm_monitor #(transaction);

  //Factory Registration
  `uvm_component_utils(monitor)

  uvm_analysis_port #(transaction) send;
  
  transaction trans;
  virtual intf vif;
  event mon_dt;
  //New Constructor
  function new(string name="monitor", uvm_component parent=null);
    super.new(name,parent);
    send = new("send",this);
  endfunction


  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
   
    trans = transaction::type_id::create("trans");

    if(!uvm_config_db#(virtual intf)::get(this,"","vif",vif))
        `uvm_fatal(get_type_name(),"couldn't get virtual interface") 
  endfunction

  virtual task run_phase(uvm_phase phase); 
    forever 
    begin
       @(vif.chip_select);        //Wait for Master to pull chip_select line low
       chip_select();    
       data_transmission(trans);
       send.write(trans);
    
    end
  endtask


extern task chip_select();
extern task data_transmission(transaction trans);
endclass

task monitor::chip_select();
   `uvm_info(get_type_name(),$sformatf("Mon Slave select is low"),UVM_NONE)
   trans.mode = vif.mode;
   `uvm_info(get_type_name(),$sformatf("Mon Mode=%b", trans.mode),UVM_NONE)
   ->mon_dt;
endtask

task monitor::data_transmission(transaction trans);
   wait(mon_dt.triggered);

    case(trans.mode)

        0 : begin
               @(vif.mode_0);
              for(int i=7; i>=0; i--)
              begin
                @(vif.n_mon_cb);
                trans.mosi[i] = vif.mosi;
                trans.miso[i] = vif.miso;
              end
            `uvm_info(get_type_name(),$sformatf("MON MOSI=%b MISO=%b", trans.mosi, trans.miso),UVM_NONE)
            end

        1 : begin
               @(vif.mode_1)
              for(int i=7; i>=0; i--)
              begin
                @(vif.p_mon_cb);
                trans.mosi[i] = vif.mosi;
                trans.miso[i] = vif.miso;
              end
            `uvm_info(get_type_name(),$sformatf("MON MOSI=%b MISO=%b", trans.mosi, trans.miso),UVM_NONE)
            end

        2 : begin
               @(vif.mode_2)
              for(int i=7; i>=0; i--)
              begin
                @(vif.n_mon_cb);
                trans.mosi[i] = vif.mosi;
                trans.miso[i] = vif.miso;
              end
            `uvm_info(get_type_name(),$sformatf("MON MOSI=%b MISO=%b", trans.mosi, trans.miso),UVM_NONE)
            end

        3 : begin     
               @(vif.mode_3)
              for(int i=7; i>=0; i--)
              begin
                @(vif.p_mon_cb);
                trans.mosi[i] = vif.mosi;
                trans.miso[i] = vif.miso;
              end
            `uvm_info(get_type_name(),$sformatf("MON MOSI=%b MISO=%b", trans.mosi, trans.miso),UVM_NONE)
            end

      endcase   
endtask
