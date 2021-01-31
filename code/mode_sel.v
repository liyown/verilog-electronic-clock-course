module mode_sel(
	input							clk   ,       // 时钟信号
	input							rst_n ,       // 复位信号

	input 		[4:0]			key   ,
	input							flag_10s,
	
	output   reg   [3:0] 	mode_set,		// 模式选择
	output	reg				set,				//设置模式控制
	
	output	reg				flag_s,			//闪烁信号
	output	reg[5:0]			mode_seg			//闪烁信号控制
	
);


//模式选择
always @(posedge clk,negedge rst_n)
begin
	if(!rst_n)
	begin 
		mode_set <= 4'b0001;		//默认时钟模式
	end
	else if(flag_10s)
		mode_set <= 4'b0001;
	else if(key[4] == 1'b1 & set == 1'b0) 
	begin
		if(mode_set == 4'b1000)
			mode_set <= 4'b0001;
		else
			mode_set <= mode_set<<1;
	end
	else 
		mode_set <= mode_set;
end
always @(posedge clk,negedge rst_n)
begin
	if(!rst_n)
		set <= 1'b0;	//默认不闪烁	
	else if(key[0] == 1'b1)
	begin
		if(mode_set[2])
			set = 1'b0;
		else
			set = ~set;
	end
end



/******************数码管控制*************/

//数码管调整闪烁


reg				set_t0;
reg				set_t1;

wire				set_clk;

always@(posedge clk)
begin
	set_t0 <= set;
	set_t1 <= set_t0;
end

assign set_clk =  ~set_t1&set_t0;

always@(posedge clk,negedge rst_n)
begin
	if(!rst_n)
	begin
		mode_seg <= 6'b111110;
	end
	else if(set_clk)
	begin
		if(mode_set == 4'b0010)
			mode_seg <= 6'b111100;
		else
			mode_seg <= 6'b111110;
	end
	else if(set)
	begin
		if(mode_set == 4'b0010)
		begin
			if(key[1])
			begin	
				if(mode_seg == 6'b001111)
					mode_seg <= 6'b111100;
				else 
					mode_seg <= (mode_seg  << 2)|6'b000011;
			end
		end
		else
		begin
			if(key[1])
			begin	
				if(mode_seg == 6'b011111)
					mode_seg <= 6'b111110;
				else 
					mode_seg <= (mode_seg  << 1)|6'b000001;
			end
		end
	end
	else
		mode_seg <= 6'b111110;	
end


reg [25:0]		pwm_seg;
always@(posedge clk or negedge rst_n) 
begin
	if(!rst_n) 
	begin
		pwm_seg <= 26'd0;
		flag_s <= 1'b1;
	end
	else if(set == 1'b1)
	begin
		if(pwm_seg <=26'd20_000000) 
		begin
			pwm_seg <= pwm_seg + 1'd1;
			flag_s <= 1'b1;
		end
		else if(26'd20_000000 < pwm_seg <= 26'd30_000000)
		begin
			pwm_seg <= pwm_seg + 1'd1;
			flag_s <= 1'b0;
		end
		else if(26'd30_000000 < pwm_seg < 26'd50_000000)
		begin
			pwm_seg <= pwm_seg + 1'd1;
			flag_s <= 1'b1;
		end
		else begin
			pwm_seg <= 26'd0;	
			flag_s <= 1'b0;
		end
	end
	else if(set == 1'b0) 
	begin
		flag_s <= 1'b1;
	end
end
endmodule




