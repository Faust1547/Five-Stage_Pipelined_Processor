//
//      CONFIDENTIAL  AND  PROPRIETARY SOFTWARE OF ARM Physical IP, INC.
//      
//      Copyright (c) 1993-2024  ARM Physical IP, Inc.  All  Rights Reserved.
//      
//      Use of this Software is subject to the terms and conditions  of the
//      applicable license agreement with ARM Physical IP, Inc.  In addition,
//      this Software is protected by patents, copyright law and international
//      treaties.
//      
//      The copyright notice(s) in this Software does not indicate actual or
//      intended publication of this Software.
//      
//      name:			Advantage Single-Port SRAM Generator
//           			TSMC 90nm CLN90G Process
//      version:		2007Q4V2
//      comment:		
//      configuration:	 -instname "DM_256_32" -words 256 -bits 32 -frequency 250 -ring_width 2.0 -mux 8 -write_mask off -wp_size 8 -top_layer "met5-9" -power_type rings -horiz met3 -vert met4 -redundancy off -rcols 2 -rrows 2 -bmux off -ser none -ema on -cust_comment "" -bus_notation on -left_bus_delim "[" -right_bus_delim "]" -pwr_gnd_rename "VDD:VDD,VSS:VSS" -prefix "" -pin_space 0.0 -name_case upper -check_instname on -diodes on -inside_ring_type VSS -drive 6 -asvm off -corners ff_1.1_-40.0,ff_1.1_.0,tt_1.0_25.0,ss_0.9_125.0
//
//      Repair Verilog RTL for Synchronous Single-Port Ram
//
//      Top Module Name:            DM_256_32_rtl_top
//      Words:                      256
//      User Bits:                  32
//      Mux:                        8
//      Drive:                      6
//      Write Mask:                 Off
//      Extra Margin Adjustment:    On
//      Accelerated Retention Test: Off
//      Redundant Rows:             0
//      Redundant Columns:          0
//      Test Muxes                  Off
//
//      Creation Date:  2024-06-16 14:45:12Z
//      Version: 	2007Q4V2
//
`timescale 1ns/1ps

 
module DM_256_32_rtl_top (
   Q,
   CLK,
   CEN,
   WEN,
   A,
   D,
   EMA
);

   output [31:0]            Q;
   input                    CLK;
   input                    CEN;
   input                    WEN;
   input [7:0]              A;
   input [31:0]             D;
   input [2:0]              EMA;
   wire		[31:0]	DI;
   wire		[31:0]	QO;


   assign Q=QO;
   assign DI=D;

DM_256_32_fr_top u0 (
   .QO(QO),
   .CLK(CLK),
   .CEN(CEN),
   .WEN(WEN),
   .A(A),
   .DI(DI),
   .EMA(EMA)
);

endmodule
module DM_256_32_fr_top (
   QO,
   CLK,
   CEN,
   WEN,
   A,
   DI,
   EMA
);

   output [31:0]            QO;
   input                    CLK;
   input                    CEN;
   input                    WEN;
   input [7:0]              A;
   input [31:0]             DI;
   input [2:0]              EMA;
   wire	[31:0]	D;
   wire	[31:0]	Q;

   assign D=DI;
   assign QO=Q;

DM_256_32 u0 (
   .Q(Q),
   .CLK(CLK),
   .CEN(CEN),
   .WEN(WEN),
   .A(A),
   .D(D),
   .EMA(EMA)
);

endmodule
