module FPCVT(
    input wire [11:0] D,
    output reg S,
    output reg [2:0] E,
    output reg [3:0] F
);

    reg [11:0] magnitude;
    integer shift_amount;
    reg [11:0] shifted;
    
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

            // If magnitude is 0, set E and F to 0, otherwise just count leading zeroes
            //     (The spec only specified the E for leading zeroes, so hardcoding otherwise)
            if (magnitude == 12'b000000000000) begin
                E = 3'b000;
                F = 4'b0000;
            end else begin
                // Count leading zeroes
                E = count_leading_zeroes_set_E(magnitude);
                shift_amount = 3'd7 - E + 1; // calculate how much to shift based on what we set E. 
                shifted = magnitude << shift_amount;
                F = shifted[11:8];
            end


        end


    end


    function automatic [2:0] count_leading_zeroes_set_E(input [11:0] magnitude);
    begin
        if (magnitude[10])      count_leading_zeroes_set_E = 3'd7; // 1 leading 0
        else if (magnitude[9])  count_leading_zeroes_set_E = 3'd6;
        else if (magnitude[8])  count_leading_zeroes_set_E = 3'd5;
        else if (magnitude[7])  count_leading_zeroes_set_E = 3'd4;
        else if (magnitude[6])  count_leading_zeroes_set_E = 3'd3;
        else if (magnitude[5])  count_leading_zeroes_set_E = 3'd2;
        else if (magnitude[4])  count_leading_zeroes_set_E = 3'd1; // 7 leading 0s
        else count_leading_zeroes_set_E = 3'd0; // 8 leading 0s or more
    end
    endfunction

endmodule