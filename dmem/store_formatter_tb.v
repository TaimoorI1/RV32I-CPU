`timescale 1ns/1ps

module store_formatter_tb;

    reg [31:0] addr;
    reg [2:0] funct3;
    reg [31:0] rd2;
    reg store_en;

    wire [31:0] store_data;
    wire [3:0] write_enable;
    wire misaligned;

    store_formatter dut (
        .addr(addr),
        .funct3(funct3),
        .rd2(rd2),
        .store_en(store_en),
        .store_data(store_data),
        .write_enable(write_enable),
        .misaligned(misaligned)
    );

    task check;
        input [2:0] test_funct3;
        input [1:0] test_offset;
        input [31:0] expected_data;
        input [3:0] expected_we;
        input expected_misaligned;

        begin
            funct3 = test_funct3;
            addr = {30'b0, test_offset};

            #1;

            if (
                store_data === expected_data &&
                write_enable === expected_we &&
                misaligned === expected_misaligned
            )
                $display(
                    "PASS: funct3=%b offset=%b",
                    test_funct3,
                    test_offset
                );
            else
                $display(
                    "FAIL: funct3=%b offset=%b data=%h we=%b misaligned=%b",
                    test_funct3,
                    test_offset,
                    store_data,
                    write_enable,
                    misaligned
                );
        end
    endtask

    initial begin

        rd2 = 32'h12345678;
        store_en = 1'b1;

        // SB
        check(3'b000, 2'b00, 32'h00000078, 4'b0001, 1'b0);
        check(3'b000, 2'b01, 32'h00007800, 4'b0010, 1'b0);
        check(3'b000, 2'b10, 32'h00780000, 4'b0100, 1'b0);
        check(3'b000, 2'b11, 32'h78000000, 4'b1000, 1'b0);

        // SH
        check(3'b001, 2'b00, 32'h00005678, 4'b0011, 1'b0);
        check(3'b001, 2'b01, 32'h00000000, 4'b0000, 1'b1);
        check(3'b001, 2'b10, 32'h56780000, 4'b1100, 1'b0);
        check(3'b001, 2'b11, 32'h00000000, 4'b0000, 1'b1);

        // SW
        check(3'b010, 2'b00, 32'h12345678, 4'b1111, 1'b0);
        check(3'b010, 2'b01, 32'h00000000, 4'b0000, 1'b1);
        check(3'b010, 2'b10, 32'h00000000, 4'b0000, 1'b1);
        check(3'b010, 2'b11, 32'h00000000, 4'b0000, 1'b1);

        // store disabled test
        store_en = 1'b0; funct3 = 3'b000; addr = 32'h0;
        #1;
        if (write_enable === 4'b0000 && store_data === 32'h00000000 && misaligned === 1'b0)
            $display("PASS: store disabled");
        else 
            $display("FAIL: store disabled, data=%h we=%b misaligned=%b",
            store_data,
            write_enable,
            misaligned);

        $finish;
    end

endmodule