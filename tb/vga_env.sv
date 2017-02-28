`ifndef VGA_ENV__SV
`define VGA_ENV__SV


`include "vga_agent.sv"

class vga_env extends uvm_env;

	protected virtual interface vga_interface vif_vga;
	// Control properties
	protected int imgs_per_sec = 30;
	protected int img_row_size = 600;
	protected int img_collumn_size = 800;
	
	// Components of the environment
	vga_agent 		vga_agent0;

	`uvm_component_utils_begin(vga_env)
		`uvm_field_int(imgs_per_sec, UVM_DEFAULT)
		`uvm_field_int(img_row_size, UVM_DEFAULT)
		`uvm_field_int(img_collumn_size, UVM_DEFAULT)
	`uvm_component_utils_end

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual vga_interface)::get(this, "", "vif_vga", vif_vga))
			`uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
		vga_agent0 = vga_agent::type_id::create("vga_agent0", this);
		vga_agent0.is_active = UVM_PASSIVE;
		uvm_config_db#(int)::set(this, "vga_agent0.*", "v_syn", 4);
		uvm_config_db#(int)::set(this, "vga_agent0.*", "v_bkporch", 23);
		uvm_config_db#(int)::set(this, "vga_agent0.*", "v_data", 16);
		uvm_config_db#(int)::set(this, "vga_agent0.*", "v_ftporch", 1);
		uvm_config_db#(int)::set(this, "vga_agent0.*", "v_total", 44);
		uvm_config_db#(int)::set(this, "vga_agent0.*", "h_syn", 128);
		uvm_config_db#(int)::set(this, "vga_agent0.*", "h_bkporch", 88);
		uvm_config_db#(int)::set(this, "vga_agent0.*", "h_data", 800);
		uvm_config_db#(int)::set(this, "vga_agent0.*", "h_ftporch", 40);
		uvm_config_db#(int)::set(this, "vga_agent0.*", "h_total", 1056);
//		parameter H_SYN 		= 128;
//		parameter H_BKPORCH 	= 88;	
//		parameter H_DATA 		= 800;
//		parameter H_FTPORCH		= 40;
//		parameter H_TOTAL    	= 1056;
//		
//		
//		parameter V_SYN 		= 4;
//		parameter V_BKPORCH 	= 23;
//		parameter V_DATA 		= 16;
//		parameter V_FTPORCH		= 1;
//		parameter V_TOTAL    	= 44;	
	endfunction : build_phase
endclass : vga_env

`endif  //VGA_ENV__SV