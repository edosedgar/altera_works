`define m 4
module VSBDmSE(input ce,        output reg[`m-1:0] Q = (1 << `m) - 1,
               input sys_clk,   output wire TC,
               input s,         output wire CEO);

assign TC = (Q == 0);
assign CEO = ce & TC;

always @(posedge sys_clk)
begin
        Q <= s? ((1 << `m) - 1) : ce? Q - 1 : Q;
end
endmodule
