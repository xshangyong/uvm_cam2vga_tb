module cam2fifo
(
	input 			cmos_pclk		,  	
	input			clk_133M_i		,  
	input			rst_133i		,  
	input			clear_wrsdram_fifo		,  
	input[15:0]		data_16b		,  
	input			data_16b_en	    ,
	output[10:0]	fifo_used_o	    ,
	output[15:0]	wr_sdram_data   ,
	input[4:0]		work_st		    
);
	// 100MHz for write fifo
	// 133MHz for read  fifo 

	
	wire[10:0]		fifo_used;
	reg				wr_fifo_en = 0;
	reg[3:0]		wr_fifo_st = 0;
	reg				wr_fifo_1d = 0;
	wire			rd_fifo;
	parameter 		Clear 	= 2'b00;
	parameter 		Idle 	= 2'b01;
	parameter 		Wr_fifo	= 2'b10; 
	parameter 		None2 	= 2'b11;
	
	parameter	W_IDLE		= 4'd0;		//idle
	parameter	W_ACTIVE	= 4'd1;		//row active 
	parameter	W_TRCD		= 4'd2;		//row active wait time  min=20ns
	parameter	W_REF		= 4'd3;		//auto refresh
	parameter	W_RC		= 4'd4;		//auto refresh wait time min=63ns
	parameter	W_READ		= 4'd5;		//read cmd
	parameter	W_RDDAT		= 4'd6;		//read data
	parameter	W_CL		= 4'd7;		//cas latency
	parameter	W_WRITE		= 4'd8;		//auto write
	parameter	W_PRECH		= 4'd9;		//precharge
	parameter	W_TRP		= 4'd10;	//precharge wait time  min=20ns
	
	assign fifo_used_o = fifo_used;
	assign rd_fifo = (work_st == W_WRITE) ? 1 : 0;
	
	
	desk_fifo inst_dfifo
	(	         
		.aclr	(clear_wrsdram_fifo),  // need clear
		.data	(data_16b[15:0]),
		.rdclk	(clk_133M_i),
		.rdreq	(rd_fifo),
		.wrclk	(cmos_pclk),
		.wrreq	(data_16b_en),
		.q		(wr_sdram_data[15:0]),
		.rdempty(),
		.rdusedw(fifo_used),
		.wrfull	(),
		.wrusedw()
	);
endmodule
