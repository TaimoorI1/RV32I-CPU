module retire_tb;

    reg clk;
    reg reset;
    wire illegal;

    wire        retire_valid;
    wire [31:0] retire_pc;
    wire [31:0] retire_instr;

    wire        retire_rd_we;
    wire [4:0]  retire_rd_addr;
    wire [31:0] retire_rd_data;

    wire        retire_mem_we;
    wire [3:0]  retire_mem_wmask;
    wire [31:0] retire_mem_addr;
    wire [31:0] retire_mem_wdata;

    wire [31:0] retire_next_pc;

    cpu dut (
        .clk(clk),
        .reset(reset),
        .illegal(illegal),

        .retire_valid(retire_valid),
        .retire_pc(retire_pc),
        .retire_instr(retire_instr),

        .retire_rd_we(retire_rd_we),
        .retire_rd_addr(retire_rd_addr),
        .retire_rd_data(retire_rd_data),

        .retire_mem_we(retire_mem_we),
        .retire_mem_wmask(retire_mem_wmask),
        .retire_mem_addr(retire_mem_addr),
        .retire_mem_wdata(retire_mem_wdata),

        .retire_next_pc(retire_next_pc)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        reset = 1;

        dut.dmem_inst.storage[6] = 32'h80F27F01;
        $readmemh("programs/asm/cpu_tb.hex", dut.fetch_inst.imem_inst.mem);

        @(posedge clk);
        #1 reset = 0;

        repeat (49) @(posedge clk);

        $finish;

    end

    always @(negedge clk) begin
            if (retire_valid) begin
                $display(
                    "RETIRE pc=%0h instr=%0h next_pc=%0h rd_we=%0b rd=%0h rd_data=%0h mem_we=%0b mem_mask=%0h mem_addr=%0h mem_data=%0h", 
                    retire_pc, 
                    retire_instr, 
                    retire_next_pc, 
                    retire_rd_we, 
                    retire_rd_addr,
                    retire_rd_data,
                    retire_mem_we,
                    retire_mem_wmask,
                    retire_mem_addr,
                    retire_mem_wdata
                );
            
                
            end


    end

endmodule