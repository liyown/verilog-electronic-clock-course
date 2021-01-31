module top(
    //全局时钟
    input            sys_clk  ,       // 全局时钟信号
    input            sys_rst_n,       // 复位信号（低有效）
	 input	[4:0]		key_in,

    //数码管输出
    output    [5:0]  seg_sel  ,       // 数码管位选信号
    output    [7:0]  seg_led 	,       // 数码管段选信号
	 output	  [3:0]	led		,
	 output				beer
);

//wire define
wire    [23:0]  clock_data;                 // 时钟数据线路
wire		[4:0]   key;									//按键总线
wire    [3:0]   mode_set;							//模式总线
wire    [5:0]   mode_seg;							//位选总线
wire				 set;
														//设置模式切换
wire				 flag;
wire				 flag_s;
wire				 flag_001;
wire				 flag_0001;
wire				 flag_10s;
wire				 flag_24h_clk;

wire	  [23:0]	 date_data;							//日期数据
wire	  [23:0]	 watch_data;						//秒表数据
wire	  [19:0]	 alarm_data_1;
wire	  [19:0]	 alarm_data_2;
wire	  [3:0]	 alarm_data_mode;
wire	  [1:0]	 alarm_up_clk;


key_scan u_key_scan(
		.clk			(sys_clk),
		.rst_n		(sys_rst_n),
		
		
		.key_in		(key_in),				//按键输入
		.key_out		(key)	   		   	//按键输出
);
//计数模块
count u_count(
		.clk			(sys_clk),
		.rst_n		(sys_rst_n),
		.key			(key),//
		
		

		.flag			(flag),					//1hz输出
		.flag_001 	(flag_001),				//100hz输出
		.flag_0001	(flag_0001),			//1000hz输出
		.flag_10s	(flag_10s)				//0.1hz输出
);
//时钟模块
mode_clock u_clock(
		.clk			(sys_clk),
		.rst_n		(sys_rst_n),

		.key			(key),				//设置输入
		.mode_set	(mode_set),			//模式输入
		.mode_seg	(mode_seg),			//位置设置输入
		.set			(set),				//	设置信号输出
		
		
		.flag_24h_clk		(flag_24h_clk),//一天信号输出
		.flag					(flag),		//1hz输入
		.clock_data			(clock_data)	//时钟信号输出
);

//日期模块
mode_date u_date(
		.clk				(sys_clk),
		.rst_n			(sys_rst_n),
			
		.key				(key),				//设置输入
		.mode_set		(mode_set),			//模式输入
		.mode_seg		(mode_seg),			//位置设置输入
		.set				(set),				//	设置信号输出
			
		.flag_24h_clk	(flag_24h_clk),
		.date_data		(date_data)			//日期信号输出
);
//秒表模块
mode_watch u_watch(
		.clk				(sys_clk),
		.rst_n			(sys_rst_n),

		.key				(key),				//设置输入
		.mode_set		(mode_set),			//模式输入
		.mode_seg		(mode_seg),			//位置设置输入

		.flag_001		(flag_001),			//100hz输入
		.watch_data		(watch_data)		//秒表数据输出
);
//闹钟模块
mode_alarm uu_alarm(
		.clk			(sys_clk),
		.rst_n		(sys_rst_n),

		.key			(key),				//设置输入
		.mode_set	(mode_set),			//模式输入
		.mode_seg	(mode_seg),			//位置设置输入
		.set			(set),				//设置信号输入
		
		.clock_data	(clock_data),//			时钟信号输入
		
		
		.alarm_data_1			(alarm_data_1),	//闹钟1数据输出
		.alarm_data_2			(alarm_data_2),	//闹钟2数据输出
		.alarm_data_mode		(alarm_data_mode),//闹钟选择输出
		.alarm_up_clk			(alarm_up_clk)	//	闹钟信号输出
);
//闹铃模块
alarm  alarm_music(
		.clk				(sys_clk),
		.rst_n			(sys_rst_n),
		.key				(key),					//按键输入
		.clock_data		(clock_data),
		.alarm_up_clk	(alarm_up_clk),		//闹钟信号输入
		.beer				(beer)//蜂鸣器输出
);


//数码显示
seg_led u_seg_led(
		.clk			(sys_clk),
		.rst_n		(sys_rst_n),
		
		.mode_seg	(mode_seg),	//闪烁位置输入
		.flag_s		(flag_s),	//闪烁控制输入
		.mode_set	(mode_set), //模式选择输入		
		
		
		.seg_sel		(seg_sel),	//位选电平输出
		.seg_led		(seg_led),	//段选电平输出
		.led			(led),

		
		
		.clock_data			(clock_data),		//时钟数据输入
		.date_data			(date_data),		//日期数据输入
		.watch_data			(watch_data),		//时钟信号输入
		
		.alarm_data_1		(alarm_data_1),	//闹钟1数据输入
		.alarm_data_2		(alarm_data_2),	//闹钟2数据输入
		.alarm_data_mode	(alarm_data_mode)	//闹钟选择输入
);
//模式切换
mode_sel u_mode(
		.clk			(sys_clk),
		.rst_n		(sys_rst_n),
		
		.key			(key),			//按键输入
		.flag_10s	(flag_10s),		
		
		.mode_set	(mode_set),		//模式输出
		.set			(set),			//设置输出
		.flag_s		(flag_s),		//闪烁控制输出
		.mode_seg	(mode_seg)		//闪烁位置输出
);

endmodule
