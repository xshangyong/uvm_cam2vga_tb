`ifndef VGA_SEQUENCER__SV
`define VGA_SEQUENCER__SV

class vga_sequencer extends uvm_sequencer #(vga_trans);

	`uvm_component_utils(vga_sequencer)
     
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

endclass : vga_sequencer

`endif  //VGA_SEQUENCER__SV