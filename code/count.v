module count(
	// 时钟输入
	input 					clk  ,    // 时钟信号
	input 					rst_n,    // 复位信号
	input			[4:0]		key,
	
	
	//信号输出
	output 	reg			flag,				//1hz
	output 	reg			flag_001,		//100hz
	output	reg			flag_0001,		//1000hz
	output	reg			flag_10s			//0.1hz
);

// parameter define
parameter    MAX_NUM = 26'd50000_000;   // 计数器计数的最大值

// reg define 
reg	[25:0]	cnt;						    // 计数器，用于计时1s

//计数器对系统时钟计数达1s时，输出一个时钟周期的脉冲信号
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		cnt  <= 26'b0;
		flag <= 1'b0;
	end
	else if(cnt < MAX_NUM - 1'b1) begin
		cnt  <= cnt + 1'b1;
		flag <= 1'b0;
	end
	else begin
		cnt  <= 26'b0;
		flag <= 1'b1;
	end
end
//计数器对系统时钟计数达0.01s时，输出一个时钟周期的脉冲信号
reg [25:0]			cnt_001;
always@(posedge clk or negedge rst_n ) begin
	if(!rst_n) begin
		cnt_001  <= 26'b0;
		flag_001 <= 1'b0;
	end
	else if(cnt_001 < 26'd500000 - 1'b1) begin
		cnt_001  <= cnt_001 + 1'b1;
		flag_001 <= 1'b0;
	end
	else begin
		cnt_001  <= 26'b0;
		flag_001 <= 1'b1;
	end
end

//计数器对系统时钟计数达0.01s时，输出一个时钟周期的脉冲信号
reg [25:0]			cnt_0001;
always@(posedge clk or negedge rst_n ) begin
	if(!rst_n) begin
		cnt_0001  <= 26'b0;
		flag_0001 <= 1'b0;
	end
	else if(cnt_0001 < 26'd500 - 1'b1) begin
		cnt_0001  <= cnt_0001 + 1'b1;
		flag_0001 <= 1'b0;
	end
	else begin
		cnt_0001  <= 26'b0;
		flag_0001 <= 1'b1;
	end
end

//0.1hz
reg			[3:0]		cnt_10s;
always@(posedge clk or negedge rst_n ) begin
	if(!rst_n) begin
		cnt_10s  <= 4'd0;
		flag_10s <= 1'b0;
	end
	else if(|key)
		cnt_10s <= 4'd0;
	else 
	begin
		if(flag)
		begin
			if(cnt_10s == 4'd10)
			begin
				cnt_10s <= 4'd0;
				flag_10s <= 1'b1;
			end
			else
			begin
				cnt_10s <= cnt_10s + 1'b1;
				flag_10s <= 1'b0;
			end
		end
	end
end
endmodule
