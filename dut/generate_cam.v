module generate_cam
(
	cmos_pclk		,
	cmos_data	,
	cmos_href	,
	cmos_vsyn
);

	input					cmos_pclk;
	output reg[7:0]		cmos_data;
	output		 reg	cmos_href;	
	output		 reg	cmos_vsyn;	
	parameter	hor_num 	 = 800;
	parameter	ver_num 	 = 480;
	parameter	horX2_100 	 = hor_num*2+100;
	parameter	total_length = (ver_num * horX2_100) + 2000;
	
	reg[31:0] cnt = 0;
	reg[31:0] cnt_row = 0;
	reg[31:0] cnt_pix = 0;
	reg[15:0] cam_data = 16'h8000;
	reg[15:0] cam_data2 = 16'h8000;
	reg[31:0] cnt_cam = 0;
	reg		  cam_data_bit = 0;
	
	reg[15:0]	red 	= 	16'h1111_1000_0000_0000;
	reg[15:0]	green 	= 	16'h0000_0111_1110_0000;
	reg[15:0]	blue 	= 	16'h0000_0000_0001_1111;
	always @(posedge cmos_pclk) begin
		if(cnt == total_length) begin
			cnt <= 0;
		end
		else begin
			cnt <= cnt + 1;
		end
		
		if( cnt >= 0 && cnt <= 1000) begin  // after  sdram initialized
			cmos_vsyn <= 1;
		end
		else begin
			cmos_vsyn <= 0;
		end
		
		if(cmos_vsyn == 0 && cnt_row < ver_num) begin
			if(cnt_pix == horX2_100 ) begin
				cnt_row <= cnt_row + 1;
				cnt_pix <= 0;
				cmos_href <= 0;
			end
			else begin
				cnt_pix <= cnt_pix + 1;
				if(cnt_pix < 100) begin
					cmos_href <= 0;
				end
				else begin
					cam_data_bit <= ~cam_data_bit;
					cmos_href <= 1;
					if(cam_data_bit == 0) begin
						cmos_data <= cam_data2[15:8];
					end
					else if(cam_data_bit == 1) begin
						cmos_data <= cam_data2[7:0];
						if(cnt_cam[31:0] < hor_num - 1) begin
							cnt_cam[31:0] <= cnt_cam[31:0] + 1;
							cam_data2 <= cam_data2 + 1;
							if(cnt_cam[31:0] < 79)  begin cam_data[15:0] <=  16'b1000_0000_0000_0000; end  //red
							else if(cnt_cam[31:0] < 159) begin cam_data[15:0] <=  16'b0100_0000_0000_0000; end  //red
							else if(cnt_cam[31:0] < 239) begin cam_data[15:0] <=  16'b0010_0000_0000_0000; end  //red
							else if(cnt_cam[31:0] < 319) begin cam_data[15:0] <=  16'b0001_0000_0000_0000; end  //red
							else if(cnt_cam[31:0] < 399) begin cam_data[15:0] <=  16'b0000_1000_0000_0000; end  //red
							else if(cnt_cam[31:0] < 479) begin cam_data[15:0] <=  16'b0000_0100_0000_0000; end  //green
							else if(cnt_cam[31:0] < 559) begin cam_data[15:0] <=  16'b0000_0010_0000_0000; end  //green
							else if(cnt_cam[31:0] < 639) begin cam_data[15:0] <=  16'b0000_0001_0000_0000; end  //green				
							else if(cnt_cam[31:0] < 719) begin cam_data[15:0] <=  16'b0000_0000_1000_0000; end  //green
							else if(cnt_cam[31:0] < 799) begin cam_data[15:0] <=  16'b0000_0000_0100_0000; end  //green
							else if(cnt_cam[31:0] < 879) begin cam_data[15:0] <=  16'b0000_0000_0010_0000; end  //green
							else if(cnt_cam[31:0] < 959) begin cam_data[15:0] <=  16'b0000_0000_0001_0000; end  //blue
							else if(cnt_cam[31:0] < 1039) begin cam_data[15:0] <= 16'b0000_0000_0000_1000; end  //blue
							else if(cnt_cam[31:0] < 1119) begin cam_data[15:0] <= 16'b0000_0000_0000_0100; end  //blue
							else if(cnt_cam[31:0] < 1199) begin cam_data[15:0] <= 16'b0000_0000_0000_0010; end  //blue
							else if(cnt_cam[31:0] < 1279) begin cam_data[15:0] <= 16'b0000_0000_0000_0001; end  //blue
						end
						else begin
							cnt_cam[31:0] <= 0;
							cam_data[15:0] <= 0;
						end
					end
				end
			end
		end
		else if(cmos_vsyn == 1) begin
			cnt_row <= 0;
		end
	end
	
	
endmodule
