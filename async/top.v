`timescale 1ns / 1ps


module async_rst(
input clk,
input Reset,
input Set,
input d,
output reg q
    );
    always @(posedge clk or negedge Reset or negedge Set)
    begin
    if(!Reset)q<=1'b0;
    else if(!Set)q<=1'b1;
    else q<=d;
    
    
    end
    
endmodule
