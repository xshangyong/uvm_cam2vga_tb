`ifndef CMOS2VGA_TB__SV
`define CMOS2VGA_TB__SV

`include "vga_env.sv"
//`include "i2c_env.sv"
//`include "cmos2vga_tb_scoreboard.sv"
`include "cmos_env.sv"
class cmos2vga_tb extends uvm_env;
    
	`uvm_component_utils(cmos2vga_tb)

	// cmos, vga and i2c environment
	cmos_env cmos_env0;
	vga_env vga_env0;
///	i2c_env i2c_env0;

	// scoreboard
//	cmos2vga_tb_scoreboard scoreboard0;

	function new (string name, uvm_component parent=null);
		super.new(name, parent);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		cmos_env0 	= cmos_env::type_id::create("cmos_env0", this);
		vga_env0 	= vga_env::type_id::create("vga_env0", this);
//		i2c_env0 	= i2c_env::type_id::create("i2c_env0", this);
//		scoreboard0 = cmos2vga_tb_scoreboard::type_id::create("scoreboard0", this);
	endfunction : build_phase

	function void connect_phase(uvm_phase phase);
		// supose to connect ports to scoreboard
	endfunction : connect_phase

endclass : cmos2vga_tb

`endif  //CMOS2VGA_TB__SV