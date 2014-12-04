module display (a,b);
	input [3:0] a;
	output reg [0:6] b;

	always@(a)
	begin
		case(a)
			0: b=7'b0000001;
			1: b=7'b1001111;
			2: b=7'b0010010;
			3: b=7'b0000110;
			4: b=7'b1001100;
			5: b=7'b0100100;
			6: b=7'b0100000;
			7: b=7'b0001111;
			8: b=7'b0000000;
			9: b=7'b0000100;
			13: b=1'b1110111;
			default: b=7'b0000001;
		endcase
	end

endmodule	


module npush(clk, Btn, outnpsh);
input clk;
input Btn;
output outnpsh;
reg [1:0] psh;
	always@(posedge clk)
	begin
	psh <= {psh[0], Btn};
	end
assign outnpsh = ~psh[1]&psh[0];
endmodule
	 

module AlarmClockV2(clk, swch1, swch2, swch3, swch4, btn1, btn2, btn3, disp1, disp2, disp3, disp4, disp5, led0, led1, led2, led3, led4, led5, led6, led7, led8, led9);
input clk;
input btn1, btn2, btn3;
input swch1, swch2, swch3, swch4; 
wire hrs, min, idgaf;
output reg led0, led1, led2, led3, led4, led5, led6, led7, led8, led9;
output [0:6] disp1, disp2, disp3, disp4, disp5;
//output wire disp5;
reg[1:0] psh1, psh2, psh3;
reg [3:0] BCD0, BCD1, BCD2, BCD3, BCD4;
reg [3:0] amin1, amin2, ahrs1, ahrs2;
reg [3:0] sec1, sec2, min1, min2, hrs1, hrs2;



// swch1 puts clock into set mode
//Formatted Based on the cookbook

initial begin
	BCD0 <= 4'b0000;
	BCD1 <= 4'b0000;
	BCD2 <= 4'b0000;
	BCD3 <= 4'b0000;
	sec1 <= 4'b0000;
	sec2 <= 4'b0000;
	min1 <= 4'b0000;
	min2 <= 4'b0000;
	hrs1 <= 4'b0000;
	hrs2 <= 4'b0000;
	amin1 <= 4'b0000;
	amin2 <= 4'b0000;
	ahrs1 <= 4'b0000;
	ahrs2 <= 4'b0000;
end
	

npush (clk, btn1, min);
npush (clk, btn2, hr);
npush (clk, btn3, idgaf);

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
// Count off 1000 ms to form 1 s
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
		msecond_cntr_max <= (msecond_cntr == 10'd998);
	end
end


/////////////////////////////////
// Count off 60s to form 1 m
/////////////////////////////////

reg second_ctr_max;

always @(posedge clk) begin
	if (swch1) begin
		sec1 <= 0;
		sec2 <= 0;
		second_ctr_max <= 0;
	end
	else if (msecond_cntr_max & usecond_cntr_max & tick_cntr_max) begin
		if (second_ctr_max) begin
			sec1 <= 4'b0000;
			sec2 <= 4'b0000;
			second_ctr_max <=1'b0;
		end
		else begin
			if (sec2 == 4'b1001) begin 					//This is when the 10's digit is at 5
				sec2 <= 4'b0000;								//If ^^ is true, turn 10's to zero (in prep for rollover)
				if (sec1 == 4'b0101) sec1 <=4'b0000; 	//If 10's is 5 and 1's is 9, set the 1's to zero as well
				else sec1 <= sec1 +1'b1;					//if 10's is 5 but the 1's is not 9, set the 1's +=
			end													
			else sec2 <= sec2 +1'b1; 						//if The 10's digit is not 5, add one to that shit
		end
	end
	second_ctr_max <= (sec1 ==4'b0101 && sec2 == 4'b1001);
end

/////////////////////////////////
// Count off 60m to form 1 hr
/////////////////////////////////

reg minute_ctr_max;

always @(posedge clk) begin
	if (swch1) begin
		if (min) begin // searching for output of npush instead of clock
			if (min2 == 4'b1001) begin 					//This is when the 10's digit is at 5
			min2 <= 4'b0000;									//If ^^ is true, turn 10's to zero (in prep for rollover)
				if (min1 == 4'b0101) min1 <=4'b0000; 	//If 10's is 5 and 1's is 9, set the 1's to zero as well
				else min1 <= min1 +1'b1;					//if 10's is 5 but the 1's is not 9, set the 1's +=
			end													
			else min2 <= min2 +1'b1; 						//if The 10's digit is not 5, add one to that shit
		end
	
				
			
	end
	else if (second_ctr_max && msecond_cntr_max & usecond_cntr_max & tick_cntr_max) begin
		if (minute_ctr_max) begin
			min1 <= 4'b0000;
			min2 <= 4'b0000;
			minute_ctr_max <=1'b0;
		end
		else begin
			if (min2 == 4'b1001) begin 					//This is when the 10's digit is at 5
				min2 <= 4'b0000;								//If ^^ is true, turn 10's to zero (in prep for rollover)
				if (min1 == 4'b0101) min1 <=4'b0000; 	//If 10's is 5 and 1's is 9, set the 1's to zero as well
				else min1 <= min1 +1'b1;					//if 10's is 5 but the 1's is not 9, set the 1's +=
			end													
			else min2 <= min2 +1'b1; 						//if The 10's digit is not 5, add one to that shit
		end
	end
	minute_ctr_max <= (min1 ==4'b0101 && min2 == 4'b1001);
end


/////////////////////////////////
// Count off 24hr to form 1 day
/////////////////////////////////

reg hour_ctr_max;

always @(posedge clk) begin
	if (swch1) begin
		if (hr) begin 												
			if (hrs1 == 4'b0010 && hrs2 == 4'b0011) begin 	
				hrs1 <= 4'b0000;
				hrs2 <= 4'b0000;										
				hour_ctr_max <= 1'b0;
			end
			else begin
				if (hrs2 == 4'b1001) begin
					hrs2 <= 4'b0000;
					hrs1 <= hrs1 +1'b1;
				end
				else hrs2 <= hrs2 + 1'b1;
			end
		end
	end

	else if (minute_ctr_max && second_ctr_max && msecond_cntr_max & usecond_cntr_max & tick_cntr_max) begin
		if (hour_ctr_max) begin
			hrs1 <= 4'b0000;
			hrs2 <= 4'b0000;
			hour_ctr_max <=1'b0;
		end
//		else if(hrs1 == 4'b0010 && hrs2 == 4'b0011) begin 	
//				hrs1 <= 4'b0000;
//				hrs2 <= 4'b0000;										
//				hour_ctr_max <= 1'b0;
//			end
		else begin
			if (hrs2 == 4'b1001) begin
				hrs2 <= 4'b0000;
				hrs1 <= hrs1 +1'b1;
			end
			else hrs2 <= hrs2 + 1'b1;
		end
	end
	hour_ctr_max <= (hrs1 == 4'b0010 && hrs2 == 4'b0011);
end

/////////////////////////////////
// Code in developement for alarm
/////////////////////////////////

always @(posedge clk) begin
	if (swch3) begin
		if (min) begin 											// searching for output of npush instead of clock
			if (amin2 == 4'b1001) begin 						//This is when the 10's digit is at 5
				amin2 <= 4'b0000;									//If ^^ is true, turn 10's to zero (in prep for rollover)
				if (amin1 == 4'b0101) amin1 <=4'b0000; 	//If 10's is 5 and 1's is 9, set the 1's to zero as well
				else amin1 <= amin1 +1'b1;						//if 10's is 5 but the 1's is not 9, set the 1's +=
			end													
			else amin2 <= amin2 +1'b1; 						//if The 10's digit is not 5, add one to that shit
		end
		if (hr) begin 												
			if (ahrs1 == 4'b0010 && ahrs2 == 4'b0011) begin 	
				ahrs1 <= 4'b0000;
				ahrs2 <= 4'b0000;										
			end
			else begin
				if (ahrs2 == 4'b1001) begin
					ahrs2 <= 4'b0000;
					ahrs1 <= ahrs1 +1'b1;
				end
				else ahrs2 <= ahrs2 + 1'b1;
			end
		end
	end
end

/////////////////////////////////
// React to Alarm
/////////////////////////////////

reg alarmoff;

always@(posedge clk) begin
	if((amin1 == min1) && (amin2 == min2) && (ahrs1 == hrs1) && (ahrs2 == hrs2) && swch4) begin
		if (hr || idgaf || min) alarmoff <= 1'b1;
	end
	else if ((amin1 != min1) && (amin2 != min2) && (ahrs1 != hrs1) && (ahrs2 != hrs2)) alarmoff <= 1'b0;
	else alarmoff <= 1'b0;
end

always @(posedge clk) begin
	if (swch4  && (!alarmoff)) begin // swch4 turns alarm on
		if ((amin1 == min1) && (amin2 == min2) && (ahrs1 == hrs1) && (ahrs2 == hrs2)) begin
			if(msecond_cntr_max & usecond_cntr_max & tick_cntr_max) begin
					led0 <= !led0;
					led1 <= !led1;
					led2 <= !led2;
					led3 <= !led3;
					led4 <= !led4;
					led5 <= !led5;
					led6 <= !led6;
					led7 <= !led7;
					led8 <= !led8;
					led9 <= !led9;
			end
		end
	end
	else if (!swch4 || alarmoff || (amin1 != min1) || (amin2 != min2) || (ahrs1 != hrs1) || (ahrs2 != hrs2)) begin
				led0 <= 1'b0;
				led1 <= 1'b0;
				led2 <= 1'b0;
				led3 <= 1'b0;
				led4 <= 1'b0;
				led5 <= 1'b0;
				led6 <= 1'b0;
				led7 <= 1'b0;
				led8 <= 1'b0;
				led9 <= 1'b0;
	end
end




/////////////////////////////////
// Choses Correct Display Config
/////////////////////////////////

always @(posedge clk) begin
	if (!swch3) begin
		if(swch2 || swch1) begin
			BCD0 <= min2;
			BCD1 <= min1;
			BCD2 <= hrs2;
			BCD3 <= hrs1;
			BCD4 <= 4'b1101; // lazy way to make the dot in the middle of the hrs/mins (Did NOT write in first dot, cant explain this problem)
		end
		else if (!swch2) begin
			BCD0 <= sec2;
			BCD1 <= sec1;
			BCD2 <= min2;
			BCD3 <= min1;
			BCD4 <= 4'b1101; // lazy way to make the dot in the middle of the hrs/mins
		end
	end
	else if (swch3) begin
		BCD0 <= amin2;
		BCD1 <= amin1;
		BCD2 <= ahrs2;
		BCD3 <= ahrs1;
		BCD4 <= 4'b1101; // lazy way to make the dot in the middle of the hrs/mins (Did NOT write in first dot, cant explain this problem)
	end
	

end


display (BCD0, disp1);
display (BCD1, disp2);
display (BCD2, disp3);
display (BCD3, disp4);
display (BCD4, disp5);

endmodule