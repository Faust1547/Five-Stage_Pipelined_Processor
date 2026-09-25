module Adder(
    input [31:0] Instr_addr,
    output wire [31:0] Next_PC
    );
assign Next_PC = Instr_addr + 32'd4;
endmodule
