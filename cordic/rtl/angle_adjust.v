`include "cordic_config.v"

module angle_adjust
#(
   parameter   NUM_DATA             = 3,
   parameter   FUNC_WIDTH           = 1,
   parameter   DATA_WIDTH           = 16,
   parameter   TOTAL_DATA_WIDTH     = NUM_DATA*DATA_WIDTH,
   parameter   TOTAL_WIDTH          = TOTAL_DATA_WIDTH+FUNC_WIDTH,
   
   parameter   X                    = 2,
   parameter   Y                    = 1,
   parameter   Z                    = 0
)(
   input                            i_vld,
   input       [TOTAL_WIDTH-1:0]    i_data,
   output                           o_vld,
   output      [TOTAL_WIDTH-1:0]    o_data
);
   localparam                            ROT        = 1'b0;
   localparam                            VEC        = 1'b1;
   localparam signed [DATA_WIDTH-1:0]    POS_PI     = 25736; 
   localparam signed [DATA_WIDTH-1:0]    NEG_PI     =-POS_PI; 
   localparam signed [DATA_WIDTH-1:0]    POS_H_PI   = 12867; 
   localparam signed [DATA_WIDTH-1:0]    NEG_H_PI   =-POS_H_PI;

   wire              [FUNC_WIDTH-1:0]    input_func;
   wire       signed [DATA_WIDTH-1:0]    input_data  [NUM_DATA-1:0];
   reg               [FUNC_WIDTH-1:0]    output_func;
   reg        signed [DATA_WIDTH-1:0]    output_data [NUM_DATA-1:0];
   
   //assign {input_func, input_data[Z], input_data[Y], input_data[X]} = i_data;
   assign input_func    =         i_data[TOTAL_WIDTH-1];
   assign input_data[X] = $signed(i_data[X*DATA_WIDTH +: DATA_WIDTH]);
   assign input_data[Y] = $signed(i_data[Y*DATA_WIDTH +: DATA_WIDTH]);
   assign input_data[Z] = $signed(i_data[Z*DATA_WIDTH +: DATA_WIDTH]);
    
   always @* begin
      output_func = input_func;
      output_data[X] = {DATA_WIDTH{1'bx}}; 
      output_data[Y] = {DATA_WIDTH{1'bx}};
      output_data[Z] = {DATA_WIDTH{1'bx}};
      
      if (input_func == VEC) begin
         output_data[X] = input_data[X];
         output_data[Y] = input_data[Y];
         output_data[Z] = input_data[Z];
      end 
      else begin
         case ({(input_data[Z] > POS_H_PI), (input_data[Z] < NEG_H_PI)})
             2'b00: begin // Angle in range
                 output_data[X] = input_data[X];
                 output_data[Y] = input_data[Y];
                 output_data[Z] = input_data[Z];
             end
             2'b01: begin // Angle negativel[Y] out of range
                 output_data[X] = -input_data[X];
                 output_data[Y] = -input_data[Y];
                 output_data[Z] = input_data[Z] + POS_PI;
             end
             2'b11: begin // Error combination 
                 output_data[X] = {DATA_WIDTH{1'bx}};
                 output_data[Y] = {DATA_WIDTH{1'bx}};
                 output_data[Z] = {DATA_WIDTH{1'bx}};
             end
             2'b10: begin // Angle positivel[Y] out of range
                 output_data[X] = -input_data[X];
                 output_data[Y] = -input_data[Y];
                 output_data[Z] = input_data[Z] + NEG_PI;
             end
             default: begin 
                 output_data[X] = {DATA_WIDTH{1'bx}};
                 output_data[Y] = {DATA_WIDTH{1'bx}};
                 output_data[Z] = {DATA_WIDTH{1'bx}};
             end
         endcase
      end
   end
   
   assign o_vld = i_vld;
   assign o_data = {output_func, output_data[X], output_data[Y], output_data[Z]};

endmodule
