`timescale 1ns / 1ps

module PmodKYPD(
    clk,
    JA,
    an,
    seg
    );
	 
	 
	input clk;					// 100Mhz onboard clock
	inout [7:0] JA;			// Port JA on Nexys3, JA[3:0] is Columns, JA[10:7] is rows
	output [3:0] an;			// Anodes on seven segment display
	output [6:0] seg;			// Cathodes on seven segment display


	
	// Output wires
	wire [3:0] an;
	wire [6:0] seg;
	
	wire [3:0] Decode;

	Decoder C0(
			.clk(clk),
			.Row(JA[7:4]),
			.Col(JA[3:0]),
			.DecodeOut(Decode)
	);

	DisplayController C1(
			.DispVal(Decode),
			.anode(an),
			.segOut(seg)
	);

endmodule
