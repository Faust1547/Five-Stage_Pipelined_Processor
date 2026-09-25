`timescale 1ns / 1ps

module tb_FinalCPU;

    localparam integer CLK_PERIOD = 50;   // 100 MHz functional simulation
    localparam integer IM_WORDS   = 256;
    localparam integer DM_WORDS   = 256;
    localparam integer RF_WORDS   = 32;
    localparam integer RUN_CYCLES = 40;   // current test only has 8 instructions

    reg         clk;
    reg         rst_n;
    reg         test_normal;
    reg [31:0]  ext_addr;
    reg [31:0]  ext_data;
    reg         ext_we;
    reg         mem_sel;
    wire [31:0] mem_out;

    reg [31:0] im_image       [0:IM_WORDS-1];
    reg [31:0] dm_image       [0:DM_WORDS-1];
    reg [31:0] expected_dm    [0:DM_WORDS-1];
    reg [31:0] expected_rf    [0:RF_WORDS-1];

    integer i;
    integer cycle_count;
    integer error_count;
    integer dm_init_words;

    TOP UUT (
        .clk         (clk),
        .rst_n       (rst_n),
        .test_normal (test_normal),
        .ext_addr    (ext_addr),
        .ext_data    (ext_data),
        .ext_we      (ext_we),
        .mem_sel     (mem_sel),
        .mem_out     (mem_out)
    );

    // ------------------------------------------------------------
    // Clock
    // ------------------------------------------------------------
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // ------------------------------------------------------------
    // Load 32-bit vector files.
    //
    // IM_32bit.dat : one 32-bit instruction per line, hexadecimal.
    // DM_32bit.dat : one 32-bit data word per line, hexadecimal.
    // expected_*.out use the same one-word-per-line format.
    // ------------------------------------------------------------
    initial begin : LOAD_VECTOR_FILES
        for (i = 0; i < IM_WORDS; i = i + 1)
            im_image[i] = 32'b0;

        // Unspecified DM words are intentionally X.  This makes accidental
        // reads from locations outside the supplied test image easy to spot.
        for (i = 0; i < DM_WORDS; i = i + 1) begin
            dm_image[i]    = 32'hxxxxxxxx;
            expected_dm[i] = 32'hxxxxxxxx;
        end

        for (i = 0; i < RF_WORDS; i = i + 1)
            expected_rf[i] = 32'hxxxxxxxx;

        #1;
        $display("[TB] Loading 32-bit vector files ...");
        $readmemh("D:/data/9IM_32bit.txt",             im_image);
        $readmemh("D:/data/9DM_32bit.txt",             dm_image);
        $readmemh("expected_DM_after_run.out", expected_dm);
        $readmemh("expected_RF_after_run.out", expected_rf);

        // The generated instruction ROM has no write port, therefore for
        // RTL functional simulation its contents are loaded hierarchically.
        // Bits [33:32] are the compiler model's redundancy bits.
        for (i = 0; i < IM_WORDS; i = i + 1) begin
            UUT.IM.mem[i][31:0]  = im_image[i];
            UUT.IM.mem[i][33:32] = 2'bxx;
        end

        $display("[TB] IM[0] = %08h", im_image[0]);
        $display("[TB] IM[1] = %08h", im_image[1]);
        $display("[TB] DM[0] = %08h", dm_image[0]);
        $display("[TB] DM[1] = %08h", dm_image[1]);
    end

    // ------------------------------------------------------------
    // External test-interface access helpers.
    // ext_addr is a BYTE address; SRAM A[7:0] is generated internally
    // from ext_addr[9:2].  Stimulus changes only at negedge so that the
    // synchronous SRAM sees stable inputs at the following posedge.
    // ------------------------------------------------------------
    task write_dm_word;
        input [7:0]  word_addr;
        input [31:0] data;
        begin
            @(negedge clk);
            test_normal = 1'b1;
            mem_sel     = 1'b1; // DM
            ext_we      = 1'b1;
            ext_addr    = {22'b0, word_addr, 2'b00};
            ext_data    = data;

            // First posedge captures external interface signals.
            // Second posedge performs the synchronous SRAM write.
            repeat (2) @(posedge clk);
            @(negedge clk);
            ext_we = 1'b0;
        end
    endtask

    task read_dm_word;
        input  [7:0]  word_addr;
        output [31:0] data;
        begin
            @(negedge clk);
            test_normal = 1'b1;
            mem_sel     = 1'b1; // DM
            ext_we      = 1'b0;
            ext_addr    = {22'b0, word_addr, 2'b00};
            ext_data    = 32'b0;

            // Interface input register + synchronous SRAM read + mem_out reg.
            repeat (3) @(posedge clk);
            #1 data = mem_out;
        end
    endtask

    // Initialize the supplied DM image through the real SRAM write port.
    task initialize_dm;
        reg done;
        begin
            $display("\n[TB] ===== LOAD DM_32bit.dat =====");
            done = 1'b0;
            dm_init_words = 0;
            for (i = 0; (i < DM_WORDS) && !done; i = i + 1) begin
                // $readmemh leaves entries not present in the file as X.
                // Stop at the first unspecified word.
                if (^dm_image[i] === 1'bx) begin
                    done = 1'b1;
                end
                else begin
                    write_dm_word(i[7:0], dm_image[i]);
                    dm_init_words = dm_init_words + 1;
                end
            end
            $display("[TB] Loaded %0d DM words.", dm_init_words);
        end
    endtask

    // ------------------------------------------------------------
    // Result checker
    // ------------------------------------------------------------
    task check_results;
        reg [31:0] actual;
        reg done;
        begin
            error_count = 0;

            $display("\n[TB] ===== CHECK REGISTER FILE =====");
            for (i = 0; i < RF_WORDS; i = i + 1) begin
                if (^expected_rf[i] !== 1'bx) begin
                    if (UUT.RF.RF_Mem[i] !== expected_rf[i]) begin
                        $display("[FAIL][RF] R[%0d] actual=%08h expected=%08h",
                                 i, UUT.RF.RF_Mem[i], expected_rf[i]);
                        error_count = error_count + 1;
                    end
                    else begin
                        $display("[PASS][RF] R[%0d] = %08h", i, UUT.RF.RF_Mem[i]);
                    end
                end
            end

            $display("\n[TB] ===== CHECK DATA MEMORY =====");
            done = 1'b0;
            for (i = 0; (i < DM_WORDS) && !done; i = i + 1) begin
                if (^expected_dm[i] === 1'bx) begin
                    done = 1'b1;
                end
                else begin
                    read_dm_word(i[7:0], actual);
                    if (actual !== expected_dm[i]) begin
                        $display("[FAIL][DM] word[%0d] actual=%08h expected=%08h",
                                 i, actual, expected_dm[i]);
                        error_count = error_count + 1;
                    end
                    else begin
                        $display("[PASS][DM] word[%0d] = %08h", i, actual);
                    end
                end
            end

            if (error_count == 0)
                $display("\n[TB] ========================================\n[TB] ALL TESTS PASSED\n[TB] ========================================");
            else
                $display("\n[TB] ========================================\n[TB] TEST FAILED: %0d mismatch(es)\n[TB] ========================================", error_count);
        end
    endtask

    // ------------------------------------------------------------
    // Main sequence
    // ------------------------------------------------------------
    initial begin : STIMULUS
        rst_n       = 1'b0;
        test_normal = 1'b1;
        ext_addr    = 32'b0;
        ext_data    = 32'b0;
        ext_we      = 1'b0;
        mem_sel     = 1'b0;
        cycle_count = 0;
        error_count = 0;

        // Wait until vector-file load initial block has completed.
        #2;

        repeat (4) @(posedge clk);
        @(negedge clk);
        rst_n = 1'b1;

        // Initialize DM while CPU remains in external test mode.
        initialize_dm();

        // Let interface settle, then start normal CPU execution.
        repeat (2) @(posedge clk);
        @(negedge clk);
        test_normal = 1'b0;
        ext_we      = 1'b0;
        mem_sel     = 1'b0;
        ext_addr    = 32'b0;

        $display("\n[TB] ===== CPU NORMAL MODE START =====\n");
        repeat (RUN_CYCLES) @(posedge clk);

        // Return to test mode before reading DM.
        @(negedge clk);
        test_normal = 1'b1;
        ext_we      = 1'b0;
        mem_sel     = 1'b1;
        repeat (3) @(posedge clk);

        check_results();

        $display("\n[TB] Simulation finished.");
        #10;
        $finish;
    end

    // ------------------------------------------------------------
    // Pipeline monitor
    // ------------------------------------------------------------
    always @(posedge clk) begin
        if (rst_n && !UUT.Interface_test_normal) begin
            cycle_count = cycle_count + 1;
            #1;
            $display("C%03d PC=%08h IM_A=%02h INST=%08h | valid=%b%b%b%b",
                     cycle_count,
                     UUT.Instr_addr,
                     UUT.Instr_addr[9:2],
                     UUT.Instruction,
                     UUT.IF_ID_valid,
                     UUT.ID_EX_valid,
                     UUT.EX_MEM_valid,
                     UUT.MEM_WB_valid);

            if (UUT.MEM_WB_valid && UUT.MEM_WB_Reg_w &&
                (UUT.MEM_WB_Rd_Addr != 5'd0))
                $display("      [RF WRITE] R[%0d] <= %08h%s",
                         UUT.MEM_WB_Rd_Addr,
                         UUT.MEM_WB_Rd_Data,
                         UUT.MEM_WB_Mem_to_reg ? " (DM)" : " (ALU)");

            if (UUT.EX_MEM_valid && UUT.EX_MEM_Mem_r)
                $display("      [DM READ]  byte_addr=%08h word_addr=%02h Q=%08h",
                         UUT.EX_MEM_ALU_result,
                         UUT.EX_MEM_ALU_result[9:2],
                         UUT.Mem_R_Data);

            if (UUT.EX_MEM_valid && UUT.EX_MEM_Mem_w)
                $display("      [DM WRITE] byte_addr=%08h word_addr=%02h data=%08h",
                         UUT.EX_MEM_ALU_result,
                         UUT.EX_MEM_ALU_result[9:2],
                         UUT.Mem_W_Data);

            if (!UUT.PC_Write)
                $display("      [STALL] load-use hazard detected");
        end
    end

    initial begin
        $dumpfile("FinalCPU_32bit_vectors.vcd");
        $dumpvars(0, tb_FinalCPU);
    end

endmodule
