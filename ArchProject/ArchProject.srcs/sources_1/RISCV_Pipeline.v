`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/01/2025 09:43:20 PM
// Design Name: 
// Module Name: RISCV_Pipeline
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


module RISCV_Pipeline(input clk, input rst);
//starting the pipeline. Feel free to look at the diagram to understand more.
//In this project, we are not implementing the full RISC-V pipeline, rather a variant, where we will also consider structural hazards

//Lets start with the IF/ID pc.
reg [31:0] beforeIDPC;
wire [31:0] beforeIDPCPLUS4;
wire [31:0] beforeIDPCOUT;

NRegister #(32) PC (clk, rst, 1'b1, beforeIDPC, beforeIDPCOUT); //Pc register


// Let's start with the PC.

wire [31:0] inputFromMux;
wire [31:0] EX_MEM_ALUoutput;
wire [31:0] dataout;

assign inputFromMuxAddr = (clk) ? { { {26'b0} } , beforeIDPCOUT[7:2] } : { {{20'b0}}, EX_MEM_ALUoutput[11:0] }; 

wire EX_MEM_MemWrite;
wire EX_MEM_MemRead;
wire [31:0] EX_MEM_rs2data;
wire [2:0] EX_MEM_Func3;

reg [31:0] noor;
singleMemory memory (clk, EX_MEM_MemRead, EX_MEM_MemWrite, EX_MEM_Func3, (clk) ? beforeIDPCOUT[11:0] : EX_MEM_ALUoutput[11:0], EX_MEM_rs2data, dataout);

always @(*) begin
        if (clk == 1)
         noor <= dataout; // Update on the rising edge of the clock
    end
wire [31:0] instruction;

assign instruction = noor;

wire [31:0] IF_ID_Instruction;
wire [31:0] IF_ID_PC;
wire [31:0] IF_ID_PC_4;
wire [31:0] IF_ID_rs1data;
wire [31:0] IF_ID_rs2data;

NRegister #(96) IF_ID (~clk, rst, 1'b1, 
{instruction, beforeIDPCOUT, beforeIDPCPLUS4},
{IF_ID_Instruction, IF_ID_PC, IF_ID_PC_4} );

wire [31:0] ID_EX_rs1data, ID_EX_rs2data;
wire [4:0] ID_EX_rs1, ID_EX_rs2, EX_MEM_writingPort;
wire [31:0] MEM_WB_writingData;

registerFile regfile (~clk, rst, IF_ID_rs1data, IF_ID_rs2data, MEM_WB_writingData,
 IF_ID_Instruction[19:15], IF_ID_Instruction[24:20], MEM_WB_writingPort, MEM_WB_RegWrite); 

wire IF_ID_RegWrite;
wire IF_ID_MemWrite;
wire IF_ID_MemRead;
wire [1:0] IF_ID_ALUop;
wire IF_ID_MemtoReg;
wire IF_ID_Branch;
wire IF_ID_ALUSrc;
wire IF_ID_auipc;
wire IF_ID_jal;
wire IF_ID_jalr;
wire IF_ID_lui;

wire RegWrite;
wire MemWrite;
wire MemRead;
wire [1:0] ALUop;
wire MemtoReg;
wire Branch;
wire ALUSrc;
wire auipc;
wire jal;
wire jalr;
wire lui;
wire fence;
ControlUnit CU ( IF_ID_Instruction[6:0],
    RegWrite,//
    MemtoReg,//
    MemWrite,//
    MemRead,//
    Branch,//
    ALUSrc,//
    ALUop,//
    jalr,
    auipc,
    jal,
    lui,
    fence);
    wire [31:0] IF_ID_imm;
 rv32_ImmGen immGen (IF_ID_Instruction, IF_ID_imm);
 
    wire ID_EX_MemRead,ID_EX_Branch,ID_EX_ALUSrc,ID_EX_RegWrite,ID_EX_MemtoReg,ID_EX_MemWrite;
    wire [1:0]ID_EX_ALUop;
    wire ID_EX_jalr,ID_EX_auipc,ID_EX_jal,ID_EX_lui;
    wire [31:0] ID_EX_imm, ID_EX_PC, ID_EX_PC_4;
    wire ID_EX_Instruction_30, ID_EX_Instruction_25;
    wire [2:0] ID_EX_Func3;
    wire [31:0] ID_EX_rs1data, ID_EX_rs2data;
    wire [4:0] ID_EX_rs1addr, ID_EX_rs2addr, ID_EX_writingPort;
    
    
  //******************************** Start ID_EX Register ************************************************
 NRegister #(192) ID_EX (clk, rst, 1'b1, 
 {IF_ID_RegWrite,IF_ID_MemtoReg,IF_ID_MemWrite,
 IF_ID_MemRead,IF_ID_Branch,IF_ID_ALUSrc,IF_ID_ALUop,IF_ID_jalr,IF_ID_auipc,IF_ID_jal,IF_ID_lui,
 IF_ID_imm, IF_ID_PC, IF_ID_PC_4, IF_ID_Instruction[30], IF_ID_Instruction[25], IF_ID_Instruction[14:12],
 IF_ID_Instruction[19:15], IF_ID_Instruction[24:20], IF_ID_Instruction[11:7], IF_ID_rs1data, IF_ID_rs2data},
 
 {ID_EX_RegWrite,ID_EX_MemtoReg,ID_EX_MemWrite,
 ID_EX_MemRead,ID_EX_Branch,ID_EX_ALUSrc,ID_EX_ALUop,ID_EX_jalr,ID_EX_auipc,ID_EX_jal,ID_EX_lui,
 ID_EX_imm, ID_EX_PC, ID_EX_PC_4, ID_EX_Instruction_30, ID_EX_Instruction_25, ID_EX_Func3,
 ID_EX_rs1addr, ID_EX_rs2addr, ID_EX_writingPort, ID_EX_rs1data, ID_EX_rs2data}
 
 );  //Finished the ID_EX register.
 //******************************** Finished ID_EX Register *************************************************
 
 //Now we are in the execution stage. we have multiple things.
 
 //Firstly, the input to the ALU. the first input to the ALU relies on the AUIPC signal.
 //The second input to the ALU relies on the ALUsrc and AUIPC. If the AUIPC signal is on, then we will take shifted
 //by 12 immediate, if ALUsrc, then we will take the immediate. not the shfited immediate, the immediate only.
 
 
//lets do this.
wire [31:0] ID_EX_a; // a for second input to ALU
wire [31:0] ID_EX_b; //b for second input to ALU
wire [31:0] ID_EX_firstInputToALU;
wire [31:0] ID_EX_secondInputToALU; 

assign ID_EX_a = (ID_EX_auipc) ? ID_EX_PC : ID_EX_firstInputToALU;  
assign ID_EX_b = (ID_EX_auipc) ? (ID_EX_imm) : ( (ID_EX_ALUSrc) ? ID_EX_imm : ID_EX_secondInputToALU ); //still need to be adjusted for the forwarding
//finished the inputs to the ALU. Next are the branch, jalr, and jal instructions.

wire [31:0] ID_EX_branchPC;
wire [31:0] ID_EX_jradder;
//************************************************************************
wire [31:0] MEM_WB_ALUoutput;

wire EX_MEM_RegWrite;
//************************************************************************
assign ID_EX_jradder = ID_EX_rs1data + ID_EX_imm; //The rs1data, which is stored in the rs1 + the immediate or offset associated.
assign ID_EX_branchPC = ID_EX_PC + (ID_EX_imm << 1); //the PC plus the shifted ID_EX_imm; 

//do not forget to store the immediate for later. this will be important in the mem/wb stage.


wire [31:0] ID_EX_ALUoutput;
wire [4:0]  ID_EX_ALUsel;
wire cf,zf,vf,sf;

ALUCU alucu(ID_EX_ALUop, ID_EX_Func3, ID_EX_Instruction_30, ID_EX_Instruction_25, ID_EX_ALUsel);

//forwarding
wire forwardA;
wire forwardB;
forwarding_unit forwardingUnit (MEM_WB_RegWrite,
    ID_EX_rs1addr,
    ID_EX_rs2addr,
    MEM_WB_writingPort,
    forwardA,
    forwardB);

assign ID_EX_firstInputToALU = (forwardA) ? MEM_WB_ALUoutput : ID_EX_rs1data;
assign ID_EX_secondInputToALU = (forwardB) ? MEM_WB_ALUoutput : ID_EX_rs2data;


prv32_ALU alu(ID_EX_a, ID_EX_b, ID_EX_ALUoutput, cf, zf, vf, sf, ID_EX_ALUsel);

wire ID_EX_branchOrNot;

branchDecoder branchdecode (cf,zf,vf,sf, ID_EX_Func3, ID_EX_branchOrNot); //finish these branchDecoder

//We finished the ID_EX Register
wire [31:0] EX_MEM_immShifted_12;
wire [31:0] EX_MEM_secondInputToALU;
wire EX_MEM_MemtoReg, EX_MEM_Branch, EX_MEM_jalr, EX_MEM_auipc, EX_MEM_jal, EX_MEM_lui;
wire EX_MEM_branchOrNot;
wire [31:0] EX_MEM_ALUoutput, EX_MEM_imm;
wire [31:0] EX_MEM_PC, EX_MEM_PC_4;
wire [31:0] EX_MEM_branchPC, EX_MEM_jradder;
wire EX_MEM_MemWrite;
wire EX_MEM_MemRead;
NRegister #(306) EX_MEM (~clk, rst, 1'b1, 
{ID_EX_RegWrite,ID_EX_MemtoReg,ID_EX_MemWrite,
 ID_EX_MemRead,ID_EX_Branch,ID_EX_jalr,ID_EX_auipc,ID_EX_jal,ID_EX_lui,
 ID_EX_branchOrNot, ID_EX_ALUoutput, ID_EX_imm, (ID_EX_imm << 12), 
 ID_EX_writingPort, 
 ID_EX_PC, ID_EX_PC_4, 
 ID_EX_branchPC, ID_EX_jradder, ID_EX_secondInputToALU, ID_EX_Func3, ID_EX_rs2data},
 
{EX_MEM_RegWrite,EX_MEM_MemtoReg,EX_MEM_MemWrite,
 EX_MEM_MemRead,EX_MEM_Branch,EX_MEM_jalr,EX_MEM_auipc,EX_MEM_jal,EX_MEM_lui,
 EX_MEM_branchOrNot, EX_MEM_ALUoutput, EX_MEM_imm, EX_MEM_immShifted_12, 
 EX_MEM_writingPort, EX_MEM_PC, EX_MEM_PC_4, EX_MEM_branchPC, EX_MEM_jradder, EX_MEM_secondInputToALU, 
 EX_MEM_Func3, EX_MEM_rs2data});

wire EX_MEM_andGate;
assign EX_MEM_andGate = (EX_MEM_branchOrNot & EX_MEM_Branch);//this is the andGate
wire [31:0] EX_MEM_branchPc;

always @ (~clk || rst) begin
    if (rst == 1)
    beforeIDPC <= 32'b0;
    
    end 
    
always @ (*) begin
case ({EX_MEM_andGate, EX_MEM_jal, EX_MEM_jalr})
    3'b001: beforeIDPC <= EX_MEM_jradder;
    3'b010: beforeIDPC <= EX_MEM_branchPC;
    3'b100: beforeIDPC <= EX_MEM_branchPC;
    default: beforeIDPC <= beforeIDPCPLUS4;
    endcase
    end

wire MEM_WB_RegWrite, MEM_WB_jalr, MEM_WB_lui, MEM_WB_MemtoReg;
wire [31:0] MEM_WB_ALUoutput;
wire [31:0] MEM_WB_dataout;
wire [4:0] MEM_WB_rs1addr, MEM_WB_rs2addr, MEM_WB_writingPort;
wire [31:0] MEM_WB_PC_4, MEM_WB_shiftedImm_12;
wire MEM_WB_jal;

reg [31:0] ghost;
always @(*) begin
        if (clk == 0)
         ghost <= dataout; // Update on the rising edge of the clock
    end
wire [31:0] dataout2;
assign dataout2 = ghost;
assign instruction = noor;

NRegister #(138) MEM_WB (clk, rst, 1'b1, 
{EX_MEM_RegWrite, EX_MEM_jalr,EX_MEM_lui, EX_MEM_MemtoReg, EX_MEM_ALUoutput, dataout2, 
EX_MEM_writingPort, EX_MEM_PC_4, EX_MEM_imm, EX_MEM_jal},

{MEM_WB_RegWrite, MEM_WB_jalr, MEM_WB_lui, MEM_WB_MemtoReg, MEM_WB_ALUoutput, MEM_WB_dataout,
MEM_WB_writingPort, MEM_WB_PC_4, MEM_WB_shiftedImm_12, MEM_WB_jal}
);

wire [31:0] MEM_WB_writingDataBefore;

assign MEM_WB_writingDataBefore = (MEM_WB_MemtoReg) ? MEM_WB_dataout : MEM_WB_ALUoutput;


assign MEM_WB_writingData = (MEM_WB_lui) ? MEM_WB_shiftedImm_12 : 
( (MEM_WB_jalr || MEM_WB_jal) ? MEM_WB_PC_4 : MEM_WB_writingDataBefore);

wire Flush;

hazard_detection_unit hazardunit (EX_MEM_jal, EX_MEM_jalr, EX_MEM_andGate, Flush);


assign {IF_ID_RegWrite, IF_ID_MemtoReg,IF_ID_MemWrite,IF_ID_MemRead, IF_ID_Branch, IF_ID_ALUSrc, IF_ID_ALUop, IF_ID_jalr,
    IF_ID_auipc, IF_ID_jal,IF_ID_lui} = (Flush == 1 || IF_ID_Instruction == 32'd0) ? 12'd0 : ({RegWrite,//
    MemtoReg,//
    MemWrite,//
    MemRead,//
    Branch,//
    ALUSrc,//
    ALUop,//
    jalr,
    auipc,
    jal,
    lui}) ;

assign beforeIDPCPLUS4 = (fence) ? beforeIDPCOUT : beforeIDPCOUT + 4;

endmodule
