`ifndef CMOS_AGENT__SV
`define CMOS_AGENT__SV

`include "cmos_driver.sv"
`include "cmos_monitor.sv"
`include "cmos_sequencer.sv"

class cmos_agent extends uvm_agent;
	
	
	`uvm_component_utils(cmos_agent)
	protected int master_id;

	cmos_driver 	driver;
	cmos_monitor 	monitor;
	cmos_sequencer	sequencer;

	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		monitor = cmos_monitor::type_id::create("monitor", this);

		if(get_is_active() == UVM_ACTIVE) begin
			sequencer = cmos_sequencer::type_id::create("sequencer", this);
			driver = cmos_driver::type_id::create("driver", this);
		end
	endfunction : build_phase

  function void connect_phase(uvm_phase phase);
    if(get_is_active() == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
  endfunction : connect_phase

endclass : cmos_agent

`endif  //CMOS_AGENT__SV