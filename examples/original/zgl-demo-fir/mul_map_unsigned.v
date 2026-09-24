module $__FABULOUS_MUL (A, B, Y);
parameter A_WIDTH=8, B_WIDTH=8, Y_WIDTH=16;
parameter A_SIGNED=0, B_SIGNED=0;
input [A_WIDTH-1:0] A;
input [B_WIDTH-1:0] B;
output [Y_WIDTH-1:0] Y;
wire [7:0] a_pad=A, b_pad=B;
wire _TECHMAP_FAIL_ = A_WIDTH>8 || B_WIDTH>8 || A_SIGNED || B_SIGNED || Y_WIDTH>16;
wire [19:0] q;
wire dsp_clk;
Global_Clock dsp_clock (.CLK(dsp_clk));
MULADD #(.A_reg(0), .B_reg(0), .C_reg(0), .ACC(0), .signExtension(0), .ACCout(0)) _TECHMAP_REPLACE_ (
.A0(a_pad[0]),
.A1(a_pad[1]),
.A2(a_pad[2]),
.A3(a_pad[3]),
.A4(a_pad[4]),
.A5(a_pad[5]),
.A6(a_pad[6]),
.A7(a_pad[7]),
.B0(b_pad[0]),
.B1(b_pad[1]),
.B2(b_pad[2]),
.B3(b_pad[3]),
.B4(b_pad[4]),
.B5(b_pad[5]),
.B6(b_pad[6]),
.B7(b_pad[7]),
.C0(1'b0),
.C1(1'b0),
.C2(1'b0),
.C3(1'b0),
.C4(1'b0),
.C5(1'b0),
.C6(1'b0),
.C7(1'b0),
.C8(1'b0),
.C9(1'b0),
.C10(1'b0),
.C11(1'b0),
.C12(1'b0),
.C13(1'b0),
.C14(1'b0),
.C15(1'b0),
.C16(1'b0),
.C17(1'b0),
.C18(1'b0),
.C19(1'b0),
.Q0(q[0]),
.Q1(q[1]),
.Q2(q[2]),
.Q3(q[3]),
.Q4(q[4]),
.Q5(q[5]),
.Q6(q[6]),
.Q7(q[7]),
.Q8(q[8]),
.Q9(q[9]),
.Q10(q[10]),
.Q11(q[11]),
.Q12(q[12]),
.Q13(q[13]),
.Q14(q[14]),
.Q15(q[15]),
.Q16(q[16]),
.Q17(q[17]),
.Q18(q[18]),
.Q19(q[19]),
.clr(1'b0),
.CLK(dsp_clk));
assign Y=q;
endmodule
