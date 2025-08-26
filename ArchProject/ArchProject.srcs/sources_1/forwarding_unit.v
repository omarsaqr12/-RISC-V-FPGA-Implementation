`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/03/2025 08:31:29 PM
// Design Name: 
// Module Name: forwarding_unit
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


module forwarding_unit (
    input wire MEM_WB_RegWrite,
    input wire [4:0] ID_EX_RegisterRs1,
    input wire [4:0] ID_EX_RegisterRs2,
    input wire [4:0] MEM_WB_RegisterRd,
    output reg forwardA,
    output reg forwardB
);

always @(*) begin
    // Default to no forwarding
    forwardA = 1'b0;
    forwardB = 1'b0;

   
    // MEM hazard (forward from MEM/WB)
    if (MEM_WB_RegWrite && (MEM_WB_RegisterRd != 0) && (MEM_WB_RegisterRd == ID_EX_RegisterRs1) )
        forwardA = 1'b1;

    if (MEM_WB_RegWrite && (MEM_WB_RegisterRd != 0) && (MEM_WB_RegisterRd == ID_EX_RegisterRs2) )
        forwardB = 1'b1;
end

endmodule
