`timescale 1ns / 1ps


module hazard_detection_unit (
    input jal,
    input jalr, 
    input branch,
    output Flush
);

assign Flush = (jal || jalr || branch) ? 1 : 0;
 
endmodule

