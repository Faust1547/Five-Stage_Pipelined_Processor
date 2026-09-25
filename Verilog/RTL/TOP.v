`timescale 1ns / 1ps
module TOP #(
    parameter ADDR_LENGTH = 32,
    parameter DATA_LENGTH = 32
)(
    input  wire                   clk,
    input  wire                   rst_n,
    input  wire                   test_normal,
    input  wire [ADDR_LENGTH-1:0] ext_addr,
    input  wire [DATA_LENGTH-1:0] ext_data,
    input  wire                   ext_we,
    input  wire                   mem_sel,
    output wire [DATA_LENGTH-1:0] mem_out,

    input  wire                   SI,
    input  wire                   SE,
    output  wire                  SO
);
    
// Interface
wire [DATA_LENGTH-1:0] Interface_mem_out;
wire                   Interface_test_normal;
wire [ADDR_LENGTH-1:0] Interface_ext_addr;
wire [DATA_LENGTH-1:0] Interface_ext_data;
wire                   Interface_ext_we;
wire                   Interface_mem_sel;

// IF_IM&PC
wire [ADDR_LENGTH-1:0] Next_PC;    
reg  [ADDR_LENGTH-1:0] Instr_addr;
wire [DATA_LENGTH-1:0] Instruction;

// IF_ID_RF
wire [DATA_LENGTH-1:0] IF_ID_Instr;
wire [DATA_LENGTH-1:0] Rt_data;
wire [DATA_LENGTH-1:0] Rs_data;

// IF_ID_Control
wire [1:0]  IF_ID_ALU_op;
wire        IF_ID_Reg_w;
wire        IF_ID_Reg_dst;
wire        IF_ID_ALU_src;
wire        IF_ID_Mem_w;
wire        IF_ID_Mem_r;
wire        IF_ID_Mem_to_reg;
    
// ID_EX
reg  [DATA_LENGTH-1:0] ID_EX_Rt_data;
reg  [DATA_LENGTH-1:0] ID_EX_Rs_data;
reg  [4:0]             ID_EX_Rs_Addr; 
reg  [4:0]             ID_EX_Rt_Addr;  // I-format
reg  [4:0]             ID_EX_Rd_Addr;  // R-format
reg  [DATA_LENGTH-1:0] ID_EX_Imm;  // shamt + funct
wire [5:0]  ALU_funct;

wire [DATA_LENGTH-1:0] ALU_result;
reg  [1:0]  ID_EX_ALU_op;
reg         ID_EX_Reg_w;
reg         ID_EX_Reg_dst;
reg         ID_EX_ALU_src;
reg         ID_EX_Mem_w;
reg         ID_EX_Mem_r;
reg         ID_EX_Mem_to_reg;

// EX_MEM
reg         EX_MEM_Reg_w;
reg         EX_MEM_Mem_w;
reg         EX_MEM_Mem_r;
reg         EX_MEM_Mem_to_reg;
reg  [4:0]  EX_MEM_Rd_Addr;
reg  [DATA_LENGTH-1:0] EX_MEM_ALU_result;
reg  [DATA_LENGTH-1:0] Mem_W_Data;
wire [DATA_LENGTH-1:0] Mem_R_Data;

// MEM_WB
reg  [4:0]  MEM_WB_Rd_Addr;
wire [DATA_LENGTH-1:0] MEM_WB_Rd_Data;
reg         MEM_WB_Reg_w;
reg         MEM_WB_Mem_to_reg;
reg [DATA_LENGTH-1:0]  MEM_WB_ALU_result;
reg [DATA_LENGTH-1:0]  MEM_WB_R_Data;

// HDU
reg PC_Write;
reg IF_ID_Write;
reg Ctrl_Select;

// FU
reg [1:0] Forward_A;
reg [1:0] Forward_B;

//
reg test_normal_d;
wire normal_start;

always @(posedge clk) begin
    if (!rst_n) 
        test_normal_d <= 1'b1;
    else 
        test_normal_d <= Interface_test_normal;
end

assign normal_start = test_normal_d & ~Interface_test_normal;

reg IF_ID_valid;
reg ID_EX_valid;
reg EX_MEM_valid;
reg MEM_WB_valid;

always @(posedge clk) begin
    if (!rst_n) begin
        IF_ID_valid  <= 1'b0;
        ID_EX_valid  <= 1'b0;
        EX_MEM_valid <= 1'b0;
        MEM_WB_valid <= 1'b0;
    end
    else if (normal_start) begin
        IF_ID_valid  <= 1'b1;
        ID_EX_valid  <= 1'b0;
        EX_MEM_valid <= 1'b0;
        MEM_WB_valid <= 1'b0;
    end
    else if (!Interface_test_normal) begin
        // IF/ID ?? IF_ID_Write:stall ???
        if (IF_ID_Write) IF_ID_valid <= 1'b1;
        else IF_ID_valid <= IF_ID_valid;

        // ID/EX ?? Ctrl_Select:stall ?? bubble
        ID_EX_valid  <= Ctrl_Select ? IF_ID_valid : 1'b0;
        EX_MEM_valid <= ID_EX_valid;
        MEM_WB_valid <= EX_MEM_valid;
    end
end

always @(*) begin:Hazard_Detection_Unit
    PC_Write    = 1'b1;
    IF_ID_Write = 1'b1;
    Ctrl_Select = 1'b1;
    if (ID_EX_valid && ID_EX_Mem_r 
    && ((ID_EX_Rt_Addr == IF_ID_Instr[25:21])
    || (ID_EX_Rt_Addr == IF_ID_Instr[20:16]))) begin
        PC_Write    = 1'b0;
        IF_ID_Write = 1'b0;
        Ctrl_Select = 1'b0;
    end
end

always @(*) begin:Forwarding_Unit
    if (EX_MEM_valid && EX_MEM_Reg_w 
    && (EX_MEM_Rd_Addr != 0)
    && (EX_MEM_Rd_Addr == ID_EX_Rs_Addr)) Forward_A = 2'b01;
    else if (MEM_WB_valid && MEM_WB_Reg_w 
    && (MEM_WB_Rd_Addr != 0)
    && (MEM_WB_Rd_Addr == ID_EX_Rs_Addr)) Forward_A = 2'b10;
    else                                  Forward_A = 2'b11;
    
    if (EX_MEM_valid && EX_MEM_Reg_w 
    && (EX_MEM_Rd_Addr != 0)
    && (EX_MEM_Rd_Addr == ID_EX_Rt_Addr)) Forward_B = 2'b01;
    else if (MEM_WB_valid && MEM_WB_Reg_w 
    && (MEM_WB_Rd_Addr != 0)
    && (MEM_WB_Rd_Addr == ID_EX_Rt_Addr)) Forward_B = 2'b10;
    else                                  Forward_B = 2'b11;
end

Interface Interface(
    .clk(clk),
    .test_normal(test_normal),
    .ext_addr(ext_addr),
    .ext_data(ext_data),
    .ext_we(ext_we),
    .mem_sel(mem_sel),
    .mem_out(mem_out),
    .Interface_mem_out(Interface_mem_out),
    .Interface_test_normal(Interface_test_normal),
    .Interface_ext_addr(Interface_ext_addr),
    .Interface_ext_data(Interface_ext_data),
    .Interface_ext_we(Interface_ext_we),
    .Interface_mem_sel(Interface_mem_sel)
);

always @(posedge clk) begin:PC
    if (!rst_n) Instr_addr <= 32'd0;
    // On the test->normal transition, IM samples byte address 0 in the same edge.
    // Advance PC to 4 immediately so instruction 0 is not fetched twice.
    else if (normal_start) Instr_addr <= 32'd4;
    else if (!Interface_test_normal && PC_Write) Instr_addr <= Next_PC;
end
Adder Adder(
    .Instr_addr(Instr_addr),
    .Next_PC(Next_PC)
);

wire [31:0] IM_byte_addr;
wire        IM_enable;

assign IM_byte_addr = Interface_test_normal ? Interface_ext_addr :
                      normal_start          ? 32'd0              : Instr_addr;

assign IM_enable =
    Interface_test_normal
        ? ((Interface_ext_addr[31:30] == 2'b10) ? 1'b0 : 1'b1)
        : (normal_start | PC_Write);

IM_256_32 IM(
    .Q  (Instruction),
    .CLK(clk),
    .CEN(~IM_enable),          // active-low chip enable; high during a stall holds Q
    .A  (IM_byte_addr[9:2])
);


assign IF_ID_Instr = Instruction;

wire        RF_test_mode;
wire [4:0]  RF_rs_addr;
wire [4:0]  RF_rt_addr;
wire [4:0]  RF_rd_addr;
wire [31:0] RF_rd_data;
wire        RF_we;

assign RF_test_mode =
    Interface_test_normal &&
    (Interface_ext_addr[31:30] == 2'b10);

assign RF_rs_addr =
    RF_test_mode ? Interface_ext_addr[4:0]
                 : IF_ID_Instr[25:21];

assign RF_rt_addr =
    RF_test_mode ? Interface_ext_addr[9:5]
                 : IF_ID_Instr[20:16];

assign RF_rd_addr =
    RF_test_mode ? Interface_ext_addr[14:10]
                 : MEM_WB_Rd_Addr;

assign RF_rd_data =
    RF_test_mode ? Interface_ext_data
                 : MEM_WB_Rd_Data;

assign RF_we =
    RF_test_mode
        ? Interface_ext_we
        : ((Interface_test_normal)
            ? 1'b0
            : (MEM_WB_Reg_w & MEM_WB_valid));

RF RF(
    .clk      (clk),
    .rst_n    (rst_n),
    .Rs_addr  (RF_rs_addr),
    .Rt_addr  (RF_rt_addr),
    .Rd_addr  (RF_rd_addr),
    .Rd_data  (RF_rd_data),
    .we_signal(RF_we),
    .Rs_data  (Rs_data),
    .Rt_data  (Rt_data)
);

Control Control(
    .OpCode(IF_ID_Instr[31:26]),
    .ALU_op(IF_ID_ALU_op),
    .Reg_w(IF_ID_Reg_w),
    .Reg_dst(IF_ID_Reg_dst),
    .ALU_src(IF_ID_ALU_src),
    .Mem_w(IF_ID_Mem_w),
    .Mem_r(IF_ID_Mem_r),
    .Mem_to_reg(IF_ID_Mem_to_reg)
);

// MUX
wire       Reg_w_to_IDEX;
wire       Mem_r_to_IDEX;
wire       Mem_w_to_IDEX;
wire       Reg_dst_to_IDEX;
wire       MemtoReg_to_IDEX;
wire       ALU_src_to_IDEX;
wire [1:0] ALU_op_to_IDEX;

assign Reg_w_to_IDEX    = Ctrl_Select ? IF_ID_Reg_w      : 1'b0;
assign Mem_r_to_IDEX    = Ctrl_Select ? IF_ID_Mem_r      : 1'b0;
assign Mem_w_to_IDEX    = Ctrl_Select ? IF_ID_Mem_w      : 1'b0;
assign Reg_dst_to_IDEX  = Ctrl_Select ? IF_ID_Reg_dst    : 1'b0;
assign MemtoReg_to_IDEX = Ctrl_Select ? IF_ID_Mem_to_reg : 1'b0;
assign ALU_src_to_IDEX  = Ctrl_Select ? IF_ID_ALU_src    : 1'b0;
assign ALU_op_to_IDEX   = Ctrl_Select ? IF_ID_ALU_op     : 2'b00;

always @(posedge clk) begin:ID_EX_STAGE
    if (!rst_n) begin
        ID_EX_Rs_data <= 0;
        ID_EX_Rt_data <= 0;    
        ID_EX_Rs_Addr <= 0;
        ID_EX_Rt_Addr <= 0;
        ID_EX_Rd_Addr <= 0;
        ID_EX_Imm     <= 0;
        
        ID_EX_ALU_op  <= 0;
        ID_EX_Reg_w   <= 0;
        ID_EX_Reg_dst <= 0;
        ID_EX_ALU_src <= 0;
        ID_EX_Mem_w   <= 0;
        ID_EX_Mem_r   <= 0;
        ID_EX_Mem_to_reg <= 0;
    end
    else begin
        ID_EX_Rs_data <= Rs_data;
        ID_EX_Rt_data <= Rt_data;    
        ID_EX_Rs_Addr <= IF_ID_Instr[25:21];
        ID_EX_Rt_Addr <= IF_ID_Instr[20:16];
        ID_EX_Rd_Addr <= IF_ID_Instr[15:11];
        ID_EX_Imm     <= (IF_ID_ALU_op == 2'b11) 
                          ? {16'b0, IF_ID_Instr[15:0]}
                          : {{16{IF_ID_Instr[15]}}, IF_ID_Instr[15:0]};
        
        ID_EX_ALU_op  <= ALU_op_to_IDEX;
        ID_EX_Reg_w   <= Reg_w_to_IDEX;
        ID_EX_Reg_dst <= Reg_dst_to_IDEX;
        ID_EX_ALU_src <= ALU_src_to_IDEX;
        ID_EX_Mem_w   <= Mem_w_to_IDEX;
        ID_EX_Mem_r   <= Mem_r_to_IDEX;
        ID_EX_Mem_to_reg <= MemtoReg_to_IDEX;
    end
end

wire  [31:0] MUX_Rs_data;
wire  [31:0] MUX_Rt_data;

assign MUX_Rs_data = (Forward_A == 2'b01) ? EX_MEM_ALU_result :
                     (Forward_A == 2'b10) ? (MEM_WB_Mem_to_reg ? Mem_R_Data : MEM_WB_ALU_result) :
                     ID_EX_Rs_data;
assign MUX_Rt_data = (Forward_B == 2'b01) ? EX_MEM_ALU_result :
                     (Forward_B == 2'b10) ? (MEM_WB_Mem_to_reg ? Mem_R_Data : MEM_WB_ALU_result) :
                     ID_EX_Rt_data;
                     
ALU_Control ALU_Control(
    .ALU_funct(ALU_funct),
    .Funct_ctrl(ID_EX_Imm[5:0]),
    .ALU_op(ID_EX_ALU_op)
);
    
ALU ALU(
    .ALU_result(ALU_result),
    .Rs_data(MUX_Rs_data), 
    .Rt_Imm_data((ID_EX_ALU_src) ? ID_EX_Imm : MUX_Rt_data),
    .Shamt(ID_EX_Imm[10:6]),
    .Funct(ALU_funct)
);

always @(posedge clk) begin:EX_MEM_STAGE
    if (!rst_n) begin
        EX_MEM_Rd_Addr    <= 0;
        EX_MEM_ALU_result <= 0;
        EX_MEM_Reg_w      <= 0;
        EX_MEM_Mem_w      <= 0;
        EX_MEM_Mem_r      <= 0;
        EX_MEM_Mem_to_reg <= 0;
    end
    else begin
        EX_MEM_Rd_Addr    <= (ID_EX_Reg_dst) ? ID_EX_Rd_Addr : ID_EX_Rt_Addr;
        EX_MEM_ALU_result <= ALU_result;
        Mem_W_Data        <= MUX_Rt_data;
        EX_MEM_Reg_w      <= ID_EX_Reg_w;
        EX_MEM_Mem_w      <= ID_EX_Mem_w;
        EX_MEM_Mem_r      <= ID_EX_Mem_r;
        EX_MEM_Mem_to_reg <= ID_EX_Mem_to_reg;
    end
end

wire        DM_access;
wire        DM_write;
wire [31:0] DM_byte_addr;
wire [31:0] DM_write_data;

assign DM_access = (Interface_test_normal)
                 ? (Interface_mem_sel &&
                    (Interface_ext_addr[31:30] != 2'b10))
                 : (EX_MEM_valid & (EX_MEM_Mem_r | EX_MEM_Mem_w));

assign DM_write = (Interface_test_normal)
                ? (Interface_ext_we &&
                   Interface_mem_sel &&
                   (Interface_ext_addr[31:30] != 2'b10))
                : (EX_MEM_valid & EX_MEM_Mem_w);

assign DM_byte_addr = (Interface_test_normal)
                    ? Interface_ext_addr
                    : EX_MEM_ALU_result;

assign DM_write_data = (Interface_test_normal)
                     ? Interface_ext_data
                     : Mem_W_Data;

DM_256_32_rtl_top DM (
    .Q   (Mem_R_Data),
    .CLK (clk),
    .CEN (~DM_access),       // active-low chip enable
    .WEN (~DM_write),        // active-low write enable
    .A   (DM_byte_addr[9:2]),
    .D   (DM_write_data),
    .EMA (3'b000)
);

always @(posedge clk) begin:MEM_WB_STAGE
    if (!rst_n) begin
        MEM_WB_Rd_Addr     <= 0;
        MEM_WB_Reg_w       <= 0;
        MEM_WB_Mem_to_reg  <= 0;
        MEM_WB_ALU_result  <= 0;
        MEM_WB_R_Data      <= 0; // retained only as a debug register
    end
    else begin
        // DM is synchronous. At this edge it samples EX_MEM_* and, after the edge,
        // Mem_R_Data corresponds to the same instruction whose metadata enters MEM/WB.
        MEM_WB_Rd_Addr     <= EX_MEM_Rd_Addr;
        MEM_WB_Reg_w       <= EX_MEM_Reg_w;
        MEM_WB_Mem_to_reg  <= EX_MEM_Mem_to_reg;
        MEM_WB_ALU_result  <= EX_MEM_ALU_result;
        MEM_WB_R_Data      <= Mem_R_Data; // debug only; do not use for load WB
    end
end    

// Use SRAM Q directly for loads. Registering Q again would delay load data one extra cycle
// relative to MEM_WB_Rd_Addr / MEM_WB_Reg_w.
assign MEM_WB_Rd_Data = MEM_WB_Mem_to_reg ? Mem_R_Data : MEM_WB_ALU_result;
assign Interface_mem_out =
    RF_test_mode
        ? (Interface_ext_addr[29] ? Rt_data : Rs_data)
        : (Interface_test_normal)
            ? ((Interface_mem_sel) ? Mem_R_Data : Instruction)
            : Mem_R_Data;
    
endmodule

