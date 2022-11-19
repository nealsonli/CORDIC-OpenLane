module cordic_top
#(
   parameter   NUM_ITER             = 12,
   parameter   NUM_STAGE            = 3,
   parameter   EN_SCALE             = 1,
   parameter   TOTAL_WIDTH          = 49
)(
   input                            i_clk,
   input                            i_rst,
   input                            i_vld,
   input       [TOTAL_WIDTH-1:0]    i_data,
   output                           o_vld,
   output      [TOTAL_WIDTH-1:0]    o_data
);

   cordic #(
      .NUM_ITER            (NUM_ITER   ),
      .NUM_STAGE           (NUM_STAGE  ),
      .EN_SCALE            (EN_SCALE   ),
      .TOTAL_WIDTH         (TOTAL_WIDTH)
   ) cordic_0 (
      .i_clk               (i_clk),
      .i_rst               (i_rst),
      .i_vld               (i_vld),
      .i_data              (i_data),
      .o_vld               (o_vld),
      .o_data              (o_data)
   );

endmodule
