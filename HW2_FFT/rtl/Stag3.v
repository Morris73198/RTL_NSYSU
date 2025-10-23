// Stag3.v - Stage 3 處理模組
module Stag3(reset, clk, en, Bus_in, W_in, Bus_out);
    input reset, clk, en;
    input [16*32-1:0] Bus_in;
    input [8*32-1:0] W_in;
    output [16*32-1:0] Bus_out;
    
    wire [31:0] Din[0:15], nDout[0:15], W[0:7];
    reg [31:0] Dout[0:15];
    integer i;
    
    always @(posedge clk) begin
        if(reset) begin
            for(i = 0; i <= 15; i = i + 1) begin
                Dout[i] <= 32'd0;
            end
        end
        else begin
            if(en) begin
                for(i = 0; i <= 15; i = i + 1) begin
                    Dout[i] <= nDout[i];
                end
            end
        end
    end
    
    assign Bus_out = {Dout[15], Dout[14], Dout[13], Dout[12],
                      Dout[11], Dout[10], Dout[9],  Dout[8],
                      Dout[7],  Dout[6],  Dout[5],  Dout[4],
                      Dout[3],  Dout[2],  Dout[1],  Dout[0]};
    
    assign {Din[15], Din[14], Din[13], Din[12],
            Din[11], Din[10], Din[9],  Din[8],
            Din[7],  Din[6],  Din[5],  Din[4],
            Din[3],  Din[2],  Din[1],  Din[0]} = Bus_in;
    
    assign {W[7], W[6], W[5], W[4],
            W[3], W[2], W[1], W[0]} = W_in;
    
    genvar giii;
    generate
        for(giii = 0; giii <= 1; giii = giii + 1) begin : TK_Loop3
            // 第 1 組: (0,2), (1,3)
			  SandeTukey U0(Din[giii],Din[giii+2],W[giii],nDout[giii],nDout[giii+2]);
			  // 第 2 組: (4,6), (5,7)
			  SandeTukey U1(Din[giii+4],Din[giii+6],W[giii+2],nDout[giii+4],nDout[giii+6]);
			  // 第 3 組: (8,10), (9,11)
			  SandeTukey U2(Din[giii+8],Din[giii+10],W[giii+4],nDout[giii+8],nDout[giii+10]);
			  // 第 4 組: (12,14), (13,15)
			  SandeTukey U3(Din[giii+12],Din[giii+14],W[giii+6],nDout[giii+12],nDout[giii+14]);
        end
    endgenerate
endmodule