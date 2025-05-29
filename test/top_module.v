`timescale 1ns / 1ps

module top_module(
    input clk,                    // 100MHz clock
    input btnC,                   // Center button for reset
    input [3:0] JA,              // PMOD JA pins 1-4 (rows)
    output [3:0] JB,             // PMOD JB pins 1-4 (columns)
    output [6:0] seg,            // 7-segment display segments
    output [3:0] an,             // 7-segment display anodes
    output dp                    // Decimal point
    );
    
    // Internal signals
    wire [3:0] key_value;
    wire key_pressed;
    reg [15:0] display_value;    // 4 digits, each 4 bits
    reg [2:0] digit_count;       // Count of entered digits
    
    // Clock divider for display refresh
    reg [16:0] clk_divider;
    wire display_clk = clk_divider[16];
    
    always @(posedge clk) begin
        clk_divider <= clk_divider + 1;
    end
    
    // Instantiate keypad decoder
    keypad_decoder keypad_inst(
        .clk(clk),
        .reset(btnC),
        .rows(JA),
        .cols(JB),
        .key_value(key_value),
        .key_pressed(key_pressed)
    );
    
    // Instantiate 7-segment display controller
    seven_seg_controller display_inst(
        .clk(display_clk),
        .reset(btnC),
        .display_value(display_value),
        .seg(seg),
        .an(an),
        .dp(dp)
    );
    
    // Handle key presses and update display
    reg key_pressed_prev;
    
    always @(posedge clk or posedge btnC) begin
        if (btnC) begin
            display_value <= 16'h0000;
            digit_count <= 0;
            key_pressed_prev <= 0;
        end else begin
            key_pressed_prev <= key_pressed;
            
            // Detect rising edge of key_pressed
            if (key_pressed && !key_pressed_prev) begin
                if (key_value == 4'hF) begin
                    // Clear display when F is pressed
                    display_value <= 16'h0000;
                    digit_count <= 0;
                end else if (key_value <= 4'h9 && digit_count < 4) begin
                    // Shift digits left and add new digit
                    display_value <= {display_value[11:0], key_value};
                    digit_count <= digit_count + 1;
                end
            end
        end
    end
    
endmodule 