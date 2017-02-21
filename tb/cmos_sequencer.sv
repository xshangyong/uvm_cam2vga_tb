`ifndef CMOS_SEQUENCER__SV
`define CMOS_SEQUENCER__SV

class cmos_sequencer extends uvm_sequencer #(cmos_trans);

	`uvm_component_utils(cmos_sequencer)
     
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

endclass : cmos_sequencer

`endif  //CMOS_SEQUENCER__SV