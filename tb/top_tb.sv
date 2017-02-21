`include "uvm_macros.svh"
import uvm_pkg::*;

`include "cmos_interface.sv"
`include "vga_interface.sv"
`include "i2c_interface.sv"
`include "test_lib.sv"

module top_tb;

	
	reg 		CLK;
	reg			RSTn;
	wire[15:0]  sdram_data  ;
	wire[12:0]  sdram_addr  ;
	wire    	sdram_clk	;
	wire[1:0]   sdram_ba	;
	wire    	sdram_ncas  ;
	wire    	sdram_clke  ;
	wire    	sdram_nwe	;
	wire    	sdram_ncs	;
	wire[1:0]   sdram_dqm	;
	wire    	sdram_nras  ;

	
	i2c_interface	vif_i2c(); 
	vga_interface	vif_vga(); 
	cmos_interface	vif_cmos(); 


	initial begin
		uvm_config_db#(virtual i2c_interface)::set(uvm_root::get(), "*", 
						"vif_i2c", vif_i2c);
		uvm_config_db#(virtual vga_interface)::set(uvm_root::get(), "*", 
						"vif_vga", vif_vga);
		uvm_config_db#(virtual cmos_interface)::set(uvm_root::get(), "*", 
						"vif_cmos", vif_cmos);
		run_test();
	end


	initial begin
		RSTn = 1;
		CLK = 0;
		#2000ns RSTn = 0;
		#8000ns RSTn = 1;
	end
	
	always begin
		#10 CLK = ~CLK;
	end
	
	vga_module dut_vga
	(
		.CLK		(CLK		),
		.RSTn		(RSTn		),
		.led_o1     (		   	),
		.led_o2     (		   	),
		.led_o3     (	   		),
		.VSYNC_Sig  (vif_vga.VSYNC_Sig	),
		.HSYNC_Sig  (vif_vga.HSYNC_Sig	),
		.Red_Sig    (vif_vga.Red_Sig  	),
		.Green_Sig  (vif_vga.Green_Sig	),
		.Blue_Sig   (vif_vga.Blue_Sig 	),
		.sdram_data	(sdram_data ),
		.sdram_addr	(sdram_addr	),
		.sdram_clk	(sdram_clk	),
		.sdram_ba	(sdram_ba	),
		.sdram_ncas	(sdram_ncas	),
		.sdram_clke	(sdram_clke	),
		.sdram_nwe	(sdram_nwe	),
		.sdram_ncs	(sdram_ncs	),
		.sdram_dqm	(sdram_dqm	),
		.sdram_nras (sdram_nras	),
		.sda		(vif_i2c.sda		),
		.sclk		(vif_i2c.sclk		),
		.cmos_vsyn	(vif_cmos.cmos_vsyn	),
		.cmos_href	(vif_cmos.cmos_href	),
		.cmos_pclk	(vif_cmos.cmos_pclk	),
		.cmos_xclk	(vif_cmos.cmos_xclk	),
		.cmos_data	(vif_cmos.cmos_data	),
		.clk_100M	(			),
		.sram_data	(			), 
		.sram_addr	(			),
		.sram_cs	(			), 
		.sram_oe	(			), 
		.sram_we	(			), 
		.sram_byte  (		 	)		
	);
	
	sdram inst_sdram
	(
		.Dq		(sdram_data), 
		.Addr	(sdram_addr), 
		.Ba		(sdram_ba), 
		.Clk	(sdram_clk), 
		.Cke	(sdram_clke), 
		.Cs_n	(sdram_ncs), 
		.Ras_n	(sdram_nras), 
		.Cas_n	(sdram_ncas), 
		.We_n	(sdram_nwe), 
		.Dqm	(1'b0)	
	);
	

	
endmodule
