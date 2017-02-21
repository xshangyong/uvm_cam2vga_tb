`ifndef CMOS_ENV__SV
`define CMOS_ENV__SV


`include "cmos_agent.sv"

class cmos_env extends uvm_env;

	protected virtual interface cmos_interface vif_cmos;

	// Control properties
	protected int imgs_per_sec = 30;
	protected int img_row_size = 600;
	protected int img_collumn_size = 800;
	
	// Components of the environment
	cmos_agent 		cmos_agent0;

	`uvm_component_utils_begin(cmos_env)
		`uvm_field_int(imgs_per_sec, UVM_DEFAULT)
		`uvm_field_int(img_row_size, UVM_DEFAULT)
		`uvm_field_int(img_collumn_size, UVM_DEFAULT)
	`uvm_component_utils_end

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual cmos_interface)::get(this, "", "vif_cmos", vif_cmos))
			`uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
		cmos_agent0 = cmos_agent::type_id::create("cmos_agent0", this);
	endfunction : build_phase
endclass : cmos_env

`endif  //CMOS_ENV__SV