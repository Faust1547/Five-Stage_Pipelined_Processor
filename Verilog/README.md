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
| `TOP.v` | 最上層模組，負責整個系統與外部資料、訊號溝通 |
| `Control_Unit_V2.v` | 負責控制系統運作狀態與加密或解密模式選擇訊號 |
| `KeyExpansion.v` | 依 AES-128 Key Schedule 產生各回合金鑰，供加密及解密流程使用 |
| `SubByte.v` | 將資料送入 S_Box 中轉換 |
| `ShiftRows.v` | 依 AES 規則對 State Matrix 各列進行循環位移 |
| `MixColumns.v` | 將 State Matrix 分組為四個 Column，整合子運算單元以完成 MixColumns 轉換 |
| `MixColumnsUnit.v` | 執行單一 Column 的 GF(2⁸) 矩陣運算 |
| `AddRoundKey.v` | 負責將回合金鑰與當前資料進行 XOR 運算 |
| `InvSubByte.v` | 將資料送入 Inv_S_Box 中逆轉換 |
| `InvShiftRow.v` | 依反向規則對 State Matrix 各列進行循環位移 |
| `InvMixColumns.v` | 整合反向列混合運算單元，完成 InvMixColumns 轉換 |
| `InvMixColumnsUnit.v` | 執行單一 Column 的反向 GF(2⁸) 矩陣運算 |
| `S_Box.v` | 實現 AES S-Box 查找表，進行非線性位元組替換 |
| `Inv_S_Box.v` | 實現 Inverse S-Box 查找表，進行反向位元組替換 |
