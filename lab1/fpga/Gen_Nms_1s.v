module countpro(sys_clk, key, out_signal);

input sys_clk;
input key;
output reg out_signal = 0;
reg [63:0] count;

always @(posedge sys_clk)
begin
        out_signal = (count == 0) ? 1'b1 : 1'b0;
        if (count == 0)
                out_signal = 1;
        count <= count + 1;
        if (key == 0)
                if (count == 64'd50_000_000_000)
                        count = 0;
        if (key == 1)
                if (count == 64'd900_000)
                        count = 0;
end

endmodule
