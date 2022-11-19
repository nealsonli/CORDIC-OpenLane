module tb_cordic;
   //`include "cordic_config.v"
//---------------------------------------------------------------//
   parameter NUM_ITER              = 12;
   parameter NUM_STAGE             = 3;
   parameter EN_SCALE              = 1;
   parameter TOTAL_WIDTH           = 49;
//---------------------------------------------------------------//
   reg                              i_clk;
   reg                              i_rst;
   reg                              i_vld;
   reg       [TOTAL_WIDTH-1:0]      i_data;
   wire                             o_vld;
   wire      [TOTAL_WIDTH-1:0]      o_data;
//---------------------------------------------------------------//
   parameter      PERIODCLK2        = 5;
   parameter real DUTY_CYCLE        = 0.5;
   parameter real OFFSET_SAMPLE     = 0;
   parameter real OFFSET            = 0.1;
   parameter real RST_OFFSET        = 0.1;
   
   reg   [1000:0] testname;
   integer        returnval;
//---------------------------------------------------------------//

   initial begin
      #OFFSET;
      forever begin
         i_clk = 1'b0;
         #(PERIODCLK2-(PERIODCLK2*DUTY_CYCLE)) i_clk = 1'b1;
         #(PERIODCLK2*DUTY_CYCLE);
      end
   end

   cordic_top #(
      .NUM_ITER            (NUM_ITER   ),
      .NUM_STAGE           (NUM_STAGE  ),
      .EN_SCALE            (EN_SCALE   ),
      .TOTAL_WIDTH         (TOTAL_WIDTH)
   ) cordic_top_0 (
      .i_clk               (i_clk),
      .i_rst               (i_rst),
      .i_vld               (i_vld),
      .i_data              (i_data),
      .o_vld               (o_vld),
      .o_data              (o_data)
   );

   initial begin : TEST_CASE
      $vcdpluson;
      $vcdplusmemon;
      `ifdef SDF 
         $sdf_annotate("./syn_dll.sdf", dll0);
      `endif
      returnval = $value$plusargs("testname=%s", testname);
      
      initialize_signals();
      repeat (10) @(posedge i_clk);	
      
      case(testname)
      	 "simple":               simple();
      	 default:                simple();
      endcase
      #1000 
      $finish;
   end

`include "./task.v"
endmodule 
