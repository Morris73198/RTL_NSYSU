// insert_to_Queue.v - 輸入緩衝佇列
module insert_to_Queue(reset, clk, Din, QB);
    input reset, clk;
    input [31:0] Din;
    output [16*32-1:0] QB;
    
    reg [31:0] QD[0:15];
    integer i;
    
    assign QB = {QD[15], QD[14], QD[13], QD[12],
                 QD[11], QD[10], QD[9],  QD[8],
                 QD[7],  QD[6],  QD[5],  QD[4],
                 QD[3],  QD[2],  QD[1],  QD[0]};
    
    always @(posedge clk) begin
        if(reset) begin
            for(i = 0; i < 16; i = i + 1) begin
                QD[i] <= 32'd0;
            end
        end
        else begin
            for(i = 0; i < 15; i = i + 1)
                QD[i] <= QD[i + 1];
            QD[15] <= Din;
        end
    end
endmodule