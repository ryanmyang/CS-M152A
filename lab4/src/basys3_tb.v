`timescale 1ns / 1ps

module basys3_tb;

    // 100 MHz system clock
    reg clk;
    initial        clk = 1'b0;
    always #5 clk = ~clk;          // 10 ns period

    
    // Shared JB bus (row & column lines)
    wire [7:0] JB;

    // ---------- columns (driven by UUT by scanning in KeypadInput.v) ----------
    wire [3:0] col_from_uut;           // probe
    assign col_from_uut = JB[3:0];     // NO TB drive on columns

    // ---------- rows (driven by TB to simulate button presses) ---------------
    reg  [3:0] row_drive_tb;           // 0 when pressed, 1 when idle
    assign JB[7:4] = row_drive_tb;

    // start with rows floating high (idle)
    initial row_drive_tb = 4'b1111;

    // UUT instantiation
    wire [3:0] an;
    wire [6:0] seg;

    basys3 uut (
        .clk (clk), //input
        .JB  (JB), // [7:4] input, 
        .an  (an), // output
        .seg (seg) // output
    );

    //------------------------------------------------------------------
    // Helper task : emulate a key press
    // row  = 0‑3  (top to bottom)
    // col  = 0‑3  (left to right)
    // cycles = # of clock cycles to hold the key down
    //------------------------------------------------------------------
    task press_button;
        input  [1:0] row;
        input  [1:0] col;
        input  integer cycles;
    begin
        // 1. be sure no row is asserted
        row_drive_tb = 4'b1111;

        // 2. wait until the desired column goes LOW first
        @(posedge clk);
        while (col_from_uut[3-col] != 1'b0)
            @(posedge clk);
            

        // 3. NOW pull the required row low
        row_drive_tb[3-row] = 1'b0;

        // // 4. keep it low for a few cycles (12 is fine)
        // repeat (cycles) @(posedge clk);

        // 5. wait until that column returns HIGH
        while (col_from_uut[3-col] == 1'b0)
            @(posedge clk);

        // 6. release (all rows high again)
        row_drive_tb = 4'b1111;
        repeat (cycles) @(posedge clk);
    end
    endtask

    //------------------------------------------------------------------
    //  Stimulus sequence
    //------------------------------------------------------------------
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, basys3_tb);
        
        // Small startup delay
        repeat (20) @(posedge clk);


        // old testing: mostly works
        // ----- Row 0 : 1 2 3 A -----
        // press_button(2'd0, 2'd0, 12);   // 1
        // #1000000;
        // // press_button(2'd0, 2'd1, 12);   // 2
        // // #1000000;
        // // press_button(2'd0, 2'd2, 12);   // 3
        // // #1000000;
        // press_button(2'd0, 2'd3, 12);   // A (+)
        // #1000000;

        // // ----- Row 1 : 4 5 6 E -----
        // press_button(2'd1, 2'd0, 12);   // 4
        // #1000000;
        // // press_button(2'd1, 2'd1, 12);   // 5
        // #1000000;
        // // press_button(2'd1, 2'd2, 12);   // 6
        // // #1000000;
        // press_button(2'd3, 2'd2, 12);   // E (=)
        // #2000000;

        // // ----- Row 2 : 7 8 9 C -----
        // press_button(2'd2, 2'd0, 12);   // 7
        // #1000000;
        // press_button(2'd2, 2'd1, 12);   // 8
        // #1000000;
        // press_button(2'd2, 2'd2, 12);   // 9
        // #1000000;
        // press_button(2'd2, 2'd3, 12);   // C
        // #1000000;

        // // ----- Row 3 : 0 F E D -----
        // press_button(2'd3, 2'd0, 12);   // 0
        // #1000000;
        // press_button(2'd3, 2'd1, 12);   // F
        // #1000000;
        // press_button(2'd3, 2'd2, 12);   // E
        // #1000000;
        // press_button(2'd3, 2'd3, 12);   // D

        




        //new testing does not work


        // Test 1: Basic operation 1+1=2
        $display("Test 1: 1+1=2");
        press_button(2'd0, 2'd0, 12);   // 1
        #5000000;
        press_button(2'd0, 2'd3, 12);   // A (+)
        #5000000;
        press_button(2'd0, 2'd0, 12);   // 1
        #5000000;
        press_button(2'd3, 2'd2, 12);   // E (=) -> Should show 2
        #8000000;

        // Test 2: Chain operation 2+2=4 (using result from previous)
        $display("Test 2: 2+2=4 (chained)");
        press_button(2'd0, 2'd3, 12);   // A (+)
        #5000000;
        press_button(2'd0, 2'd1, 12);   // 2
        #5000000;
        press_button(2'd3, 2'd2, 12);   // E (=) -> Should show 4
        #5000000;

        

        // Test 3: Clear and start fresh 7+5=C
        $display("Test 3: Clear and start fresh 7+5=C");
        press_button(2'd3, 2'd1, 12);   // F (clear)
        #5000000;
        press_button(2'd2, 2'd0, 12);   // 7
        #5000000;
        press_button(2'd0, 2'd3, 12);   // A (+)
        #5000000;
        press_button(2'd1, 2'd1, 12);   // 5
        #5000000;
        press_button(2'd3, 2'd2, 12);   // E (=) -> Should show C (12 in hex)
        #5000000;



        // Test 4: Test multi-digit numbers 10+5=15
        $display("Test 4: Multi-digit 10+5=15");
        press_button(2'd3, 2'd1, 12);   // F (clear)
        #5000000;
        press_button(2'd0, 2'd0, 12);   // 1
        #5000000;
        press_button(2'd3, 2'd0, 12);   // 0
        #5000000;
        press_button(2'd0, 2'd3, 12);   // A (+)
        #5000000;
        press_button(2'd1, 2'd1, 12);   // 5
        #5000000;
        press_button(2'd3, 2'd2, 12);   // E (=) -> Should show 15 (hex)
        #5000000;

        // Finish simulation
        $display("Simulation complete");
        #100000;
        $finish;
    end

endmodule