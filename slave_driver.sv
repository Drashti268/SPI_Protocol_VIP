class s_driver extends uvm_driver #(transaction);

  //Factory Registration
  `uvm_component_utils(s_driver)

  //Put port to send slave transaction directly to scoreboard
   uvm_blocking_put_port #(transaction)slave_send;
  
  //Registers the user-defined callback which is extended from uvm_callback
  `uvm_register_cb(driver,spi_callback)

  //New Constructor
  function new(string name="s_driver", uvm_component parent=null);
    super.new(name,parent);
    slave_send = new("slave_send",this);
  endfunction

  transaction trans_s;
  virtual intf vif;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
   
    trans_s = transaction::type_id::create("trans_s");

    if(!uvm_config_db#(virtual intf)::get(this,"","vif",vif))
        `uvm_fatal(get_type_name(),"couldn't get virtual interface") 
  endfunction

  virtual task run_phase(uvm_phase phase); 
    forever 
    begin
      seq_item_port.get_next_item(trans_s);
      
      @(vif.chip_select);       //Wait till master pulls down ss pin low
      `uvm_info(get_type_name(),$sformatf(" Slave select is low"),UVM_NONE)

      slave_send.put(trans_s);  //send slave data to scb
      
      `uvm_do_callbacks(s_driver, spi_callback, update_trans(trans_s));  //Calls update_trans(trans_s) of user-defined callback class

      drive_data_s(trans_s);    //drive_data_s() for transmitting data

      seq_item_port.item_done();
     
    end
  endtask
   
extern task drive_data_s(transaction trans_s);

endclass

// ---------------------------------------------------------------------------
// ----------------------------drive_data_s()---------------------------------
// ---------------------------------------------------------------------------
task s_driver::drive_data_s(transaction trans_s);
  
  case(vif.mode)  
    //CPOL = 0  CPHA = 0 i.e sck initial value is 0, data is sampled on rising edge, received on falling edge
     0: fork
          //MOSI Master Out Slave In--> Master sends data to Slave
          begin
            @(vif.mode_0);
            for(int i=7; i>=0; i--)
            begin
              @(vif.n_drv_cb);
              trans_s.mosi[i] = vif.mosi;
            end
            `uvm_info(get_type_name(),$sformatf("Mode-0 MOSI=%b", trans_s.mosi),UVM_NONE)
          end

          //MISO Master In Slave Out--> Slave sends data to Master
          begin 
            @(vif.p_drv_cb);
            vif.miso <= trans_s.miso[7];
            ->vif.mode_0_s;

            for(int i=6; i>=0; i--)
            begin
              @(vif.p_drv_cb);
              vif.miso <= trans_s.miso[i];
            end
            `uvm_info(get_type_name(),$sformatf("Mode-0 MISO=%b", trans_s.miso),UVM_NONE)
          end

        join

     //CPOL = 0  CPHA = 1 i.e sck initial value is 0, data is sampled on falling edge, received on rising edge
     1: fork
          //MOSI Master Out Slave In--> Master sends data to Slave
          begin
            @(vif.mode_1);
            for(int i=7; i>=0; i--)
            begin
              @(vif.p_drv_cb);
              trans_s.mosi[i] = vif.mosi;
            end
            `uvm_info(get_type_name(),$sformatf("Mode-1 MOSI=%b", trans_s.mosi),UVM_NONE)
          end

           //MISO Master In Slave Out--> Slave sends data to Master
            begin   
              @(vif.n_drv_cb);
              vif.miso <= trans_s.miso[7];
              ->vif.mode_1_s;
              
              for(int i=6; i>=0; i--)
              begin
                @(vif.n_drv_cb);
                vif.miso <= trans_s.miso[i];
              end
              `uvm_info(get_type_name(),$sformatf("Mode-1 MISO=%b", trans_s.miso),UVM_NONE)
            end 

          join

     //CPOL = 1  CPHA = 0 i.e sck initial value is 1, data is sampled on rising edge, received on falling edge
     2: fork
          //MOSI Master Out Slave In--> Master sends data to Slave
          begin
            @(vif.mode_2);
            for(int i=7; i>=0; i--)
            begin
              @(vif.n_drv_cb);
              trans_s.mosi[i] = vif.mosi;
             end
            `uvm_info(get_type_name(),$sformatf("Mode-2 MOSI=%b", trans_s.mosi),UVM_NONE)
          end

          //MISO Master In Slave Out--> Slave sends data to Master
          begin  
            @(vif.p_drv_cb);
            vif.miso <= trans_s.miso[7];
            ->vif.mode_2_s;
              
            for(int i=6; i>=0; i--)
            begin
              @(vif.p_drv_cb);
              vif.miso <= trans_s.miso[i];
            end
            `uvm_info(get_type_name(),$sformatf("Mode-2 MISO=%b", trans_s.miso),UVM_NONE)
          end

        join

     //CPOL = 1  CPHA = 1 i.e sck initial value is 1, data is sampled on falling edge, received on rising edge
     3: fork  
          //MOSI Master Out Slave In--> Master sends data to Slave
          begin
            @(vif.mode_3);
            for(int i=7; i>=0; i--)
            begin
              @(vif.p_drv_cb);
              trans_s.mosi[i] = vif.mosi;
            end
            `uvm_info(get_type_name(),$sformatf("Mode-3 MOSI=%b", trans_s.mosi),UVM_NONE)
          end
      
           //MISO Master In Slave Out--> Slave sends data to Master
           begin
             @(vif.n_drv_cb);
             vif.miso <= trans_s.miso[7];
             ->vif.mode_3_s;

              for(int i=6; i>=0; i--)
              begin
                @(vif.n_drv_cb);
                vif.miso <= trans_s.miso[i];
              end
              `uvm_info(get_type_name(),$sformatf("Mode-3 MISO=%b", trans_s.miso),UVM_NONE)
           end

         join
    
    endcase
 
endtask
