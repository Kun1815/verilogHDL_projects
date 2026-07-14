//同步
module sync_rst(
input d,
input clk,
input reset,
input set,
output reg q
    );
  always@(posedge clk)begin
  if(!reset)q<=1'b0;
  else if(!set)q<=1'b1;
  else q<=d;
  
  end
    
endmodule
