## Top Module

`TOP.v`

## Testbench

`tb_FinalCPU.v`

## Module Hierarchy

```text
TOP.v
├── Interface.v
├── RF.v
├── Control.v
├── ALU_Control.v
├── ALU.v
├── Adder.v
├── IM_256_32.v
└── DM_256_32_rtl_top.v
    └── DM_256_32.v
```
| Module | Description |
|---|---|
| `TOP.v` | 最上層模組 |
| `Interface.v` | 負責連接外部與內部資料的輸出入介面 |
| `RF.v` | 檔案暫存器 |
| `Control.v` | 根據當前指令類型輸出對應的 Reg_dst、Reg_w、ALU_src、ALU_op、Mem_w、Mem_r、Mem_to_reg 訊號|
| `ALU_Control.v` | 根據當前指令類型輸出對應的 addu、addiu、subu、subiu、sll、or 運算指令 |
| `ALU.v` | 運算邏輯單元 |
| `Adder.v` | 負責計算 PC 位址 |
| `IM_256_32.v` | IM SRAM IP |
| `DM_256_32_rtl_top.v` | RTL wrapper for DM SRAM IP |
| `DM_256_32.v` | DM SRAM IP  |
