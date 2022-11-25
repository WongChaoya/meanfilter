`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////////
// COPYRIGHT(c)2022, GENERTEC GUOCE TIME GRATING TECHNOLOGY CO.,LTD. 
// All rights reserved.
// File name   : meanfilter.v
// Author      : ChaoyaWang
// Date        : 2022-11-02
// Version     : 0.1
// Description :
//    滑动均值滤波窗
//    
//    
// Modification History:
//   Date       |   Author      |   Version     |   Change Description
//==============================================================================
// 2022-11-02   |    ChaoyaWang |     0.1        | Base Version
////////////////////////////////////////////////////////////////////////////////
module meanWindow #(
    parameter        DATA_WITH    =   24,
    parameter   MEAN_Level      =   7
) 
(
    //系统信号
    input       wire                        clk,
    input       wire                        en,
    //输入信号
    input       wire                        iValid,
    input       wire [DATA_WITH-1:0]     iData,
    //输出信号
    output      wire [DATA_WITH + MEAN_Level -1:0]     oData,
    output      wire                        oReady

);


reg     [DATA_WITH-1:0]  iDataReg    =   0;
reg     [DATA_WITH-1:0]  iDataReg2    =   0;
reg     [DATA_WITH + MEAN_Level -1:0] data_mult =   0;
reg     [DATA_WITH + MEAN_Level -1:0] data_sum   =   0;
reg     [DATA_WITH + MEAN_Level -1:0] data_div   =   0;
reg     [4:0]iValidReg  =   0;
reg     [1:0] StateReg  =   0;

always @(posedge clk) begin
    if (en) begin
        case (StateReg)
            0:begin
                if (~iValidReg[1] && iValidReg[0]) begin
                    StateReg    <=  StateReg    +   1'b1;
                    data_div    <=  iDataReg;
                end
            end 
            1:begin//待优化
                if(~iValidReg[2] && iValidReg[1])    begin
                    data_mult   <=  (data_div    <<   MEAN_Level) - data_div;
                    StateReg    <=  StateReg    +   1'b1;
                end
            end
            2:begin
                if (~iValidReg[3] && iValidReg[2]) begin
                    data_sum    <=  data_mult   +   iData;
                    StateReg    <=  StateReg    +   1'b1;
                end
            end
            3:begin//待优化
                if (~iValidReg[4] && iValidReg[3]) begin
                    data_div    <=  data_sum    >>  MEAN_Level;
                    StateReg    <=  1;
                end
            end
            default: StateReg   <=  0;
        endcase 
    end
    else begin
        data_div[DATA_WITH  -1:0]    <=  iData;
    end
end

always @(posedge clk) begin
    if (~iValidReg[0] && iValid) begin
        iDataReg    <=  iData;
    end
end

always @(posedge clk) begin
    iValidReg   <=  {iValidReg[3:0],iValid};
end
assign  oData   =   en ? data_sum   :   {iDataReg,{(MEAN_Level){1'b0}}};
assign  oReady  =   iValidReg[4];

endmodule
