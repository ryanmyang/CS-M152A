`timescale 1ns / 1ps

module basys3_tb();
    // Test bench signals
    reg clk;
    reg [7:0] keypad_state;  // Simulated keypad state
    wire [3:0] an;
    wire [6:0] seg;
    
    // Instantiate the unit under test
    basys3 uut (
        .clk(clk),
        .JB(keypad_state),  // Connect the simulated keypad state directly
        .an(an),
        .seg(seg)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end
    
    // Waveform dump for simulation
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, basys3_tb);
    end
    
    // Task to simulate a button press
    // row: 0=R1, 1=R2, 2=R3, 3=R4
    // col: 0=C1, 1=C2, 2=C3, 3=C4
    task press_button;
        input [1:0] row;
        input [1:0] col;
        input [31:0] press_time;
        begin
            // Set the corresponding row and column low (simulate button press)
            keypad_state = ~((4'b0001 << row) | (4'b0001 << (col + 4)));
            // Hold the press for the specified time
            repeat (press_time) @(posedge clk);
            // Release the button (all signals high)
            keypad_state = 8'b11111111;
        end
    endtask
    
    // Test sequence
    initial begin
        // Start with all signals high (no button pressed)
        keypad_state = 8'b11111111;
        // Wait for initial setup
        #1000000;
        
        // Test each button
        // Row 1
        press_button(2'd0, 2'd0, 100000); // 1
        press_button(2'd0, 2'd1, 100000); // 2
        press_button(2'd0, 2'd2, 100000); // 3
        press_button(2'd0, 2'd3, 100000); // A
        
        // Row 2
        press_button(2'd1, 2'd0, 100000); // 4
        press_button(2'd1, 2'd1, 100000); // 5
        press_button(2'd1, 2'd2, 100000); // 6
        press_button(2'd1, 2'd3, 100000); // B
        
        // Row 3
        press_button(2'd2, 2'd0, 100000); // 7
        press_button(2'd2, 2'd1, 100000); // 8
        press_button(2'd2, 2'd2, 100000); // 9
        press_button(2'd2, 2'd3, 100000); // C
        
        // Row 4
        press_button(2'd3, 2'd0, 100000); // 0
        press_button(2'd3, 2'd1, 100000); // F
        press_button(2'd3, 2'd2, 100000); // E
        press_button(2'd3, 2'd3, 100000); // D
        
        // End simulation
        #1000000;
        $finish;
    end
    
endmodule 