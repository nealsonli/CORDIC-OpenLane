module scale 
#(
   parameter   NUM_ITER             = 12,
   parameter   EN_SCALE             = 1,

   parameter   NUM_DATA             = 3,
   parameter   FUNC_WIDTH           = 1,
   parameter   DATA_WIDTH           = 16,
   parameter   TOTAL_DATA_WIDTH     = NUM_DATA*DATA_WIDTH,
   parameter   TOTAL_WIDTH          = TOTAL_DATA_WIDTH+FUNC_WIDTH,
   
   parameter   DATA_OP_WIDTH        = 18,
   parameter   TOTAL_DATA_OP_WIDTH  = NUM_DATA*DATA_OP_WIDTH,
   parameter   TOTAL_OP_WIDTH       = TOTAL_DATA_OP_WIDTH+FUNC_WIDTH,
   parameter   X                    = 2,
   parameter   Y                    = 1,
   parameter   Z                    = 0
)(
   input                            i_vld,
   input       [TOTAL_OP_WIDTH-1:0] i_data,
   output                           o_vld,
   output      [TOTAL_WIDTH-1:0]    o_data
);
   localparam [0:14*DATA_OP_WIDTH-1] K={
         18'd5642,  //  1 0x016A0
         18'd5181,  //  2 0x0143D
         18'd5026,  //  3 0x013A2
         18'd4987,  //  4 0x0137B
         18'd4977,  //  5 0x01371
         18'd4975,  //  6 0x0136F
         18'd4974,  //  7 0x0136E
         18'd4974,  //  8 0x0136E
         18'd4974,  //  9 0x0136E
         18'd4974,  // 10 0x0136E
         18'd4974,  // 11 0x0136E
         18'd4974,  // 12 0x0136E
         18'd4974,  // 13 0x0136E
         18'd4974   // 14 0x0136E
   };

   localparam DATA_MUL_WIDTH        = 2*DATA_OP_WIDTH-1;
   localparam INT_WIDTH             = 4;
   localparam FRAC_WIDTH            = 13;
   localparam FRAC_LSB              = FRAC_WIDTH;
   localparam INT_MSB               = INT_WIDTH + 2*FRAC_WIDTH-1;

   wire        [FUNC_WIDTH-1:0]     output_func;
   wire signed [DATA_WIDTH-1:0]     output_data[NUM_DATA-1:0];

   generate
      if(EN_SCALE == 1) begin: sc_0
         wire signed [DATA_MUL_WIDTH-1:0] scale_x;
         wire signed [DATA_MUL_WIDTH-1:0] scale_y;
         
         assign scale_x = $signed(i_data[X*DATA_OP_WIDTH +: DATA_OP_WIDTH]) * $signed(K[NUM_ITER*DATA_OP_WIDTH +: DATA_OP_WIDTH]);
         assign scale_y = $signed(i_data[Y*DATA_OP_WIDTH +: DATA_OP_WIDTH]) * $signed(K[NUM_ITER*DATA_OP_WIDTH +: DATA_OP_WIDTH]);
         assign output_data[X] = {scale_x[DATA_MUL_WIDTH-1], scale_x[INT_MSB-2:FRAC_LSB]};
         assign output_data[Y] = {scale_y[DATA_MUL_WIDTH-1], scale_y[INT_MSB-2:FRAC_LSB]};
      end
      else begin: sc_0
         assign output_data[X] = $signed(i_data[X*DATA_OP_WIDTH +: DATA_OP_WIDTH]);
         assign output_data[Y] = $signed(i_data[Y*DATA_OP_WIDTH +: DATA_OP_WIDTH]);
      end
   endgenerate

   assign output_func    =         i_data[TOTAL_OP_WIDTH-1];
   assign output_data[Z] = $signed(i_data[Z*DATA_OP_WIDTH +: DATA_OP_WIDTH]);
   assign o_vld  = i_vld;
   assign o_data = {output_func, output_data[X], output_data[Y], output_data[Z]};
   
endmodule
