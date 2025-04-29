
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
        D = 12'b000001111101;  // 125 (spec example, should be 128)
        #10;
        D = 12'b000001111110;  // 126
        #10;
        D = 12'b000001111111;  // 127
        #10;
        D = 12'b000010000000;  // 128
        #10;
        D = 12'b000010000001;  // 129
        #10;
        D = 12'b000010000111;  // 135
        #10
        D = 12'b000010001000;  // 136
        #10
        D = 12'b000010001001;  // 137
        #10
        D = 12'b000010010000;  // 144
        #10;
        // negatives
        D = ~12'b000001111101 + 1;  // 125 (spec example, should be 128)
        #10;
        D = ~12'b000001111110 + 1;  // 126
        #10;
        D = ~12'b000001111111 + 1;  // 127
        #10;
        D = ~12'b000010000000 + 1;  // 128
        #10;
        D = ~12'b000010000001 + 1;  // 129
        #10;

        // Normalization testing

        D = 12'b000000010000;  // +16
        #10;
        D = 12'b000000111000;  // +56
        #10;


        $finish;
    end

endmodule