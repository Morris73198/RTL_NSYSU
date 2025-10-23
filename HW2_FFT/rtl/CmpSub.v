// CmpSub.v - 複數減法模組
module CmpSub(A, B, Dout);
    input [31:0] A, B;
    output [31:0] Dout;
    
    wire signed [15:0] Ar, Ai, Br, Bi, Dr, Di;
    
    assign {Ar, Ai} = A;
    assign {Br, Bi} = B;
    assign Dr = Ar - Br;
    assign Di = Ai - Bi;
    assign Dout = {Dr, Di};
endmodule