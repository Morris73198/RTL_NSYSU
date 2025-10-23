// CmpAdd.v - 複數加法模組
module CmpAdd(A, B, Dout);
    input [31:0] A, B;
    output [31:0] Dout;
    
    wire signed [15:0] Ar, Ai, Br, Bi, Dr, Di;
    
    assign {Ar, Ai} = A;
    assign {Br, Bi} = B;
    assign Dr = Ar + Br;
    assign Di = Ai + Bi;
    assign Dout = {Dr, Di};
endmodule