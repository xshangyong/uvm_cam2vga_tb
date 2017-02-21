`ifndef TEST_LIB__SV
`define TEST_LIB__SV

`include "cmos2vga_tb.sv"
`include "cmos_seq_lib.sv"

// Base Test
class coms2vga_base_test extends uvm_test;

	`uvm_component_utils(coms2vga_base_test)

	cmos2vga_tb cmos2vga_tb0;

	bit test_pass = 1;

	function new(string name = "coms2vga_base_test", 
		uvm_component parent=null);
		super.new(name,parent);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		cmos2vga_tb0 = cmos2vga_tb::type_id::create("coms2vga_tb0", this);
	endfunction : build_phase

  task run_phase(uvm_phase phase);
    phase.phase_done.set_drain_time(this, 50000000);
  endtask : run_phase

//	function void extract_phase(uvm_phase phase);
//	if(ubus_example_tb0.scoreboard0.sbd_error)
//		test_pass = 1'b0;
//	endfunction // void
  
//  function void report_phase(uvm_phase phase);
//    if(test_pass) begin
//      `uvm_info(get_type_name(), "** UVM TEST PASSED **", UVM_NONE)
//    end
//    else begin
//      `uvm_error(get_type_name(), "** UVM TEST FAIL **")
//    end
//  endfunction

endclass : coms2vga_base_test


class test_ten_frame extends coms2vga_base_test;

  `uvm_component_utils(test_ten_frame)

  function new(string name = "test_ten_frame", uvm_component parent=null);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
	send_one_seq	seq0;
    super.build_phase(phase);
	seq0 = new("seq0");
    uvm_config_db#(uvm_sequence_base)::set(this,
		    "coms2vga_tb0.cmos_env0.cmos_agent0.sequencer.run_phase", 
			       "default_sequence", seq0);				
  end
  endfunction : build_phase

endclass : test_ten_frame


`endif  //TEST_LIB__SV