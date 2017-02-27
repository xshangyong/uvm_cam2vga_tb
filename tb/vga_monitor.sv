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
	typedef enum   {INIT=0, VSYN_H, VSYN_L_RL, VSYN_L_RH} vga_state;
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
  endfunction: build_phase

  // run phase
  virtual task run_phase(uvm_phase phase);
	fork
      collect_trans(trans_collected);
    join
  endtask : run_phase

  // collect_trans
	virtual protected task collect_trans(vga_trans trans_collected);
	`uvm_info("monitor", "COLECT TRANS", UVM_LOW);
	forever begin
		case (c_state) 
			INIT: begin
				if(vif_vga.VSYNC_Sig == 0) begin
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
				if(vif_vga.VSYNC_Sig == 0) begin
					c_state <= VSYN_H;
				end
				else begin
					c_state <= VSYN_L_RL;
					frame_cnt <= frame_cnt + 1;
				end
			end
			VSYN_L_RL: begin
				if(vif_vga.VSYNC_Sig == 1 && vif_vga.HSYNC_Sig == 0) begin
					c_state <= VSYN_L_RL;
					cnt_column <= 0;
				end
				else if(vif_vga.VSYNC_Sig == 1 && vif_vga.HSYNC_Sig == 1) begin
					c_state <= VSYN_L_RH;
					cnt_column <= cnt_column + 1;
					data_tmp.push_back(vif_vga.vga_data[15:0]) ;
					idx <= idx + 1;
				end
				else if(vif_vga.VSYNC_Sig == 0)begin
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
				if(vif_vga.VSYNC_Sig == 1 && vif_vga.HSYNC_Sig == 1) begin
					c_state <= VSYN_L_RH;
					cnt_column <= cnt_column + 1;
					data_tmp.push_back(vif_vga.vga_data[15:0]) ;
					idx <= idx + 1;
				end
				else if(vif_vga.VSYNC_Sig == 1 && vif_vga.HSYNC_Sig == 0) begin
					c_state <= VSYN_L_RL;
					cnt_column <= 0;
					cnt_row <= cnt_row + 1;
					trans_collected.column_ar.push_back(cnt_column);
					trans_collected.column_size <= cnt_column;
					`uvm_info("monitor",$sformatf("END, REF, size = %d",data_tmp.size()), UVM_LOW);
				end
			end
		endcase
		@(posedge vif_vga.vga_clk);
	end
	endtask : collect_trans


endclass : vga_monitor

`endif  //VGA_MONITOR__SV