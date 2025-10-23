// SandeTukey.v - 蝶形運算單元
module SandeTukey(A, B, W, Aout, Bout);
    input [31:0] A, B, W;
    output [31:0] Aout, Bout;
    
    wire [31:0] X;
    
    CmpAdd U0(A, B, Aout);
    CmpSub U1(A, B, X);
    CmpMul_SR10 U2(X, W, Bout);
endmodule