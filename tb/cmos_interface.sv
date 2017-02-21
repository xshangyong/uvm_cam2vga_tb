`ifndef CMOS_INTERFACE__SV
`define CMOS_INTERFACE__SV

interface cmos_interface;

	logic		cmos_vsyn;
	logic		cmos_href;
	logic		cmos_pclk;
	logic		cmos_xclk;
	logic[7:0]	cmos_data;
endinterface	

`endif  //CMOS_INTERFACE__SV