`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/25/2025 04:55:53 PM
// Design Name: 
// Module Name: controlUnit
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

module ControlUnit (
    input [6:0] opcode,
    output reg RegWrite,//
    output reg MemtoReg,//
    output reg MemWrite,//
    output reg MemRead,//
    output reg Branch,//
    output reg  ALUSrc,//
    output reg [1:0]ALUop,//
    output reg jalr,
    output reg auipc,
    output reg jal,
    output reg lui,
    output reg fence);
initial begin
end
always @(*) begin
    case(opcode[6:2])   
        5'b01100: begin // the alu operations without the i-format
            RegWrite = 1;
            MemtoReg = 0;
            MemWrite = 0;
            MemRead = 0;
            Branch <= 0;
            ALUop <=2'b10;
            ALUSrc<=0;
            jalr <= 0;
            auipc <=0;
            jal <=0;
            lui <= 1'b0;
            fence <= 1'b0;
        end
        5'b11000: begin
            RegWrite = 1'bx;
            MemtoReg = 1'bX;
            MemWrite = 0;
            MemRead = 0;
            Branch <= 1'b1;
            ALUop <=2'b01;
            ALUSrc <=0;
            jalr <= 0;
            auipc <=0;
            jal <=0;
            lui <= 1'b0;
            fence <= 1'b0;
        end
        5'b00000: begin
            RegWrite = 1;
            MemtoReg = 1;
            MemWrite = 0;
            MemRead = 1;
            Branch <= 0;
            ALUop <=2'b00;
            ALUSrc <=1;
            jalr <= 0;
            auipc <=0;
            jal <=0;
            lui <= 1'b0;
            fence <= 1'b0;
        end
        5'b01000: begin //storing instructions
            RegWrite <= 0;
            MemtoReg <= 1'bX;
            MemWrite <= 1;
            MemRead <= 0;
            Branch <= 0;
            ALUop <=2'b00;
            ALUSrc <=1;
            jalr <= 0;
            auipc <=0;
            jal <=0;
            lui <= 1'b0;
            fence <= 1'b0;
        end
        
        5'b00101: begin //AUIPC Decoding Unit
            RegWrite <= 1;
            MemtoReg <= 1'b0; 
            MemWrite <= 1'bx;
            MemRead <= 1'b0;
            Branch <= 0;
            ALUop <= 2'b00;
            ALUSrc <= 1'b0;
            jalr <= 0;
            auipc <=1'b1;
            jal <=0;
            lui <= 1'b0;
            fence <= 1'b0;
        end
        5'b11011: begin //jal instruction. 
            RegWrite <= 1'b1;
            MemtoReg <= 1'bx; 
            MemWrite <= 1'bx;
            MemRead <= 1'b0;
            Branch <= 0;
            ALUop <= 2'bxx;
            ALUSrc <= 1'bx;
            jalr <= 1'b0;
            auipc <=1'b0;
            jal <=1'b1;
            lui <= 1'b0;
            fence <= 1'b0;
        end
        5'b11001: begin //jalr decoding
            RegWrite <= 1;
            MemtoReg <= 1'bx; 
            MemWrite <= 1'bx;
            MemRead <= 1'b0;
            Branch <= 1'b0;
            ALUop <= 2'bxx;
            ALUSrc <= 1'bx;
            jalr <= 1'b1;
            auipc <= 1'b0;
            jal <= 1'b0;
            lui <= 1'b0;
            fence <= 1'b0;
        end
        5'b01101: begin //LUI decoding
        RegWrite <= 1'b1;
        MemtoReg <= 1'bx;
        MemWrite <= 1'bx;
        MemRead <= 1'bx;
        Branch <= 1'b0;
        ALUop <= 2'bxx;
        ALUSrc <= 1'bx; 
        jalr <= 1'b0;
        auipc <=1'b0;
        jal <= 1'b0;
        lui <= 1'b1;
        fence <= 1'b0;
        end
        5'b00100: begin
        RegWrite <= 1'b1;
        MemtoReg <= 1'b0;
        MemWrite <= 1'bx;
        MemRead  <= 1'bx;
        Branch <= 1'b0;
        ALUop <= 2'b11;
        ALUSrc <= 1'b1;
        jalr <= 1'b0;
        auipc <=1'b0;
        jal <= 1'b0;
        lui <= 1'b0;
        fence <= 1'b0;
        end
        5'b00011: begin 
        RegWrite <= 1'bx;
        MemtoReg <= 1'bx;
        MemWrite <= 1'bx;
        MemRead <= 1'bx;
        Branch <= 1'bx;
        ALUop <= 2'bxx;
        ALUSrc <= 1'bx; 
        jalr <= 1'bx;
        auipc <=1'bx;
        jal <= 1'bx;
        lui <= 1'bx;
        fence <= 1'b1;
        end
        5'b11100: begin
        RegWrite <= 1'bx;
        MemtoReg <= 1'bx;
        MemWrite <= 1'bx;
        MemRead <= 1'bx;
        Branch <= 1'bx;
        ALUop <= 2'bxx;
        ALUSrc <= 1'bx; 
        jalr <= 1'bx;
        auipc <=1'bx;
        jal <= 1'bx;
        lui <= 1'bx;
        fence <= 1'b1;
        end
        default: {RegWrite, MemtoReg, MemWrite, MemRead, Branch, ALUop, ALUSrc, jalr, auipc, jal, lui, fence} = 13'dx;
endcase
end
endmodule