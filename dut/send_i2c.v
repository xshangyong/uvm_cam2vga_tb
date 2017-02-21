module send_i2c
(
	clk_20k,
	rst_100,
	cfg_data,
	i2c_req,
	i2c_ack,
	sclk,
	sda
);

	input 		clk_20k;
	input 		rst_100;
	inout		sda;
	input[31:0]	cfg_data;
	input		i2c_req;
	output reg	i2c_ack = 0;
	output 		sclk;
	
	
	wire[7:0]	cnt_i2c;
	reg[7:0]	cnt_i2c_r 	= 0;
	reg[4:0]	n_state 	= 0;	
	reg[4:0]	c_state 	= 0;	
	reg[15:0]	cnt_sclk 	= 0;
	reg			sclk_pulse 	= 0;
	reg			sda_r 		= 1;

    reg [5:0] cyc_count=6'b111111;
    reg reg_sdat=1;
    reg reg_clk=1;
    reg ack1,ack2,ack3;
 
   
    wire i2c_sclk;
    wire i2c_sdat;
    wire ack;
   
    assign sclk=reg_clk|(((cyc_count>=4)&(cyc_count<=39))?~clk_20k:0);
    assign sda=reg_sdat?1'bz:0;

	always@(posedge clk_20k or  negedge rst_100)
    begin
       if(!rst_100)
         cyc_count<=6'b111111;
       else 
		   begin
           if(i2c_req==0)
             cyc_count<=0;
           else if(cyc_count<6'b111111)
             cyc_count<=cyc_count+1;
         end
    end

    always@(posedge clk_20k or negedge rst_100)
    begin
		if(!rst_100)
		begin
			i2c_ack<=0;
			reg_clk<=1;
			reg_sdat<=1;
		end
       else
          case(cyc_count)
          0:begin i2c_ack<=0;reg_clk<=1;reg_sdat<=1;end
          1:reg_sdat<=0;                 //开始传输
          2:reg_clk<=0;
          3:reg_sdat<=cfg_data[31];
          4:reg_sdat<=cfg_data[30];
          5:reg_sdat<=cfg_data[29];
          6:reg_sdat<=cfg_data[28];
          7:reg_sdat<=cfg_data[27];
          8:reg_sdat<=cfg_data[26];
          9:reg_sdat<=cfg_data[25];
          10:reg_sdat<=cfg_data[24];
          11:reg_sdat<=1;                //应答信号
          12:begin reg_sdat<=cfg_data[23];end
          13:reg_sdat<=cfg_data[22];
          14:reg_sdat<=cfg_data[21];
          15:reg_sdat<=cfg_data[20];
          16:reg_sdat<=cfg_data[19];
          17:reg_sdat<=cfg_data[18];
          18:reg_sdat<=cfg_data[17];
          19:reg_sdat<=cfg_data[16];
          20:reg_sdat<=1;                //应答信号       
          21:begin reg_sdat<=cfg_data[15];end
          22:reg_sdat<=cfg_data[14];
          23:reg_sdat<=cfg_data[13];
          24:reg_sdat<=cfg_data[12];
          25:reg_sdat<=cfg_data[11];
          26:reg_sdat<=cfg_data[10];
          27:reg_sdat<=cfg_data[9];
          28:reg_sdat<=cfg_data[8];
          29:reg_sdat<=1;                //应答信号       
          30:begin reg_sdat<=cfg_data[7];end
          31:reg_sdat<=cfg_data[6];
          32:reg_sdat<=cfg_data[5];
          33:reg_sdat<=cfg_data[4];
          34:reg_sdat<=cfg_data[3];
          35:reg_sdat<=cfg_data[2];
          36:reg_sdat<=cfg_data[1];
          37:reg_sdat<=cfg_data[0];
          38:reg_sdat<=1;                //应答信号       
          39:begin reg_clk<=0;reg_sdat<=0;end
          40:reg_clk<=1;
          41:begin reg_sdat<=1;i2c_ack<=1;end
          endcase
	end	
	
	
endmodule
