module fetch (
    input  clk,
    input  reset,
    input  redirect_valid,
    input  [31:0] redirect_target,
    output [31:0] pc,        // current address (exposed so we can watch it)
    output [31:0] instr      // instruction fetched this cycle
);

    // internal wires: signals that run BETWEEN the bricks
    wire [31:0] pc_plus_4;
    wire [31:0] next_pc;

    // its next_pc input is fed by redirect mux
    pc pc_inst (
        .clk     (clk),
        .reset   (reset),
        .next_pc (next_pc),    // next address comes from the adder
        .pc      (pc)
    );

    // instruction memory brick 
    imem imem_inst (
        .addr  (pc),
        .instr (instr)
    );

    assign pc_plus_4 = pc + 4;
    assign next_pc = redirect_valid ? redirect_target : pc_plus_4;


endmodule