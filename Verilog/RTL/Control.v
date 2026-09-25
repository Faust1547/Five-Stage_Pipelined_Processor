module Control(
    output reg       Reg_dst,
    output reg       ALU_src,
    output reg [1:0] ALU_op,
    output reg       Reg_w,
    output reg       Mem_w,
    output reg       Mem_r,
    output reg       Mem_to_reg,
    input      [5:0] OpCode
    );

always @(*) begin
    Reg_dst    = 1'b0;
    Reg_w      = 1'b0;
    ALU_src    = 1'b0;
    ALU_op     = 2'b00;
    Mem_w      = 1'b0;
    Mem_r      = 1'b0;
    Mem_to_reg = 1'b0;
    case (OpCode)
        6'b000000: begin:R_TYPE
            Reg_dst    = 1'b1;
            Reg_w      = 1'b1;
            Mem_to_reg = 1'b0;
            ALU_op     = 2'b10;
        end
        6'b001001: begin:ADD_IMM
            Reg_w      = 1'b1;
            ALU_src    = 1'b1;
            Mem_to_reg = 1'b0;
            ALU_op     = 2'b00;
        end
        6'b101011: begin:SW
            ALU_src    = 1'b1;
            Mem_w      = 1'b1;
            ALU_op     = 2'b00;
        end
        6'b100011: begin:LW
            Reg_w      = 1'b1;
            ALU_src    = 1'b1;
            Mem_r      = 1'b1;
            Mem_to_reg = 1'b1;
            ALU_op     = 2'b00;
        end
        6'b001101: begin:OR_IMM
            Mem_to_reg = 1'b0;
            Reg_w      = 1'b1;
            ALU_src    = 1'b1;
            ALU_op     = 2'b11;
        end
    endcase
end
endmodule
