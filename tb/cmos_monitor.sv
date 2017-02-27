`ifndef CMOS_MONITOR__SV
`define CMOS_MONITOR__SV

`include "cmos_trans.sv"
class cmos_monitor extends uvm_monitor;
    bit 		odd=0;
	bit[7:0]	temp_data;
	int 		idx=0;
	int 		state;
	int 		cnt_column=0;
	int 		cnt_row=0;
	int 		frame_cnt=0;
	bit [15:0]	data_tmp[$];
	int			size;
	typedef enum   {INIT=0, VSYN_H, VSYN_L_RL, VSYN_L_RH} cmos_state;
	cmos_state c_state = INIT;
	protected virtual cmos_interface vif_cmos;
	`uvm_component_utils(cmos_monitor)
	uvm_analysis_port #(cmos_trans) item_collected_port;
	cmos_trans trans_collected;

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
	fork
      collect_trans(trans_collected);
    join
  endtask : run_phase

  // collect_trans
	virtual protected task collect_trans(cmos_trans trans_collected);
	`uvm_info("monitor", "COLECT TRANS", UVM_LOW);
	forever begin
		case (c_state) 
			INIT: begin
				if(vif_cmos.cmos_vsyn == 1) begin
					c_state <= VSYN_H;
				end
			end
			VSYN_H: begin
				if(trans_collected.data.size() != 0) begin
					trans_collected.print();
					item_collected_port.write(trans_collected);
					trans_collected.set_zero();
					`uvm_info("monitor", "END ONE FRAME", UVM_LOW);
				end
				if(vif_cmos.cmos_vsyn == 1) begin
					c_state <= VSYN_H;
				end
				else begin
					c_state <= VSYN_L_RL;
					frame_cnt <= frame_cnt + 1;
				end
			end
			VSYN_L_RL: begin
				if(vif_cmos.cmos_vsyn == 0 && vif_cmos.cmos_href == 0) begin
					c_state <= VSYN_L_RL;
					cnt_column <= 0;
				end
				else if(vif_cmos.cmos_vsyn == 0 && vif_cmos.cmos_href == 1) begin
					c_state <= VSYN_L_RH;
					cnt_column <= cnt_column + 1;
					if(odd==0) begin
						temp_data[7:0] <= vif_cmos.cmos_data[7:0];
						odd <= 1;
					end
					else begin
						odd <= 0;
						data_tmp.push_back({temp_data[7:0],vif_cmos.cmos_data[7:0]}) ;
						idx <= idx + 1;
					end
				end
				else if(vif_cmos.cmos_vsyn == 1)begin
					c_state <= VSYN_H;
					cnt_row <= 0;
					idx <= 0;
					trans_collected.row_size <= cnt_row;
					begin
						trans_collected.size = data_tmp.size();
						trans_collected.data = new[trans_collected.size];
						for(int i=0;i<trans_collected.size;i++) begin
							trans_collected.data[i] = data_tmp.pop_front();
						end
					end
					`uvm_info("monitor",$sformatf("END OF L L , size = %d",size), UVM_LOW); 
				end
			end
			VSYN_L_RH: begin
				if(vif_cmos.cmos_vsyn == 0 && vif_cmos.cmos_href == 1) begin
					c_state <= VSYN_L_RH;
					cnt_column <= cnt_column + 1;
					if(odd==0) begin
						temp_data[7:0] <= vif_cmos.cmos_data[7:0];
						odd <= 1;
					end
					else begin
						odd <= 0;
						data_tmp.push_back({temp_data[7:0],vif_cmos.cmos_data[7:0]}) ;
						idx <= idx + 1;
					end
				end
				else if(vif_cmos.cmos_vsyn == 0 && vif_cmos.cmos_href == 0) begin
					c_state <= VSYN_L_RL;
					cnt_column <= 0;
					cnt_row <= cnt_row + 1;
					trans_collected.column_ar.push_back(cnt_column);
					trans_collected.column_size <= cnt_column;
					`uvm_info("monitor",$sformatf("END, REF, size = %d",data_tmp.size()), UVM_LOW);
				end
			end
		endcase
		@(posedge vif_cmos.cmos_pclk);
	end
	endtask : collect_trans


endclass : cmos_monitor

`endif  //CMOS_MONITOR__SV