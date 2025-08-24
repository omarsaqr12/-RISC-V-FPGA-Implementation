module rv32_ImmGen (
    input  wire [31:0]  IR,
    output reg  [31:0]  Imm
);
wire func3;
assign func3 = IR[14:12];
always @(*) begin
	case (IR[6:2])
		 5'b00_100  :  begin
		                if (func3 == 3'b101 || func3 == 3'b001)
		                  Imm = { {27{1'b0}}, IR[24:21], IR[20] };
		                else
		                Imm = { {21{IR[31]}}, IR[30:25], IR[24:21], IR[20] };
		                end
		 5'b01_000  :     Imm = { {21{IR[31]}}, IR[30:25], IR[11:8], IR[7] };
		 5'b01_101  :       Imm = { IR[31], IR[30:20], IR[19:12], 12'b0 };
		 5'b00_101     :     Imm = { IR[31], IR[30:20], IR[19:12], 12'b0 };
		 5'b11_011     : 	Imm = { {13{IR[31]}}, IR[19:12], IR[20], IR[30:25], IR[24:21]}; //contained the 1'b0
		 5'b11_001      : 	Imm = { {21{IR[31]}}, IR[30:25], IR[24:21], IR[20] };
		 5'b11_000    : 	Imm = { {21{IR[31]}}, IR[7], IR[30:25], IR[11:8]}; //contained the 1'b0
		 5'b00_000     :     Imm = { {21{IR[31]}}, IR[30:25], IR[24:21], IR[20] }; //Load instructions
		default           : 	Imm = { {21{IR[31]}}, IR[30:25], IR[24:21], IR[20] }; // IMM_I
	endcase 
end

endmodule