`ifndef VGA_INTERFACE__SV
`define VGA_INTERFACE__SV

interface vga_interface;
	logic    	VSYNC_Sig  	;
	logic    	HSYNC_Sig  	;
	logic[4:0]   Red_Sig    ;
	logic[5:0]   Green_Sig  ;
	logic[4:0]   Blue_Sig   ;
endinterface	

`endif  //VGA_INTERFACE__SV