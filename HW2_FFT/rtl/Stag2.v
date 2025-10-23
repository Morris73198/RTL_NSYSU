// Stag2.v - Stage 2 處理模組
module Stag2(reset, clk, en, Bus_in, W_in, Bus_out);
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
    
    genvar gii;
    generate
        for(gii = 0; gii <= 3; gii = gii + 1) begin : TK_Loop2
            SandeTukey UTK_A(
                Din[gii],
                Din[gii + 4],
                W[gii],
                nDout[gii],
                nDout[gii + 4]
            );
            SandeTukey UTK_B(
                Din[gii + 8],
                Din[gii + 12],
                W[gii + 4],
                nDout[gii + 8],
                nDout[gii + 12]
            );
        end
    endgenerate
endmodule