// Copyright (C) 2018  Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License 
// Subscription Agreement, the Intel Quartus Prime License Agreement,
// the Intel FPGA IP License Agreement, or other applicable license
// agreement, including, without limitation, that your use is for
// the sole purpose of programming logic devices manufactured by
// Intel and sold by Intel or its authorized distributors.  Please
// refer to the applicable agreement for further details.

// *****************************************************************************
// This file contains a Verilog test bench template that is freely editable to  
// suit user's needs .Comments are provided in each section to help the user    
// fill out necessary details.                                                  
// *****************************************************************************
// Generated on "02/25/2022 09:39:23"
                                                                                
// Verilog Test Bench template for design : meanWindow
// 
// Simulation tool : ModelSim-Altera (Verilog)
// 
`define CLK_50M     20  
`define CLK_6P25M   16000   
`timescale 1 ns/ 1 ns
module meanfilter_tb();
// constants                                           
// test vector input registers
parameter MEAN_LEVEL = 3;
parameter DATAIN_WIDTH = 24;
reg clk;
reg en;
reg [DATAIN_WIDTH-1:0] iData;
reg iValid;
// wires                                               
wire [DATAIN_WIDTH + MEAN_LEVEL -1:0]  oData;
wire oReady;
integer i;
integer fd;
reg [DATAIN_WIDTH-1:0] mem[9999:0];



// assign statements (if any)                          
meanfilter #(
    .DATA_WITH(DATAIN_WIDTH),
    .MEAN_Level(MEAN_LEVEL)
)
i1 (
// port map - connection between master ports and signals/registers   
	.clk(clk),
	.en(1'b1),
	.iData(iData),
	.iValid(iValid),
	.oData(oData),
	.oReady(oReady)
);
//初始化
initial begin
    clk     =   0   ;
    en      =   0   ;
    iValid  =   0   ;
    i       =   0   ;
    iData   =  mem[0];
end
//读数据
initial begin
    $readmemh("data.txt",mem);
end
//产生50Mhz时钟
always begin
    #(`CLK_50M  /   2)  clk     =   ~clk    ;
end
always begin
    #(`CLK_6P25M /  2)  iValid  =   ~iValid ;   
end
initial begin
    fd  = $fopen("dataafterfilter.txt");
    repeat(10000) begin
        @(posedge iValid)  begin
            en      =   1   ;
            iData   =   mem[i];
            i       =   i   +   1;   
        end
    end
    #200    en  =   0   ;
    #200    ;
    $stop   ;
end
always @(i) begin
    $fdisplay(fd,"%d",oData[26:3]);
end

endmodule


