`timescale 1ns / 1ps


module tb();

    reg clk;      
    reg Reset;    
    reg Set;      
    reg d;        
    wire q;   

    async_rst u1(
        .clk(clk),
        .Reset(Reset),
        .Set(Set),
        .d(d),
        .q(q)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 每5ns翻转一次，周期10ns
    end

    //测试
    initial begin
        Reset = 1;  
        Set   = 1;  
        d     = 0;  
        

        
        #100;
        d = 1;   // 输入1,输出都是1

        
        #10;     
        d = 0;   // 输入0，输出都是0

        
        #10;
        d = 1;   // 输入1,输出都是1

        
        #10;
        Reset = 0;  // 输出变0

        
        #10;
        Reset = 1;  // 输出变1

        
        #10;
        d = 0;   // 输入是0，输出是0
 
        
        #10;
        Set = 0;  // 变1

        
        #10;
        Set = 1;  // 变0

        
        #10;
        Reset = 0;  // 输出0，reset优先
        Set   = 0;  

        
        #10;
        Reset = 1;//置1，输出1

        
        #10;
        Set = 1;

        
        // 异步和同步的区别
        
        
        // 输出0
        Reset = 0;

        
        #10;
        Reset = 1;//输出0

        
        #10;
        Set = 0;   // 异步会立即变成1

        #2;  
        #8;  
       
        

        Set = 1;

        

        #20;
        $finish;
    end

endmodule
