module alarm(	
			input						clk 	,
			input						rst_n	,
			input		[4:0]			key	,
			
			input		[1:0]			alarm_up_clk,
			input		[23:0]		clock_data,
					
			output					beer
			
);
/**********************音乐模块*******************/
localparam 	L_1=17'd95420,
				L_2=17'd85324,
				L_3=17'd75987,
				L_4=17'd71633,
				L_5=17'd63775,
				L_6=17'd56818,
				L_7=17'd50607,
				
				M_1=17'd47801,
				M_2=17'd42662,
				M_3=17'd37993,
				M_4=17'd35868,
				M_5=17'd31928,
				M_6=17'd28441,
				M_7=17'd25329,
				
				H_1=17'd23923,
				H_2=17'd21349,
				H_3=17'd18996,
				H_4=17'd17946,
				H_5=17'd15994,
				H_6=17'd14245,
				H_7=17'd12683,
				
				O	 =17'd0	 ;
//------------------------------------- 闹钟使能逻辑 ---------------------------------------------------------------------------------------
 reg flag_en_1,flag_en_2,flag_en_key;
 reg	[24:0]	state_key	;
 reg	 [7:0] 	state			;
 reg	[3:0]	clock_data_t;
 reg	flag_en_1_re,flag_en_2_re;
 always@(posedge clk, negedge rst_n) begin
	  if(!rst_n)
	  begin
			flag_en_1 <= 1'b0;
			flag_en_2 <= 1'b0;
			flag_en_key <= 1'b0;
	  end
	  else if(alarm_up_clk[0])  //闹钟1时间到
			flag_en_1 <= 1'b1;
	  else if(alarm_up_clk[1])  //闹钟2时间到
			flag_en_2 <= 1'b1;
	  else if(key)
	  begin
			  flag_en_key <= 1'b1;
			  if(key[2]&(flag_en_1|flag_en_2))
			  begin
					 flag_en_1 <= 1'b0;
					 flag_en_2 <= 1'b0;
					 flag_en_1_re <= 1'b0;
					 flag_en_2_re <= 1'b0;
					 clock_data_t <= 4'd0;
			  end
			  else if(key[3]&flag_en_1 == 1'b1)
			  begin
					flag_en_1 <= 1'b0;
					flag_en_1_re <= 1'b1;
					clock_data_t <= clock_data[11:8];
			  end
			  else if(key[3]&flag_en_2 == 1'b1)
			  begin
					flag_en_2 <= 1'b0;
					flag_en_2_re <= 1'b1;
					clock_data_t <= clock_data[11:8];
			  end
	  end
	  else if((clock_data[11:8] - clock_data_t == 4'd5||clock_data_t - clock_data[11:8]==4'd5)&flag_en_1_re == 1'b1)
	  begin
			flag_en_1 <= 1'b1;
	  end
	  else if((clock_data[11:8] - clock_data_t == 4'd5||clock_data_t - clock_data[11:8]==4'd5)&flag_en_2_re == 1'b1)
	  begin
			flag_en_2 <= 1'b1;
	  end
	  else if(flag_en_1&flag_en_2)
		begin
				flag_en_2 <= 1'b0;
				flag_en_1 <= 1'b1;
		end
	  else if(state_key == 25'd6999999)
			flag_en_key <= 1'b0;
	  else
	  begin
			clock_data_t <= clock_data_t;
			flag_en_key <= flag_en_key;
			flag_en_1 <= flag_en_1;
			flag_en_2 <= flag_en_2;
	  end
 end 


//------------------------------------ 音乐 ---------------------------------------------------------------------------------
 reg beep_r;    
 reg [16:0] count, pitch;			//音高
 reg [23:0] count1;					//音长


reg	[26:0] TIME;  //每个音的长短（250ms）     
 assign beer = beep_r;
 
 
 always@(posedge clk, negedge rst_n) begin
	  if(!rst_n) begin
			count <= 17'h0;
			beep_r <= 1'b0;
	  end 
	  else if(flag_en_1|flag_en_2) begin
			count <= count + 1'b1;
			if(count == pitch) begin
				 count <= 17'h0;
				 beep_r <= !beep_r;
			end 
	  end
	  else if(flag_en_key)
	  begin
			state_key <= state_key + 1'b1;
			begin
				count <= count +1'b1;
				if(count == M_3)
				begin	
					 count <= 17'h0;
					 beep_r <= !beep_r;
				end
		   end
			if(state_key == 25'd6999999)
				state_key <= 25'd0;
	  end
	  else begin
			count <= 17'h0;
			beep_r <= 1'b0;            
	  end 
 end 
 
 always@(posedge clk, negedge rst_n) begin
	  if(!rst_n) begin
			count1 <= 24'd0;
			state <= 8'd0;
	  end
	  else if(flag_en_1|flag_en_2) begin
			if(count1 < TIME) 
				 count1 <= count1 + 1'b1;
			else begin
				 count1 <= 24'd0;
				 if(state == 8'd65)
					  state <= 8'd0;
				 else
					  state <= state + 1'b1;        
			end         
	  end 
	  else begin
			count1 <= 24'd0;
			state <= 8'd0;
	  end            
 end 
 
 always@(posedge	clk) 
 begin
	 if(flag_en_1)
	 begin
		  TIME <= 26'd12000000;
		  case(state)
				8'd0		:	pitch =M_1;
				8'd1		:	pitch =H_1;
				8'd2		:	pitch =M_7;
				8'd3		:	pitch =M_5;
				8'd4		:	pitch =M_2;
				8'd5		:	pitch =M_2;
				8'd6		:	pitch =M_2;
				8'd7		:	pitch =M_3;
				8'd8		:	pitch =M_3;
				8'd9		:	pitch =M_3;
				//你不是真正的快乐
				8'd10		:	pitch =	O;
				8'd11		:	pitch =M_1;
				8'd12		:	pitch =H_1;
				8'd13		:	pitch =M_7;
				8'd14		:	pitch =M_5;
				8'd15		:	pitch =M_2;
				8'd16		:	pitch =M_2;
				8'd17		:	pitch =M_2;
				8'd18		:	pitch =M_2;
				8'd19		:	pitch =M_1;
				8'd20		:	pitch =M_2;
				8'd21		:	pitch =M_5;
				8'd22		:	pitch =M_5;
				8'd23		:	pitch =M_3;
				8'd24		:	pitch =M_3;
				8'd25		:	pitch =M_3;
				//你的笑只是你穿的保护色
				8'd26		:	pitch =O;	
				8'd27		:	pitch =L_6;
				8'd28		:	pitch =L_6;
				8'd29		:	pitch =L_7;
				8'd30		:	pitch =M_1;
				8'd31		:	pitch =M_3;
				8'd32		:	pitch =M_6;
				8'd33		:	pitch =M_6;
				//你决定不恨了
				8'd34		:	pitch =O;
				8'd35		:	pitch =L_6;
				8'd36 	:	pitch =L_6;
				8'd37		:	pitch =L_7;
				8'd38		:	pitch =M_1;
				8'd39		:	pitch =M_3;
				8'd40		:	pitch =M_5;
				8'd41		:	pitch =M_5; 
				//也决定不爱了
				8'd42		:	pitch =O;
				8'd43		:	pitch =L_5;
				8'd44		:	pitch =L_6;
				8'd45		:	pitch =L_7;
				8'd46		:	pitch =M_1;
				8'd47		:	pitch =M_3;
				8'd48		:	pitch =M_6;
				8'd49		:	pitch =M_5;
				8'd50		:	pitch =M_6;
				8'd51 	:	pitch =M_7;
				8'd52		:	pitch =H_1;
				8'd53		:	pitch =M_7;
				8'd54		:	pitch =H_1;
				8'd55		:	pitch =H_2;
				8'd56		:	pitch =M_7;	
				8'd57		:	pitch =M_7;
				8'd58		:	pitch =M_7;
				8'd59		:	pitch = O ;
				default	:	pitch = 17'hxxxxx; 
		  endcase
	 end
	 else if(flag_en_2)
	 begin
		  TIME <= 26'd9000000;
		  case(state)
				// 第一段
				8'd0		: pitch = H_1;
				8'd1		: pitch = H_1;
				8'd2		: pitch = O;
				8'd3		: pitch = H_1;
				8'd4		: pitch = H_1;
				8'd5		: pitch = O;
				8'd6		: pitch = H_1;		  
				8'd7		: pitch = H_1;	
				8'd8		: pitch = O;	
				8'd9		: pitch = M_3;					
				8'd10		: pitch = M_4;					
				8'd11		: pitch = M_5;					
				8'd12		: pitch = M_6;
				8'd13		: pitch = M_5;				
				8'd14		: pitch = M_3;
				8'd15		: pitch = M_5;
				8'd16		: pitch = M_5;
				8'd17	   : pitch = H_1;
				8'd18    : pitch = H_2;
				// 第二段
				8'd19    : pitch = H_3;
				8'd20    : pitch = H_3;
				8'd21    : pitch = H_3;
				8'd22    : pitch = H_3;
				8'd23    : pitch = H_3;
				8'd24    : pitch = H_3;
				8'd25 	: pitch = H_1;
				8'd26 	: pitch = H_2;
				8'd27 	: pitch = H_3;
				8'd28 	: pitch = H_2;
				8'd29 	: pitch = H_2;
				8'd30 	: pitch = H_1;
				8'd31 	: pitch = H_2;
				8'd32 	: pitch = H_2;
				8'd33 	: pitch = H_3;
				8'd34 	: pitch = H_2;
				// 第三段
				8'd35		: pitch = H_1;
				8'd36		: pitch = H_1;
				8'd37		: pitch = H_1;
				8'd38		: pitch = H_1;
				8'd39 	: pitch = H_1;		  
				8'd40		: pitch = H_1;	
				8'd41		: pitch = M_3;					
				8'd42		: pitch = M_4;					
				8'd43		: pitch = M_5;					
				8'd44		: pitch = M_6;
				8'd45		: pitch = M_5;				
				8'd46		: pitch = M_3;
				8'd47		: pitch = M_5;
				8'd48		: pitch = M_5;
				8'd49	   : pitch = H_1;
				8'd50    : pitch = H_2;
				8'd51		: pitch = H_3;
				8'd52		: pitch = H_3;
				8'd53		: pitch = H_3;
				8'd54		: pitch = H_3;
				8'd55		: pitch = O;
				8'd56		: pitch = H_2;
				8'd57		: pitch = H_2;
				8'd58		: pitch = H_2;
				8'd59		: pitch = H_2;
				8'd60		: pitch = O;
				8'd61		: pitch = H_1;
				8'd62		: pitch = H_1;
				8'd63		: pitch = H_1;
				8'd64		: pitch = H_1;
				8'd65    : pitch = O;
				default:                     pitch = 17'hxxxxx; 
		  endcase
	 end
 end 
endmodule 
