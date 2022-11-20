module cordic_unit 
#(
   parameter                                NUM_ITER       = 12,
   /* verilator lint_off WIDTH */
   parameter         [$clog2(NUM_ITER)-1:0] STAGE_NUMBER   =  0,
   parameter                                FUNC_WIDTH     =  1,
   parameter                                DATA_OP_WIDTH  = 18,
   parameter  signed [DATA_OP_WIDTH-1:0]    ELEM_ANGLE     =  0
)(                                         
   input             [FUNC_WIDTH-1:0]      i_func,
                                           
   input      signed [DATA_OP_WIDTH-1:0]   i_x,
   input      signed [DATA_OP_WIDTH-1:0]   i_y,
   input      signed [DATA_OP_WIDTH-1:0]   i_z,

   /* verilator lint_off UNOPTFLAT */                                        
   output reg signed [DATA_OP_WIDTH-1:0]   o_x,
   /* verilator lint_off UNOPTFLAT */
   output reg signed [DATA_OP_WIDTH-1:0]   o_y,
   /* verilator lint_off UNOPTFLAT */
   output reg signed [DATA_OP_WIDTH-1:0]   o_z
);                                         
   wire       signed [DATA_OP_WIDTH-1:0]   x_shift;
   wire       signed [DATA_OP_WIDTH-1:0]   y_shift;
   wire                                    sigma;
   wire                                    sigma_vec;
   wire                                    sigma_rot;

   assign x_shift = i_x >>> STAGE_NUMBER;
   assign y_shift = i_y >>> STAGE_NUMBER;

   assign sigma_rot =  i_z[DATA_OP_WIDTH-1];
   assign sigma_vec =!(i_x[DATA_OP_WIDTH-1] || i_y[DATA_OP_WIDTH-1]);
   assign sigma     =  i_func ? sigma_vec : sigma_rot;

   always @*  begin
       if(sigma == 1'b1) begin //sigma is negative
           o_x = i_x + y_shift;
           o_y = i_y - x_shift;
           o_z = i_z + ELEM_ANGLE;
       end 
       else begin      
           o_x = i_x - y_shift;
           o_y = i_y + x_shift;
           o_z = i_z - ELEM_ANGLE;
       end
   end

endmodule
