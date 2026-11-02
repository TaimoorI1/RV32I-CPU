
`timescale 1ns/1ps

typedef struct packed {
    logic [31:0] pc;
    logic [31:0] instr;
    logic        valid;
} pipe_data_t;

module practice_pipe_reg (
    input  logic       clk,
    input  logic       reset,
    input  logic       stall,
    input  logic       flush,
    input  pipe_data_t d,
    output pipe_data_t q
);

    always_ff @(posedge clk) begin
        if (reset)
            q <= '0;
        else if (flush)
            q <= '0;
        else if (stall)
            q <= q;
        else
            q <= d;
    end

endmodule
