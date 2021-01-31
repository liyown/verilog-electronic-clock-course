module mode_clock(
	input							clk   ,       // 时钟信号
	input							rst_n ,       // 复位信号
	
	input			[4:0]		   key,
	input			[3:0]			mode_set,
	input			[5:0]			mode_seg,
	input							set,
	
	input							flag,
	
	output		reg[23:0]	clock_data,
	output						flag_24h_clk
);

reg						flag_1s;
reg						flag_10s;
reg						flag_60s;
reg						flag_10m;
reg						flag_60m;
reg						flag_10h;
reg						flag_24h;
reg						set_clock;

reg						flag_10s_t0;
reg						flag_10s_t1;

reg						flag_60s_t0;
reg						flag_60s_t1;

reg						flag_10m_t0;
reg						flag_10m_t1;

reg						flag_60m_t0;
reg						flag_60m_t1;

reg						flag_10h_t0;
reg						flag_10h_t1;

reg						flag_24h_t0;
reg						flag_24h_t1;


wire						flag_10s_clk;
wire						flag_60s_clk;
wire						flag_10m_clk;
wire						flag_60m_clk;
wire						flag_10h_clk;




always@(posedge clk)
begin	
	flag_10s_t0 <= flag_10s;
	flag_10s_t1 <= flag_10s_t0;
	
	flag_60s_t0 <= flag_60s;
	flag_60s_t1 <= flag_60s_t0;

	flag_10m_t0 <= flag_10m;
	flag_10m_t1 <= flag_10m_t0;

	flag_60m_t0 <= flag_60m;
	flag_60m_t1 <= flag_60m_t0;
	
	flag_10h_t0 <= flag_10h;
	flag_10h_t1 <= flag_10h_t0;
	
	flag_24h_t0 <= flag_24h;
	flag_24h_t1 <= flag_24h_t0;
end

assign flag_10s_clk = ~flag_10s_t1&flag_10s_t0;
assign flag_60s_clk = ~flag_60s_t1&flag_60s_t0;
assign flag_10m_clk = ~flag_10m_t1&flag_10m_t0;
assign flag_60m_clk = ~flag_60m_t1&flag_60m_t0;
assign flag_10h_clk = ~flag_10h_t1&flag_10h_t0;
assign flag_24h_clk = ~flag_24h_t1&flag_24h_t0;


//000001
always @(posedge clk , negedge rst_n)
begin
	if(!rst_n)
	begin
		clock_data[3:0] <= 4'd0; 
	end
	else if(mode_set[0]&set)
	begin
		if(~mode_seg[0])
		begin
			if(key[2])
			begin
				if(clock_data[3:0] < 4'd9)
					clock_data[3:0] <= clock_data[3:0] + 1'b1;
				else
					clock_data[3:0] <= 4'd0;
			end
			else if(key[3])
			begin
				if(clock_data[3:0] > 4'd0)
					clock_data[3:0] <= clock_data[3:0] - 1'b1;
				else	
					clock_data[3:0] <= 4'd9;
			end
		end
	end
	else if(flag)
	begin
		if(clock_data[3:0] == 4'd9)
		begin
			flag_10s = 1'b1;
			clock_data[3:0] <= 4'd0;
		end
		else 
		begin
			clock_data[3:0] <= clock_data[3:0] + 1'd1;
			flag_10s = 1'b0;
		end
	end
	else
	begin
		flag_10s = 1'b0;
	end
end

//000010
always @(posedge clk , negedge rst_n)
begin
	if(!rst_n)
		clock_data[7:4] <= 4'd0;
	else if(mode_set[0]&set)
	begin
		if(~mode_seg[1])
		begin
			if(key[2])
			begin
				if(clock_data[7:4] < 4'd5)
					clock_data[7:4] <= clock_data[7:4] + 1'b1;
				else
					clock_data[7:4] <= 4'd0;
			end
			else if(key[3])
			begin
				if(clock_data[7:4] > 4'd0)
					clock_data[7:4] <= clock_data[7:4] - 1'b1;
				else	
					clock_data[7:4] <= 4'd5;
			end
		end
	end
	else if(flag_10s_clk)
	begin
		if(clock_data[7:4] == 4'd5)
		begin
			flag_60s = 1'b1;
			clock_data[7:4] <= 4'd0;
			
		end
		else 
		begin
			flag_60s = 1'b0;
			clock_data[7:4] <= clock_data[7:4] + 1'd1;
			
		end
	end
	else
	begin
		flag_60s = 1'b0;
	end
end

//000100
always @(posedge clk , negedge rst_n)
begin
	if(!rst_n)
		clock_data[11:8] <= 4'd0;
	else if(mode_set[0]&set)
	begin
		if(~mode_seg[2])
		begin
			if(key[2])
			begin
				if(clock_data[11:8] < 4'd9)
					clock_data[11:8] <= clock_data[11:8] + 1'b1;
				else
					clock_data[11:8] <= 4'd0;
			end
			else if(key[3])
			begin
				if(clock_data[11:8] > 4'd0)
					clock_data[11:8] <= clock_data[11:8] - 1'b1;
				else	
					clock_data[11:8] <= 4'd9;
			end
		end
	end
	else if(flag_60s_clk)
	begin
		if(clock_data[11:8] == 4'd9)
		begin
			clock_data[11:8] = 4'd0;
			flag_10m = 1'b1;
		end
		else 
		begin
			clock_data[11:8] <= clock_data[11:8] + 1'd1;
			flag_10m = 1'b0;
		end
	end
	else
	begin
		flag_10m = 1'b0;
	end
end

//001000
always @(posedge clk ,negedge rst_n)
begin
	if(!rst_n)
		clock_data[15:12] <= 4'd0;
	else if(mode_set[0]&set)
	begin
		if(~mode_seg[3])
		begin
			if(key[2])
			begin
				if(clock_data[15:12] < 4'd5)
					clock_data[15:12] <= clock_data[15:12] + 1'b1;
				else
					clock_data[15:12] <= 4'd0;
			end
			else if(key[3])
			begin
				if(clock_data[15:12] > 4'd0)
					clock_data[15:12] <= clock_data[15:12] - 1'b1;
				else	
					clock_data[15:12] <= 4'd5;
			end
		end
	end
	else if(flag_10m_clk)
	begin
		if(clock_data[15:12] == 4'd5)
		begin
			clock_data[15:12] <= 4'd0;
			flag_60m = 1'b1;
		end
		else 
		begin
			clock_data[15:12] <= clock_data[15:12] + 1'd1;
			flag_60m = 1'b0;
		end
	end
	else
	begin
		flag_60m = 1'b0;
	end
end
//010000
always @(posedge clk ,negedge rst_n)
begin
	if(!rst_n)
		clock_data[19:16] <= 4'd6;
	else if(mode_set[0]&set)
	begin
		if(~mode_seg[4])
		begin
			if(clock_data[23:20] == 4'd0 || clock_data[23:20] == 4'd1)
			begin
				if(key[2])
				begin
					if(clock_data[19:16] < 4'd9)
						clock_data[19:16] <= clock_data[19:16] + 1'b1;
					else 
						clock_data[19:16] <= 4'd0;
				end
				if(key[3])
				begin
					if(clock_data[19:16] > 4'd0)
						clock_data[19:16] <= clock_data[19:16] - 1'b1;
					else 
						clock_data[19:16] <= 4'd9;
				end
			end
			else if(clock_data[23:20] == 4'd2)
			begin
				if(key[2])
				begin
					if(clock_data[19:16] < 4'd3)
						clock_data[19:16] <= clock_data[19:16] + 1'b1;
					else 
						clock_data[19:16] <= 4'd0;
				end
				if(key[3])
				begin
					if(clock_data[19:16] > 4'd0)
						clock_data[19:16] <= clock_data[19:16] - 1'b1;
					else 
						clock_data[19:16] <= 4'd3;
				end
			end
		end
	end
	else if(flag_60m_clk)
	begin
		if(clock_data[23:20] == 4'd0||clock_data[23:20] == 4'd1)
		begin
			if(clock_data[19:16] == 4'd9)
			begin
				clock_data[19:16] <= 4'd0;
				flag_10h = 1'b1;
			end
			else 
			begin
				clock_data[19:16] <= clock_data[19:16] + 1'b1;
				flag_10h = 1'b0;
			end
		end
		else if(clock_data[23:20] == 4'd2)
		begin
			if(clock_data[19:16] == 4'd3)
			begin
				clock_data[19:16] <= 4'd0;
				flag_10h = 1'b1;
			end
			else 
			begin
				clock_data[19:16] <= clock_data[19:16] + 1'b1;
				flag_10h = 1'b0;
			end
		end
	end
	else
	begin
		flag_10h = 1'b0;
	end
end

//100000
always @(posedge clk ,negedge rst_n)
begin
	if(!rst_n)
		clock_data[23:20] <= 4'd0;
	else if(mode_set[0]&set)
	begin
		if(~mode_seg[5])
		begin
			if(clock_data[19:16] > 4'd3)
			begin
				if(key[2])
				begin
					if(clock_data[23:20] < 4'd1)
						clock_data[23:20]<= clock_data[23:20] +1'b1;
					else
						clock_data[23:20]<= 4'd0;
				end
				else if(key[3])
				begin
					if(clock_data[23:20] > 4'd0)
						clock_data[23:20]<= clock_data[23:20] - 1'b1;
					else
						clock_data[23:20]<= 4'd1;
				end
			end
			else if(clock_data[19:16] <= 4'd3)
			begin
				if(key[2])
				begin
					if(clock_data[23:20] < 4'd2)
						clock_data[23:20]<= clock_data[23:20] +1'b1;
					else
						clock_data[23:20]<= 4'd0;
				end
				else if(key[3])
				begin
					if(clock_data[23:20] > 4'd0)
						clock_data[23:20]<= clock_data[23:20] - 1'b1;
					else
						clock_data[23:20]<= 4'd2;
				end
			end			 
		end
	end
	else if(flag_10h_clk)
	begin
		if(clock_data[23:20] == 4'd2)
		begin
			clock_data[23:20] <= 4'd0;
			flag_24h = 1'b1;
		end
		else 
		begin
			clock_data[23:20] <= clock_data[23:20] + 1'd1;
			flag_24h = 1'b0;
		end
	end
	else
	begin
		flag_24h = 1'b0;
	end
end
endmodule
