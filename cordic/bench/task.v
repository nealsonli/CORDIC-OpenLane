task initialize_signals();
   begin
      #OFFSET i_rst      =1'b1;
              i_clk      =1'b0;
      #OFFSET i_vld      =1'b0;
      #OFFSET i_data     ={TOTAL_WIDTH{1'b0}};
   end
endtask

task reset_signals();
   begin
      repeat (10) @(posedge i_clk);
      initialize_signals();
   end
endtask

task simple();
   begin
      reset_signals();
        
      @(posedge i_clk);
      #RST_OFFSET    i_rst  =  1'b0;
      
      repeat (10) @(posedge i_clk);
      
      @(posedge i_clk);
      #OFFSET        i_vld  =  1'b1;
      //                         func     x        y       z
      //#OFFSET        i_data = {1'b0,16'hC000,16'hC000,16'h2AEE};
      #OFFSET        i_data = {1'b0,16'h4000,16'h4000,16'hC667};
      //#OFFSET        i_data = {1'b1,16'h4000,16'h4000,16'h0000};
      
      @(posedge i_clk);
      #OFFSET        i_vld  =  1'b0;
      
      repeat (20) @(posedge i_clk);
      
      @(posedge i_clk);
      #OFFSET        i_vld  =  1'b1;
      #OFFSET        i_data = 49'd100;
      
      @(posedge i_clk);
      #OFFSET        i_vld  =  1'b0;
      
      reset_signals();
    end
endtask


