// ============================================================================
// Systolic Array 4x4 Matrix Multiplier
// Based on Digital Circuit Design and Verification L3
// ============================================================================

// Processing Element (PE) Module
module PE(
    input clk,
    input reset,
    input [7:0] Ain,
    input [7:0] Bin,
    output reg [7:0] Aout,
    output reg [7:0] Bout,
    output reg [15:0] PEout
);
    wire [15:0] PEtmp;
    
    assign PEtmp = PEout + Ain * Bin;
    
    always @(posedge clk) begin
        if(reset) begin
            PEout <= 16'd0;
            Aout <= 8'd0;
            Bout <= 8'd0;
        end
        else begin
            PEout <= PEtmp;
            Aout <= Ain;
            Bout <= Bin;
        end
    end
endmodule

// 4x4 PE Array Module
module PE_Array #(
    parameter Size = 4
)(
    input clk,
    input reset,
    input [Size*8-1:0] AB,  // Size*8 bits for A inputs
    input [Size*8-1:0] BB,  // Size*8 bits for B inputs
    output [Size*Size*8-1:0] PAB // Size*Size*8 bits for outputs (truncated to 8 bits)
);
    
    wire [7:0] A[Size-1:0];
    wire [7:0] B[Size-1:0];
    wire [15:0] PEout[Size-1:0][Size-1:0];
    wire [7:0] PE[Size-1:0][Size-1:0][1:0];
    
    genvar m, n;
    
    // Map input buses to array elements
    generate
        for(m=0; m<Size; m=m+1) begin: BusMap
            assign A[m] = AB[((m+1)*8-1):m*8];
            assign B[m] = BB[((m+1)*8-1):m*8];
        end
    endgenerate
    
    // Map PE outputs to output bus
    generate
        for(m=0; m<Size; m=m+1) begin: PoutMap_R
            for(n=0; n<Size; n=n+1) begin: PoutMap_C
                assign PAB[(m*Size+n+1)*8-1:(m*Size+n)*8] = PEout[m][n][7:0]; // Truncate to 8 bits
            end
        end
    endgenerate
    
    // Instantiate PE array
    generate
        for(m=0; m<Size; m=m+1) begin: R_loop
            for(n=0; n<Size; n=n+1) begin: V_loop
                if((m==0) && (n==0))
                    PE PE_inst(
                        .clk(clk),
                        .reset(reset),
                        .Ain(A[0]),
                        .Bin(B[0]),
                        .Aout(PE[m][n][0]),
                        .Bout(PE[m][n][1]),
                        .PEout(PEout[m][n])
                    );
                else if((m==0) && (n!=0))
                    PE PE_inst(
                        .clk(clk),
                        .reset(reset),
                        .Ain(PE[m][n-1][0]),
                        .Bin(B[n]),
                        .Aout(PE[m][n][0]),
                        .Bout(PE[m][n][1]),
                        .PEout(PEout[m][n])
                    );
                else if((m!=0) && (n==0))
                    PE PE_inst(
                        .clk(clk),
                        .reset(reset),
                        .Ain(A[m]),
                        .Bin(PE[m-1][n][1]),
                        .Aout(PE[m][n][0]),
                        .Bout(PE[m][n][1]),
                        .PEout(PEout[m][n])
                    );
                else
                    PE PE_inst(
                        .clk(clk),
                        .reset(reset),
                        .Ain(PE[m][n-1][0]),
                        .Bin(PE[m-1][n][1]),
                        .Aout(PE[m][n][0]),
                        .Bout(PE[m][n][1]),
                        .PEout(PEout[m][n])
                    );
            end
        end
    endgenerate
    
endmodule

// Top Module for Systolic Array (parameterized)
module array44 #(
    parameter Size = 4
)(
    input reset,
    input clk,
    input [Size*8-1:0] AB,
    input [Size*8-1:0] BB,
    output [Size*Size*8-1:0] PAB
);
    
    PE_Array #(.Size(Size)) PE_Array_inst(
        .clk(clk),
        .reset(reset),
        .AB(AB),
        .BB(BB),
        .PAB(PAB)
    );
    
endmodule