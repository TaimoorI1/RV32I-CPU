module branch_unit_tb;
reg [31:0] rd1;
reg [31:0] rd2;
reg [2:0] funct3;

wire branch_taken;

branch_unit dut (
    .rd1(rd1),
    .rd2(rd2),
    .funct3(funct3),
    .branch_taken(branch_taken)
);

integer errors = 0;
integer tests = 0;

task check(input expected, input [127:0] name);
begin  
    #1;
    tests = tests + 1;
    if (branch_taken != expected) begin
        errors = errors + 1;
        $display("FAIL: [%0s] | got %0b, expected %0b", name, branch_taken, expected);
    end
end
endtask

initial begin

    // Test 1
    rd1 = 32'd15;
    rd2 = 32'd15;
    funct3 = 3'b000;
    check(1'b1, "BEQ taken");

    // Test 2
    rd1 = 32'd14;
    rd2 = 32'd15;
    funct3 = 3'b000;
    check(1'b0, "BEQ not taken");

    // Test 3
    rd1 = 32'd14;
    rd2 = 32'd15;
    funct3 = 3'b001;
    check(1'b1, "BNE taken");

    // Test 4
    rd1 = 32'd15;
    rd2 = 32'd15;
    funct3 = 3'b001;
    check(1'b0, "BNE not taken");

    // Test 5 
    rd1 = 32'd1;
    rd2 = 32'd2;
    funct3 = 3'b100;
    check(1'b1, "BLT taken");

    // Test 6 
    rd1 = 32'd11;
    rd2 = 32'd2;
    funct3 = 3'b100;
    check(1'b0, "BLT not taken");
    
    // Test 7
    rd1 = 32'hFFFFFFFF;
    rd2 = 32'h00000001;
    funct3 = 3'b100;
    check(1'b1, "BLT taken");

    // Test 8 
    rd1 = 32'h00000001;
    rd2 = 32'hFFFFFFFF;
    funct3 = 3'b100;
    check(1'b0, "BLT not taken");

    // Test 9
    rd1 = 32'd2;
    rd2 = 32'd1;
    funct3 = 3'b101;
    check(1'b1, "BGE taken");

    // Test 10
    rd1 = 32'd1;
    rd2 = 32'd2;
    funct3 = 3'b101;
    check(1'b0, "BGE not taken");

    // Test 10
    rd1 = 32'h00000001;
    rd2 = 32'hFFFFFFFF;
    funct3 = 3'b101;
    check(1'b1, "BGE taken");

     // Test 11
    rd1 = 32'hFFFFFFFF;
    rd2 = 32'd00000001;
    funct3 = 3'b101;
    check(1'b0, "BGE not taken");

    // Test 12
    rd1 = 32'd1;
    rd2 = 32'd2;
    funct3 = 3'b110;
    check(1'b1, "BLTU taken");

    // Test 13
    rd1 = 32'hFFFFFFFF;
    rd2 = 32'h00000001;
    funct3 = 3'b110;
    check(1'b0, "BLTU not taken");

    // Test 14
    rd1 = 32'hFFFFFFFF;
    rd2 = 32'h00000001;
    funct3 = 3'b111;
    check(1'b1, "BGEU taken");

    // Test 14
    rd1 = 32'h00000001;
    rd2 = 32'hFFFFFFFF;
    funct3 = 3'b111;
    check(1'b0, "BGEU taken");

    // Test 15 
    funct3 = 3'b010;
    check(1'b0, "Invalid funct3");

    if (errors == 0) 
        $display("PASS: %0d/%0d TESTS PASSED", tests, tests);
    else 
        $display("FAIL: %0d/%0d TESTS FAILED", errors, tests);


    $finish;

end

endmodule