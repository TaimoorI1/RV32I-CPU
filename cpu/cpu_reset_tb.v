module cpu_tb_reset;
    reg clk;
    reg reset;
    wire illegal;
    
    cpu dut (
        .clk(clk),
        .reset(reset),
        .illegal(illegal)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    integer errors = 0;
    integer tests = 0;

    integer illegal_count;
    initial illegal_count = 0;

    always @(posedge clk) begin
        if (illegal === 1'b1)
            illegal_count = illegal_count + 1;
    end

    task check(input [31:0] actual, input [31:0] expected, input [127:0] name);
    begin
        #1;
        tests = tests + 1;

        if (actual !== expected) begin
            errors = errors + 1;
            $display("FAIL [%0s]: got %h, expected %h", name, actual, expected);
        end
    end
    endtask

    initial begin
        #100000;
        $display("TIMEOUT: simulation did not finish");
        $fatal(1);
    end

    initial begin

        reset = 1;

        dut.dmem_inst.storage[6] = 32'h80F27F01;
        
        $readmemh("programs/asm/cpu_tb.hex", dut.fetch_inst.imem_inst.mem);

    
         repeat (5) @(posedge clk);

        if (dut.regfile_inst.registers[1] === 32'd10) begin
            $display("FAIL: reg written on reset high");
            errors = errors + 1;
            end
        
        if (dut.fetch_inst.pc_inst.pc !== 32'b0) begin
            $display("FAIL: PC not 0 with reset high");
            errors = errors + 1;
            end

        #1 reset = 0;

        if (errors != 0)
            $fatal(1);




     
  
        $finish;
    end

endmodule