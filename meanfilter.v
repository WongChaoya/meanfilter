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
module meanfitler #(
    parameter           DATA_WITH    =  24,
    parameter    [7:0]  MEAN_Level   =  7
) 
(
    //系统信号
    input       wire                        clk,
    input       wire                        en,
    //输入信号
    input       wire                        iValid,
    input       wire [DATA_WITH-1:0]     iData,
    //输出信号
    output      wire  [DATA_WITH + MEAN_Level -1:0]     oData,
    output      wire                        oReady

);


reg     [DATA_WITH-1:0]  iDataReg    =   0;
reg     [DATA_WITH + MEAN_Level -1:0] data_mult =   0;
reg     [DATA_WITH + MEAN_Level -1:0] data_sum       =   0;
reg     [DATA_WITH + MEAN_Level -1:0] data_div   =   0;
reg     [4:0]iValidReg  =   0;
reg     [1:0] StateReg  =   0;
wire  crossline =   ((iDataReg[DATA_WITH-1:DATA_WITH-2] ==2'b11) && (iData[DATA_WITH-1:DATA_WITH-2] == 2'b00))||
                    ((iDataReg[DATA_WITH-1:DATA_WITH-2] ==2'b00) && (iData[DATA_WITH-1:DATA_WITH-2] == 2'b11)) ;
always @(posedge clk) begin
    if (en) begin
        case (StateReg)
            2'd0:begin
                if (crossline) begin
                    StateReg    <=  StateReg    +   1'b1;
                    data_div    <=  iData;
                end
                else if (~iValidReg[1] && iValidReg[0]) begin
                    StateReg    <=  StateReg    +   1'b1;
                    data_div    <=  iDataReg;
                end
            end 
            2'd1:begin//待优化
                if (crossline) begin
                    data_mult   <=  (iData   <<     MEAN_Level) -  iData;
                    StateReg    <=  StateReg    +   1'b1;
                end
                else if(~iValidReg[2] && iValidReg[1])    begin
                    data_mult   <=  (data_div    <<   MEAN_Level) - data_div;
                    StateReg    <=  StateReg    +   1'b1;
                end
            end
            2'd2:begin
                if (crossline) begin
                    data_sum    <=  iData << MEAN_Level;
                    StateReg    <=  StateReg    +   1'b1;
                end
                else if(~iValidReg[3] && iValidReg[2])    begin
                    data_sum    <=  data_mult   +   iData;
                    StateReg    <=  StateReg    +   1'b1;
                end
            end
            2'd3:begin//待优化
                if (crossline) begin
                    data_div    <=  iData ;
                    StateReg    <=  1;
                end
                else if (~iValidReg[4] && iValidReg[3]) begin
                    data_div        <=  data_sum    >>  MEAN_Level;
                    StateReg    <=  1;
                end
            end
            default: ;
        endcase 
    end
/*     else begin
        StateReg    <=  2'd0;
    end */
end

always @(posedge clk) begin
    if (~iValidReg[0] && iValid) begin
        iDataReg    <=  iData;
    end
end

always @(posedge clk) begin
    iValidReg   <=  {iValidReg[3:0],iValid};
end

assign  oData   =   en  ?   data_sum    :   {iData,{(MEAN_Level){1'b0}}};
assign  oReady  =   iValidReg[4];

endmodule
