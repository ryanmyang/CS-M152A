`timescale 1ns / 1ps

module testbench();
    reg clk;
    reg btnC;
    reg [3:0] rows;
    wire [3:0] cols;
    wire [6:0] seg;
    wire [3:0] an;
    wire dp;
    
    // Instantiate the top module
    top_module uut (
        .clk(clk),
        .btnC(btnC),
        .JA(rows),
        .JB(cols),
        .seg(seg),
        .an(an),
        .dp(dp)
    );
    
    // Clock generation - 100MHz
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Simulate keypad press with reduced timing
    task press_key;
        input [1:0] row;
        input [1:0] col;
        begin
            // Wait for the correct column to be scanned
            wait(cols[col] == 1'b0);
            
            // Assert the row
            case(row)
                2'b00: rows = 4'b1110;
                2'b01: rows = 4'b1101;
                2'b10: rows = 4'b1011;
                2'b11: rows = 4'b0111;
            endcase
            
            // Hold for key press duration (reduced from 50ms to 50us for simulation)
            #50000;  // 50us
            
            // Release key
            rows = 4'b1111;
            
            // Wait before next key press (reduced from 50ms to 50us)
            #50000;  // 50us
        end
    endtask
    
    // Test sequence
    initial begin
        // Initialize
        btnC = 1;
        rows = 4'b1111;  // No key pressed
        
        // Wait and release reset
        #1000;
        btnC = 0;
        
        // Wait for system to stabilize (reduced from 10ms to 10us)
        #10000;
        
        // Test sequence: Enter "1234"
        $display("Pressing key 1");
        press_key(2'b00, 2'b00);  // Key 1
        
        $display("Pressing key 2");
        press_key(2'b00, 2'b01);  // Key 2
        
        $display("Pressing key 3");
        press_key(2'b00, 2'b10);  // Key 3
        
        $display("Pressing key 4");
        press_key(2'b01, 2'b00);  // Key 4
        
        // Wait to see the display (reduced from 100ms to 100us)
        #100000;
        
        // Test clear function - press F
        $display("Pressing key F to clear");
        press_key(2'b11, 2'b10);  // Key F
        
        // Wait to see cleared display
        #100000;
        
        // Test more digits
        $display("Pressing key 5");
        press_key(2'b01, 2'b01);  // Key 5
        
        $display("Pressing key 6");
        press_key(2'b01, 2'b10);  // Key 6
        
        // Wait and finish
        #100000;
        $display("Test completed");
        $finish;
    end
    
    // Monitor display changes
    reg [15:0] prev_display;
    initial begin
        prev_display = 16'hFFFF;
        forever begin
            #1000;  // Check every 1us instead of 1ms
            if (uut.display_value != prev_display) begin
                $display("Time=%0t: Display value changed to %h", $time, uut.display_value);
                prev_display = uut.display_value;
            end
        end
    end
    
endmodule 