// ============================================================================
// Testbench for 8x8 Systolic Array Matrix Multiplier
// Based on 4x4 design, extended to 8x8
// ============================================================================

`timescale 1ns/10ps

module array88tb;
    parameter Size = 8;
    parameter BusSize = 8*8;
    
    reg clk;
    reg reset;
    wire [7:0] As[Size-1:0][Size-1:0];
    wire [7:0] Bs[Size-1:0][Size-1:0];
    reg [7:0] A[Size-1:0];
    reg [7:0] B[Size-1:0];
    wire [7:0] PEout[Size-1:0][Size-1:0];
    integer i, k, ii;
    
    wire [Size*Size*8-1:0] PAB;
    reg [BusSize-1:0] AB, BB;
    
    // Test matrices A and B
    // A = [1 1 1 1 1 1 1 1]
    //     [2 2 2 2 2 2 2 2]
    //     [3 3 3 3 3 3 3 3]
    //     [4 4 4 4 4 4 4 4]
    //     [5 5 5 5 5 5 5 5]
    //     [6 6 6 6 6 6 6 6]
    //     [7 7 7 7 7 7 7 7]
    //     [8 8 8 8 8 8 8 8]
    
    assign {As[0][0],As[0][1],As[0][2],As[0][3],As[0][4],As[0][5],As[0][6],As[0][7],
            As[1][0],As[1][1],As[1][2],As[1][3],As[1][4],As[1][5],As[1][6],As[1][7],
            As[2][0],As[2][1],As[2][2],As[2][3],As[2][4],As[2][5],As[2][6],As[2][7],
            As[3][0],As[3][1],As[3][2],As[3][3],As[3][4],As[3][5],As[3][6],As[3][7],
            As[4][0],As[4][1],As[4][2],As[4][3],As[4][4],As[4][5],As[4][6],As[4][7],
            As[5][0],As[5][1],As[5][2],As[5][3],As[5][4],As[5][5],As[5][6],As[5][7],
            As[6][0],As[6][1],As[6][2],As[6][3],As[6][4],As[6][5],As[6][6],As[6][7],
            As[7][0],As[7][1],As[7][2],As[7][3],As[7][4],As[7][5],As[7][6],As[7][7]}
        = {8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,8'd1,
           8'd2,8'd2,8'd2,8'd2,8'd2,8'd2,8'd2,8'd2,
           8'd3,8'd3,8'd3,8'd3,8'd3,8'd3,8'd3,8'd3,
           8'd4,8'd4,8'd4,8'd4,8'd4,8'd4,8'd4,8'd4,
           8'd5,8'd5,8'd5,8'd5,8'd5,8'd5,8'd5,8'd5,
           8'd6,8'd6,8'd6,8'd6,8'd6,8'd6,8'd6,8'd6,
           8'd7,8'd7,8'd7,8'd7,8'd7,8'd7,8'd7,8'd7,
           8'd8,8'd8,8'd8,8'd8,8'd8,8'd8,8'd8,8'd8};
    
    // B = [1 2 3 4 5 6 7 8]
    //     [1 2 3 4 5 6 7 8]
    //     [1 2 3 4 5 6 7 8]
    //     [1 2 3 4 5 6 7 8]
    //     [1 2 3 4 5 6 7 8]
    //     [1 2 3 4 5 6 7 8]
    //     [1 2 3 4 5 6 7 8]
    //     [1 2 3 4 5 6 7 8]
    
    assign {Bs[0][0],Bs[0][1],Bs[0][2],Bs[0][3],Bs[0][4],Bs[0][5],Bs[0][6],Bs[0][7],
            Bs[1][0],Bs[1][1],Bs[1][2],Bs[1][3],Bs[1][4],Bs[1][5],Bs[1][6],Bs[1][7],
            Bs[2][0],Bs[2][1],Bs[2][2],Bs[2][3],Bs[2][4],Bs[2][5],Bs[2][6],Bs[2][7],
            Bs[3][0],Bs[3][1],Bs[3][2],Bs[3][3],Bs[3][4],Bs[3][5],Bs[3][6],Bs[3][7],
            Bs[4][0],Bs[4][1],Bs[4][2],Bs[4][3],Bs[4][4],Bs[4][5],Bs[4][6],Bs[4][7],
            Bs[5][0],Bs[5][1],Bs[5][2],Bs[5][3],Bs[5][4],Bs[5][5],Bs[5][6],Bs[5][7],
            Bs[6][0],Bs[6][1],Bs[6][2],Bs[6][3],Bs[6][4],Bs[6][5],Bs[6][6],Bs[6][7],
            Bs[7][0],Bs[7][1],Bs[7][2],Bs[7][3],Bs[7][4],Bs[7][5],Bs[7][6],Bs[7][7]}
        = {8'd1,8'd2,8'd3,8'd4,8'd5,8'd6,8'd7,8'd8,
           8'd1,8'd2,8'd3,8'd4,8'd5,8'd6,8'd7,8'd8,
           8'd1,8'd2,8'd3,8'd4,8'd5,8'd6,8'd7,8'd8,
           8'd1,8'd2,8'd3,8'd4,8'd5,8'd6,8'd7,8'd8,
           8'd1,8'd2,8'd3,8'd4,8'd5,8'd6,8'd7,8'd8,
           8'd1,8'd2,8'd3,8'd4,8'd5,8'd6,8'd7,8'd8,
           8'd1,8'd2,8'd3,8'd4,8'd5,8'd6,8'd7,8'd8,
           8'd1,8'd2,8'd3,8'd4,8'd5,8'd6,8'd7,8'd8};
    
    // Instantiate 8x8 Systolic Array (using 4 instances of 4x4)
    // For simplicity, we'll use a custom 8x8 PE_Array
    PE_Array #(.Size(8)) DUT (
        .reset(reset),
        .clk(clk),
        .AB(AB),
        .BB(BB),
        .PAB(PAB)
    );
    
    // Map outputs
    generate
        genvar m, n;
        for(m=0; m<Size; m=m+1) begin: PoutMap_R
            for(n=0; n<Size; n=n+1) begin: PoutMap_C
                assign PEout[m][n] = PAB[(m*Size+n+1)*8-1:(m*Size+n)*8];
            end
        end
    endgenerate
    
    // Clock generation
    always #5 clk = ~clk;
    
    // Data arrangement task
    task data_arrangement;
        input [7:0] ii_in, i_in;
        output [7:0] Ai, Bi;
        begin
            Ai = ((ii_in >= i_in) && (ii_in < Size+i_in)) ? As[i_in][ii_in-i_in] : 8'd0;
            Bi = ((ii_in >= i_in) && (ii_in < Size+i_in)) ? Bs[ii_in-i_in][i_in] : 8'd0;
        end
    endtask
    
    // Initial block
    initial begin
        $display("========================================");
        $display("8x8 Systolic Array Matrix Multiplier");
        $display("========================================");
        $display("Matrix A:");
        $display("  1  1  1  1  1  1  1  1");
        $display("  2  2  2  2  2  2  2  2");
        $display("  3  3  3  3  3  3  3  3");
        $display("  4  4  4  4  4  4  4  4");
        $display("  5  5  5  5  5  5  5  5");
        $display("  6  6  6  6  6  6  6  6");
        $display("  7  7  7  7  7  7  7  7");
        $display("  8  8  8  8  8  8  8  8");
        $display("");
        $display("Matrix B:");
        $display("  1  2  3  4  5  6  7  8");
        $display("  1  2  3  4  5  6  7  8");
        $display("  1  2  3  4  5  6  7  8");
        $display("  1  2  3  4  5  6  7  8");
        $display("  1  2  3  4  5  6  7  8");
        $display("  1  2  3  4  5  6  7  8");
        $display("  1  2  3  4  5  6  7  8");
        $display("  1  2  3  4  5  6  7  8");
        $display("");
        
        clk = 1'd0;
        reset = 1'd0;
        AB = 0;
        BB = 0;
        ii = 0;
        
        #10;
        reset = 1'd1;
        #15;
        reset = 1'd0;
        
        // Feed data into systolic array
        // Total cycles = Size + (Size-1) + (Size-1) + 1 = 8 + 7 + 7 + 1 = 23
        for(ii=0; ii < Size+(Size-1)+(Size-1)+1; ii=ii+1) begin
            for(i=0; i<Size; i=i+1) begin
                data_arrangement(ii, i, A[i], B[i]);
            end
            
            #2
            for(k=0; k<Size; k=k+1) begin
                AB = {AB[BusSize-9:0], A[Size-k-1]};
                BB = {BB[BusSize-9:0], B[Size-k-1]};
            end
            
            #8;
            
            // Display intermediate results every few cycles
            if(ii % 4 == 0 || ii > 18) begin
                $display("Cycle %0d:", ii+1);
                $display("  PE Results (first row):");
                $display("    [%3d %3d %3d %3d %3d %3d %3d %3d]",
                    PEout[0][0], PEout[0][1], PEout[0][2], PEout[0][3],
                    PEout[0][4], PEout[0][5], PEout[0][6], PEout[0][7]);
            end
        end
        
        AB = 0;
        BB = 0;
        
        #20;
        
        // Display final results
        $display("");
        $display("========================================");
        $display("Final Result Matrix C = A x B:");
        $display("========================================");
        $display("[%3d %3d %3d %3d %3d %3d %3d %3d]",
            PEout[0][0], PEout[0][1], PEout[0][2], PEout[0][3],
            PEout[0][4], PEout[0][5], PEout[0][6], PEout[0][7]);
        $display("[%3d %3d %3d %3d %3d %3d %3d %3d]",
            PEout[1][0], PEout[1][1], PEout[1][2], PEout[1][3],
            PEout[1][4], PEout[1][5], PEout[1][6], PEout[1][7]);
        $display("[%3d %3d %3d %3d %3d %3d %3d %3d]",
            PEout[2][0], PEout[2][1], PEout[2][2], PEout[2][3],
            PEout[2][4], PEout[2][5], PEout[2][6], PEout[2][7]);
        $display("[%3d %3d %3d %3d %3d %3d %3d %3d]",
            PEout[3][0], PEout[3][1], PEout[3][2], PEout[3][3],
            PEout[3][4], PEout[3][5], PEout[3][6], PEout[3][7]);
        $display("[%3d %3d %3d %3d %3d %3d %3d %3d]",
            PEout[4][0], PEout[4][1], PEout[4][2], PEout[4][3],
            PEout[4][4], PEout[4][5], PEout[4][6], PEout[4][7]);
        $display("[%3d %3d %3d %3d %3d %3d %3d %3d]",
            PEout[5][0], PEout[5][1], PEout[5][2], PEout[5][3],
            PEout[5][4], PEout[5][5], PEout[5][6], PEout[5][7]);
        $display("[%3d %3d %3d %3d %3d %3d %3d %3d]",
            PEout[6][0], PEout[6][1], PEout[6][2], PEout[6][3],
            PEout[6][4], PEout[6][5], PEout[6][6], PEout[6][7]);
        $display("[%3d %3d %3d %3d %3d %3d %3d %3d]",
            PEout[7][0], PEout[7][1], PEout[7][2], PEout[7][3],
            PEout[7][4], PEout[7][5], PEout[7][6], PEout[7][7]);
        $display("");
        $display("Expected Result (each element = row_index*8 * col_index):");
        $display("  [  8  16  24  32  40  48  56  64]");
        $display("  [ 16  32  48  64  80  96 112 128]");
        $display("  [ 24  48  72  96 120 144 168 192]");
        $display("  [ 32  64  96 128 160 192 224 256]");
        $display("  [ 40  80 120 160 200 240 280 320]");
        $display("  [ 48  96 144 192 240 288 336 384]");
        $display("  [ 56 112 168 224 280 336 392 448]");
        $display("  [ 64 128 192 256 320 384 448 512]");
        $display("========================================");
        
        #50;
        $finish;
    end
    
    // VCD dump for waveform viewing
    initial begin
        $dumpfile("systolic_array_8x8.vcd");
        $dumpvars(0, array88tb);
    end
    
endmodule