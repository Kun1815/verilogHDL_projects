`timescale 1ns / 1ps

module bit1 (
    input a,
    input b,
    input cin,
    output cout,
    output s
);
assign {cout,s}=a+b+cin;
endmodule



module serial_adder_16bits(
    input [15:0]a,
    input [15:0]b,
    output [15:0]s,
    output Cout
);
wire [14:0]cout;

bit1 u0(.a(a[0]),.b(b[0]),.cin(1'b0),.cout(cout[0]),.s(s[0]));
bit1 u1(.a(a[1]),.b(b[1]),.cin(cout[0]),.cout(cout[1]),.s(s[1]));
bit1 u2(.a(a[2]),.b(b[2]),.cin(cout[1]),.cout(cout[2]),.s(s[2]));
bit1 u3(.a(a[3]),.b(b[3]),.cin(cout[2]),.cout(cout[3]),.s(s[3]));

bit1 u4(.a(a[4]),.b(b[4]),.cin(cout[3]),.cout(cout[4]),.s(s[4]));
bit1 u5(.a(a[5]),.b(b[5]),.cin(cout[4]),.cout(cout[5]),.s(s[5]));
bit1 u6(.a(a[6]),.b(b[6]),.cin(cout[5]),.cout(cout[6]),.s(s[6]));
bit1 u7(.a(a[7]),.b(b[7]),.cin(cout[6]),.cout(cout[7]),.s(s[7]));

bit1 u8(.a(a[8]),.b(b[8]),.cin(cout[7]),.cout(cout[8]),.s(s[8]));
bit1 u9(.a(a[9]),.b(b[9]),.cin(cout[8]),.cout(cout[9]),.s(s[9]));
bit1 u10(.a(a[10]),.b(b[10]),.cin(cout[9]),.cout(cout[10]),.s(s[10]));
bit1 u11(.a(a[11]),.b(b[11]),.cin(cout[10]),.cout(cout[11]),.s(s[11]));

bit1 u12(.a(a[12]),.b(b[12]),.cin(cout[11]),.cout(cout[12]),.s(s[12]));
bit1 u13(.a(a[13]),.b(b[13]),.cin(cout[12]),.cout(cout[13]),.s(s[13]));
bit1 u14(.a(a[14]),.b(b[14]),.cin(cout[13]),.cout(cout[14]),.s(s[14]));
bit1 u15(.a(a[15]),.b(b[15]),.cin(cout[14]),.cout(Cout),.s(s[15]));

endmodule

