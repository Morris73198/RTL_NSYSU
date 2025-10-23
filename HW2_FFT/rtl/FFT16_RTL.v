/* *
 * ======================================================================
 * FFT16_RTL.v (頂層模組 - 串列輸入 / 串列輸出) - [電位致能版]
 * ======================================================================
 */
module FFT16_RTL (
    input clk,
    input reset,
    
    // --- 串列輸入 ---
    input             load_en,        // "致能"：告訴模組這筆 32-bit 輸入資料有效
    input [31:0]      serial_data_in, // "資料"：32-bit 串列輸入埠
    
    // --- 串列輸出 ---
    output reg [31:0] serial_data_out, // "資料"：32-bit 串列輸出埠
    output reg        data_out_valid,  // "致能"：告訴外界這筆 32-bit 輸出資料有效
    output reg        fft_done,        // "旗標"：告訴外界 "所有" 16 筆資料都已輸出完畢
    
    // (fft_start 仍是內部訊號，但如果你想在外部監看它，可以保留 output)
    output reg        fft_core_en        // 1-cycle 脈衝，用於 "觸發" FSM 的管線追蹤器
);

    // --- 內部訊號 ---
    wire [16*32-1:0] internal_bus_in;  // 512-bit 內部匯流排 (RAM -> FFT 核心)
    wire [16*32-1:0] internal_bus_out; // 512-bit 內部匯流排 (FFT 核心 -> 結果暫存器)
    
    reg [31:0] buffer_ram [0:15];      // 16x32-bit 的 "輸入緩衝 RAM"
    
    // --- 內部控制訊號 ---
    reg [3:0] load_counter;            // 載入計數器 (0 到 15)
    integer   i;                       // (供 for 迴圈使用)
    reg       trigger_fft_next_cycle;  // 輔助訊號

    // [修改] 新增一個 "電位" 致能訊號給 FFT 核心
    reg       fft_start;             // 這個訊號將在你要求的區間保持為 1

    // 追蹤 FFT 管線延遲 (4 級) - *這仍然由 1-cycle 的 fft_start 觸發*
    reg start_pipe_s0, start_pipe_s1, start_pipe_s2, start_pipe_s3;

    // --- 內部 "輸出緩衝" ---
    reg [16*32-1:0] internal_result_reg; 
    reg [3:0]       unload_counter;      
    reg             unloading_active;    


    // --- 實例化 FFT 核心 ---
    // [修改] 將 .en 連接到新的 fft_core_en
    FFT16 uut_fft_core (
        .reset(reset),
        .clk(clk),
        .en(fft_core_en), // <--- 連接到新的電位致能訊號
        .Bus_in(internal_bus_in),
        .Bus_out(internal_bus_out)
    );

    // --- 連接緩衝 RAM 到 FFT 核心的 Bus_in (打包器) ---
    genvar gi;
    generate
        for (gi = 0; gi < 16; gi = gi + 1) begin : RAM_PACK_LOOP
            assign internal_bus_in[gi*32 +: 32] = buffer_ram[gi];
        end
    endgenerate

    // --- 狀態機：控制資料 "載入"、"處理" 與 "卸載" ---
    always @(posedge clk) begin
        if (reset) begin
            // 重置所有控制訊號
            load_counter           <= 4'd0;
            fft_start              <= 1'b0;
            fft_done               <= 1'b0;
            data_out_valid         <= 1'b0;
            serial_data_out        <= 32'd0;
            unloading_active       <= 1'b0;
            unload_counter         <= 4'd0;
            trigger_fft_next_cycle <= 1'b0;
            start_pipe_s0          <= 1'b0;
            start_pipe_s1          <= 1'b0;
            start_pipe_s2          <= 1'b0;
            start_pipe_s3          <= 1'b0;
            fft_core_en            <= 1'b0; // [新增] 重置
        end
        else begin
            // 預設值
            fft_start              <= trigger_fft_next_cycle;
            trigger_fft_next_cycle <= 1'b0; // 脈衝自動歸 0
            fft_done               <= 1'b0;
            data_out_valid         <= 1'b0;


            // --- [新增] fft_core_en 的控制邏輯 ---
            // (這是一個 SR Flip-Flop)
            // SET: 當載入完成時 (由 trigger_fft_next_cycle 觸發)
            if (trigger_fft_next_cycle) begin
                fft_core_en <= 1'b1;
            end
            // RESET: 當卸載完成時 (見下方 unloading_active 區塊)
            

            // --- 狀態 3: 卸載 (Unloading) ---
            if (unloading_active) begin
                
                data_out_valid  <= 1'b1; 
                serial_data_out <= internal_result_reg[unload_counter*32 +: 32];
                
                if (unload_counter == 4'd15) begin
                    // 這是最後一筆資料 (第 16 筆)
                    unloading_active <= 1'b0; // 停止卸載
                    fft_done         <= 1'b1; // 升起 "全部完成" 旗標
                    
                    // [修改] 在這裡 RESET fft_core_en
                    fft_core_en      <= 1'b0; // 關閉 FFT 核心
                end
                else begin
                    // 繼續卸載下一筆
                    unload_counter <= unload_counter + 1;
                end
            end
            
            // --- 狀態 1: 載入 (Loading) ---
            // (如果沒有在卸載，也沒有在處理，才檢查是否要載入)
            // [修改] 增加條件 !fft_core_en，確保不會在運算中途又開始載入
            else if (load_en && !fft_core_en) begin
                
                buffer_ram[load_counter] <= serial_data_in;
                
                if (load_counter == 4'd15) begin
                    // 這是最後一筆輸入 (第 16 筆)
                    load_counter <= 4'd0;     
                    trigger_fft_next_cycle <= 1'b1; // 觸發 "下一週期" 的 fft_start 和 fft_core_en
                end
                else begin
                    load_counter <= load_counter + 1;
                end
            end
            
            // --- 狀態 2: 處理 (Processing) - (這部分恆時運作) ---
            
            // 移位暫存器，用於 "追蹤" fft_start 脈衝
            // (FSM 外部計時器，模擬 4 級管線的延遲)
            start_pipe_s0 <= fft_start; // 仍然由 1-cycle 的 fft_start 觸發
            start_pipe_s1 <= start_pipe_s0;
            start_pipe_s2 <= start_pipe_s1;
            start_pipe_s3 <= start_pipe_s2;

            // 當 4 級管線都跑完 (start_pipe_s3 == 1)
            // 這表示在 4 個週期前，fft_start 曾經為 1
            if (start_pipe_s3) begin
                // 512-bit 的並行結果 "internal_bus_out" 此刻有效！
                // (因為 fft_core_en 從 fft_start 開始就一直是 1)
                
                internal_result_reg <= internal_bus_out;
                unloading_active    <= 1'b1;
                unload_counter      <= 4'd0;
            end
        end
    end

endmodule