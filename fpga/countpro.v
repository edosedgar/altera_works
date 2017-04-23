module countpro(sys_clk,led);

input sys_clk;
output [2:0] led;
reg [22:0] count;
reg [2:0] led;

always @(posedge sys_clk)
	begin
		count <= count + 1;
		if (count == 22'b11_1111_1111_1111_1111_1110)
			begin
			led <= led + 2;
			end
		else
			led <= led;
	end

endmodule
