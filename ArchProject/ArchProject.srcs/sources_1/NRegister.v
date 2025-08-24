`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/18/2025 02:51:57 PM
// Design Name: 
// Module Name: NRegister
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module NRegister # (parameter n=32) (input clk, input rst, input load, input [n-1:0] inputData, output [n-1:0] data);

wire [n-1:0] pass;
    genvar i;
    generate
    for ( i = 0; i<n ;i=i+1)  begin
        assign pass[i]= (load==0)?data[i]:inputData[i];
        DFlipFlop D(clk, rst, pass[i], data[i]);
    end
    endgenerate 
    
endmodule
