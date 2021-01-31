module key_scan(
	input							clk   ,       // 时钟信号
	input							rst_n ,       // 复位信号

	
	input			[4:0]		   key_in,

	output      [4:0]	   	key_out
);
reg [23:0]		timer;
reg [4:0]		new_key;
reg [4:0]		last_key;
wire				flag_up;
reg[31:0]		count;

always @(posedge clk,negedge rst_n)
begin
	if(!rst_n)
	begin
		timer <=24'd0;
	end
	else if(timer == 24'd4_999999)
	begin	
		timer <=24'd0;
		new_key[0] <= key_in[0];
		new_key[1] <= key_in[1];
		new_key[2] <= key_in[2];
		new_key[3] <= key_in[3];
		new_key[4] <= key_in[4];
	end
	else	timer <= timer + 1'b1;
end
always @(posedge clk)
begin
	last_key[0] <= new_key[0];
	last_key[1] <= new_key[1];
	last_key[2] <= new_key[2];
	last_key[3] <= new_key[3];
	last_key[4] <= new_key[4];
end

assign			key_out[0] = (last_key[0])&~new_key[0];
assign			key_out[1] = (last_key[1])&~new_key[1];
assign			key_out[2] = (last_key[2])&~new_key[2];
assign			key_out[3] = (last_key[3])&~new_key[3];
assign			key_out[4] = (~last_key[4])&new_key[4];


endmodule
	
	
	
	