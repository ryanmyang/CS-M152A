`timescale 1ns / 1ps

module basys3_tb();
    // Test bench signals
    reg clk;
    wire [7:0] JB;
    wire [3:0] an;
    wire [6:0] seg;
    
    // Registers to drive the row lines (simulate button press)
    reg [3:0] row_drive;
    // Columns are driven by the Decoder, so we leave them as wires
    wire [3:0] col_drive;
    
    // Connect JB: upper 4 bits are rows (driven by testbench), lower 4 bits are columns (driven by DUT)
    assign JB = {row_drive, col_drive};
    
    // Instantiate the unit under test
    basys3 uut (
        .clk(clk),
        .JB(JB),
        .an(an),
        .seg(seg)
    );
    
    // Connect col_drive to the Decoder's output inside the DUT
    assign col_drive = uut.Decoder.Col;
    
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
    
    // Task to simulate a button press at a given row and column
    // row_idx: 0=R1, 1=R2, 2=R3, 3=R4
    // col_pattern: value of col_drive when the Decoder is scanning the desired column
    task press_button;
        input [1:0] row_idx;
        input [3:0] col_pattern;
        input [31:0] press_time;
        begin
            // Wait until the Decoder is scanning the desired column
            while (col_drive !== col_pattern) @(posedge clk);
            // Set the corresponding row low (simulate button press)
            row_drive = ~(4'b0001 << row_idx);
            // Hold the press for the specified time
            repeat (press_time) @(posedge clk);
            // Release the button (all rows high)
            row_drive = 4'b1111;
        end
    endtask
    
    // Test sequence
    initial begin
        // Start with all rows high (no button pressed)
        row_drive = 4'b1111;
        // Wait for initial setup
        #100;
        
        // The Decoder scans columns in this order:
        // C1: 4'b0111, C2: 4'b1011, C3: 4'b1101, C4: 4'b1110
        // For each button, wait for the Decoder to scan the column, then pull the appropriate row low
        // Button order: 1 2 3 A, 4 5 6 B, 7 8 9 C, 0 F E D
        
        // Row 1 (R1 = 0)
        press_button(2'd0, 4'b0111, 1000); // 1
        press_button(2'd0, 4'b1011, 1000); // 2
        press_button(2'd0, 4'b1101, 1000); // 3
        press_button(2'd0, 4'b1110, 1000); // A
        // Row 2 (R2 = 1)
        press_button(2'd1, 4'b0111, 1000); // 4
        press_button(2'd1, 4'b1011, 1000); // 5
        press_button(2'd1, 4'b1101, 1000); // 6
        press_button(2'd1, 4'b1110, 1000); // B
        // Row 3 (R3 = 2)
        press_button(2'd2, 4'b0111, 1000); // 7
        press_button(2'd2, 4'b1011, 1000); // 8
        press_button(2'd2, 4'b1101, 1000); // 9
        press_button(2'd2, 4'b1110, 1000); // C
        // Row 4 (R4 = 3)
        press_button(2'd3, 4'b0111, 1000); // 0
        press_button(2'd3, 4'b1011, 1000); // F
        press_button(2'd3, 4'b1101, 1000); // E
        press_button(2'd3, 4'b1110, 1000); // D
        
        // End simulation
        #10000;
        $finish;
    end
    
endmodule 