`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/10/2025 04:58:36 PM
// Design Name: 
// Module Name: shifter
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


module shifter(input [31:0] a, input [4:0] shamt, input [1:0] type, output reg [31:0] r);

// this shifter module is responsible for whether shifting left or shifting right logical, or shifting right arithmetic

//shamt is just an immediate and that's it. the type will be responsible for determining SRA, SRL, SRAI

always @* begin

case(type)

2'b00: r = a << shamt; // shift left logical

2'b01: r = (a >> shamt); //shift right logical

2'b10: r = $signed(a) >>> shamt; // shift right arithmetic

default: r = 32'd0;

endcase


end

endmodule
