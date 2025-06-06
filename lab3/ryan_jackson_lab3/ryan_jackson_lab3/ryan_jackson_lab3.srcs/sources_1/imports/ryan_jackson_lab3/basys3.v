module basys3 (/*AUTOARG*/
   // Outputs
   input seg[6:0],
   input dp,
   input an[3:0],
   
   // Inputs
   input [1:0] sw, 
   input btnS, 
   input btnR, 
   input clk
   );

`include "seq_definitions.v"
   
   // USB-UART
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   reg [16:0]  clk_dv;
   
   // ===========================================================================
   // 763Hz timing signal for clock enable
   // ===========================================================================

   assign clk_dv_inc = clk_dv + 1;
   
   always @ (posedge clk)
     if (rst)
       begin
          clk_dv   <= 0;
          clk_en   <= 1'b0;
       end
     else
       begin
          clk_dv   <= clk_dv_inc[16:0];
          clk_en   <= clk_dv_inc[17];
       end
   
   // ===========================================================================
   // Instruction Stepping Control
   // ===========================================================================

   always @ (posedge clk)
     if (rst)
       begin
          inst_wd[7:0] <= 0;
          step_d[2:0]  <= 0;
       end
     else if (clk_en)
       begin
          inst_wd[7:0] <= sw[7:0];
          step_d[2:0]  <= {btnS, step_d[2:1]};
       end

   always @ (posedge clk)
     if (rst)
       inst_vld <= 1'b0;
     else
       inst_vld <= ~step_d[0] & step_d[1] & clk_en_d;

   always @ (posedge clk)
     if (rst)
       inst_cnt <= 0;
     else if (inst_vld)
       inst_cnt <= inst_cnt + 1;

   assign led[7:0] = inst_cnt[7:0];
   
   // ===========================================================================
   // Sequencer
   // ===========================================================================

   seq seq_ (// Outputs
             .o_tx_data                 (seq_tx_data[seq_dp_width-1:0]),
             .o_tx_valid                (seq_tx_valid),
             // Inputs
             .i_tx_busy                 (uart_tx_busy),
             .i_inst                    (inst_wd[seq_in_width-1:0]),
             .i_inst_valid              (inst_vld),
             /*AUTOINST*/
             // Inputs
             .clk                       (clk),
             .rst                       (rst));
   
   // ===========================================================================
   // UART controller
   // ===========================================================================

   uart_top uart_top_ (// Outputs
                       .o_tx            (RsTx),
                       .o_tx_busy       (uart_tx_busy),
                       .o_rx_data       (uart_rx_data[7:0]),
                       .o_rx_valid      (uart_rx_valid),
                       // Inputs
                       .i_rx            (RsRx),
                       .i_tx_data       (seq_tx_data[seq_dp_width-1:0]),
                       .i_tx_stb        (seq_tx_valid),
                       /*AUTOINST*/
                       // Inputs
                       .clk             (clk),
                       .rst             (rst));
   
endmodule // basys3
// Local Variables:
// verilog-library-flags:("-f ../input.vc")
// End:
