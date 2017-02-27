`ifndef VGA_AGENT__SV
`define VGA_AGENT__SV

`include "vga_driver.sv"
`include "vga_monitor.sv"
`include "vga_sequencer.sv"

class vga_agent extends uvm_agent;
	
	
	`uvm_component_utils(vga_agent)
	protected int master_id;

	vga_driver 		driver;
	vga_monitor 	monitor;
	vga_sequencer	sequencer;

	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		monitor = vga_monitor::type_id::create("monitor", this);

		if(get_is_active() == UVM_ACTIVE) begin
			sequencer = vga_sequencer::type_id::create("sequencer", this);
			driver = vga_driver::type_id::create("driver", this);
		end
	endfunction : build_phase

  function void connect_phase(uvm_phase phase);
    if(get_is_active() == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
  endfunction : connect_phase

endclass : vga_agent

`endif  //VGA_AGENT__SV