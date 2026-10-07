module pc (
    input logic clk,
    input logic reset,
    input logic [31:0] next_pc,
    output logic [31:0] pc
);

    // clocked update:
    always_ff @(posedge clk)
        if (reset) 
            pc <= 32'b0; // reset high, pc <= address 0
        else
            pc <= next_pc; // otherwise pc <= next_pc

endmodule