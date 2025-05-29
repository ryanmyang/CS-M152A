module KeypadInput(
    input clk,						// 100MHz onboard clock
    input [3:0] Row,				// Rows on KYPD
    output reg [3:0] Col,			// Columns on KYPD
    output reg [3:0] DecodeOut,	// Output data
	output reg KeyPressed		// Output key pressed
    );

	// Count register
	reg [19:0] sclk;
	
	// Debouncing registers
	reg [3:0] StableKey = 4'b0000;      // Last stable key value
	reg [3:0] CurrentKey = 4'b0000;     // Current detected key
	reg KeyDetected = 1'b0;             // Raw key detection signal
	reg [15:0] DebounceCounter = 0;     // Counter for debouncing
	parameter DEBOUNCE_TIME = 16'd50000; // 0.5ms at 100MHz
	
	// Key release detection
	reg KeyReleased = 1'b1;             // Track if key has been released

	initial begin
		Col = 4'b1111;
		DecodeOut = 4'b0000;
		sclk = 20'b0;
		KeyPressed = 1'b0;
	end

	always @(posedge clk) begin

			// 1ms
			if (sclk == 20'b00011000011010100000) begin
				//C1
				Col <= 4'b0111;
				sclk <= sclk + 1'b1;
			end
			
			// check row pins
			else if(sclk == 20'b00011000011010101000) begin
				//R1
				if (Row == 4'b0111) begin
					CurrentKey <= 4'b0001;		//1
					KeyDetected <= 1'b1;
				end
				//R2
				else if(Row == 4'b1011) begin
					CurrentKey <= 4'b0100; 		//4
					KeyDetected <= 1'b1;
				end
				//R3
				else if(Row == 4'b1101) begin
					CurrentKey <= 4'b0111; 		//7
					KeyDetected <= 1'b1;
				end
				//R4
				else if(Row == 4'b1110) begin
					CurrentKey <= 4'b0000; 		//0
					KeyDetected <= 1'b1;
				end
				else begin
					KeyDetected <= 1'b0;
					CurrentKey <= 4'b0000;
				end
				sclk <= sclk + 1'b1;
			end

			// 2ms
			else if(sclk == 20'b00110000110101000000) begin
				//C2
				Col<= 4'b1011;
				sclk <= sclk + 1'b1;
			end
			
			// check row pins
			else if(sclk == 20'b00110000110101001000) begin
				//R1
				if (Row == 4'b0111) begin
					CurrentKey <= 4'b0010; 		//2
					KeyDetected <= 1'b1;
				end
				//R2
				else if(Row == 4'b1011) begin
					CurrentKey <= 4'b0101; 		//5
					KeyDetected <= 1'b1;
				end
				//R3
				else if(Row == 4'b1101) begin
					CurrentKey <= 4'b1000; 		//8
					KeyDetected <= 1'b1;
				end
				//R4
				else if(Row == 4'b1110) begin
					CurrentKey <= 4'b1111; 		//F
					KeyDetected <= 1'b1;
				end
				else begin
					KeyDetected <= 1'b0;
					CurrentKey <= 4'b0000;
				end
				sclk <= sclk + 1'b1;
			end

			//3ms
			else if(sclk == 20'b01001001001111100000) begin
				//C3
				Col<= 4'b1101;
				sclk <= sclk + 1'b1;
			end
			
			// check row pins
			else if(sclk == 20'b01001001001111101000) begin
				//R1
				if(Row == 4'b0111) begin
					CurrentKey <= 4'b0011; 		//3	
					KeyDetected <= 1'b1;
				end
				//R2
				else if(Row == 4'b1011) begin
					CurrentKey <= 4'b0110; 		//6
					KeyDetected <= 1'b1;
				end
				//R3
				else if(Row == 4'b1101) begin
					CurrentKey <= 4'b1001; 		//9
					KeyDetected <= 1'b1;
				end
				//R4
				else if(Row == 4'b1110) begin
					CurrentKey <= 4'b1110; 		//E
					KeyDetected <= 1'b1;
				end
				else begin
					KeyDetected <= 1'b0;
					CurrentKey <= 4'b0000;
				end
				sclk <= sclk + 1'b1;
			end

			//4ms
			else if(sclk == 20'b01100001101010000000) begin
				//C4
				Col<= 4'b1110;
				sclk <= sclk + 1'b1;
			end

			// Check row pins
			else if(sclk == 20'b01100001101010001000) begin
				//R1
				if(Row == 4'b0111) begin
					CurrentKey <= 4'b1010; //A
					KeyDetected <= 1'b1;
				end
				//R2
				else if(Row == 4'b1011) begin
					CurrentKey <= 4'b1011; //B
					KeyDetected <= 1'b1;
				end
				//R3
				else if(Row == 4'b1101) begin
					CurrentKey <= 4'b1100; //C
					KeyDetected <= 1'b1;
				end
				//R4
				else if(Row == 4'b1110) begin
					CurrentKey <= 4'b1101; //D
					KeyDetected <= 1'b1;
				end
				else begin
					KeyDetected <= 1'b0;
					CurrentKey <= 4'b0000;
				end
				sclk <= 20'b00000000000000000000;
			end

			// Otherwise increment
			else begin
				sclk <= sclk + 1'b1;
			end
			
	end
	
	// Debouncing logic - runs in parallel
	always @(posedge clk) begin
		if (KeyDetected) begin
			// Key is being pressed
			if (CurrentKey == StableKey) begin
				// Same key still pressed
				if (DebounceCounter < DEBOUNCE_TIME) begin
					DebounceCounter <= DebounceCounter + 1;
				end else if (KeyReleased) begin
					// Key has been stable for debounce time and was previously released
					KeyPressed <= 1'b1;
					DecodeOut <= StableKey;
					KeyReleased <= 1'b0;
				end
			end else begin
				// Different key detected, reset debounce
				StableKey <= CurrentKey;
				DebounceCounter <= 0;
				KeyPressed <= 1'b0;
			end
		end else begin
			// No key pressed
			if (DebounceCounter > 0) begin
				DebounceCounter <= DebounceCounter - 1;
			end else begin
				StableKey <= 4'b0000;
				KeyPressed <= 1'b0;
				KeyReleased <= 1'b1;  // Mark that key has been released
			end
		end
	end

endmodule
