module VCBmCLED(ce, Q, up, CEO, di, TC, L, sys_clk, clr);

input ce;
output reg [3:0] Q = 0;
input up;
output wire CEO;
input [3:0] di;
output wire TC;
input L;
input sys_clk;
input clr;

assign TC = up ? (Q == 15) : (Q == 0);
assign CEO = ce & TC;

always @(posedge clr or posedge sys_clk)
begin
        if (clr)
                Q <= 0;
        else
                Q <= L ? di : (up & ce) ? Q + 4'd1 :
                              (!up & ce) ? Q - 4'd1 : Q;
end

endmodule
