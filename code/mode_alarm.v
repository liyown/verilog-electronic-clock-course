module mode_alarm(
	input							clk   ,       // 时钟信号
	input							rst_n ,       // 复位信号
	/******************控制信号输入*************/
	input			[4:0]		   key,
	input			[3:0]			mode_set,
	input			[5:0]			mode_seg,
	input							set,
	input			[7:0]			state,
	
	/***************时钟信号输入***************/
	input			[23:0]		clock_data,
	
	/***************闹钟数据输出显示************/
	output		reg[19:0]		alarm_data_1,
	output		reg[19:0]		alarm_data_2,
	output		reg[3:0]			alarm_data_mode,
	/***************闹钟数据闹铃控制************/
	output		[1:0]				alarm_up_clk

);

reg		[1:0]			alarm_make_t0	;
reg		[1:0]			alarm_make_t1	;
reg		[1:0]			alarm_make		;
always@(posedge clk)
begin
	alarm_make_t0[0] <= alarm_make[0]	;
	alarm_make_t1[0] <= alarm_make_t0[0];
	
	alarm_make_t0[1] <= alarm_make[1]	;
	alarm_make_t1[1] <= alarm_make_t0[1];
end

assign	alarm_up_clk[0] = ~alarm_make_t1[0]&alarm_make_t0[0];
assign	alarm_up_clk[1] = ~alarm_make_t1[1]&alarm_make_t0[1];


//闹铃判断
always@(posedge clk or negedge rst_n) 
begin
	if(!rst_n) 
	begin
		alarm_make[1:0] <= 2'b00;
	end
	else if(clock_data[23:0] == {alarm_data_1[15:0],8'd1}) //闹钟1判断
	begin
		if(alarm_data_1[19:16] == 4'd1)
		begin
			alarm_make[0] = 1'b1; 
		end
		else if(alarm_data_1[19:16] == 4'd2)
		begin
			alarm_make[1] = 1'b1; 
		end
	end
	else if(clock_data[23:0] == {alarm_data_2[15:0],8'd1}) // 闹钟2判断
	begin
		if(alarm_data_2[19:16] == 4'd1)
		begin
			alarm_make[0] = 1'b1; 
		end
		else if(alarm_data_2[19:16] == 4'd2)
		begin
			alarm_make[1] = 1'b1; 
		end
	end
	else
		alarm_make = 2'b00;
end


//设置闹钟和铃声
always @(posedge	clk,negedge rst_n)
begin
	if(!rst_n)
		alarm_data_mode[3:0] <= 4'd1;
	else if(mode_set == 4'b1000)
	begin
		if(key[2]&set)
		begin
			if(~mode_seg[0])
			begin
				if(alarm_data_mode[3:0] < 4'd2)
					alarm_data_mode[3:0] <= alarm_data_mode[3:0] + 1'd1;
				else
					alarm_data_mode[3:0]<=4'd1;
			end
		end
		if(key[3]&set)
		begin
			if(~mode_seg[0])
			begin
				if(alarm_data_mode[3:0] > 4'd1)
					alarm_data_mode[3:0] <= alarm_data_mode[3:0] - 1'd1;
				else
					alarm_data_mode[3:0]<=4'd2;
			end
		end		
	end
end


//设置闹钟1
always @(posedge	clk,negedge rst_n)
begin
	if(!rst_n)begin
		alarm_data_1[19:16] <= 4'd1;
		alarm_data_1[3:0]		<=4'd0;
		alarm_data_1[7:4]		<=4'd1;
		alarm_data_1[11:8]	<=4'd6;
		alarm_data_1[15:12]	<=4'd0;
	end
	else 
	begin
		if(mode_set[3]&set)
		begin
			if(key[2])
			begin
				if(alarm_data_mode[3:0] == 4'd1)
				begin
					if(~mode_seg[1])begin
						if(alarm_data_1[19:16] < 4'd2)
							alarm_data_1[19:16] <= alarm_data_1[19:16] +1'b1;
						else	
							alarm_data_1[19:16] <= 1'd0;
					end			
					else if(~mode_seg[2])begin
						if(alarm_data_1[3:0] < 4'd9)
							alarm_data_1[3:0] <= alarm_data_1[3:0] +1'b1;
						else	
							alarm_data_1[3:0] <= 1'd0;
					end
					else if(~mode_seg[3])begin
						if(alarm_data_1[7:4] < 3'd5)
							alarm_data_1[7:4] <= alarm_data_1[7:4] +1'b1;	
						else
							alarm_data_1[7:4] <= 1'd0;
					end
					else if(~mode_seg[4])begin
						if(alarm_data_1[11:8] < 2'd3)
							alarm_data_1[11:8] <= alarm_data_1[11:8] +1'b1;
						else	
							alarm_data_1[11:8] <= 1'd0;
					end
					else if(~mode_seg[5])begin
						if(alarm_data_1[15:12] < 2'd2)
							alarm_data_1[15:12] <= alarm_data_1[15:12] +1'b1;
						else
							alarm_data_1[15:12] <=1'd0;
					end
				end
			end
			else if(key[3])
			begin
				if(alarm_data_mode[3:0] == 4'd1)
				begin
					if(~mode_seg[1])begin
						if(alarm_data_1[19:16] > 1'd0)
							alarm_data_1[19:16] <= alarm_data_1[19:16] -1'b1;
						else	
							alarm_data_1[19:16] <= 4'd2;
					end
					else if(~mode_seg[2])begin
						if(alarm_data_1[3:0] > 1'd0)
							alarm_data_1[3:0] <= alarm_data_1[3:0] -1'b1;
						else	
							alarm_data_1[3:0] <= 4'd9;
					end
					else if(~mode_seg[3])begin
						if(alarm_data_1[7:4] > 1'd0)
							alarm_data_1[7:4] <= alarm_data_1[7:4] -1'b1;	
						else
							alarm_data_1[7:4] <= 3'd5;
					end
					else if(~mode_seg[4])begin
						if(alarm_data_1[11:8] > 1'd0)
							alarm_data_1[11:8] <= alarm_data_1[11:8] -1'b1;
						else	
							alarm_data_1[11:8] <= 2'd3;
					end
					else if(~mode_seg[5])begin
						if(alarm_data_1[15:12] > 1'd0)
							alarm_data_1[15:12] <= alarm_data_1[15:12]-1'b1;
						else
							alarm_data_1[15:12] <=2'd2;
					end
				end
			end
		end	
	end
end


//设置闹钟2
always @(posedge	clk,negedge rst_n)
begin
	if(!rst_n)begin
		alarm_data_2[19:16] <= 4'd0;
		alarm_data_2[3:0]		<=4'd5;
		alarm_data_2[7:4]		<=4'd1;
		alarm_data_2[11:8]	<=4'd6;
		alarm_data_2[15:12]	<=4'd0;
	end
	else 
	begin
		if(mode_set[3]&set)
		begin
			if(key[2])
			begin
				if(alarm_data_mode[3:0] == 4'd2)
				begin
					if(~mode_seg[1])begin
						if(alarm_data_2[19:16] < 4'd2)
							alarm_data_2[19:16] <= alarm_data_2[19:16] +1'b1;
						else	
							alarm_data_2[19:16] <= 1'd0;
					end			
					else if(~mode_seg[2])begin
						if(alarm_data_2[3:0] < 4'd9)
							alarm_data_2[3:0] <= alarm_data_2[3:0] +1'b1;
						else	
							alarm_data_2[3:0] <= 1'd0;
					end
					else if(~mode_seg[3])begin
						if(alarm_data_2[7:4] < 3'd5)
							alarm_data_2[7:4] <= alarm_data_2[7:4] +1'b1;	
						else
							alarm_data_2[7:4] <= 1'd0;
					end
					else if(~mode_seg[4])begin
						if(alarm_data_2[11:8] < 2'd3)
							alarm_data_2[11:8] <= alarm_data_2[11:8] +1'b1;
						else	
							alarm_data_2[11:8] <= 1'd0;
					end
					else if(~mode_seg[5])begin
						if(alarm_data_2[15:12] < 2'd2)
							alarm_data_2[15:12] <= alarm_data_2[15:12] +1'b1;
						else
							alarm_data_2[15:12] <=1'd0;
					end
				end
			end
			else if(key[3])
			begin
				if(alarm_data_mode[3:0] == 4'd2)
				begin
					if(~mode_seg[1])begin
						if(alarm_data_2[19:16] > 1'd0)
							alarm_data_2[19:16] <= alarm_data_2[19:16] -1'b1;
						else	
							alarm_data_2[19:16] <= 4'd2;
					end
					else if(~mode_seg[2])begin
						if(alarm_data_2[3:0] > 1'd0)
							alarm_data_2[3:0] <= alarm_data_2[3:0] -1'b1;
						else	
							alarm_data_2[3:0] <= 4'd9;
					end
					else if(~mode_seg[3])begin
						if(alarm_data_2[7:4] > 1'd0)
							alarm_data_2[7:4] <= alarm_data_2[7:4] -1'b1;	
						else
							alarm_data_2[7:4] <= 3'd5;
					end
					else if(~mode_seg[4])begin
						if(alarm_data_2[11:8] > 1'd0)
							alarm_data_2[11:8] <= alarm_data_2[11:8] -1'b1;
						else	
							alarm_data_2[11:8] <= 2'd3;
					end
					else if(~mode_seg[5])begin
						if(alarm_data_2[15:12] > 1'd0)
							alarm_data_2[15:12] <= alarm_data_2[15:12]-1'b1;
						else
							alarm_data_2[15:12] <=2'd2;
					end
				end
			end
		end	
	end
end





endmodule
