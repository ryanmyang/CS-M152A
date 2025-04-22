`timescale 1ns / 1ps

module lab2_tb;

    // Inputs
    reg clk;
    reg reset;
    reg a;
    reg b;

    // Outputs
    wire y;

    // Instantiate the Unit Under Test (UUT)
    lab2 uut (
        .a(a),
        .b(b),
        .y(y)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Initialize Inputs
        clk = 0;
        reset = 1;
        a = 0;
        b = 0;

        // Dump waveforms
        $dumpfile("wave.vcd");
        $dumpvars(0, lab2_tb);

        // Wait for global reset
        #10;
        reset = 0;

        // Apply test cases
        #10 a = 0; b = 1;
        #10 a = 1; b = 0;
        #10 a = 1; b = 1;
        #10 a = 0; b = 0;

        // Add more test cases as needed
        #10 $finish;
    end

    initial begin
        // Monitor signals
        $monitor("Time = %0t | clk = %b | reset = %b | a = %b | b = %b | y = %b", 
                 $time, clk, reset, a, b, y);
    end

endmodule