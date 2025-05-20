`timescale 1ns / 1ps

module basys3(
    input clk, // 100Mhz onboard clock
    input JB, // Port JB on Nexys3, JB[3:0] is Columns, JB[10:7] is rows
    output wire an, // Anodes on seven segment display
    output wire seg // Cathodes on seven segment display
    );
	
	
	wire [3:0] KeypadVal;

	KeypadInput KeypadInput (
			.clk(clk),
			.Row(JB[7:4]),
			.Col(JB[3:0]),
			.DecodeOut(KeypadVal)
	);

	DisplayController  DisplayController (
			.DispVal(KeypadVal),
			.anode(an),
			.segOut(seg)
	);

endmodule
