`ifndef VGA_MONITOR__SV
`define VGA_MONITOR__SV

`include "vga_trans.sv"
class vga_monitor extends uvm_monitor;
    bit 		odd=0;
	bit[7:0]	temp_data;
	int 		idx=0;
	int 		state;
	int 		cnt_column=0;
	int 		cnt_row=0;
	int 		frame_cnt=0;
	bit [15:0]	data_tmp[$];
	int			size;
	
	int 	h_syn 			;
	int 	h_bkporch 	;
	int 	h_data 			;
	int 	h_ftporch	;
	int 	h_total    		;

	int 	v_syn 		;
	int 	v_bkporch 	;
	int 	v_data 		;
	int 	v_ftporch	;
	int 	v_total    	;	

	
	
	
	
	
	typedef enum   {INIT=0, VSYN_L, VSYN_H_RL, VSYN_H_RH} vga_state;
	vga_state c_state = INIT;
	protected virtual vga_interface vif_vga;
	`uvm_component_utils(vga_monitor)
	uvm_analysis_port #(vga_trans) item_collected_port;
	vga_trans trans_collected;

  function new (string name, uvm_component parent);
    super.new(name, parent);
    trans_collected = new();
    item_collected_port = new("item_collected_port", this);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
	if(!uvm_config_db#(virtual vga_interface)::get(this, "", "vif_vga", vif_vga))
		`uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
		uvm_config_db#(int)::get(null, get_full_name(), "v_syn", 		v_syn);
		uvm_config_db#(int)::get(null, get_full_name(), "v_bkporch", 	v_bkporch);
		uvm_config_db#(int)::get(null, get_full_name(), "v_data", 		v_data);
		uvm_config_db#(int)::get(null, get_full_name(), "v_ftporch", 	v_ftporch);
		uvm_config_db#(int)::get(null, get_full_name(), "v_total", 		v_total);
		uvm_config_db#(int)::get(null, get_full_name(), "h_syn", 		h_syn);
		uvm_config_db#(int)::get(null, get_full_name(), "h_bkporch", 	h_bkporch);
		uvm_config_db#(int)::get(null, get_full_name(), "h_data",	 	h_data);
		uvm_config_db#(int)::get(null, get_full_name(), "h_ftporch", 	h_ftporch);
		uvm_config_db#(int)::get(null, get_full_name(), "h_total", 		h_total);
  endfunction: build_phase

  // run phase
  virtual task run_phase(uvm_phase phase);
	
	`uvm_info("monitor",$sformatf("syn=%d,v_bkporch=%d,v_data=%d,v_ftporch=%d,v_total=%d",v_syn,v_bkporch,v_data,v_ftporch,v_total), UVM_LOW);
	fork
      collect_trans(trans_collected);
    join
  endtask : run_phase

  // collect_trans
  //  BKPORCH 23 DATA 16 FTPORCH 1
	virtual protected task collect_trans(vga_trans trans_collected);
	`uvm_info("monitor", "COLECT TRANS", UVM_LOW);
	forever begin
		case (c_state) 
			INIT: begin
				if(vif_vga.VSYNC_Sig == 0) begin
					c_state <= VSYN_L;
				end
			end
			VSYN_L: begin
				if(trans_collected.data.size() != 0) begin
					trans_collected.print();
					item_collected_port.write(trans_collected);
					trans_collected.set_zero();
					`uvm_info("monitor", "END ONE FRAME", UVM_LOW);
				end
				if(vif_vga.VSYNC_Sig == 0) begin
					c_state <= VSYN_L;
				end
				else begin
					c_state <= VSYN_H_RL;
					frame_cnt <= frame_cnt + 1;
				end
			end
			VSYN_H_RL: begin
				if(vif_vga.VSYNC_Sig == 1 && vif_vga.HSYNC_Sig == 0) begin
					c_state <= VSYN_H_RL;
					cnt_column <= 0;
				end
				else if(vif_vga.VSYNC_Sig == 1 && vif_vga.HSYNC_Sig == 1) begin
					c_state <= VSYN_H_RH;
					if(cnt_row >= v_bkporch && cnt_row < v_bkporch + v_data && cnt_column >= h_bkporch && cnt_column < h_bkporch + h_data)begin
						data_tmp.push_back(vif_vga.vga_data[15:0]) ;
					end		
					idx <= idx + 1;
					cnt_column <= cnt_column + 1;
				end
				else if(vif_vga.VSYNC_Sig == 0)begin
					c_state <= VSYN_L;
					cnt_row <= 0;
					idx <= 0;
					trans_collected.row_size <= cnt_row;
						trans_collected.size = data_tmp.size();
						trans_collected.data = new[trans_collected.size];
						for(int i=0;i<trans_collected.size;i++) begin
							trans_collected.data[i] = data_tmp.pop_front();
						end
					`uvm_info("monitor",$sformatf("END OF L L , size = %d",trans_collected.size), UVM_LOW); 
				end
			end
			VSYN_H_RH: begin
				if(vif_vga.VSYNC_Sig == 1 && vif_vga.HSYNC_Sig == 1) begin
					c_state <= VSYN_H_RH;
					if(cnt_row >= 23 && cnt_row < 39 && cnt_column >= h_bkporch && cnt_column < h_bkporch + h_data)begin
						data_tmp.push_back(vif_vga.vga_data[15:0]) ;
					end		
					idx <= idx + 1;
					cnt_column <= cnt_column + 1;
				end
				else if(vif_vga.VSYNC_Sig == 1 && vif_vga.HSYNC_Sig == 0) begin
					c_state <= VSYN_H_RL;
					cnt_column <= 0;
					cnt_row <= cnt_row + 1;
					if(cnt_row >= 23 && cnt_row < 39)begin
						trans_collected.column_ar.push_back(cnt_column);
						trans_collected.column_size <= cnt_column;
						`uvm_info("monitor",$sformatf("END, REF, size = %d",data_tmp.size()), UVM_LOW);
					end
				end
				else if(vif_vga.VSYNC_Sig == 0) begin
					c_state <= VSYN_L;
					cnt_row <= 0;
					idx <= 0;
					trans_collected.row_size <= cnt_row;
						trans_collected.size = data_tmp.size();
						trans_collected.data = new[trans_collected.size];
						for(int i=0;i<trans_collected.size;i++) begin
							trans_collected.data[i] = data_tmp.pop_front();
						end
					`uvm_info("monitor",$sformatf("END OF L L , size = %d",trans_collected.size), UVM_LOW); 
				end
			end
		endcase
		@(posedge vif_vga.vga_clk);
	end
	endtask : collect_trans


endclass : vga_monitor

`endif  //VGA_MONITOR__SV