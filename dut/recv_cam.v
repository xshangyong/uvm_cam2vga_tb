
module recv_cam
(
	cmos_data,
	cmos_pclk,
	cmos_href,
	cmos_vsyn,
	frame_en,
	cfg_done,
	data_16b,
	data_16b_en,
	cmos_data_valid
);


	assign 	cfg_done_use = cfg_done;
	assign	cmos_valid_use = 0;



	input[7:0] 		cmos_data;
	input			cmos_pclk;
	input			cfg_done;
	input			cmos_href;
	input			cmos_vsyn;
	input			frame_en;			// low valid 
	
	output [15:0]	data_16b;
	output 			data_16b_en;	
	output 			cmos_data_valid;	
	
	reg			done_d1,done_d2;
	reg			data_bit = 0;
	reg[15:0]	data_16b_r = 0;
	reg			data_16b_enr = 0;
	reg			cmos_vsyn_d1=0;
	reg			cmos_vsyn_d2=0;
	reg[7:0]	cnt_vsyn=0;
	reg			cmos_valid = 0 ;
	reg[7:0]	cnt_frame_en=0;
	reg[3:0]	frame_st=0;
	reg[3:0]	nxt_fst=0;
	wire 	vsyn_neg;	
//	assign 	data_16b = data_16b_r;
//	assign 	data_16b_en = data_16b_enr;
	wire	frame_en_valid;
	wire	cfg_done_use, cmos_valid_use;
	parameter	FRM_IDE			= 4'b0000;
	parameter	FRM_FRAM_EN		= 4'b0001;
	parameter	FRM_PROC_OK		= 4'b0010;
	parameter	FRM_SEND_FRAM	= 4'b0011;
	
	always@(posedge cmos_pclk)begin
		done_d1 <= cfg_done_use;  //sim change    done_d1 <= cfg_done;   1
		done_d2 <= done_d1;
	end
	always@(posedge cmos_pclk)begin
		if(done_d2 == 0 || cmos_vsyn == 1 || cmos_valid == 0) begin //
			data_16b_r <= 0;
			data_16b_enr <= 0;
			data_bit <= 1'b0;
		end
		else begin
			if(cmos_href) begin
				if(data_bit == 0) begin
					data_16b_r[15:8] <= cmos_data[7:0];
					data_bit <= 1'b1;
					data_16b_enr <= 1'b0;
				end
				else if (data_bit == 1) begin
					data_16b_r[7:0] <= cmos_data[7:0];
					data_bit <= 1'b0;
					data_16b_enr <= 1'b1;
				end
			end
			else begin
				data_16b_r <= data_16b_r;
				data_16b_enr <= 0;
			end
		end
	end 

	//		if frame_en is longer than 1000 pclk 
	always@(posedge cmos_pclk)begin
		if(frame_en == 0) begin
			if(cnt_frame_en >= 100) begin
				cnt_frame_en <= 100;
			end
			else begin
				cnt_frame_en <= cnt_frame_en + 1;
			end	
		end
		else begin
			cnt_frame_en <= 0;
		end	
	end
	assign frame_en_valid = cnt_frame_en == 100 ? 1 : 0;

	always@(posedge cmos_pclk)begin
		frame_st <= nxt_fst;
	end
	
	always@(*) begin
		case(frame_st)
			FRM_IDE : begin
				if(frame_en_valid == 1)begin
					nxt_fst = FRM_FRAM_EN;
				end
				else begin
					nxt_fst = nxt_fst;
				end
			end
			FRM_FRAM_EN : begin
				if(1)begin
					nxt_fst = FRM_PROC_OK;
				end
				else begin
					nxt_fst = nxt_fst;
				end
			end
			FRM_PROC_OK : begin
				if(vsyn_neg == 1)begin
					nxt_fst = FRM_SEND_FRAM;
				end
				else begin
					nxt_fst = nxt_fst;
				end
			end
			FRM_SEND_FRAM : begin
				if(vsyn_neg == 1)begin
					nxt_fst = FRM_IDE;
				end
				else begin
					nxt_fst = nxt_fst;
				end
			end
		endcase
	end


	assign data_16b = data_16b_r;
	assign data_16b_en = data_16b_enr;
	assign cmos_data_valid = 1;
	
	// always@(*) begin
		// case(frame_st)
			// FRM_SEND_FRAM : begin
				// data_16b = data_16b_r;
				// data_16b_en = data_16b_enr;
				// cmos_data_valid = 1;
			// end
			
			// default begin
				// data_16b = 0;
				// data_16b_en = 0;
				// cmos_data_valid = 0;
			// end
		// endcase
	// end	
	
	
	assign vsyn_neg = ~cmos_vsyn_d1 & cmos_vsyn_d2;
	always@(posedge cmos_pclk)begin
		cmos_vsyn_d1 <= cmos_vsyn;
		cmos_vsyn_d2 <= cmos_vsyn_d1;
		
		if(vsyn_neg == 1) begin
			if(cnt_vsyn == 1) begin
				cnt_vsyn <= cnt_vsyn;
				cmos_valid <= 1;
			end
			else begin
				cnt_vsyn <= cnt_vsyn + 1;
				cmos_valid <= cmos_valid_use;     // sim change  cmos_valid <= 0   1
			end
		end
		else begin
			cmos_valid <= cmos_valid;    	 // sim change  cmos_valid <= cmos_valid  1
		end
		
	end

	
	
endmodule
