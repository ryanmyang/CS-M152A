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
    // state 0 will be entering first dig logic
    // state 1 will be ERROR

    // Displayed digs (dig0 = rightmost)
    reg [3:0] dig0 = 0, dig1 = 0, dig2 = 0, dig3 = 0;

	// dig Entry Tracking
	reg [2:0] numLength = 0;
    reg [3:0] digbuffer0 = 0, digbuffer1 = 0, digbuffer2 = 0, digbuffer3 = 0;
    reg [3:0] opbuffer = 0;


    task automatic do_clear; // task to do the clear logic
    begin
        digbuffer0 <= 0;
        digbuffer1 <= 0;
        digbuffer2 <= 0;
        digbuffer3 <= 0;
        dig0 <= 0;
        dig1 <= 0;
        dig2 <= 0;
        dig3 <= 0;
        numLength <= 0;
        opbuffer <= 0;
        state <= 2'b00;
    end
    endtask

    // e = equals, f = clear

    // On keypress, shift digs
    always @(posedge clk) begin
        if (KeyStrobe) begin
			case (state) 
				 2'b00: begin // entering first dig logic
                 // Start with operand logic
                    if (KeypadRaw != 4'ha && KeypadRaw != 4'hb && KeypadRaw != 4'hc && KeypadRaw != 4'hd && KeypadRaw != 4'he && KeypadRaw != 4'hf) begin
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
                    else begin

                        if (KeypadRaw != 4'he && KeypadRaw != 4'hf) begin // if press operator, (not equal or clear)
                            // if operator but already have operator, set error state
                            if (opbuffer != 0) begin
                                state <= 2'b01;
                            end
                            else begin
                                // set the state to the operator, save data
                                // ig we don't really need to even have state 1 since it automatically goes back to state 0
                                digbuffer0 <= dig0;
                                digbuffer1 <= dig1;
                                digbuffer2 <= dig2;
                                digbuffer3 <= dig3;            
                                dig0 <= 0;
                                dig1 <= 0;
                                dig2 <= 0;
                                dig3 <= 0;
                                numLength <= 0;
                                opbuffer <= KeypadRaw;
                            end
                        end
                        else if (KeypadRaw == 4'he) begin // equals - handle the operation
                            // TODO: add operator logic
                            case (opbuffer)
                                4'ha: begin // +
                                    
                                end
                                4'hb: begin // -
                                    // TODO: add - logic
                                end
                                4'hc: begin // *
                                    // TODO: add * logic
                                end
                                4'hd: begin // /
                                    // TODO: add / logic
                                end
                            endcase
                        end
                        else begin  // if press clear, set all digs to 0, clear all data
                            do_clear;
                        end

                    end
                 end
                 2'b01: begin // ERROR state
                    if (KeypadRaw == 4'hf) begin
                        do_clear;
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