`timescale 1ns/1ps

// 詳細測試FFT16的每個Stage輸出
module tb_FFT16;
    reg reset, clk, en;
	 
    reg [16*32-1:0] Bus_in;
    wire [16*32-1:0] BS1_out, BS2_out, BS3_out, BS4_out;
    
    wire [8*32-1:0] W1, W2, W3, W4;
    
    // 直接實例化各個Stage（複製FFT16.v的連接）
    assign W1 = {
        32'hFC4EFE78,  // W16^7
        32'hFD2CFD4C,  // W16^6
        32'hFE78FC4E,  // W16^5
        32'h0000FC00,  // W16^4
        32'h0188FC4E,  // W16^3
        32'h02D4FD4C,  // W16^2
        32'h03B2FE78,  // W16^1
        32'h04000000   // W16^0
    };
    
    assign W2 = {
        32'hFD2CFD4C,  // W16^6
        32'h0000FC00,  // W16^4
        32'h02D4FD4C,  // W16^2
        32'h04000000,  // W16^0
        32'hFD2CFD4C,  // W16^6
        32'h0000FC00,  // W16^4
        32'h02D4FD4C,  // W16^2
        32'h04000000   // W16^0
    };
    
    assign W3 = {
        32'h0000FC00,  // W16^4
        32'h04000000,  // W16^0
        32'h0000FC00,  // W16^4
        32'h04000000,  // W16^0
        32'h0000FC00,  // W16^4
        32'h04000000,  // W16^0
        32'h0000FC00,  // W16^4
        32'h04000000   // W16^0
    };
    
    assign W4 = {
        32'h04000000, 32'h04000000,
        32'h04000000, 32'h04000000,
        32'h04000000, 32'h04000000,
        32'h04000000, 32'h04000000
    };
    
    Stag1 SU0(reset, clk, 1'b1, Bus_in,  W1, BS1_out);
    Stag2 SU1(reset, clk, 1'b1, BS1_out, W2, BS2_out);
    Stag3 SU2(reset, clk, 1'b1, BS2_out, W3, BS3_out);
    Stag4 SU3(reset, clk, 1'b1, BS3_out, W4, BS4_out);
    
    initial clk = 0;
    always #5 clk = ~clk;
    
    integer i;
    reg [31:0] test_in[0:15];
    reg [31:0] stage1[0:15], stage2[0:15], stage3[0:15], stage4[0:15];
    
    initial begin
        $display("========================================");
        $display("  FFT16 Detailed Stage Analysis");
        $display("========================================\n");
        
        // 準備測試資料：impulse
        test_in[0] = 32'h04000000;  // 1024 + 0j
        for(i = 1; i < 16; i = i + 1)
            test_in[i] = 32'h00000000;
        
        Bus_in = {test_in[15], test_in[14], test_in[13], test_in[12],
                  test_in[11], test_in[10], test_in[9],  test_in[8],
                  test_in[7],  test_in[6],  test_in[5],  test_in[4],
                  test_in[3],  test_in[2],  test_in[1],  test_in[0]};

//		  Bus_in = {test_in[0],  test_in[1],  test_in[2],  test_in[3],
//					   test_in[4],  test_in[5],  test_in[6],  test_in[7],
//					   test_in[8],  test_in[9],  test_in[10], test_in[11],
//					   test_in[12], test_in[13], test_in[14], test_in[15]};
        
        $display("Input (Impulse at index 0):");
        $display("  x[0] = 1024+j0, x[1..15] = 0\n");
        
        // Reset
        reset = 1;
        en = 0;
        #20 reset = 0;
        #10;
        
        // Enable所有stage
        @(posedge clk);
        en = 1;
        
        // 等待4個cycle讓資料通過所有stage
        repeat(4) @(posedge clk);
        en = 0;
        @(posedge clk);
        
        // 收集各stage輸出
        for(i = 0; i < 16; i = i + 1) begin
            stage1[i] = BS1_out[i*32 +: 32];
            stage2[i] = BS2_out[i*32 +: 32];
            stage3[i] = BS3_out[i*32 +: 32];
            stage4[i] = BS4_out[i*32 +: 32];
        end
        
        // 顯示Stage 1輸出
        $display("========================================");
        $display("  Stage 1 Output");
        $display("========================================");
        for(i = 0; i < 16; i = i + 1) begin
            $display("S1[%2d] = %h (Real=%5d, Imag=%5d)", 
                     i, stage1[i],
                     $signed(stage1[i][31:16]),
                     $signed(stage1[i][15:0]));
        end
        
        // 顯示Stage 2輸出
        $display("\n========================================");
        $display("  Stage 2 Output");
        $display("========================================");
        for(i = 0; i < 16; i = i + 1) begin
            $display("S2[%2d] = %h (Real=%5d, Imag=%5d)", 
                     i, stage2[i],
                     $signed(stage2[i][31:16]),
                     $signed(stage2[i][15:0]));
        end
        
        // 顯示Stage 3輸出
        $display("\n========================================");
        $display("  Stage 3 Output");
        $display("========================================");
        for(i = 0; i < 16; i = i + 1) begin
            $display("S3[%2d] = %h (Real=%5d, Imag=%5d)", 
                     i, stage3[i],
                     $signed(stage3[i][31:16]),
                     $signed(stage3[i][15:0]));
        end
        
        // 顯示Stage 4輸出
        $display("\n========================================");
        $display("  Stage 4 Output (Final)");
        $display("========================================");
        for(i = 0; i < 16; i = i + 1) begin
            $display("S4[%2d] = %h (Real=%5d, Imag=%5d)", 
                     i, stage4[i],
                     $signed(stage4[i][31:16]),
                     $signed(stage4[i][15:0]));
        end
        
        // 分析
        $display("\n========================================");
        $display("  Analysis");
        $display("========================================");
        $display("Expected: All outputs ≈ 1024+j0 for impulse input");
        $display("Actual: Check above results");
        
        $display("\nNon-zero outputs:");
        for(i = 0; i < 16; i = i + 1) begin
            if(stage4[i] != 32'h00000000) begin
                $display("  Output[%2d] = %d + j%d", i,
                         $signed(stage4[i][31:16]),
                         $signed(stage4[i][15:0]));
            end
        end
        
        $display("\n========================================");
        $display("  Test Completed!");
        $display("========================================");
        #100;
        $finish;
    end
endmodule