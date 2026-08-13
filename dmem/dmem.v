module dmem (
    input clk,
    input [31:0] addr,
    input [3:0] write_enable,
    input[31:0] store_data,
    output [31:0] read_data
);

reg [31:0] storage [0:255];

assign read_data = storage[addr[9:2]];

always @(posedge clk) begin

    if (write_enable[0]) storage[addr[9:2]][7:0] <= store_data[7:0];
    
    if (write_enable[1]) storage[addr[9:2]][15:8] <= store_data[15:8];

    if (write_enable[2]) storage[addr[9:2]][23:16] <= store_data[23:16];

    if (write_enable[3]) storage[addr[9:2]][31:24] <= store_data[31:24];

end

endmodule
