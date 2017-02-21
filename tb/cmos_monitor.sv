`ifndef CMOS_MONITOR__SV
`define CMOS_MONITOR__SV

`include "cmos_trans.sv"
class cmos_monitor extends uvm_monitor;

	protected virtual cmos_interface vif_cmos;
	`uvm_component_utils(cmos_monitor)
	uvm_analysis_port #(cmos_trans) item_collected_port;
	protected cmos_trans trans_collected;

  function new (string name, uvm_component parent);
    super.new(name, parent);
    trans_collected = new();
    item_collected_port = new("item_collected_port", this);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
	if(!uvm_config_db#(virtual cmos_interface)::get(this, "", "vif_cmos", vif_cmos))
		`uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction: build_phase

  // run phase
  virtual task run_phase(uvm_phase phase);
    `uvm_info({get_full_name()," MASTER ID"},$sformatf(" = %0d",master_id),UVM_MEDIUM)
	fork
      collect_trans(trans_collected);
      item_collected_port.write(trans_collected);
    join
  endtask : run_phase

  // collect_trans
	virtual protected task collect_trans(cmos_trans trans_collected);
    bit 		odd=0;
	bit[7:0]	temp_data;
	int 		idx=0;
	forever begin
		@(posedge vif_cmos.cmos_pclk);
			if(vif_cmos.cmos_vsyn == 1) begin
				trans_collected.data.set_zero(); 
				idx=0;
			end
			else begin
				if(vif_cmos.cmos_href == 1) begin
					if(odd=0) begin
						temp_data[7:0] <= vif_cmos.data[7:0];
						odd <= 1;
					end
					else begin
						odd <= 0;
						trans_collected.data[idx] <= {temp_data[7:0],vif_cmos.data[7:0]};
					end
				end

			end
		end
	endtask : collect_trans


endclass : cmos_monitor

`endif  //CMOS_MONITOR__SV