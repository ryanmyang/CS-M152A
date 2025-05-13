module basys3 (/*AUTOARG*/
   // Outputs
   output [6:0] seg,
//   output reg  dp,
   output [3:0] an,
   
   // Inputs
   input wire [1:0] sw, 
   input wire btnS, 
   input wire btnR, 
   input wire clk
   );
   
   wire clk_1hz;
  wire clk_2hz;
   wire clk_500hz;
   wire clk_4hz;
   clock clock_module (.clk(clk), .clk_1hz(clk_1hz), .clk_2hz(clk_2hz), .clk_500hz(clk_500hz), .clk_4hz(clk_4hz));
   
     wire [3:0] dig3;
    wire [3:0] dig2;
    wire [3:0] dig1;
    wire [3:0] dig0;
    reg enable;
    reg btnSDB;
     reg [1:0] sw_db;
     reg rst_db;

     wire adj = sw_db[1]; // set the adj wire to the debounced version of the switch
     wire sel = sw_db[0]; // set the sel wire to the debounced version of the switch

     stopwatch stopwatch (
         .clk_1hz(clk_1hz),
         .clk_2hz(clk_2hz),
         .rst(rst_db),
         .enable(enable),
         .adj(adj),
         .sel(sel),
        .dig3(dig3), .dig2(dig2), .dig1(dig1), .dig0(dig0)
     );   
     display_mux display_mux(
         .clk_500hz(clk_500hz),
         .clk_4hz(clk_4hz),
         .adj_sw(adj),
         .sel_sw(sel),
         .dig3(dig3), .dig2(dig2), .dig1(dig1), .dig0(dig0),
         .an(an), .seg(seg)
     );
    
    always @ (posedge btnSDB) begin
         enable <= ~enable;
    end 
    
    always @(posedge clk_500hz) begin
         btnSDB <= btnS;
         sw_db <= sw;
         rst_db <= btnR;
    end
//   always @ (posedge clk) begin
        
//   end
   

endmodule // basys3
// Local Variables:
// verilog-library-flags:("-f ../input.vc")
// End:
