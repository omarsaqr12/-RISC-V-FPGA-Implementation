`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/25/2025 05:33:24 PM
// Design Name: 
// Module Name: ALUCU
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

module ALUCU( input[1:0] AluOP, input [2:0] Inst, input Ins_30, input Ins_25, output reg [4:0]  ALU_sel);

reg [4:0] ALUCont;

// slt -> 1101
// sltu -> 1111

// shift left logical -> 1000
// shift right logical -> 1001
// shift right arithmetic -> 1010
//xor -> 0111
always@(*)begin  
    ALUCont = {Ins_25,Ins_30,Inst};
    case(AluOP)
    2'b00: ALU_sel=5'b00000; // load byte, halfword, and word, store byte, halfword, and word.
    2'b01: ALU_sel=5'b00001; // branch if equal
    2'b10: begin // R-format
        if(ALUCont ==5'b00000)ALU_sel=5'b00000 ; //addition
        else if(ALUCont == 5'b01000) ALU_sel=5'b00001; // subtract
        else if(ALUCont==5'b00111) ALU_sel=5'b00101; // and
        else if(ALUCont==5'b00110 )ALU_sel=5'b00100; //or
        else if (ALUCont == 5'b00001)// sll  shift left logical
        ALU_sel = 5'b01000;
        else if (ALUCont == 5'b00010) // SLT
        ALU_sel = 5'b01101;
        else if (ALUCont == 5'b00011) // SLTU
        ALU_sel = 5'b01111;
        else if (ALUCont == 5'b00100) //XOR
        ALU_sel = 5'b00111;
        else if (ALUCont == 5'b00101) //SRL
        ALU_sel = 5'b01001;
        else if (ALUCont == 5'b01101) //SRA
        ALU_sel = 5'b01010; 
        else if (ALUCont == 5'b00110) //OR
        ALU_sel = 5'b00100;
        else if (ALUCont == 5'b00111) //AND
        ALU_sel = 5'b00101;
        else if (ALUCont == 5'b10000) // support for multiplication, division, and rem. RV32IM
        ALU_sel = 5'b10000;
        else if (ALUCont == 5'b10001)
        ALU_sel = 5'b10001;
        else if (ALUCont == 5'b10010)
        ALU_sel = 5'b10010;
        else if (ALUCont == 5'b10011)
        ALU_sel = 5'b10011;
        else if (ALUCont == 5'b10100)
        ALU_sel = 5'b10100;
        else if (ALUCont == 5'b10101)
        ALU_sel = 5'b10101;
        else if (ALUCont == 5'b10110)
        ALU_sel = 5'b10110;
        else if (ALUCont == 5'b10111)
        ALU_sel = 5'b10111;
    end    
    2'b11: begin //to support I-format instructions only
        if(Inst == 3'b000) //ADDI
        ALU_sel = 5'b00000; //
        else if (Inst == 3'b010) //slti
        ALU_sel = 5'b01101;
        else if (Inst == 3'b011) //sltiu
        ALU_sel = 5'b01111;
        else if (Inst == 3'b100) //xori
        ALU_sel = 5'b00111;
        else if (Inst == 3'b110) //ORI
        ALU_sel = 5'b00100;
        else if (Inst == 3'b111) //ANDI
        ALU_sel = 5'b00101;
        else if (Inst == 3'b001) //SLLI
        ALU_sel = 5'b01000; 
        else if (Inst == 3'b101) //SRLI or SRAI
        begin
        if (Ins_30 == 1'b1) // SRAI (Shift right arithmetic immediate)
        ALU_sel = 5'b01010;
        else if (Ins_30 == 1'b0) //SRLI (Shift Right Logical Immediate)
        ALU_sel = 5'b01001;
        end
        end
     default: ALU_sel = 5'dx;
    endcase   
end        
endmodule
    







