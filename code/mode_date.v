module mode_date(
	input							clk   ,       // 鏃堕挓淇″彿
	input							rst_n ,       // 澶嶄綅淇″彿
	
	input			[4:0]		   key,
	input			[3:0]			mode_set,
	input			[5:0]			mode_seg,
	input							set,
	
	
	input							flag_24h_clk,
	output		reg[23:0]	date_data
);


reg								flag_d;
reg								flag_m;


reg								flag_d_t0;
reg								flag_d_t1;

reg								flag_m_t0;
reg								flag_m_t1;

wire								flag_d_clk;
wire								flag_m_clk;

always@(posedge clk)
begin
	flag_d_t0 <= flag_d;
	flag_d_t1 <= flag_d_t0;	

	flag_m_t0 <= flag_m;
	flag_m_t1 <= flag_m_t0;
end

assign  flag_d_clk = ~flag_d_t1&flag_d_t0;
assign  flag_m_clk = ~flag_m_t1&flag_m_t0;

always @(posedge clk,negedge rst_n)
begin
	if(!rst_n)
		date_data[7:0] <= 8'd22;
	else if(mode_set[1]&set)
	begin
		if(mode_seg == 6'b111100)
		begin
			if(date_data[15:8] == 8'd1 ||
				date_data[15:8] == 8'd3 ||
				date_data[15:8] == 8'd5 ||
				date_data[15:8] == 8'd7 ||
				date_data[15:8] == 8'd8 ||
				date_data[15:8] == 8'd10||
				date_data[15:8] == 8'd12
			)
			begin
				if(key[2])
				begin
					if(date_data[7:0] < 8'd31)
						date_data[7:0]<= date_data[7:0] + 1'b1;
					else	
						date_data[7:0] <= 8'd0;
				end
				else if(key[3])
				begin
					if(date_data[7:0] > 8'd0)
						date_data[7:0] <= date_data[7:0] -1'b1;
					else
						date_data[7:0] <= 8'd31;
				end
			end
			else if(date_data[15:8] == 8'd4 ||
					  date_data[15:8] == 8'd6 ||
					  date_data[15:8] == 8'd9 ||
					  date_data[15:8] == 8'd11
			)
			begin
				if(key[2])
				begin
					if(date_data[7:0] < 8'd30)
						date_data[7:0]<= date_data[7:0] + 1'b1;
					else	
						date_data[7:0] <= 8'd0;
				end
				else if(key[3])
				begin
					if(date_data[7:0] > 8'd0)
						date_data[7:0] <= date_data[7:0] -1'b1;
					else
						date_data[7:0] <= 8'd30;
				end
			end
			else if(date_data[15:8] == 8'd2)
			begin
				if(key[2])
				begin
					if(date_data[7:0] < 8'd28)
						date_data[7:0]<= date_data[7:0] + 1'b1;
					else	
						date_data[7:0] <= 8'd0;
				end
				else if(key[3])
				begin
					if(date_data[7:0] > 8'd0)
						date_data[7:0] <= date_data[7:0] -1'b1;
					else
						date_data[7:0] <= 8'd28;
				end
			end
		end
	end
	
	else if(flag_24h_clk)
	begin
		if(date_data[15:8] == 8'd1 ||
			date_data[15:8] == 8'd3 ||
			date_data[15:8] == 8'd5 ||
			date_data[15:8] == 8'd7 ||
			date_data[15:8] == 8'd8 ||
			date_data[15:8] == 8'd10||
			date_data[15:8] == 8'd12
		)
		begin
			if(date_data[7:0] == 8'd31)
			begin
				date_data[7:0] <= 8'd0;
				flag_d <= 1'b1;
			end
			else
			begin
				date_data[7:0] <= date_data[7:0] + 1'b1;
				flag_d <= 1'b0;
			end
		end	
		else if(date_data[15:8] == 8'd4 ||
				  date_data[15:8] == 8'd6 ||
				  date_data[15:8] == 8'd9 ||
				  date_data[15:8] == 8'd11
		)
		begin
			if(date_data[7:0] == 8'd30)
			begin
				date_data[7:0] <= 8'd0;
				flag_d <= 1'b1;
			end
			else
			begin
				date_data[7:0] <= date_data[7:0] + 1'b1;
				flag_d <= 1'b0;
			end
		end
		else if(date_data[15:8] == 8'd2
		)
		begin
			if(date_data[7:0] == 8'd28)
			begin
				date_data[7:0] <= 8'd0;
				flag_d <= 1'b1;
			end
			else
			begin
				date_data[7:0] <= date_data[7:0] + 1'b1;
				flag_d <= 1'b0;
			end
		end
	end
end

always @(posedge clk , negedge rst_n)
begin
	if(!rst_n)
	begin
		date_data[15:8] <= 8'd1; 
	end
	else if(mode_set[1]&set)
	begin
		if(mode_seg == 6'b110011)
		begin
			if(key[2])
			begin
				if(date_data[15:8] < 8'd12)
					date_data[15:8] <= date_data[15:8] + 1'b1;
				else
					date_data[15:8] <= 8'd1;
			end
			else if(key[3])
			begin
				if(date_data[15:8] > 8'd1 )
					date_data[15:8] <= date_data[15:8] - 1'b1;
				else
					date_data[15:8] <= 8'd12;
			end
		end
	end
	else if(flag_d_clk)
	begin
		if(date_data[15:8] == 8'd12)
		begin
			date_data[15:8] <= 8'd0;
			flag_m           <= 1'b1;
		end
		else
		begin	
			date_data[15:8] <= date_data[15:8]+1'b1;
			flag_m           <= 1'b0;	
		end
	end
end

always @(posedge clk , negedge rst_n)
begin
	if(!rst_n)
	begin
		date_data[23:16] <= 8'd21; 
	end
	else if(mode_set[1]&set)
	begin
		if(mode_seg == 6'b001111)
		begin
			if(key[2])
			begin
				if(date_data[23:16] < 8'd99)
					date_data[23:16] <= date_data[23:16] + 1'b1;
				else
					date_data[23:16] <= 8'd0;
			end
			else if(key[3])
			begin
				if(date_data[23:16] > 8'd0 )
					date_data[23:16] <= date_data[23:16] - 1'b1;
				else
					date_data[23:16] <= 8'd99;
			end
		end
	end
	else if(flag_m_clk)
	begin
		if(date_data[23:16] == 8'd99)
		begin
			date_data[23:16] <= 8'd0;
		end
		else
		begin	
			date_data[23:16] <= date_data[23:16]+1'b1;
		end
	end
end
endmodule
