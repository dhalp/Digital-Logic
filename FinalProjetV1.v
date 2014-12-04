
module FinalProjetV1(clk, swch1, swch2, btn0, btn1, btn2, disp1);
input clk;
input btn0, btn1, btn2;
output reg [0:27] disp1;
input swch1, swch2;
reg [5:0] cntr;

initial begin
cntr <= 5'd0;
end

	reg [9:0] usecond_cntr;
	reg [9:0] msecond_cntr;
	
parameter CLOCK_MHZ =50;

reg [7:0] tick_cntr;
reg tick_cntr_max;


always @(posedge clk) begin
	if (swch1) begin
		tick_cntr <= 0;
		tick_cntr_max <= 0;
	end
	else begin
		if (tick_cntr_max)tick_cntr <= 1'b0;
		else tick_cntr <= tick_cntr +1'b1;
		tick_cntr_max <= (tick_cntr == (CLOCK_MHZ - 2'd2));
	end
end

/////////////////////////////////
// Count off 1000 us to form 1 ms
/////////////////////////////////
reg usecond_cntr_max;

always @(posedge clk) begin
	if (swch1) begin
		usecond_cntr <= 0;
		usecond_cntr_max <= 0;
	end
	else if (tick_cntr_max) begin
		if (usecond_cntr_max) usecond_cntr <= 1'b0;
		else usecond_cntr <= usecond_cntr + 1'b1;
		usecond_cntr_max <= (usecond_cntr == 10'd998);
	end
end



/////////////////////////////////
// Count off 1000 ms to form 0.5 s
/////////////////////////////////
reg msecond_cntr_max;

always @(posedge clk) begin
	if (swch1) begin
		msecond_cntr <= 0;
		msecond_cntr_max <= 0;
	end
	else if (usecond_cntr_max & tick_cntr_max) begin
		if (msecond_cntr_max) msecond_cntr <= 1'b0;
		else msecond_cntr <= msecond_cntr + 1'b1;
		msecond_cntr_max <= (msecond_cntr == 10'd498);
	end
end

always@ (posedge clk) begin
//There is no need to debounce because this is not controlling a counter
	if (!btn0 & msecond_cntr_max & usecond_cntr_max & tick_cntr_max) begin
		cntr <= cntr + 1'b1;
		if (cntr == 5'd19)begin
			cntr <= 5'd0;
		end
	end	
	else if (!btn1 & msecond_cntr_max & usecond_cntr_max & tick_cntr_max) begin
		cntr <= cntr + 1'b1;
		if (cntr == 5'd7)begin
			cntr <= 5'd0;
		end
	end	
	else if (!btn2 & msecond_cntr_max & usecond_cntr_max & tick_cntr_max) begin
		cntr <= cntr + 1'b1;
		if (cntr == 5'd11)begin
			cntr <= 5'd0;
		end
	end	
	else if ((btn0 & btn1 & btn2) | swch1) begin
		cntr <=  5'd0;
	end
end



always@ (posedge clk) begin
	if (!btn0) begin
		case(cntr)
			0: disp1=28'b1111111111111111111111110111;
			1: disp1=28'b1111111111111111101111111111;
			2: disp1=28'b1111111111011111111111111111;
			3: disp1=28'b1110111111111111111111111111;
			4: disp1=28'b1101111111111111111111111111;
			5: disp1=28'b0111111111111111111111111111;
			6: disp1=28'b1111111011111111111111111111;
			7: disp1=28'b1111111111111101111111111111;
			8: disp1=28'b1111111111111111111110111111;
			9: disp1=28'b1111111111111111111111111101;
			10: disp1=28'b1111111111111111111111111110;
			11: disp1=28'b1111111111111111111101111111;
			12: disp1=28'b1111111111111011111111111111;
			13: disp1=28'b1111110111111111111111111111;
			14: disp1=28'b1011111111111111111111111111;
			15: disp1=28'b0111111111111111111111111111;
			16: disp1=28'b1111111011111111111111111111;
			17: disp1=28'b1111111111111101111111111111;
			18: disp1=28'b1111111111111111111110111111;
			19: disp1=28'b1111111111111111111111111011;
			default: disp1=28'b0110110011011001101100110110;
		endcase
	end
	else if (!btn1) begin
		case(cntr)
			0: disp1=28'b1111110111111011111101111110;
			1: disp1=28'b1111101111110111111011111101;
			2: disp1=28'b0111111011111101111110111111;
			3: disp1=28'b1101111110111111011111101111;
			4: disp1=28'b1110111111011111101111110111;
			5: disp1=28'b1111011111101111110111111011;
			6: disp1=28'b0111111011111101111110111111;
			7: disp1=28'b1011111101111110111111011111;
			default: disp1=28'b0110110011011001101100110110;
		endcase
	end
	else if (!btn2) begin
		case(cntr)
			0: disp1=28'b1111111111011111111111110111;
			1: disp1=28'b1110111111111111101111111111;
			2: disp1=28'b1101111111111111011111111111;
			3: disp1=28'b0111111111111101111111111111;
			4: disp1=28'b1111111011111111111110111111;
			5: disp1=28'b1111111111110111111111111101;
			6: disp1=28'b1111111111111011111111111110;
			7: disp1=28'b1111110111111111111101111111;
			8: disp1=28'b1011111111111110111111111111;
			9: disp1=28'b0111111111111101111111111111;
			10: disp1=28'b1111111011111111111110111111;
			11: disp1=28'b1111111111101111111111111011;
			default: disp1=28'b0110110011011001101100110110;
		endcase
	end		
	else if(swch2) begin
		disp1=28'b0001100010001101011110101011;
	end
	else if (!swch2)begin
		disp1=28'b0001001000100010001110001100;
	end
	
		
	
end


endmodule        