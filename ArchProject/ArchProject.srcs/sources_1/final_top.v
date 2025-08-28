module final(input clk, input rst);
   reg [31:0] pcIn;
   wire [31:0] pcout;
   wire [31:0] pcPlus4;
   NRegister #(32) PC (clk, rst, 1'b1, pcIn, pcout);
   assign pcPlus4 = pcout + 4;
   wire [31:0] inst;
   InstMem instructionMemory (pcout[7:2], inst); //instructionsOutput is the output coming from the instructions
   //finished the instructions memory.
   wire [31:0] readingPortOne, readingPortTwo;
   wire RegWrite; // write to the register something if needed.
   wire [31:0] writeToRegisterFile; // the output that will come as a result of MUX 
   //between AUIPC, Jalr, and ALU output. This will be used later in the 4x1 MUX case statement.
   registerFile regfile ( clk,rst, readingPortOne, readingPortTwo, writeToRegisterFile, inst[19:15], inst[24:20], 
    inst[11:7], RegWrite);
    wire MemtoReg, MemWrite, MemRead, Branch, ALUsrc, jalr, auipc, jal, lui;
    wire [1:0] ALUop;
   ControlUnit unit(inst[6:0], RegWrite,//
    MemtoReg,//
    MemWrite,//
    MemRead,//
    Branch,//
    ALUsrc,//
    ALUop,//
    jalr,
    auipc,
    jal,
    lui);
    // this will give all the outputs we need for the controls.    
    always @ * begin
    if (rst == 1)
    pcIn <= 1'b0;
    end
    //now we will start a case statement for AUIPC. This selects between rs1, and PC register.
    reg [31:0] inputA; //first input to ALU
    reg [31:0] inputB; //second input to ALU
    always @ * begin
    if (auipc)
    inputA = pcout;
    else 
    inputA = readingPortOne;
    end
    
    //second input to ALU chooses between the immediate shifted by 12 (which is in the AUIPC immediate case)
    // or the immediate coming from the immediate generator
    // or the readingPortTwo.
    wire [31:0] immOut; //note that the immOut is the immediate coming from the immGen.
    wire [31:0] immOutShifted12;
    rv32_ImmGen imm(inst, immOut);
    assign immOutShifted12 = (immOut << 12);
    always @ * begin
    case ({auipc,ALUsrc})
    2'b00: inputB = readingPortTwo;
    2'b01: inputB = immOut;
    2'b10: inputB = immOutShifted12;
    endcase
    end
    // the case above is just implementing a 3x1 MUX that selects between readingPortTwo, immOut, and immOutShifted12
    wire [31:0] outputFromALU;
    wire zeroFlag, carryFlag, overflowFlag, signFlag;
    wire [3:0] ALUsel;
    ALUCU alucu (ALUop, inst[14:12], inst[30], ALUsel); // ALU control unit responsible for selecting the operation.
    prv32_ALU ALU(inputA, inputB, outputFromALU, carryFlag, zeroFlag, overflowFlag, signFlag, ALUsel);
    wire branchOrNot;
    branchDecoder decoder(carryFlag,zeroFlag,overflowFlag,signFlag, inst[14:12], branchOrNot); // this is for decoding whether
    // there's a branch instruction or not. could be BLTU or BLT, and so on..
    wire ANDGate = branchOrNot & Branch; // this is for the branch instructions andGate as in the figure.
    /* break */
    wire [31:0] pcPlusBranch;
    assign pcPlusBranch = (immOut << 1) + pcout;
    wire [31:0] outputFromDataMem;
    DataMem dataMemory (clk,MemRead,MemWrite,inst[14:12], outputFromALU[11:0], readingPortTwo, outputFromDataMem);
    
    wire [31:0] output_From_MUX_of_ALU_dataMem;
    
    assign output_From_MUX_of_ALU_dataMem = (MemtoReg) ? outputFromALU : outputFromDataMem;
    
    
    assign writeToRegisterFile = (lui) ? (immOutShifted12) : ( (jalr || jal) ? (pcPlus4) : output_From_MUX_of_ALU_dataMem);
    //if lui is 1, then take the shifted immediate by 12 and write it to the destination register.
    // if lui is 0, then check if jalr is 1. If jalr = 1 , then store pcPlus4, otherwise take the output from the ALU
    //this output from the ALU/DataMem can contain load and stores, and AUIPC's as well, and any other adds/sub
    wire [31:0] pcPlusJalr;
    assign pcPlusJalr = immOut + readingPortOne;
    
    always @ (clk || rst) begin
    if (rst == 1)
    pcIn <= 1'b0;
    else begin
    case ({ANDGate,jal,jalr})
    3'b001: pcIn <= pcPlusJalr;
    3'b010: pcIn <= pcPlusBranch;
    3'b100: pcIn <= pcPlusBranch;
    default: pcIn <= pcPlus4;
    endcase
    end
    end 
    
endmodule