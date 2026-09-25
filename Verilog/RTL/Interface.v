module Interface(
    input              clk,
    input  wire        test_normal,
    input  wire [31:0] ext_addr,
    input  wire [31:0] ext_data,
    input  wire        ext_we,
    input  wire        mem_sel,
    output reg  [31:0] mem_out,
    
    input      [31:0] Interface_mem_out,
    output reg        Interface_test_normal,
    output reg [31:0] Interface_ext_addr,
    output reg [31:0] Interface_ext_data,
    output reg        Interface_ext_we,
    output reg        Interface_mem_sel
);

always @(posedge clk) begin
    mem_out <= Interface_mem_out;
    Interface_test_normal <= test_normal;
    Interface_ext_addr <= ext_addr;
    Interface_ext_data <= ext_data;
    Interface_ext_we <= ext_we;
    Interface_mem_sel = mem_sel;
end

endmodule