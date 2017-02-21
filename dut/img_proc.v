module img_proc
(
	input			cmos_pclk		,			
	input[15:0]		data_16b		,
	input			data_16b_en	    ,
	input			cmos_data_valid ,
	inout[15:0]		sram_data		,
	output reg[17:0]  sram_addr		,
	output reg		sram_we		    ,
	output reg		sram_oe		    ,
	output 			sram_cs		    ,
	output[1:0]		sram_byte		,
	output reg[15:0]	coms_data_proc	,
	output 			coms_valid_proc ,
	output reg		coms_clk_proc   
);

	parameter	IMG_ROW		= 8;
	parameter	IMG_COL		= 512;

	
	reg[3:0]	proc_st=0;
	reg[3:0]	proc_sub_st=0;
	reg[3:0]	nxt_fst=0;
	reg[3:0]	nxt_sub_fst=0;
	reg			valid_d1,valid_d2;
	reg[15:0]	sram_wr_data=0;
	reg[17:0]	sram_wr_addr=0;
	reg[17:0]	sram_rd_addr=0;
	reg[8:0]	wra_addr=0;
	reg[8:0]	rda_addr=0;
	reg[8:0]	wrb_addr=0;
	reg[8:0]	rdb_addr=0;
	reg[8:0]	line_wra_addr=0;
	reg[8:0]	line_rda_addr=0;
	reg[8:0]	line_wrb_addr=0;
	reg[8:0]	line_rdb_addr=0;
	reg[10:0]	rowA_count=0;
	reg[10:0]	rowB_count=0;
	reg			wra_en=0;
	reg			wrb_en=0;
	reg			rda_en=0;
	reg			rdb_en=0;
	reg			outa_valid=0;
	reg			outb_valid=0;
	reg[10:0]	row_count=0;		
	reg			sram_wr_data_flag=0;
	reg			proc_done=1;
	wire		valid_pos, valid_neg;
	reg			frame_valid=0;
	wire[15:0]	outa_data;
	wire[15:0]	outb_data;
	
	parameter	PROC_WAIT_DONE		= 4'b0000;
	parameter	PROC_WAIT_FRAM		= 4'b0001;
	parameter	PROC_WR_SRAM		= 4'b0010;
	parameter	PROC_FILTER			= 4'b0011;
	parameter	PROC_END			= 4'b0100;

//	parameter	PROC_PROC_OK		= 4'b0011;
//	parameter	PROC_SEND_FRAM		= 4'b0100;
	
	parameter	PROC_SUB_IDLE		= 4'b0000;
	parameter	PROC_SUB_WA			= 4'b0001;
	parameter	PROC_SUB_WBRA		= 4'b0010;
	parameter	PROC_SUB_WARB		= 4'b0011;
	parameter	PROC_SUB_RB			= 4'b0100;
	parameter	PROC_SUB_END		= 4'b0101;


	always@(posedge cmos_pclk)begin
		valid_d1 <= cmos_data_valid;
		valid_d2 <= valid_d1;
	end
	assign valid_pos 	= valid_d1 & ~valid_d2;
	assign valid_neg 	= ~valid_d1 & valid_d2;
	assign sram_byte 	= 2'b00;
	assign sram_cs 		= 1'b0;
	assign sram_data 	= sram_wr_data_flag ? sram_wr_data : 16'bzzzz_zzzz_zzzz_zzzz;
//	assign coms_data_proc = outa_data;
	
	// state machine control
	always@(posedge cmos_pclk)begin
		proc_st <= nxt_fst;
		proc_sub_st <= nxt_sub_fst;
	end

	always@(*) begin
		case(proc_st)
			PROC_WAIT_DONE : begin
				if(valid_pos == 1)begin
					nxt_fst = PROC_WR_SRAM;
				end
				else begin
					nxt_fst = nxt_fst;
				end
			end
			PROC_WR_SRAM : begin
				if(valid_neg == 1)begin
					nxt_fst = PROC_FILTER;
				end
				else begin
					nxt_fst = nxt_fst;
				end
			end 
			PROC_FILTER : begin
				case(proc_sub_st)
					PROC_SUB_IDLE : begin
						nxt_sub_fst <= PROC_SUB_WA;
					end
					PROC_SUB_WA : begin
						if(line_wra_addr ==IMG_COL - 1 ) begin
							nxt_sub_fst = PROC_SUB_WBRA;
						end
						else begin
							nxt_sub_fst = nxt_sub_fst;
						end
					end
					PROC_SUB_WBRA : begin
						if(line_wrb_addr ==IMG_COL - 1 ) begin
							if(row_count==IMG_ROW - 1) begin
								nxt_sub_fst = PROC_SUB_RB;
							end
							else begin
								nxt_sub_fst = PROC_SUB_WARB;
							end
						end
						else begin
							nxt_sub_fst = nxt_sub_fst;
						end
					end
					PROC_SUB_WARB : begin
						if(line_wra_addr ==IMG_COL - 1 ) begin
							nxt_sub_fst = PROC_SUB_WBRA;
						end
						else begin
							nxt_sub_fst = nxt_sub_fst;
						end
					end
					 
					PROC_SUB_RB : begin
						if(line_rdb_addr ==IMG_COL - 1 ) begin
							nxt_sub_fst = PROC_SUB_END;
						end
						else begin
							nxt_sub_fst = nxt_sub_fst;
						end
					end	
					PROC_SUB_END : begin
						nxt_sub_fst = nxt_sub_fst;
						nxt_fst = PROC_END;
					end
				endcase
			end
			PROC_END : begin
				nxt_fst = PROC_WAIT_DONE;
			end
		endcase
	end
	
	
	// image porcessing 
	always@(posedge cmos_pclk)begin
		case(proc_st)
			PROC_WAIT_DONE : begin
				sram_wr_addr <= 0;
				sram_rd_addr <= 0;
				sram_addr	 <= 0;
				sram_we	 	 <= 1;
				sram_oe	 	 <= 1;
				frame_valid  <= 0;
				
			end
			PROC_WR_SRAM : begin
				sram_oe		<= 	1;
				frame_valid  <= 1;
				if(data_16b_en == 1) begin
					sram_wr_addr 		<= 	sram_wr_addr + 1;
					sram_addr 			<= 	sram_wr_addr;
					sram_wr_data 		<= 	data_16b;
					sram_we				<= 	0;
					sram_wr_data_flag 	<= 	1;
				end	
				else begin	
					sram_wr_data		<= 	0;
					sram_wr_data_flag 	<= 	0;
					sram_we				<= 	1;
				end
			end
			PROC_FILTER : begin
				frame_valid  <= 1;
				sram_we		<=	1;
				case(proc_sub_st)
					PROC_SUB_IDLE : begin
						line_wra_addr	<=	0;
						line_rda_addr	<=	0;
						line_wrb_addr	<=	0;
						line_rdb_addr	<=	0;
						wra_addr		<= 	0;
						row_count		<=	0;
					end
					PROC_SUB_WA : begin
						sram_addr		<=	sram_rd_addr;
						sram_rd_addr	<=	sram_rd_addr + 1;
						sram_oe			<= 	0;			
						wra_addr		<= 	line_wra_addr;
						wra_en			<= 	1;
						wrb_en			<= 	0;
						rda_en			<=	0;
						rdb_en			<=	0;
						if(line_wra_addr ==IMG_COL - 1 ) begin
							row_count 	<= row_count + 1;
							line_wra_addr	<= 0;
						end
						else begin
							row_count <= row_count;
							line_wra_addr	<= 	line_wra_addr + 1;
						end
					end
					PROC_SUB_WBRA : begin
						sram_addr		<=	sram_rd_addr;
						sram_rd_addr	<=	sram_rd_addr + 1;
						sram_oe			<= 	0;			
						wrb_addr		<= 	line_wrb_addr;
						wrb_en			<= 	1;
						wra_en			<= 	0;
						rda_en			<=	1;
						rdb_en			<=	0;
						rda_addr		<= 	line_rda_addr;
						line_rda_addr	<= 	line_rda_addr + 1;
						if(line_wrb_addr ==IMG_COL - 1 ) begin
							row_count 	<= row_count + 1;
							line_wrb_addr	<= 0;
						end
						else begin
							row_count <= row_count;
							line_wrb_addr	<= 	line_wrb_addr + 1;
						end
					end
					PROC_SUB_WARB : begin
						sram_addr		<=	sram_rd_addr;
						sram_rd_addr	<=	sram_rd_addr + 1;
						sram_oe			<= 	0;			
						wra_addr		<= 	line_wra_addr;
						wra_en			<= 	1;
						wrb_en			<= 	0;
						rda_en			<=	0;
						rdb_en			<=	1;
						rdb_addr		<= 	line_rdb_addr;
						line_rdb_addr	<= 	line_rdb_addr + 1;
						if(line_wra_addr ==IMG_COL - 1 ) begin
							row_count 	<= row_count + 1;
							line_wra_addr	<= 0;
						end
						else begin
							row_count <= row_count;
							line_wra_addr	<= 	line_wra_addr + 1;
						end
					end
					
					PROC_SUB_RB : begin
						sram_oe			<= 	1;		
						rdb_addr		<= 	line_rdb_addr;
						wra_en			<= 	0;
						wrb_en			<= 	0;
						rda_en			<=	0;
						rdb_en			<=	1;
						line_rdb_addr	<= 	line_rdb_addr + 1;
						if(line_rdb_addr ==IMG_COL - 1 ) begin
							row_count 	<= row_count + 1;
							line_rdb_addr	<= 0;
						end
						else begin
							row_count <= row_count;
							line_rdb_addr	<= 	line_rdb_addr + 1;
						end
					end
					PROC_SUB_END : begin
						wra_en			<= 	0;
						wrb_en			<= 	0;
						rda_en			<=	0;
						rdb_en			<=	0;
					end
				endcase
			end
			
			
//			default begin
//				coms_data_proc 	<= 0;
//				coms_valid_proc 	<= 0;
//			end
		endcase
	end

	always@(posedge cmos_pclk)begin
		outa_valid <= rda_en;
		outb_valid <= rdb_en;
	end
	line_buf inst_linea
	(
		.data		(sram_data),
		.rdaddress	(rda_addr),
		.rdclock	(cmos_pclk),
		.wraddress	(wra_addr),
		.wrclock	(cmos_pclk),
		.wren		(wra_en),
		.q          (outa_data)
	);	
	
	line_buf inst_lineb 
	(
		.data		(sram_data),
		.rdaddress	(rdb_addr),
		.rdclock	(cmos_pclk),
		.wraddress	(wrb_addr),
		.wrclock	(cmos_pclk),
		.wren		(wrb_en),
		.q          (outb_data)
	);	
	
	always@(*)begin
		if(outa_valid==1) begin
			coms_data_proc=outa_data;
		end
		else if(outb_valid==1) begin
			coms_data_proc=outb_data;
		end
		else begin
			coms_data_proc=0;
		end
	end
	assign coms_valid_proc = outa_valid | outb_valid;
	
	rgb2hsv inst_rgb2hsv
	(
		.rgb_in			(coms_data_proc),
		.rgb_clk_in		(cmos_pclk),
		.rgb_fram_valid	(frame_valid),
		.rgb_data_valid	(coms_valid_proc),
		.hsv_out		(),
		.hsv_clk_out    (),
		.hsv_fram_valid ()
	);
	
	
	
endmodule
