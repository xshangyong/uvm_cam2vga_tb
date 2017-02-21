module rgb2hsv
(
	input[15:0]		rgb_in ,
	input			rgb_clk_in		,
	input			rgb_fram_valid	,
	input			rgb_data_valid	,
	output reg[15:0]	hsv_out			,
	output		reg	hsv_clk_out    	,
	output		reg	hsv_fram_valid 	
);	

	
	wire[5:0]	red;
	wire[5:0]	green;
	wire[5:0]	blue;
	
	reg[5:0]	hue;
	reg[5:0]	satur;
	reg[5:0]	value;
	
	assign red[5:0]   =  {rgb_in[15:11],1'b0};
	assign green[5:0] =  rgb_in[10:5];
	assign blue[5:0]  =  {rgb_in[4:0],1'b0};
	
	reg[5:0]	max_1 = 0;
	reg[5:0]	min_1 = 0;
	reg[5:0]	demo_h_2 = 0;
	reg[5:0]	numer_h_2 = 0;
	reg[5:0]	demo_s_2 = 0;
	reg[5:0]	numer_s_2 = 0;
	wire[5:0]	quot_h_8;
	wire[5:0]	remain_h_8;
	wire[5:0]	quot_s_8;
	wire[5:0]	remain_s_8;
	wire[10:0]	mult_8 = 0;

// first clk ,get max_1 and min_1	
	always@(posedge rgb_clk_in)begin
		if(red >= green && green >= blue) begin
			max_1 <= red;
			min_1 <= blue;
		end
		else if(red >= blue && blue >= green) begin
			max_1 <= red;
			min_1 <= green;
		end
		else if(green >= red && red >= blue) begin
			max_1 <= green;
			min_1 <= blue;
		end
		else if(green >= blue && blue >= red) begin
			max_1 <= green;
			min_1 <= red;
		end
		else if(blue >= red && red >= green) begin
			max_1 <= red;
			min_1 <= green;
		end
		else if(blue >= green && green >= red) begin
			max_1 <= green;
			min_1 <= red;
		end
	end
	
// second clk ,get numer and demo	
	always@(posedge rgb_clk_in)begin
		if(max_1 == 0) begin	//  if max_1==0   then s=0;
			numer_s_2 <= 0;
			demo_s_2	<= 1;
		end
		else begin
			numer_s_2	<= max_1 - min_1;
			demo_s_2	<= max_1;
		end
	end
	
	always@(posedge rgb_clk_in)begin
		demo_h_2	<= max_1 - min_1;
		if(max_1 == min_1) begin //	if max_1==min_1   then h=0;
			numer_h_2 <= 0;
		end
		else if(max_1 == red) begin
			numer_h_2 <= green - blue;
		end
		else if(max_1 == green) begin
			numer_h_2 <= blue - red;
		end
		else if(max_1 == blue) begin
			numer_h_2 <= red - green;
		end
	end
	
	// divider output latnecy  6 clock cycle , get result after 7 clock
	// clock 3~8
	hsv_divid5 inst_div_h(
	.clock		(rgb_clk_in),		
	.denom		(demo_h_2),
	.numer		(numer_h_2),
	.quotient	(quot_h_8),
	.remain		(remain_h_8)		
	);
	
	hsv_divid5 inst_div_s(
	.clock		(rgb_clk_in),		
	.denom		(demo_s_2),
	.numer		(numer_s_2),
	.quotient	(quot_s_8),
	.remain		(remain_s_8)		
	);

// 	9th clock
	hsv_mult inst_mult_10 (
	.dataa		(quot_h_8),
	.result		(mult_8)	
	);
	
	always@(posedge rgb_clk_in)begin
		if(max_1 == red && green >= blue) begin
			hue <= mult_8[5:0];
		end		
		else if(max_1 == red && green <= blue) begin
			hue <= mult_8[5:0] + 64;
		end		
		else if(max_1 == green) begin
			hue <= mult_8[5:0] + 21;
		end		
		else if(max_1 == blue) begin
			hue <= mult_8[5:0] + 42;
		end		
	end
	
	
	
	
	// h = (60 x (x/y)  + 0) 	/ 360	* 64 	
	// h = (60 x (x/y)  + 120) 	/ 360 	* 64
	// h = (60 x (x/y)  + 240) 	/ 360	* 64
	// h = (60 x (x/y)  + 360) 	/ 360	* 64
	
endmodule
