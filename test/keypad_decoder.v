`timescale 1ns / 1ps

module keypad_decoder(
    input clk,
    input reset,
    input [3:0] rows,           // Row inputs from keypad
    output reg [3:0] cols,      // Column outputs to keypad
    output reg [3:0] key_value, // Decoded key value
    output reg key_pressed      // Key press detected flag
    );
    
    // Keypad scanning states
    parameter IDLE = 3'b000;
    parameter SCAN_COL0 = 3'b001;
    parameter SCAN_COL1 = 3'b010;
    parameter SCAN_COL2 = 3'b011;
    parameter SCAN_COL3 = 3'b100;
    parameter KEY_DETECTED = 3'b101;
    parameter WAIT_RELEASE = 3'b110;
    
    reg [2:0] state, next_state;
    reg [19:0] scan_timer;      // Timer for scanning rate
    reg [19:0] debounce_timer;  // Timer for debouncing
    reg [1:0] detected_col;     // Store which column was active when key detected
    reg [1:0] row_index;
    
    // Keypad matrix mapping
    // Layout:
    //   1  2  3  A
    //   4  5  6  B
    //   7  8  9  C
    //   *  0  #  D
    //   E  F  (extra keys if needed)
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            scan_timer <= 0;
            debounce_timer <= 0;
            cols <= 4'b1111;
            key_value <= 4'h0;
            key_pressed <= 0;
            detected_col <= 2'b00;
        end else begin
            state <= next_state;
            
            // Increment timers
            if (scan_timer < 100000)  // 1ms at 100MHz
                scan_timer <= scan_timer + 1;
            else
                scan_timer <= 0;
                
            if (state == KEY_DETECTED || state == WAIT_RELEASE) begin
                if (debounce_timer < 2000000)  // 20ms debounce
                    debounce_timer <= debounce_timer + 1;
            end else begin
                debounce_timer <= 0;
            end
        end
    end
    
    // State machine logic
    always @(*) begin
        next_state = state;
        
        case (state)
            IDLE: begin
                if (scan_timer == 0)
                    next_state = SCAN_COL0;
            end
            
            SCAN_COL0: begin
                cols = 4'b1110;  // Enable column 0
                if (scan_timer == 50000) begin  // Wait for signal to settle
                    if (rows != 4'b1111)
                        next_state = KEY_DETECTED;
                    else
                        next_state = SCAN_COL1;
                end
            end
            
            SCAN_COL1: begin
                cols = 4'b1101;  // Enable column 1
                if (scan_timer == 50000) begin
                    if (rows != 4'b1111)
                        next_state = KEY_DETECTED;
                    else
                        next_state = SCAN_COL2;
                end
            end
            
            SCAN_COL2: begin
                cols = 4'b1011;  // Enable column 2
                if (scan_timer == 50000) begin
                    if (rows != 4'b1111)
                        next_state = KEY_DETECTED;
                    else
                        next_state = SCAN_COL3;
                end
            end
            
            SCAN_COL3: begin
                cols = 4'b0111;  // Enable column 3
                if (scan_timer == 50000) begin
                    if (rows != 4'b1111)
                        next_state = KEY_DETECTED;
                    else
                        next_state = IDLE;
                end
            end
            
            KEY_DETECTED: begin
                if (debounce_timer >= 2000000) begin
                    key_pressed = 1;
                    next_state = WAIT_RELEASE;
                end
            end
            
            WAIT_RELEASE: begin
                if (rows == 4'b1111) begin
                    key_pressed = 0;
                    next_state = IDLE;
                end
            end
        endcase
    end
    
    // Store column when key is detected
    always @(posedge clk) begin
        if (state != KEY_DETECTED && next_state == KEY_DETECTED) begin
            case (state)
                SCAN_COL0: detected_col <= 2'b00;
                SCAN_COL1: detected_col <= 2'b01;
                SCAN_COL2: detected_col <= 2'b10;
                SCAN_COL3: detected_col <= 2'b11;
                default: detected_col <= 2'b00;
            endcase
        end
    end
    
    // Decode key based on current state and row input
    always @(posedge clk) begin
        if (state == KEY_DETECTED && debounce_timer == 1) begin
            // Determine row
            case (rows)
                4'b1110: row_index = 2'b00;  // Row 0
                4'b1101: row_index = 2'b01;  // Row 1
                4'b1011: row_index = 2'b10;  // Row 2
                4'b0111: row_index = 2'b11;  // Row 3
                default: row_index = 2'b00;
            endcase
            
            // Map to key value
            case ({row_index, detected_col})
                4'b0000: key_value = 4'h1;  // Row 0, Col 0
                4'b0001: key_value = 4'h2;  // Row 0, Col 1
                4'b0010: key_value = 4'h3;  // Row 0, Col 2
                4'b0011: key_value = 4'hA;  // Row 0, Col 3
                
                4'b0100: key_value = 4'h4;  // Row 1, Col 0
                4'b0101: key_value = 4'h5;  // Row 1, Col 1
                4'b0110: key_value = 4'h6;  // Row 1, Col 2
                4'b0111: key_value = 4'hB;  // Row 1, Col 3
                
                4'b1000: key_value = 4'h7;  // Row 2, Col 0
                4'b1001: key_value = 4'h8;  // Row 2, Col 1
                4'b1010: key_value = 4'h9;  // Row 2, Col 2
                4'b1011: key_value = 4'hC;  // Row 2, Col 3
                
                4'b1100: key_value = 4'hE;  // Row 3, Col 0 (*)
                4'b1101: key_value = 4'h0;  // Row 3, Col 1
                4'b1110: key_value = 4'hF;  // Row 3, Col 2 (#)
                4'b1111: key_value = 4'hD;  // Row 3, Col 3
                
                default: key_value = 4'h0;
            endcase
        end
    end
    
endmodule 