`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/25/2025 04:08:03 PM
// Design Name: 
// Module Name: RegisterFile
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


module registerFile #(parameter N=32)
(
  input clk,
  input rst,
  output [N-1:0]ReadingPortOne,
  output [N-1:0] ReadingPortTwo,
  input  [N-1:0] WritingPort, 
  input [4:0] SelectReadOne,
  input [4:0] SelectReadTwo,
  input[4:0] SelectWrite, 
  input RegWrite);

reg[N-1:0] Registers[0:31] ; // for the instructions themselves, from register 0 to register 31
assign ReadingPortOne = Registers[SelectReadOne];
assign ReadingPortTwo = Registers[SelectReadTwo];
integer i; 

always @ (posedge clk || rst) begin
Registers[0] <= 32'd0;
if(rst == 1)begin
    for(i=0;i<32;i=i+1)begin
        Registers[i]=32'd0;
    end end
  else begin
      if (SelectWrite && RegWrite)
        Registers[SelectWrite] = WritingPort;
    end
  end 
endmodule

