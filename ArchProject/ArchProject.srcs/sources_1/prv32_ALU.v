

module prv32_ALU(
	input [31:0] a, b,
	output  reg signed [31:0] r,
	output  wire        cf, zf, vf, sf,
	input   wire [4:0]  alufn
);

    wire [31:0] add, op_b;

    assign op_b = (~b);
    
    assign {cf, add} = alufn[0] ? (a + op_b + 1'b1) : (a + b);
    
    assign zf = (add == 0);
    assign sf = add[31];
    assign vf = (a[31] ^ (op_b[31]) ^ add[31] ^ cf);
    
    wire [31:0] sh;
    shifter shifter0(.a(a), .shamt(b[4:0]), .type(alufn[1:0]),  .r(sh));
    // support for multiplication, division, and remainder.
    wire signed [63:0] MUL;
    wire unsigned [63:0] MULHSU;
    wire unsigned [63:0] MULHU;
    wire signed [31:0] DIV;
    wire signed [31:0] DIVU;
    wire signed [31:0] REM;
    wire signed [31:0] REMU;
    
    //Multiplication part.
    assign MUL = $signed(a) * $signed(b);
    
    assign MULHSU = $unsigned(a) * $signed(b);
    
    assign MULHU = $unsigned(a)  * $unsigned(b); 
    // division part.
    assign DIV = (b == 0) ? {32{1'b1}} : ( $signed(a) / $signed(b) );
    
    
    
    assign DIVU = (b==0) ? {32{1'b1}} : ( a / b );
    
    //Remainder part.
    assign REM = $signed(a) % b;
    assign REMU = a % b;
    
    
    reg [31:0] divB;
    reg [31:0] divA;
    reg [31:0] rdiv;
    reg [31:0] remainder;
    always @ * begin
        case (alufn)
            // arithmetic
            5'b000_00 : r = add;
            5'b000_01 : r = add;
            5'b000_11 : r = b;
            // logic
            5'b001_00:  r = a | b;
            5'b001_01:  r = a & b;
            5'b001_11:  r = a ^ b;
            // shift
            5'b010_00:  r=sh;
            5'b010_01:  r=sh;
            5'b010_10:  r=sh;
            // slt & sltu
            5'b011_01:  r = {31'b0,(sf != vf)}; 
            5'b011_11:  r = {31'b0, (~cf)};      
            // Multiplication   
            5'b100_00:  r =  MUL [31:0] ;
            5'b100_01:  r = MUL[63:32];
            5'b100_10:  r = MULHSU [63:32] ;
            5'b100_11:  r =  MULHU [63:32]  ;
            //Division
            5'b101_00:  begin
       
            if (b[31] == 1'b1)
            divB <= ~(b) + 1;
            else
            divB <= b;
            if (a[31] == 1'b1)
            divA <= ~(a) + 1;
            else
            divA <= a;
            
            rdiv <= $unsigned(divA) / $unsigned(divB);
            
            if( (a[31] ^ b[31]) == 1'b1 )
            r <= (~rdiv) + 1;
            else 
            r <= rdiv;
            end
            5'b101_01: begin
            divB <= {1'b0, b[30:0]};
            divA <= {1'b0, a[30:0]};
            rdiv <= divA/divB;
            r = { 1'b0 , rdiv[30:0] };
            end
            //REM
            5'b101_10:  begin 
             if (b[31] == 1'b1)
            divB <= ~(b) + 1;
            else
            divB <= b;
            if (a[31] == 1'b1)
            divA <= ~(a) + 1;
            else
            divA <= a;
            
            remainder <= $unsigned(divA) % $unsigned(divB);
            
            if( (a[31] ^ b[31]) == 1'b1 )
            r <= (~remainder) + 1;
            else 
            r <= remainder;
            end
            5'b101_11:  begin 
            divA <= {1'b0, a[30:0] };
            divB <= {1'b0, b[30:0] };
            remainder <= divA % divB;
            r = { 1'b0, remainder[30:0] };
            end
            //Done.  
            default: r = 32'bx;	
        endcase
    end
endmodule