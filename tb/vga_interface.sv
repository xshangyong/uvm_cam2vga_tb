`ifndef VGA_INTERFACE__SV
`define VGA_INTERFACE__SV

interface vga_interface;
	logic    	VSYNC_Sig  	;
	logic    	HSYNC_Sig  	;
	wire[15:0]	vga_data	;
	logic		vga_clk;
	logic[4:0]   Red_Sig    ;
	logic[5:0]   Green_Sig  ;
	logic[4:0]   Blue_Sig   ;
	
	
	
	assign  vga_data[15:11] =	Red_Sig[4:0];
	assign 	vga_data[10:5] 	= 	Green_Sig[5:0];
	assign 	vga_data[4:0]	=	Blue_Sig[4:0];
endinterface	

`endif  //VGA_INTERFACE__SV