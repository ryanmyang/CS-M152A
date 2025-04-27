
`timescale 1ns/1ps

module FPCVT_tb;

    reg [11:0] D;
    wire S;
    wire [2:0] E;
    wire [3:0] F;

    FPCVT uut (
        .D(D),
        .S(S),
        .E(E),
        .F(F)
    );

    initial begin
        $monitor("Time=%0t | D=%b | S=%b | E=%b | F=%b", $time, D, S, E, F);
        $dumpfile("wave.vcd");
        $dumpvars(0, FPCVT_tb);
        // Test zero
        D = 12'b000000000000;
        #10;

        // Test maximum positive value
        D = 12'b011111111111; // 2047
        #10;

        // Test minimum negative value (-2048)
        D = 12'b100000000000;
        #10;

        // Test -2047
        D = 12'b100000000001;
        #10;

        // Test -1
        D = 12'b111111111111;
        #10;

        // no rounding positive numbers (can be represented with 4 bits F, and E)
        D = 12'b000000000001;  // +1
        #10;
        D = 12'b000000000010;  // +2
        #10;
        D = 12'b000000010000;  // +16
        #10;
        D = 12'b000000100000;  // +32
        #10;
        D = 12'b000001000000;  // +64
        #10;
        D = 12'b000010000000;  // +128
        #10;
        D = 12'b000100000000;  // +256
        #10;

        // small negative numbers
        D = 12'b111111111111;  // -1
        #10;
        D = 12'b111111111110;  // -2
        #10;
        D = 12'b111111100000;  // -16
        #10;

        // positives
        D = 12'b000010101101;  // e.g., +173 decimal
        #10;


        $finish;
    end

endmodule