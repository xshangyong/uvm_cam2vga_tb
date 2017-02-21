module bank_switch(
	input 			clk				,			
	input 			rst_133			,
	input 			vga_rise    	,
	input 			cam_rise    	,
	input			button			,
	input[21:9]		wr_sdram_add_i	,
	output reg[1:0] vga_bank    	,
	output reg[1:0] cam_bank    	,
	output reg[1:0] bk3_state  		,	// 01 for empty ; 10 for full
	output reg[21:9] wr_sdram_add_o
	
	);       
	
	reg	vga_rise_1d,vga_rise_2d;
	reg	cam_rise_1d,cam_rise_2d;
	wire	vga_negedge, cam_posedge;
	always @ (posedge clk or negedge rst_133) begin
		if(!rst_133) begin
			vga_rise_1d <= 0;
			vga_rise_2d <= 0;
			cam_rise_1d <= 0;
			cam_rise_2d <= 0;
		end
		else begin
			vga_rise_1d <= vga_rise;
			vga_rise_2d <= vga_rise_1d;
			cam_rise_1d <= cam_rise;
			cam_rise_2d <= cam_rise_1d;
		end
	end
	assign vga_negedge = ~vga_rise_1d & vga_rise_2d;
	assign cam_posedge = cam_rise_1d & ~cam_rise_2d;
	always @ (posedge clk or negedge rst_133) begin
		if(!rst_133) begin
			vga_bank  <= 	2'b00;
			cam_bank  <= 	2'b01;
			bk3_state <= 	2'b01;			
		end
		else begin
			if(button)begin			// sim change
				if(vga_negedge && cam_posedge) begin
					vga_bank <= cam_bank;
					cam_bank <=	vga_bank;
					bk3_state <=  2'b01;
				end
				else if(vga_negedge && bk3_state == 2'b10) begin
					vga_bank <=  ~(vga_bank^cam_bank); 	//switch vga_bank to the 3rd bank, if it's full
					bk3_state <= 2'b01;
				end
				else if(cam_posedge) begin
					cam_bank <=  ~(vga_bank^cam_bank); 	//switch vga_bank to the 3rd bank, if it's full
					bk3_state <= 2'b10;
					wr_sdram_add_o[21:9] <= wr_sdram_add_i[21:9];
				end
			end
		end
	end
endmodule

