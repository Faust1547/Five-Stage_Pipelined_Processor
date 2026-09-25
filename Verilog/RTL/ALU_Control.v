module ALU_Control(
    output reg [5:0] ALU_funct,
    input [5:0] Funct_ctrl,
    input [1:0] ALU_op
    );
    
always @(*) begin
    case (ALU_op)
        2'b00: ALU_funct = 6'b001001; // addition: addiu, lw, sw
        2'b11: ALU_funct = 6'b100101; // or: ori

        2'b10: begin
            case (Funct_ctrl)
                6'b100001: ALU_funct = 6'b001001; // addu
                6'b100011: ALU_funct = 6'b001010; // subu
                6'b000000: ALU_funct = 6'b100001; // sll
                6'b100101: ALU_funct = 6'b100101; // or
                default:   ALU_funct = 6'b000000;
            endcase
        end

        default: ALU_funct = 6'b000000;
    endcase
end
endmodule
