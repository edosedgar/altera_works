module VCBDmSE(ce, Q, sys_clk, TC, s, CEO);

input ce;
output reg [3:0] Q = 4'd0;
input sys_clk;
output wire TC;
input s;
output wire CEO;

assign TC = (Q == 0);
assign CEO = ce & TC;

always @(posedge sys_clk)
begin
        Q <= s ? 4'd15 : ce ? Q - 4'd1 : Q;
end

endmodule
