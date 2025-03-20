interface intf;

bit  ss=1;  //slave_select
bit  sck;   //Serial clock

bit [1:0]mode;

//always #5 sck = ~sck;

logic miso; //master in slave out
logic mosi; //master out slave in

event a;
event chip_select;

event mode_0;
event mode_0_s;
event mode_1;
event mode_1_s;
event mode_2;
event mode_2_s;
event mode_3;
event mode_3_s;

clocking  p_drv_cb@(posedge sck);
  default input #1 output #2;
  output mosi;
  output miso;
endclocking

clocking  n_drv_cb@(negedge sck);
  default input #1 output #2;
  output miso;
  output mosi;
endclocking

clocking n_mon_cb@(negedge sck);
  default input #1 output #2;
  input mosi;
  input miso;
endclocking

clocking p_mon_cb@(posedge sck);
  default input #1 output #2;
  input mosi;
  input miso;
endclocking

//Sequence s1 for checking mosi stable
sequence s1;
 ($stable(mosi) && (sck==1));
endsequence

sequence s2;
 ($stable(mosi) && (sck==0));
endsequence

//Check 1 for Unknown bits
property p1 ;
  @(posedge sck)   $fell(ss)  |=>  !($isunknown(mosi)) ##[1:$] $rose(ss);
endproperty

//Check 2 Data is stable between edges of sck                  //Not sure about this assetion.................
property p2;
  disable iff(!(mode == 2'b00 || mode == 2'b10)) @(edge sck) $fell(ss) |-> ##[1:$] s1 ##[1:$] $rose(ss); //@(negedge sck) $stable(mosi) ##[1:$] $rose(ss);
endproperty

//Check 3 Data is stable between edges of sck                 //Not sure about this assetion..................
property p3;
  disable iff(!(mode == 2'b01 || mode == 2'b11)) @(edge sck) $fell(ss) |-> ##[1:$] s2 ##[1:$] $rose(ss); //@(negedge sck) $stable(mosi) ##[1:$] $rose(ss);
endproperty

/*//Check 4 Data is stable between edges of sck
property p4;
  disable iff(mode != 2'b10) @(edge sck) $fell(ss) |-> ##[1:$] s1 ##[1:$] $rose(ss); //@(negedge sck) $stable(mosi) ##[1:$] $rose(ss);
endproperty

//Check 5 Data is stable between edges of sck
property p5;
  disable iff(mode != 2'b11) @(edge sck) $fell(ss) |-> ##[1:$] s2 ##[1:$] $rose(ss); //@(negedge sck) $stable(mosi) ##[1:$] $rose(ss);
endproperty*/


  BIT_UNKNOWN_CHECK: assert property(p1); //$info("pass");
                 
  DATA_STABLE_CHECK0_2: assert property(p2); //$info("pass");
                  
  DATA_STABLE_CHECK1_3: assert property(p3); //$info("pass");
                  
        //DATA_STABLE_CHECK2: assert property(p4) $info("pass");
                  
//DATA_STABLE_CHECK3: assert property(p5) $info("pass");
                 

//Check 6 Mode-0 initial value for sck is 0
    SCK_0_CHECK_M0: assert property(@(edge sck) disable iff(mode !=2'b00) $fell(ss) |-> (sck==0)); //$info("pass");
             
//Check 7 Mode-1 initial value of sck is 0
      SCK_0_CHECK_M1: assert property(@(edge sck) disable iff(mode !=2'b01) $fell(ss) |-> (sck==0));// $info("pass");

//Check 8 Mode-2 initial value of sck is 1
        SCK_1_CHECK_M2: assert property(@(edge sck) disable iff(mode !=2'b10) $fell(ss) |-> (sck==1)); // $info("pass");

//Check 9 Mode-3 initial value of sck is 1
          SCK_1_CHECK_M3: assert property(@(edge sck) disable iff(mode !=2'b11) $fell(ss) |-> (sck==1)); // $info("pass");

/*//Check 7 if sck = 0 and data is sampled at posedge sck then Mode is 0
M1_CHECK: assert property(@(posedge sck) $fell(ss) ##0 sck==0 |-> mode == 2'b00) $info("pass");
          else 
            $info("fail");
//Check 8
M2_CHECK: assert property(@(negedge sck) $fell(ss) ##0 sck==0 |-> mode == 2'b01) $info("pass");
          else 
            $info("fail");*/

endinterface
