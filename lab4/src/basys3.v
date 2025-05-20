`timescale 1ns / 1ps

module basys3(
    clk,
    JB,
    an,
    seg
    );
	 
	 
	input clk;					// 100Mhz onboard clock
	inout [7:0] JB;			// Port JB on Nexys3, JB[3:0] is Columns, JB[10:7] is rows
	output [3:0] an;			// Anodes on seven segment display
	output [6:0] seg;			// Cathodes on seven segment display


	
	// Output wires
	wire [3:0] an;
	wire [6:0] seg;
	
	wire [3:0] Decode;

	Decoder Decoder (
			.clk(clk),
			.Row(JB[7:4]),
			.Col(JB[3:0]),
			.DecodeOut(Decode)
	);

	DisplayController  DisplayController (
			.DispVal(Decode),
			.anode(an),
			.segOut(seg)
	);

endmodule
