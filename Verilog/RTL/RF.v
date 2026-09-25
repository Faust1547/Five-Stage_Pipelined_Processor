module RF(
    input               clk,
    input               rst_n,

    input       [4:0]   Rs_addr,
    input       [4:0]   Rt_addr,
    input       [4:0]   Rd_addr,
    input       [31:0]  Rd_data,
    input               we_signal,

    output reg  [31:0]  Rs_data,
    output reg  [31:0]  Rt_data
);

reg [31:0] RF_Mem [0:31];
integer i;

// Two original asynchronous read ports.
always @(*) begin
    if (Rs_addr == 5'd0)
        Rs_data = 32'b0;
    else if (we_signal && (Rd_addr != 5'd0) && (Rd_addr == Rs_addr))
        Rs_data = Rd_data;
    else
        Rs_data = RF_Mem[Rs_addr];

    if (Rt_addr == 5'd0)
        Rt_data = 32'b0;
    else if (we_signal && (Rd_addr != 5'd0) && (Rd_addr == Rt_addr))
        Rt_data = Rd_data;
    else
        Rt_data = RF_Mem[Rt_addr];
end

// Original synchronous write port.
always @(posedge clk) begin : WRITE
    if (!rst_n) begin
        for (i = 0; i < 32; i = i + 1)
            RF_Mem[i] <= 32'b0;
    end
    else begin
        if (we_signal && (Rd_addr != 5'd0))
            RF_Mem[Rd_addr] <= Rd_data;

        RF_Mem[0] <= 32'b0;
    end
end

endmodule

