`ifndef CMOS_DRIVER__SV
`define CMOS_DRIVER__SV

`include "cmos_trans.sv"
class cmos_driver extends uvm_driver # (cmos_trans);
	protected virtual cmos_interface vif_cmos;

	 `uvm_component_utils(cmos_driver)

	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual cmos_interface)::get(this, "", "vif_cmos", vif_cmos))
			`uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
	endfunction: build_phase

	virtual task run_phase(uvm_phase phase);
		fork
			get_and_drive();
		join
	endtask : run_phase

	virtual protected task get_and_drive();
			vif_cmos.cmos_pclk <= 0;
			vif_cmos.cmos_href <= 0;
			vif_cmos.cmos_vsyn <= 0;
			vif_cmos.cmos_data <= 0;
			
			
			
			
		fork		
			while(1)begin
				#19.75ns;
				vif_cmos.cmos_pclk <= ~vif_cmos.cmos_pclk;
			end
			
			while(1)begin
			  @(posedge vif_cmos.cmos_pclk);
			  seq_item_port.get_next_item(req);
			  drive_one_img(req);
			  seq_item_port.item_done();
			end
		join_none
	endtask : get_and_drive
	

	virtual protected task drive_one_img(cmos_trans cmos_img);
		vif_cmos.cmos_href <= 0;
		vif_cmos.cmos_vsyn <= 1;
		repeat(cmos_img.vsyn_high_width) begin
			@(posedge vif_cmos.cmos_pclk);
		end
		vif_cmos.cmos_vsyn <= 0;
		repeat(cmos_img.bank_size) begin
			@(posedge vif_cmos.cmos_pclk);
		end
		for(int i = 0; i < cmos_img.row_size; i++) begin			
			for(int j = 0; j < cmos_img.column_size*2; j++) begin
				vif_cmos.cmos_href <= 1;
				if(j%2==0)
					vif_cmos.cmos_data <= cmos_img.data[i*cmos_img.row_size+j/2][15:8];
				else
					vif_cmos.cmos_data <= cmos_img.data[i*cmos_img.row_size+j/2][7:0];
				@(posedge vif_cmos.cmos_pclk);
			end
			vif_cmos.cmos_href <= 0;
			repeat(cmos_img.ref_gap)
				@(posedge vif_cmos.cmos_pclk);
		end 
		repeat(cmos_img.bank_size)
			@(posedge vif_cmos.cmos_pclk);
	endtask : drive_one_img
endclass : cmos_driver

`endif  //CMOS_DRIVER__SV