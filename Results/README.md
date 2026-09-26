## Hierarchy
``` text
Results
├── README.md
├── ATPG Result
│   └── Stuck Fault Summary Report.png
├── Post-sim Result
│   ├── Input Data
│   ├── Output Data
│   ├── Verification Data
│   └── README.md
└── VLSI Implement 
    ├── Area
    ├── Chip
    ├── LVS
    ├── Power
    └── Timing
```
## Post-sim Result
透過 Testbench 驗證五級 Pipeline CPU 的外部指令與資料載入、指令執行及資料記憶體讀寫功能，並測試 Hazard Detection 與 Forwarding 機制，以確認處理器能正確處理資料相依問題。

## Physical Implementation
| Specification | TSMC 90 nm 1P9M |
|---|---|
| Frequency | 200 MHz |
| Timing Closure | Setup / Hold Met |
| Dynamic Power | 50.7013 mW | 
| Cell Leakage Power | 635.2643 µW |  
| Core Area | 738,807.679 μm² | 
| Chip Area | 1,630,160.620 μm² | 
| LVS | Correct |

## ATPG Stuck Fault Summary Report
| Specification | Result |
|---|---|
| Total Faults | 52826 |
| Test Coverage | 95.87 % |
| Fault Coverage | 93.40 % | 
