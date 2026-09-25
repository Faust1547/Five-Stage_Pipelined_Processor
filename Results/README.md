## Hierarchy
``` text
Results
├── README.md
├── ATPG Result
│   └── Stuck Fault Summary Report.png
├── Post-sim Result
│   └── README.md
└── VLSI Implement 
    ├── Area
    ├── Chip
    ├── LVS
    ├── Power
    └── Timing
```
## RTL Simulation
透過 Testbench 驗證五階 Pipeline CPU 能否正確輸入外部資料至 IM 與 DM，依照指令執行對應運算，並且能透過 Hazard Detect與 Forwarding 設計應對 Data Hazard的狀況。

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
