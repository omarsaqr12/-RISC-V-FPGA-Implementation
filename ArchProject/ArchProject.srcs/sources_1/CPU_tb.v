`timescale 100ps/1ps

module CPU_tb();

  reg clk;
  reg rst;
RISCV_Pipeline cpu(clk,rst);

initial begin
    clk <= 0;
    forever begin
        #(50) clk = ~clk;
    end
end

initial begin 
    rst <= 1;
    #99 rst <= 0;
end


endmodule
