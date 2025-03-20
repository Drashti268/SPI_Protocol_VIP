class driver extends uvm_driver #(transaction);

  //Factory Registration
  `uvm_component_utils(driver)

  //Put port to send master transaction directly to scoreboard
   uvm_blocking_put_port #(transaction)master_send;
  
  //Registers the user-defined callback which is extended from uvm_callback
   `uvm_register_cb(driver,spi_callback)
 
  //New Constructor
  function new(string name="driver", uvm_component parent=null);
    super.new(name,parent);
    master_send = new("master_send",this);
  endfunction

  transaction trans_m;
  virtual intf vif;
  
  rand int delay;
  event ev;
  event a;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(!uvm_config_db#(virtual intf)::get(this,"","vif",vif))
        `uvm_fatal(get_type_name(),"couldn't get virtual interface") 
  endfunction

  virtual task run_phase(uvm_phase phase); 
    forever 
    begin
      seq_item_port.get_next_item(trans_m);

      delay = $urandom_range(1,4);        //random delay specified for ss to be low
     
      master_send.put(trans_m);           //send master data to scb

     `uvm_do_callbacks(driver, spi_callback, update_trans(trans_m));  //Calls update_trans(trans_m) of user-defined callback class

      vif.mode = trans_m.mode;            //Mode selection for SPI
     `uvm_info(get_type_name(),$sformatf("Mode=%b", vif.mode),UVM_NONE)

      fork
          //Thread 1 to select slave
          begin
            vif.mosi = 1'bz;
            vif.miso = 1'bz;
            vif.ss = trans_m.ss;
            #(delay);
            vif.ss = 0;
            ->ev;
            ->vif.chip_select;       //chip select event trigger to indicate master has pull down the slave_select to low
          end

          //Thread 2 to initialze sck and generation of sck
          begin
            initialize_clk();        //Initialize sck based on mode[1] 

            wait(ev.triggered);      //wait till ss becomes low then master will generate sck.
    
            for(int i=0; i<9; i++) 
            begin
             #5; vif.sck <= ~vif.sck;
             #5; vif.sck <= ~vif.sck;
            end
          end
 
          //Thread 3 for transmission of data
          begin
            wait(ev.triggered);     //wait till ss becomes low then master will start sending data.
            drive_data_m(trans_m);  //drive_data_m() for transmitting data
          end
      
      join
      
      seq_item_port.item_done();

      //Synchronization purpose with monitor
      ->vif.a;
    end
  endtask

extern task initialize_clk();
extern task drive_data_m(transaction trans_m);

endclass 

// ---------------------------------------------------------------------------
// ----------------------------Initialize sck()-------------------------------
// ---------------------------------------------------------------------------
task driver::initialize_clk();
  case(vif.mode[1])
    0: vif.sck = 0;
    1: vif.sck = 1;
  endcase
  `uvm_info(get_type_name(),$sformatf("CPOL=%b", vif.sck),UVM_NONE)
endtask


// ---------------------------------------------------------------------------
// ----------------------------drive_data_m()---------------------------------
// ---------------------------------------------------------------------------
task driver::drive_data_m(transaction trans_m);
  case(vif.mode)
    // Mode 0 -> CPOL = 0  CPHA = 0 i.e sck initial value is 0, data is sampled on rising edge, received on falling edge
    0: fork 
         //Thread1-> MOSI -> Master Out Slave In--> Master sends data to Slave
         begin
           @(vif.p_drv_cb);   
           vif.mosi <= trans_m.mosi[7];      //Send data to Interface
           ->vif.mode_0;

           for(int i=6; i>=0; i--)
           begin
             @(vif.p_drv_cb);  
             vif.mosi <= trans_m.mosi[i];      //Send data to Interface
           end
           `uvm_info(get_type_name(),$sformatf("Mode-0 MOSI=%b", trans_m.mosi),UVM_NONE)
          end

          //Thread2-> MISO Master In Slave Out--> Slave sends data to Master
          begin
            @(vif.mode_0_s);
            for(int i=7; i>=0; i--)
            begin
              @(vif.n_drv_cb);
              trans_m.miso[i] = vif.miso;
            end
            `uvm_info(get_type_name(),$sformatf("Mode-0 MISO=%b", trans_m.miso),UVM_NONE)
           end

         join
 
    //CPOL = 0  CPHA = 1 i.e sck initial value is 0, data is sampled on falling edge, received on rising edge
    1: fork           
         //MOSI Master Out Slave In--> Master sends data to Slave
         begin
           @(vif.n_drv_cb);
           vif.mosi <= trans_m.mosi[7];
           ->vif.mode_1;
              
           for(int i=6; i>=0; i--)
           begin
             @(vif.n_drv_cb);
             vif.mosi <= trans_m.mosi[i];
           end
           `uvm_info(get_type_name(),$sformatf("Mode-1 MOSI=%b", trans_m.mosi),UVM_NONE)
         end

         //MISO Master In Slave Out--> Slave sends data to Master
         begin 
           @(vif.mode_1_s);
           for(int i=7; i>=0; i--)
           begin
             @(vif.p_drv_cb);
             trans_m.miso[i] = vif.miso;
           end
           `uvm_info(get_type_name(),$sformatf("Mode-1 MISO=%b", trans_m.miso),UVM_NONE)
         end
       
       join

    //CPOL = 1  CPHA = 0 i.e sck initial value is 1, data is sampled on rising edge, received on falling edge
    2:  fork
          //MOSI Master Out Slave In--> Master sends data to Slave
          begin 
            @(vif.p_drv_cb);
            vif.mosi <= trans_m.mosi[7];
            ->vif.mode_2;
              
            for(int i=6; i>=0; i--)
            begin
              @(vif.p_drv_cb);
              vif.mosi <= trans_m.mosi[i];
            end
            `uvm_info(get_type_name(),$sformatf("Mode-2 MOSI=%b", trans_m.mosi),UVM_NONE)
          end
          
          //MISO Master In Slave Out--> Slave sends data to Master
          begin
            @(vif.mode_2_s);
            for(int i=7; i>=0; i--)
            begin
              @(vif.n_drv_cb);
              trans_m.miso[i] = vif.miso;
            end
            `uvm_info(get_type_name(),$sformatf("Mode-2 MISO=%b", trans_m.miso),UVM_NONE)
          end

        join

    //CPOL = 1  CPHA = 1 i.e sck initial value is 1, data is sampled on falling edge, received on rising edge
    3:  fork            
          //MOSI Master Out Slave In--> Master sends data to Slave
          begin
            @(vif.n_drv_cb);
            vif.mosi <= trans_m.mosi[7];
            ->vif.mode_3;
            
            for(int i=6; i>=0; i--)
            begin
              @(vif.n_drv_cb);
              vif.mosi <= trans_m.mosi[i];
            end
            `uvm_info(get_type_name(),$sformatf("Mode-3 MOSI=%b", trans_m.mosi),UVM_NONE)
           end
 
          //MISO Master In Slave Out--> Slave sends data to Master
          begin
            @(vif.mode_3_s);
            for(int i=7; i>=0; i--)
            begin
              @(vif.p_drv_cb);
              trans_m.miso[i] = vif.miso;
            end
            `uvm_info(get_type_name(),$sformatf("Mode-3 MISO=%b", trans_m.miso),UVM_NONE)
          end

        join
    
  endcase

  vif.ss = 1;
 // initialize_clk();
endtask
