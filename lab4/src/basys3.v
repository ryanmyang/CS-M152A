`timescale 1ns / 1ps

module basys3(
    input clk, // 100Mhz onboard clock
    inout [7:0] JB, // JB[3:0] = Col, JB[7:4] = Row
    output wire [3:0] an, // Display anodes
    output wire [6:0] seg // Segment cathodes
);

    // Keypad interface
    wire [3:0] KeypadRaw;
    wire  KeyPressed;

    KeypadInput KeypadInput (
        .clk(clk),
        .Row(JB[7:4]),
        .Col(JB[3:0]),
        .DecodeOut(KeypadRaw),
        .KeyPressed(KeyPressed)
    );

    // Edge detection
    reg PrevPressed = 0;
    wire KeyStrobe = (KeyPressed && !PrevPressed);
    always @(posedge clk)
        PrevPressed <= KeyPressed;

	reg [1:0] state = 0;

    // Displayed digs (dig0 = rightmost)
    reg [3:0] dig0 = 0, dig1 = 0, dig2 = 0, dig3 = 0;

	// dig Entry Tracking
	reg [2:0] numLength = 0;

    // On keypress, shift digs
    always @(posedge clk) begin
        if (KeyStrobe) begin
			case (state) 
				 2'b00: begin // entering first dig logic
					if (numLength <= 3 && ((numLength > 0 || KeypadRaw != 0) || (numLength == 1 && KeypadRaw == 0))) begin 
						// if you are starting a new number with non-zero digs, OR entering a number after hitting zero,
						// shift the digs and set the button pressed to the ones place
						dig3 <= dig2;
						dig2 <= dig1;
						dig1 <= dig0;
						dig0 <= KeypadRaw;
						if (!(KeypadRaw == 0 && numLength == 1)) begin
							numLength <= numLength + 1;
							// we only want to increment numLength if we didn't just enter a number after starting with zero
						end
					end
					else if ((numLength == 0 && KeypadRaw == 0)) begin // if entering a 0, set numLength to 1
						numLength <= 1; 
						// note: if you press an operator after 0, it uses 0 as the first number.
						// If you press a number after 0, it will try to just restart the number entry
					end



					end
			endcase
			
        end
    end

    // Display all 4 digs with a multiplexing controller
    wire [15:0] disp_data = {dig3, dig2, dig1, dig0};

    DisplayController display (
        .clk(clk),
        .digits(disp_data),
        .an(an),
        .seg(seg)
    );

endmodule