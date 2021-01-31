module seg_led(
	input							clk   ,       // 时钟信号
	input							rst_n ,       // 复位信号
	
	/*************控制信号****************/
	input			[5:0]					mode_seg,
	input			[3:0]					mode_set,
	input									flag_s,

	/*************时钟数据****************/
	input			[23:0]				clock_data,  			// 时钟数据

	/*************秒表数据****************/
	input			[23:0]				watch_data,
	
	/*************日期数据****************/
	input			[23:0]				date_data,
	
	/*************闹钟数据****************/
	input			[19:0]		alarm_data_1,
	input			[19:0]		alarm_data_2,
	input			[3:0]			alarm_data_mode,
	
	/*************数码管输出引脚**********/
	output		reg[5:0]			seg_sel,		//数码管位选
	output		reg[7:0]			seg_led,		//数码管段选
	output		reg[3:0]			led
	
);

// parameter define
localparam	MAX_NUM	  = 23'd5000;   //对数码管驱动时钟
// reg define
reg		[3:0]					clk_cnt;      // 时钟分频计数器
reg		[22:0]				cnt0;
reg		[23:0]				num;			  // 24位bcd码寄存器
reg								flag;			  // 标志信号（标志着cnt0计数达到1s）
reg		[2:0]					cnt_sel;		  // 数码管位选计数器
reg      [3:0]             num_disp;	  // 当前数码管显示的数据
reg								dot_disp;     // 当前数码管显示的小数点

//将20位2进制数转换为8421bcd码(即使用4位二进制数表示1位十进制数）
always@(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		num <= 24'b0;
	end
	else if(mode_set == 4'b0001)
	begin
		led <= 4'b0001;
		num[23:20] <= clock_data[23:20];
		num[19:16] <= clock_data[19:16];
		num[15:12] <= clock_data[15:12];
		num[11:8]  <= clock_data[11:8];
		num[7:4]   <= clock_data[7:4];
		num[3:0]   <= clock_data[3:0];
	end
	else if(mode_set == 4'b0010)
	begin
		led <= 4'b0010;
		num[23:20] <= date_data[23:16]/8'd10;
		num[19:16] <= date_data[23:16]%8'd10;
		num[15:12] <= date_data[15:8]/8'd10;
		num[11:8]  <= date_data[15:8]%8'd10;
		num[7:4]   <= date_data[7:0]/8'd10;
		num[3:0]   <= date_data[7:0]%8'd10;
	end
	else if(mode_set == 4'b0100)
	begin
		led <= 4'b0100;
		num[23:20] <= watch_data[23:20];
		num[19:16] <= watch_data[19:16];
		num[15:12] <= watch_data[15:12];
		num[11:8]  <= watch_data[11:8];
		num[7:4]   <= watch_data[7:4];
		num[3:0]   <= watch_data[3:0];
	end
	else if(mode_set == 4'b1000)
	begin
		led <= 4'b1000;
		if(alarm_data_mode[3:0] == 4'd1)
		begin
			num[23:20] <= alarm_data_1[15:12];
			num[19:16] <= alarm_data_1[11:8];
			num[15:12] <= alarm_data_1[7:4];
			num[11:8]  <= alarm_data_1[3:0];
			num[7:4]   <= alarm_data_1[19:16];
			num[3:0]   <= alarm_data_mode[3:0];
		end
		if(alarm_data_mode[3:0] == 4'd2)
		begin
			num[23:20] <= alarm_data_2[15:12];
			num[19:16] <= alarm_data_2[11:8];
			num[15:12] <= alarm_data_2[7:4];
			num[11:8]  <= alarm_data_2[3:0];
			num[7:4]   <= alarm_data_2[19:16];
			num[3:0]   <= alarm_data_mode[3:0];
		end
	end
end

//每当计数器对数码管驱动时钟计数时间达1s，输出一个时钟周期的脉冲信号
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		cnt0 <= 23'b0;
		flag <= 1'b0;
	end
	else if(cnt0 < MAX_NUM - 1'b1) begin
		cnt0 <= cnt0 + 1'b1;
		flag <= 1'b0;
	end
	else begin
		cnt0 <= 23'b0;
		flag <= 1'b1;
	end
end

//对系统时钟10分频，得到的频率为5MHz的数码管驱动时钟dri_clk
reg 				dri_clk;
always @(posedge clk or negedge rst_n) begin
   if(!rst_n) begin
       clk_cnt <= 4'd0;
       dri_clk <= 1'b1;
   end
   else if(clk_cnt == 4'b10/2 - 1'd1) begin
       clk_cnt <= 4'd0;
       dri_clk <= ~dri_clk;
   end
   else begin
       clk_cnt <= clk_cnt + 1'b1;
       dri_clk <= dri_clk;
   end
end

//cnt_sel从0计数到5，用于选择当前处于显示状态的数码管
always @ (posedge dri_clk or negedge rst_n) begin
    if (rst_n == 1'b0)
        cnt_sel <= 3'b0;
    else if(flag) begin
        if(cnt_sel < 3'd5)
            cnt_sel <= cnt_sel + 1'b1;
        else
            cnt_sel <= 3'b0;
    end
    else
        cnt_sel <= cnt_sel;
end


//控制数码管位选信号，使6位数码管轮流显示
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n) 
	begin
		seg_sel  <= 6'b111111;           // 位选信号低电平有效
		num_disp <= 4'b0; 
		dot_disp <= 1'b1;                // 共阳极数码管，低电平导通
	end
	else 
	begin
		case (cnt_sel)
			3'd0 :begin
				if(flag_s||mode_seg[0])
				begin
					seg_sel  <= 6'b111110;   //显示数码管最低位
					num_disp <= num[3:0];   // 显示的数据
					dot_disp <= 1'b1;
				end
				else seg_sel  <= 6'b111111;
			end
			3'd1 :begin
				if(flag_s||mode_seg[1])
				begin
					seg_sel  <= 6'b111101;  //显示数码管第二位
					num_disp <= num[7:4];   // 显示的数据
					dot_disp <= 1'b1;
				end
				else seg_sel  <= 6'b111111;
			end
			3'd2 :begin
				if(flag_s||mode_seg[2])
				begin
					seg_sel  <= 6'b111011;  //显示数码管第三位
					num_disp <= num[11:8];   // 显示的数据
					dot_disp <= 1'b0;
				end
				else
				begin
					seg_sel  <= 6'b111011;
					num_disp <= 8'd10;
					dot_disp <= 1'b0;
				end
			end
			3'd3 :begin
				if(flag_s||mode_seg[3])
				begin
					seg_sel  <= 6'b110111;  //显示数码管第四位
					num_disp <= num[15:12];   // 显示的数据
					dot_disp <= 1'b1;
				end
				else seg_sel  <= 6'b111111;
			end
			3'd4 :begin
				if(flag_s||mode_seg[4])
				begin
					seg_sel  <= 6'b101111;  //显示数码管第五位
					num_disp <= num[19:16];   // 显示的数据
					dot_disp <= 1'b0;
				end
				else
				begin
					seg_sel  <= 6'b101111;
					num_disp <= 8'd10;
					dot_disp <= 1'b0;
				end
			end
			3'd5 :begin
				if(flag_s||mode_seg[5])
				begin
					seg_sel  <= 6'b011111;  //显示数码管第六位
					num_disp <= num[23:20];   // 显示的数据
					dot_disp <= 1'b1;
				end 
				else seg_sel  <= 6'b111111;
			end
			default :begin
			  seg_sel  <= 6'b111111;
			  num_disp <= 4'b0;
			  dot_disp <= 1'b1;
			end
		endcase
	end
end

//控制数码管段选信号，显示字符
always @ (posedge clk or negedge rst_n) begin
    if (!rst_n)begin
        seg_led <= 8'hc0;
	 end 
    else begin
        case (num_disp)
            4'd0 : seg_led <= {dot_disp,7'b1000000}; //显示数字 0
            4'd1 : seg_led <= {dot_disp,7'b1111001}; //显示数字 1
            4'd2 : seg_led <= {dot_disp,7'b0100100}; //显示数字 2
            4'd3 : seg_led <= {dot_disp,7'b0110000}; //显示数字 3
            4'd4 : seg_led <= {dot_disp,7'b0011001}; //显示数字 4
            4'd5 : seg_led <= {dot_disp,7'b0010010}; //显示数字 5
            4'd6 : seg_led <= {dot_disp,7'b0000010}; //显示数字 6
            4'd7 : seg_led <= {dot_disp,7'b1111000}; //显示数字 7
            4'd8 : seg_led <= {dot_disp,7'b0000000}; //显示数字 8
            4'd9 : seg_led <= {dot_disp,7'b0010000}; //显示数字 9
				4'd10: seg_led <= {dot_disp,7'b1111111}; //显示数字 9
            default: 
						 seg_led <= {dot_disp,7'b1000000};
        endcase
    end
end
endmodule


        					