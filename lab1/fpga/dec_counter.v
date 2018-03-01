module dec_counter(sys_clk, scathod, ssegment, led, key);

input sys_clk;
input key;
output wire [6:0] ssegment;
output wire [3:0] scathod;
output reg [2:0] led = 3'b111;

reg [22:0] count = 0;
reg div_clk = 0;
wire [15:0] digit;
wire CEO;
wire TC;
/* Counter 1 */
reg L = 1'b0;
reg clr = 1'b0;
reg ce = 1'b1;

always @(posedge sys_clk)
begin
        ce <= 1'b1;
        count <= count + 1'b1;
        led[0] <= CEO;
        led[1] <= TC;
        if (count == 22'b11_1111_1111_1111_1111_1111)
        begin
                div_clk <= div_clk ^ 1'b1;
        end
end

VCBmCLED_dec shift(ce, digit[3:0], key, CEO, , TC, L,
                   div_clk, clr);

seven_seg display(sys_clk, scathod, ssegment, digit);

endmodule
