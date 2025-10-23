// CmpMul_SR10.v - 複數乘法模組
module CmpMul_SR10(A, B, Dout);
    input [31:0] A, B;
    output [31:0] Dout;
    
    wire signed [15:0] Ar, Ai, Br, Bi;
    wire signed [31:0] Tr, Ti, Tr1, Ti1, Tr2, Ti2;
    
    assign {Ar, Ai} = A;
    assign {Br, Bi} = B;
    
    assign Tr1 = Ar * Br;
    assign Ti1 = Ai * Bi;
    assign Tr2 = Ar * Bi;
    assign Ti2 = Ai * Br;
    
    assign Tr = Tr1 - Ti1;
    assign Ti = Tr2 + Ti2;
    
    assign Dout = {Tr[25:10], Ti[25:10]};
endmodule