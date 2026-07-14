module top(
    input clk,
    input [3:0]sw,
    input BTNU,//确认键
    input BTND,//复位键
    input BTNL,//清除密码键    
    
    output reg [15:0]led,
    output reg [3:0]seg_sel,
    output reg [6:0]seg_data

);

//延时模块
reg [28:0]cnt_1s;//计数，1s
reg wait_1s;
reg [28:0]cnt_5s;
reg wait_5s;
reg [31:0]cnt_30s;
reg wait_30s;
reg [28:0]cnt_1s_zero;//计数，1s,之后置0
reg wait_1s_zero;

//密码模块
reg [4:0]password[0:3];
reg [4:0]password_input[0:3];
reg [4:0]password_input_once[0:3];
reg [4:0]password_input_twice[0:3];
reg [2:0]input_num;//输入位数
reg [3:0]sw_input;//开关输入中间值，让密码输入限制在0~9

//输出模块
reg led_on;
reg [3:0]error_num;//错误计数

//状态模块
reg [1:0]state;//00输入，01比较，10结果输出,11修改密码
reg [1:0]result;//对比结果,11对，00错

//改密码
reg [3:0]modify_num;

//按键边沿检测
reg BTNU_before,BTND_before,BTNL_before;
wire BTNU_pos,BTND_pos,BTNL_pos;
always@(posedge clk)begin
    BTNU_before<=BTNU;
    BTND_before<=BTND;
    BTNL_before<=BTNL;
end
assign BTNU_pos=BTNU && !BTNU_before;
assign BTND_pos=BTND && !BTND_before;
assign BTNL_pos=BTNL && !BTNL_before;


//开关输入中间值
always @(*) begin
    sw_input = (sw <= 4'd9) ? sw : 4'd0;
end

//主循环
always@(posedge clk)begin

    if(led_on && !wait_30s)begin//LED显示
        led[9:0]<=(16'b1<<sw_input);
    end else begin
        led[9:0]<=0;
    end
    
    if(BTND_pos  && !wait_30s)begin//复位
        state<=0;
        cnt_1s<=0;
        led_on<=0;
        error_num<=0;
        
        input_num<=0;
        wait_1s<=0;
        result<=2'b01;//不错不对
        wait_5s<=0;
        
        cnt_5s<=0;
        led[10]<=0;
        cnt_30s<=0;
        wait_30s<=0;
        
        password_input[3]<=0;
        password_input[2]<=0;
        password_input[1]<=0;
        password_input[0]<=0;
        
        password[3]<=1;
        password[2]<=2;
        password[1]<=3;
        password[0]<=4;
 
        password_input_twice[3]<=0;
        password_input_twice[2]<=0;
        password_input_twice[1]<=0;
        password_input_twice[0]<=0;
                
        password_input_once[3]<=0;
        password_input_once[2]<=0;
        password_input_once[1]<=0;
        password_input_once[0]<=0;                
                
        modify_num<=0;             
        cnt_1s_zero<=0;
        wait_1s_zero<=0;
                
    end else if(BTNL_pos&& !wait_30s)begin//清除密码
        input_num<=0;
    
        password_input[3]<=0;
        password_input[2]<=0;
        password_input[1]<=0;
        password_input[0]<=0;
        
        modify_num <= 0;
        password_input_once[0] <= 0;
        password_input_once[1] <= 0;
        password_input_once[2] <= 0;
        password_input_once[3] <= 0;
        
        password_input_twice[0] <= 0;
        password_input_twice[1] <= 0;
        password_input_twice[2] <= 0;
        password_input_twice[3] <= 0;
      
    end else begin
    
    
        if(wait_1s_zero)begin//延时1s,input_num置0
            if(cnt_1s_zero>=29'd100_000_000)begin
                wait_1s_zero<=0;
                cnt_1s_zero<=0;
                input_num<=0;
            end else begin
                cnt_1s_zero<=cnt_1s_zero+1;
            end
        end    
    
        
        if(wait_1s)begin//延时1s
            if(cnt_1s>=29'd100_000_000)begin
                wait_1s<=0;
                cnt_1s<=0;
            end else begin
                cnt_1s<=cnt_1s+1;
            end
        end
        
        if(wait_5s)begin//延时5s,input_num置0
            if(result == 2'b11 && BTNU_pos)begin
                state<=2'b11;//修改密码
                wait_5s<=0;
                cnt_5s<=0;
                led[10]<=0;//表示解锁
                input_num<=0;
                
            end else if(cnt_5s>=29'd500_000_000)begin
                wait_5s<=0;
                cnt_5s<=0;
                led[10]<=0;
                input_num<=0;
            end else begin
                cnt_5s<=cnt_5s+1;
            end
        end        
        
        if(wait_30s&&!wait_5s)begin//延时30s，期间input_num=3'b100，input_num置0,
                                    //error_num置0
            input_num<=3'b100;
        
            password_input[3]<=14;//L
            password_input[2]<=0;//0
            password_input[1]<=15;//C
            password_input[0]<=16;//k        

            if(cnt_30s>=32'd3_000_000_000)begin
                wait_30s<=0;
                cnt_30s<=0;
                error_num<=0;
                input_num<=0;
            end else begin
                cnt_30s<=cnt_30s+1;
            end
        end        
        
    
        if(state==2'b00)begin//输入密码
            led_on<=1;
            //第一位
            if(BTNU_pos && !wait_1s && input_num==3'b000&& !wait_5s&& !wait_30s)begin
                password_input[3]<=sw_input;
                wait_1s<=1;  
                input_num<=3'b001;
            end
        
            //第二位
            if(BTNU_pos && !wait_1s && input_num==3'b001&& !wait_5s&& !wait_30s)begin
                password_input[2]<=sw_input;
                wait_1s<=1;
                input_num<=3'b010;
            end       
         
            //第三位
            if(BTNU_pos && !wait_1s && input_num==3'b010&& !wait_5s&& !wait_30s)begin
                password_input[1]<=sw_input;
                wait_1s<=1;
                input_num<=3'b011;
            end    
        
            //第四位
            if(BTNU_pos && !wait_1s && input_num==3'b011&& !wait_5s&& !wait_30s)begin
                password_input[0]<=sw_input;
                wait_1s<=1;
                input_num<=3'b100;
            end
            
            if(BTNU_pos && !wait_1s && input_num==3'b100&& !wait_5s&& !wait_30s)begin        
                state<=2'b01;        
            end        
                    
        end else if(state==2'b01)begin//比较
            led_on<=0;
            
            if( 
                password_input[3] == password[3]&&
                password_input[2] == password[2]&&
                password_input[1] == password[1]&&
                password_input[0] == password[0]
            )begin
                result<=2'b11; 
            end else begin
                result<=2'b00;
            end
            state<=2'b10;
        
        end else if(state==2'b10)begin//显示结果
            if(result == 2'b11)begin//结果正确
                password_input[3]<=0;//O
                password_input[2]<=10;//P
                password_input[1]<=11;//E
                password_input[0]<=12;//n
                
                led[10]<=1;
                wait_5s<=1;
                state<=2'b00;
                error_num<=0;

                
            end else if(result == 2'b00) begin//结果错误
                error_num<=error_num+1;
                
                password_input[3]<=11;//E
                password_input[2]<=13;//r
                password_input[1]<=13;//r
                password_input[0]<=error_num+1; 
                state<=2'b00;
                if(error_num +1== 3)begin
                    password_input[3]<=14;//L
                    password_input[2]<=0;//0
                    password_input[1]<=15;//C
                    password_input[0]<=16;//k
                    
                    wait_30s<=1;//延时30s                    
                end else begin
                    wait_1s_zero<=1;
                end
           
            end
        end else if(state==2'b11)begin//修改密码
            led_on<=1;
            //第一位
            if(BTNU_pos && !wait_1s && input_num==3'b000&& !wait_5s&& !wait_30s && modify_num==0)begin
                password_input[3]<=sw_input;
                password_input_once[3]<=sw_input;
                wait_1s<=1;  
                input_num<=3'b001;
                modify_num<=1;
            end
                
            //第二位
            if(BTNU_pos && !wait_1s && input_num==3'b001&& !wait_5s&& !wait_30s&& modify_num==1)begin
                password_input[2]<=sw_input;
                password_input_once[2]<=sw_input;
                wait_1s<=1;
                input_num<=3'b010;
                modify_num<=2;
            end       
                 
            //第三位
            if(BTNU_pos && !wait_1s && input_num==3'b010&& !wait_5s&& !wait_30s&& modify_num==2)begin
                password_input[1]<=sw_input;
                password_input_once[1]<=sw_input;
                wait_1s<=1;
                input_num<=3'b011;
                modify_num<=3;
            end    
                
            //第四位
            if(BTNU_pos && !wait_1s && input_num==3'b011&& !wait_5s&& !wait_30s&& modify_num==3)begin
                password_input[0]<=sw_input;
                password_input_once[0]<=sw_input;
                input_num<=3'b100;
                wait_1s_zero<=1;
                modify_num<=4;                
            end
            
            //第二次输入
            
            //第一位
            if(BTNU_pos && !wait_1s && input_num==3'b000&& !wait_5s&& !wait_30s&& modify_num==4)begin
                password_input[3]<=sw_input;
                password_input_twice[3]<=sw_input;
                wait_1s<=1;  
                input_num<=3'b001;
                modify_num<=5;
            end
                
            //第二位
            if(BTNU_pos && !wait_1s && input_num==3'b001&& !wait_5s&& !wait_30s&& modify_num==5)begin
                password_input[2]<=sw_input;
                password_input_twice[2]<=sw_input;
                wait_1s<=1;
                input_num<=3'b010;
                modify_num<=6;
            end       
                 
            //第三位
            if(BTNU_pos && !wait_1s && input_num==3'b010&& !wait_5s&& !wait_30s&& modify_num==6)begin
                password_input[1]<=sw_input;
                password_input_twice[1]<=sw_input;
                wait_1s<=1;
                input_num<=3'b011;
                modify_num<=7;
            end    
                
            //第四位
            if(BTNU_pos && !wait_1s && input_num==3'b011&& !wait_5s&& !wait_30s&& modify_num==7)begin
                password_input[0]<=sw_input;
                password_input_twice[0]<=sw_input;
                wait_1s<=1;
                input_num<=3'b100;
                modify_num<=8;        
            end        
        
            //比较,输出比较结果
            if(input_num==3'b100&&modify_num==8)begin
                if( 
                    password_input_once[3] == password_input_twice[3]&&
                    password_input_once[2] == password_input_twice[2]&&
                    password_input_once[1] == password_input_twice[1]&&
                    password_input_once[0] == password_input_twice[0]
                )begin//两次密码一样
                
                    password[3]<=password_input_once[3];
                    password[2]<=password_input_once[2];
                    password[1]<=password_input_once[1];
                    password[0]<=password_input_once[0];
                
                    password_input[3]<=1;
                    password_input[2]<=1;
                    password_input[1]<=1;
                    password_input[0]<=1;
                
                    wait_1s_zero<=1;   wait_1s_zero< = 1;
                    state<=2'b00;   state< = 2 'b00   2》b00;
                    modify_num<=0;   modify_num<=0;
                end else begin//两次密码不一样
                    password_input[3]<=11;
                    password_input[2]<=13;
                    password_input[1]<=13;
                    password_input[0]<=0;   password_input [0] & lt; = 0;
                
                    wait_1s_zero<=1;   wait_1s_zero< = 1;
                    state<=2'b00;   state< = 2 'b00   2》b00;
                    modify_num<=0;                   modify_num<=0;
                end   结束
            end   结束
        
        
        end   结束
    end   结束
end   结束

//数码管显示,与input_num已输入位，有关
reg [16:0]cnt_1kHz;//计数用的，搞出1kHz
reg [1:0]scan_sel;//用来循环选定数码管位数,1ms变一次

always@(posedge clk)begin   always   总是@ (posedge clk)开始
    if(cnt_1kHz>=17'd99_999)begin如果(cnt_1kHz> = 17 'd99_999)开始
        scan_sel<=scan_sel+1;   scan_sel< = scan_sel 1;
        cnt_1kHz<=0;
    end else begin   结束else开始
        cnt_1kHz<=cnt_1kHz+1;   cnt_1kHz< = cnt_1kHz 1;
    end   结束
end   结束

always@(*)begin   always   总是@(*)开始

    case(scan_sel)//scan_sel -> seg_sel
        2'd0:seg_sel=4'b1110;
        2'd1:seg_sel=4'b1101;
        2'd2:seg_sel=4'b1011;
        2'd3:seg_sel=4'b0111;
    endcase

    if(input_num > 0 && scan_sel >= (4 - input_num))beginIf (input_num > 0 && scan_sel >= （4 - input_num）
        case(password_input[scan_sel])例(password_input [scan_sel])
            5'd0: seg_data = 7'b1000000;5'd0: seg_data = 7'b1000000；
            5'd1: seg_data = 7'b1001111;5'd: seg_data = 7'b1001111；
            5'd2: seg_data = 7'b0100100;5' 2: seg_data = 7'b0100100；
            5'd3: seg_data = 7'b0110000;5'd3: seg_data = 7'b0110000；
            5'd4: seg_data = 7'b0011001;5'd4: seg_data = 7'b0011001；
            5'd5: seg_data = 7'b0010010;5'd5: seg_data = 7'b0010010；
            5'd6: seg_data = 7'b0000010;5'd6: seg_data = 7'b0000010；
            5'd7: seg_data = 7'b1111000;5'd7: seg_data = 7'b1111000；
            5'd8: seg_data = 7'b0000000;5'd8: seg_data = 7'b0000000；
            5'd9: seg_data = 7'b0010000;5'd9: seg_data = 7'b0010000；
            5'd10: seg_data = 7'b0001100;//P5'd10: seg_data = 7'b0001100；/ / P
            5'd11: seg_data = 7'b0000110;//E5'd11: seg_data = 7'b0000110；/ / E
            5'd12: seg_data = 7'b0101011;//n5'd12: seg_data = 7'b0101011；/ / n
            5'd13: seg_data = 7'b1001110;//r
            5'd14: seg_data = 7'b1000111;//L
            5'd15: seg_data = 7'b1000110;//C
            5'd16: seg_data = 7'b0000111;//k    
            default:seg_data=7'b1111111;//全灭    
        endcase    
    end else begin   结束else开始
        seg_data=7'b1111111;
    end   结束
end   结束



                                                             endmodule
