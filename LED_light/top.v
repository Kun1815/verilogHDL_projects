module top(
    input clk,
    input [3:0]sw,
    input BTNU, //确认键
    input BTND,  //复位键

    output [15:0]led,
    output [3:0]seg_sel,
    output [6:0]seg_data

);

reg [3:0]num;
reg led_on;
reg [28:0]count;//计数，3s

always@(posedge clk or posedge BTND)begin//开关，确认->亮

    if(BTND)begin//复位
        led_on<=0;
        num<=0;
        count<=0;    
    end else if(BTNU)begin
        led_on<=1;
        num<=sw;
        count<=0;         
    end else if(led_on)begin
        if(count>=29'd300_000_000)begin
            led_on<=0;
        end else begin
            count<=count+1;
        end    
    end

end



//LED显示，LED由led_on控制
assign led=led_on?(16'b1<<num):16'b0;

//数码管显示，独立运行，与开关,led_on有关
assign seg_sel=4'b1110;
reg [6:0]seg_code;

always@(*)begin
    case(sw[3:0])
            4'h0: seg_code = 7'b1000000;
            4'h1: seg_code = 7'b1111001;
            4'h2: seg_code = 7'b0100100;
            4'h3: seg_code = 7'b0110000;
            4'h4: seg_code = 7'b0011001;
            4'h5: seg_code = 7'b0010010;
            4'h6: seg_code = 7'b0000010;
            4'h7: seg_code = 7'b1111000;
            4'h8: seg_code = 7'b0000000;
            4'h9: seg_code = 7'b0010000;
            4'hA: seg_code = 7'b0001000;
            4'hB: seg_code = 7'b0000011;
            4'hC: seg_code = 7'b1000110;
            4'hD: seg_code = 7'b0100001;
            4'hE: seg_code = 7'b0000110;
            4'hF: seg_code = 7'b0001110;
    endcase
end
//led_on=1时数码管才亮
assign seg_data=(led_on==1)?seg_code:7'b1111111;

endmodule
