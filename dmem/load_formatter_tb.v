module load_formatter_tb;

reg [31:0] dmem_data;
reg [1:0] addr_offset;
reg [2:0] funct3;

wire [31:0] load_data;
wire misaligned;

integer errors = 0;


load_formatter dut (
    .dmem_data(dmem_data),
    .addr_offset(addr_offset),
    .funct3(funct3),
    .load_data(load_data),
    .misaligned(misaligned)
);

initial begin  

    // Test 1: LB
    dmem_data = 32'h80F27F01;
    addr_offset = 2'b10;
    funct3 = 3'b000;
    #1;
    if (load_data === 32'hFFFFFFF2 && misaligned === 1'b0)
        $display("PASS: LB");
    else begin
        $display("FAIL: LB | expected ld = %0h ma = %0b, got ld = %0h ma = %0b", 32'hFFFFFFF2, 1'b0, load_data, misaligned);
        errors = errors + 1;
    end

    // Test 2: LBU
    dmem_data = 32'h80F27F01;
    addr_offset = 2'b10;
    funct3 = 3'b100;
    #1;
    if (load_data === 32'h000000F2 && misaligned === 1'b0)
        $display("PASS: LBU");
    else begin
        $display("FAIL: LBU | expected ld = %0h ma = %0b, got ld = %0h ma = %0b", 32'h000000F2, 1'b0, load_data, misaligned);
        errors = errors + 1; 
    end

    // Test 3: LH
    dmem_data = 32'h80F27F01;
    addr_offset = 2'b10;
    funct3 = 3'b001;
    #1;
    if (load_data === 32'hFFFF80F2 && misaligned === 1'b0)
        $display("PASS: LH");
    else begin
        $display("FAIL: LH | expected ld = %0h ma = %0b, got ld = %0h ma = %0b", 32'hFFFF80F2, 1'b0, load_data, misaligned);
        errors = errors + 1; 
    end

    // Test 4: LHU
    dmem_data = 32'h80F27F01;
    addr_offset = 2'b10;
    funct3 = 3'b101;
    #1;
    if (load_data === 32'h000080F2 && misaligned === 1'b0)
        $display("PASS: LHU");
    else begin
        $display("FAIL: LHU | expected ld = %0h ma = %0b, got ld = %0h ma = %0b", 32'h000080F2, 1'b0, load_data, misaligned);
        errors = errors + 1; 
    end

    // Test 5: LW
    dmem_data = 32'h80F27F01;
    addr_offset = 2'b00;
    funct3 = 3'b010;
    #1;
    if (load_data === 32'h80F27F01 && misaligned === 1'b0)
        $display("PASS: LW");
    else begin
        $display("FAIL: LW | expected ld = %0h ma = %0b, got ld = %0h ma = %0b", 32'h80F27F01, 1'b0, load_data, misaligned);
        errors = errors + 1; 
    end

    // Test 6: misaligned LH
    dmem_data = 32'h80F27F01;
    addr_offset = 2'b01; // uneven
    funct3 = 3'b001;
    #1;
    if (load_data === 32'b0 && misaligned === 1'b1)
        $display("PASS: LH misaligned");
    else begin
        $display("FAIL: LH misaligned | expected ld = %0h ma = %0b, got ld = %0h ma = %0b", 32'h00000000, 1'b1, load_data, misaligned);
        errors = errors + 1; 
    end

    // Test 7: misaligned LW
    dmem_data = 32'h80F27F01;
    addr_offset = 2'b11; // not zero
    funct3 = 3'b010;
    #1;
    if (load_data === 32'b0 && misaligned === 1'b1)
        $display("PASS: LW misaligned");
    else begin
        $display("FAIL: LW misaligned | expected ld = %0h ma = %0b, got ld = %0h ma = %0b", 32'h00000000, 1'b1, load_data, misaligned);
        errors = errors + 1; 
    end

    // Test 8: LB top-byte
    dmem_data = 32'h80F27F01;
    addr_offset = 2'b11;
    funct3 = 3'b000;
    #1;
    if (load_data === 32'hFFFFFF80 && misaligned === 1'b0)
        $display("PASS: LB top-byte");
    else begin
        $display("FAIL: LB top-byte | expected ld = %0h ma = %0b, got ld = %0h ma = %0b", 32'hFFFFFF80, 1'b0, load_data, misaligned);
        errors = errors + 1;
    end
    
    if (errors == 0) begin
        $display("ALL TESTS PASSED");
        $finish;
    end
    else begin
        $display("%0d TEST(S) FAILED", errors);
        $fatal(1);
    end

end

endmodule