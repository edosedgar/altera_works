module VCJmRE(ce, TC, sys_clk, CEO, R, Q);

input ce;
output wire TC;
input sys_clk;
output wire CEO;
input R;
output reg [3:0] Q = 0;

assign TC = (Q == 15);
assign CEO = ce & TC;

always @(posedge sys_clk)
begin
        Q <= R ? 0 : ce ? Q << 1 | !Q[3] : Q;
end

endmodule
