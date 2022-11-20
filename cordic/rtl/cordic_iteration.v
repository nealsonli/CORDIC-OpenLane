module cordic_iteration 
#(
   parameter   NUM_ITER             = 12,
   parameter   NUM_STAGE            = 3,
   parameter   NUM_ITER_PER_STG     = NUM_ITER/NUM_STAGE,
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
   input                            i_clk,
   input                            i_rst,
   
   input                            i_vld,
   input       [TOTAL_WIDTH-1:0]    i_data,
   output                           o_vld,
   output      [TOTAL_OP_WIDTH-1:0] o_data
);

   localparam [14*DATA_OP_WIDTH-1:0] ELEM_ANGLE={  
         18'd1,    // 13
         18'd2,    // 12
         18'd4,    // 11
         18'd8,    // 10
         18'd16,   //  9
         18'd32,   //  8
         18'd64,   //  7
         18'd128,  //  6
         18'd256,  //  5
         18'd512,  //  4
         18'd1019, //  3
         18'd2007, //  2
         18'd3799, //  1
         18'd6434  //  0
   };
   
   wire                             cordic_vld     [NUM_STAGE-1:0];
   wire        [FUNC_WIDTH-1:0]     cordic_func    [NUM_STAGE-1:0];
   wire signed [DATA_OP_WIDTH-1:0]  cordic_data    [NUM_STAGE-1:0][NUM_ITER_PER_STG:0][NUM_DATA-1:0];

   // Extend DATA_WIDTH to DATA_OP_WIDTH to handle overflow
   assign cordic_vld [0]       =         i_vld;
   assign cordic_func[0]       =         i_data[TOTAL_WIDTH-1];
   /* verilator lint_off WIDTH */
   assign cordic_data[0][0][X] = $signed(i_data[X*DATA_WIDTH +: DATA_WIDTH]);
   /* verilator lint_off WIDTH */
   assign cordic_data[0][0][Y] = $signed(i_data[Y*DATA_WIDTH +: DATA_WIDTH]);
   /* verilator lint_off WIDTH */
   assign cordic_data[0][0][Z] = $signed(i_data[Z*DATA_WIDTH +: DATA_WIDTH]);
   
   // Generate CORDIC units for each pipe stage
   genvar i, j;
   generate
      for (i=0; i<NUM_STAGE; i=i+1) begin: gen_stage 
         for (j=0; j<NUM_ITER_PER_STG; j=j+1) begin: gen_iter
            localparam STAGE_NUM = i*NUM_ITER_PER_STG+j;
            cordic_unit #(
               .NUM_ITER         (NUM_ITER), 
               .STAGE_NUMBER     (STAGE_NUM), 
               .FUNC_WIDTH       (FUNC_WIDTH), 
               .DATA_OP_WIDTH    (DATA_OP_WIDTH), 
               .ELEM_ANGLE       (ELEM_ANGLE[STAGE_NUM*DATA_OP_WIDTH +: DATA_OP_WIDTH])
            ) u_cordic_unit (
               .i_func           (cordic_func[i]),

               .i_x              (cordic_data[i][j][X]),
               .i_y              (cordic_data[i][j][Y]),
               .i_z              (cordic_data[i][j][Z]),

               .o_x              (cordic_data[i][j+1][X]),
               .o_y              (cordic_data[i][j+1][Y]),
               .o_z              (cordic_data[i][j+1][Z])
            );
         
         end
      end
   endgenerate

   // Generate Flipflops to store pipe stage results
   genvar k;
   generate
      if(NUM_STAGE-1 > 0) begin: gen_inter_stage
         reg                              r_cordic_vld   [NUM_STAGE-2:0];
         reg         [FUNC_WIDTH-1:0]     r_cordic_func  [NUM_STAGE-2:0];
         reg  signed [DATA_OP_WIDTH-1:0]  r_cordic_data  [NUM_STAGE-2:0][NUM_DATA-1:0];

         for (k=0; k<NUM_STAGE-1; k=k+1) begin: gen_stage_ff

            always @(posedge i_clk or posedge i_rst) begin
               if(i_rst) begin
                  r_cordic_func[k]    <= {FUNC_WIDTH{1'b0}};
                  r_cordic_data[k][X] <= {DATA_OP_WIDTH{1'b0}};
                  r_cordic_data[k][Y] <= {DATA_OP_WIDTH{1'b0}};
                  r_cordic_data[k][Z] <= {DATA_OP_WIDTH{1'b0}};
               end 
               else begin
                  r_cordic_vld [k]    <= cordic_vld [k];
                  r_cordic_func[k]    <= cordic_func[k];
                  r_cordic_data[k][X] <= cordic_data[k][NUM_ITER_PER_STG][X];
                  r_cordic_data[k][Y] <= cordic_data[k][NUM_ITER_PER_STG][Y];
                  r_cordic_data[k][Z] <= cordic_data[k][NUM_ITER_PER_STG][Z];
               end
            end

            assign cordic_vld [k+1]       = r_cordic_vld [k]   ;
            assign cordic_func[k+1]       = r_cordic_func[k]   ;
            assign cordic_data[k+1][0][X] = r_cordic_data[k][X];
            assign cordic_data[k+1][0][Y] = r_cordic_data[k][Y];
            assign cordic_data[k+1][0][Z] = r_cordic_data[k][Z];

         end
      end
   endgenerate

   assign o_vld = cordic_vld[NUM_STAGE-1];
   assign o_data = {cordic_func[NUM_STAGE-1], cordic_data[NUM_STAGE-1][NUM_ITER_PER_STG][X], 
                                              cordic_data[NUM_STAGE-1][NUM_ITER_PER_STG][Y], 
                                              cordic_data[NUM_STAGE-1][NUM_ITER_PER_STG][Z]};
endmodule
