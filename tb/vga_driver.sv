`ifndef VGA_DRIVER__SV
`define VGA_DRIVER__SV

`include "vga_trans.sv"
class vga_driver extends uvm_driver # (vga_trans);
	protected virtual vga_interface vif_vga;

	 `uvm_component_utils(vga_driver)

	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual vga_interface)::get(this, "", "vif_vga", vif_vga))
			`uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
	endfunction: build_phase

endclass : vga_driver

`endif  //VGA_DRIVER__SV