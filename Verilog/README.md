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
| `TOP.v` | 整合五級 Pipeline CPU、記憶體與外部資料介面 |
| `Interface.v` | 負責外部資料介面控制，並整合 Hazard Detection 與 Forwarding 邏輯|
| `RF.v` | 暫存器檔案（Register File），負責暫存器資料讀寫 |
| `Control.v` | 根據指令欄位產生暫存器、ALU 與記憶體操作所需的控制訊號|
| `ALU_Control.v` | 根據指令及 ALU 控制訊號決定執行的運算 |
| `ALU.v` | 執行算術及邏輯運算 |
| `Adder.v` | 計算下一個 PC 位址 |
| `IM_256_32.v` | 256 × 32-bit Instruction Memory |
| `DM_256_32_rtl_top.v` | Data Memory SRAM IP 的 RTL Wrapper |
| `DM_256_32.v` | 256 × 32-bit Data Memory  |
