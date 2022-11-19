`ifndef __CORDIC_CONSTANT__
`define __CORDIC_CONSTANT__
   
   //// dimention
   //localparam NUM_DATA              = 3;
   //localparam DATA_WIDTH            = 16;
   //localparam FUNC_WIDTH            = 1;
   //localparam TOTAL_DATA_WIDTH      = NUM_DATA*DATA_WIDTH;
   //localparam TOTAL_WIDTH           = TOTAL_DATA_WIDTH+FUNC_WIDTH;
   //
   //localparam DATA_OP_WIDTH         = 18;
   //localparam TOTAL_DATA_OP_WIDTH   = NUM_DATA*DATA_WIDTH;
   //localparam TOTAL_OP_WIDTH        = TOTAL_DATA_OP_WIDTH+FUNC_WIDTH;
   //
   //localparam DATA_MUL_WIDTH        = 2*DATA_OP_WIDTH-1;
   //localparam INT_WIDTH             = 4;
   //localparam FRAC_WIDTH            = 13;
   //localparam FRAC_LSB              = FRAC_WIDTH;
   //localparam INT_MSB               = INT_WIDTH + 2*FRAC_WIDTH-1;

   //// index
   //localparam X                     = 0;
   //localparam Y                     = 1;
   //localparam Z                     = 2;
   //localparam ROT                   = 0;
   //localparam VEC                   = 1;
   //
   //// PI
   //localparam signed [DATA_WIDTH-1:0]    POS_PI     = 25736; 
   //localparam signed [DATA_WIDTH-1:0]    NEG_PI     =-POS_PI; 
   //localparam signed [DATA_WIDTH-1:0]    POS_H_PI   = 12867; 
   //localparam signed [DATA_WIDTH-1:0]    NEG_H_PI   =-POS_H_PI;

   // Scaling Factor
   //localparam signed [DATA_OP_WIDTH-1:0] K          [1:14]
   //                                                 ={5642,     //  1 0x016A0 
   //                                                   5181,     //  2 0x0143D 
   //                                                   5026,     //  3 0x013A2 
   //                                                   4987,     //  4 0x0137B 
   //                                                   4977,     //  5 0x01371 
   //                                                   4975,     //  6 0x0136F 
   //                                                   4974,     //  7 0x0136E 
   //                                                   4974,     //  8 0x0136E 
   //                                                   4974,     //  9 0x0136E 
   //                                                   4974,     // 10 0x0136E 
   //                                                   4974,     // 11 0x0136E 
   //                                                   4974,     // 12 0x0136E 
   //                                                   4974,     // 13 0x0136E
   //                                                   4974};    // 14 0x0136E
   
   // Elementary Angle 
   //localparam signed [DATA_OP_WIDTH-1:0] ELEM_ANGLE [0:13]
   //                                                 ={18'd6434, //  0
   //                                                   18'd3799, //  1
   //                                                   18'd2007, //  2
   //                                                   18'd1019, //  3
   //                                                   18'd512,  //  4
   //                                                   18'd256,  //  5
   //                                                   18'd128,  //  6
   //                                                   18'd64,   //  7
   //                                                   18'd32,   //  8
   //                                                   18'd16,   //  9
   //                                                   18'd8,    // 10
   //                                                   18'd4,    // 11
   //                                                   18'd2,    // 12
   //                                                   18'd1};   // 13
`endif
