`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/10/2025 08:11:39 PM
// Design Name: 
// Module Name: branchDecoder
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


module branchDecoder(input carryFlag, zeroFlag, overflowFlag, signFlag, input [2:0] func3, output reg branchOrNot );

always @ * begin
case(func3)
    3'b000:begin if(zeroFlag)
            branchOrNot <=1'b1;
            end
     3'b001: begin
            if (!zeroFlag)
            branchOrNot <=1'b1;
            else
            branchOrNot <= 1'b0;
            end
     3'b100: begin
            if ( signFlag != overflowFlag)
            branchOrNot <= 1'b1;
            else
            branchOrNot <= 1'b0;
            end
     3'b101: begin
            if ( signFlag == overflowFlag)
            branchOrNot <= 1'b1;
            else 
            branchOrNot <= 1'b0;
     end
     3'b110: begin
            if (!carryFlag)
            branchOrNot <= 1'b1;
            else
            branchOrNot <= 1'b0;
     end
     3'b111: begin
            if (carryFlag)
            branchOrNot <= 1'b1;
            else
            branchOrNot <= 1'b0;
     end
     default: branchOrNot <= 1'b0;
endcase
end
endmodule
