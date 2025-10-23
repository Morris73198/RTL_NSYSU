// Stag4.v - Stage 4 Processing Module (Corrected)
module Stag4(reset, clk, en, Bus_in, W_in, Bus_out);
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
                    Dout[i]<= nDout[i];
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
    
    // Bit-reversal mapping for 16-point DIF FFT
    // Input index → Output index (bit-reversed)
    SandeTukey UTK0(Din[0],  Din[1],  W[0], nDout[0],  nDout[8]);   // 0→0, 1→8
    SandeTukey UTK1(Din[2],  Din[3],  W[1], nDout[4],  nDout[12]);  // 2→4, 3→12
    SandeTukey UTK2(Din[4],  Din[5],  W[2], nDout[2],  nDout[10]);  // 4→2, 5→10
    SandeTukey UTK3(Din[6],  Din[7],  W[3], nDout[6],  nDout[14]);  // 6→6, 7→14
    SandeTukey UTK4(Din[8],  Din[9],  W[4], nDout[1],  nDout[9]);   // 8→1, 9→9
    SandeTukey UTK5(Din[10], Din[11], W[5], nDout[5],  nDout[13]);  // 10→5, 11→13
    SandeTukey UTK6(Din[12], Din[13], W[6], nDout[3],  nDout[11]);  // 12→3, 13→11
    SandeTukey UTK7(Din[14], Din[15], W[7], nDout[7],  nDout[15]);  // 14→7, 15→15
endmodule