`ifndef I2C_INTERFACE__SV
`define I2C_INTERFACE__SV

interface i2c_interface;
	wire		sda;
	logic		sda_r;
	logic		sda_rw;
	wire 		sclk;

//	assign sda = sda_rw ? sda_r : 1'bz;

endinterface	

`endif  //I2C_INTERFACE__SV