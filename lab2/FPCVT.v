module FPCVT(
    input wire [11:0] D,
    output reg S,
    output reg [2:0] E,
    output reg [3:0] F
);

    reg [11:0] magnitude;
    always @(*) begin
        S = D[11];
        //If D is -2048, hardcode the conversion from two's complement to floating point
        if (D == 12'b100000000000) begin
            E = 3'b111;
            F = 4'b1111;
        end


        else begin // everything else

        // If positive keep mag, if negative, take 2's complement
            if (S == 1'b0) begin
                magnitude = D;
            end else begin
                magnitude = ~D + 1;
            end

            

        end


    end

endmodule