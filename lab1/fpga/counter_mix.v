module counter_mix(sys_clk, scathod, ssegment, led);

input sys_clk;
output wire [6:0] ssegment;
output wire [3:0] scathod;
output reg [2:0] led = 3'b111;

reg [19:0] count = 0;
reg div_clk = 0;
wire [15:0] digit;
wire [3:0] CEO;
wire [3:0] TC;
/* Counter 1 */
reg ce = 1'b1;
reg s = 1'b0;
/* Counter 2 */
reg L = 1'b0;
reg up = 1'b1;
reg clr = 1'b0;
/* Counter 3 */
reg R = 1'b0;
/* Counter 4 */

always @(posedge sys_clk)
begin
        ce <= 1'b1;
        up <= 1'b1;
        count <= count + 1'b1;
        if (count == 20'b1111_1111_1111_1111_1111)
        begin
                div_clk <= div_clk ^ 1'b1;
        end
end

VCBDmSE shift(ce, digit[3:0], div_clk,
              TC[0:0], s, CEO[0:0]);

VCBmCLED shift2(CEO[0:0], digit[7:4], up,
                CEO[1:1], , TC[1:1], L,
                div_clk, clr);

VCD4RE shift3(CEO[1:1], digit[11:8], div_clk,
              TC[2:2], R, CEO[2:2]);

VCJmRE shift4(CEO[2:2], TC[3:3], div_clk,
              CEO[3:3], R, digit[15:12]);

seven_seg display(sys_clk, scathod, ssegment, digit);

endmodule
