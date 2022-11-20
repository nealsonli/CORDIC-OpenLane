
`include "cordic_config.v"

module cordic
(
   input                            i_clk,
   input                            i_rst,
   
   input                            i_vld,
   input       [`TOTAL_WIDTH-1:0]   i_data,
   output                           o_vld,
   output      [`TOTAL_WIDTH-1:0]   o_data
);

   localparam  NUM_ITER_PER_STG     = `NUM_ITER/`NUM_STAGE;
   localparam  NUM_DATA             = 3;
   localparam  FUNC_WIDTH           = 1;
   localparam  DATA_WIDTH           = 16;
   localparam  TOTAL_DATA_WIDTH     = NUM_DATA*DATA_WIDTH;
   localparam  DATA_OP_WIDTH        = 18;
   localparam  TOTAL_DATA_OP_WIDTH  = NUM_DATA*DATA_OP_WIDTH;
   localparam  TOTAL_OP_WIDTH       = TOTAL_DATA_OP_WIDTH+FUNC_WIDTH;
   localparam  X                    = 2;
   localparam  Y                    = 1;
   localparam  Z                    = 0;

   reg                              r_input_vld;
   reg         [`TOTAL_WIDTH-1:0]   r_input_data;
   reg                              r_output_vld;
   reg         [`TOTAL_WIDTH-1:0]   r_output_data;
   
   wire                             aa2it_vld;
   wire        [`TOTAL_WIDTH-1:0]   aa2it_data;
   wire                             it2sc_vld;
   wire        [TOTAL_OP_WIDTH-1:0] it2sc_data;
   wire                             sc2ff_vld;
   wire        [`TOTAL_WIDTH-1:0]   sc2ff_data;
   
   // Input Flipflop
   always @(posedge i_clk or posedge i_rst) begin
      if(i_rst) begin
         r_input_vld  <= 1'b0;
         r_input_data <= {`TOTAL_WIDTH{1'b0}};
      end 
      else begin
         r_input_vld  <= i_vld;
         r_input_data <= i_data;
      end
   end

   // Angle Adjust
   angle_adjust
   #(
      .NUM_DATA            (NUM_DATA           ),
      .FUNC_WIDTH          (FUNC_WIDTH         ),
      .DATA_WIDTH          (DATA_WIDTH         ),
      .TOTAL_DATA_WIDTH    (TOTAL_DATA_WIDTH   ),
      .TOTAL_WIDTH         (`TOTAL_WIDTH       ),
      .X                   (X                  ),
      .Y                   (Y                  ),
      .Z                   (Z                  )
   ) u_angle_adjust (
      .i_vld               (r_input_vld),
      .i_data              (r_input_data),
      .o_vld               (aa2it_vld),
      .o_data              (aa2it_data)
   );

   cordic_iteration
   #(
      .NUM_ITER            (`NUM_ITER           ),
      .NUM_STAGE           (`NUM_STAGE          ),
      .NUM_ITER_PER_STG    (NUM_ITER_PER_STG   ),
      .EN_SCALE            (`EN_SCALE           ),
      
      .NUM_DATA            (NUM_DATA           ),
      .FUNC_WIDTH          (FUNC_WIDTH         ),
      .DATA_WIDTH          (DATA_WIDTH         ),
      .TOTAL_DATA_WIDTH    (TOTAL_DATA_WIDTH   ),
      .TOTAL_WIDTH         (`TOTAL_WIDTH       ),
      .DATA_OP_WIDTH       (DATA_OP_WIDTH      ),
      .TOTAL_DATA_OP_WIDTH (TOTAL_DATA_OP_WIDTH),
      .TOTAL_OP_WIDTH      (TOTAL_OP_WIDTH     ),
      .X                   (X                  ),
      .Y                   (Y                  ),
      .Z                   (Z                  )
   ) u_cordic_iteration (
      .i_clk               (i_clk),
      .i_rst               (i_rst),
      .i_vld               (aa2it_vld),
      .i_data              (aa2it_data),
      .o_vld               (it2sc_vld),
      .o_data              (it2sc_data)
   );

   scale
   #(
      .NUM_ITER            (`NUM_ITER          ),
      .EN_SCALE            (`EN_SCALE          ),
      
      .NUM_DATA            (NUM_DATA           ),
      .FUNC_WIDTH          (FUNC_WIDTH         ),
      .DATA_WIDTH          (DATA_WIDTH         ),
      .TOTAL_DATA_WIDTH    (TOTAL_DATA_WIDTH   ),
      .TOTAL_WIDTH         (`TOTAL_WIDTH       ),
      .DATA_OP_WIDTH       (DATA_OP_WIDTH      ),
      .TOTAL_DATA_OP_WIDTH (TOTAL_DATA_OP_WIDTH),
      .TOTAL_OP_WIDTH      (TOTAL_OP_WIDTH     ),
      .X                   (X                  ),
      .Y                   (Y                  ),
      .Z                   (Z                  )
   ) u_scale (
      .i_vld               (it2sc_vld),
      .i_data              (it2sc_data),
      .o_vld               (sc2ff_vld),
      .o_data              (sc2ff_data)
   );

   // Output Flipflop
   always @(posedge i_clk or posedge i_rst) begin
      if(i_rst) begin
         r_output_vld  <= 1'b0;
         r_output_data <= {`TOTAL_WIDTH{1'b0}};
      end 
      else begin
         r_output_vld  <= sc2ff_vld;
         r_output_data <= sc2ff_data;
      end
   end

   assign o_vld  = r_output_vld;
   assign o_data = r_output_data;
   
endmodule
