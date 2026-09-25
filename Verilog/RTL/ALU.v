module ALU(
    output [31:0] ALU_result,
    input  [31:0] Rs_data, 
    input  [31:0] Rt_Imm_data,
    input  [4:0]  Shamt,
    input  [5:0]  Funct
    );
assign ALU_result = (Funct == 6'b001001) ? Rs_data + Rt_Imm_data :
                    (Funct == 6'b001010) ? Rs_data - Rt_Imm_data :
                    (Funct == 6'b100001) ? Rt_Imm_data << Shamt :
                    (Funct == 6'b100101) ? Rs_data | Rt_Imm_data :
                    32'b0;
endmodule
