module chatter_button(sys_clk, scathod, ssegment, led, key);

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
reg ce = 1'b1;
reg s = 1'b0;

/* Button */
reg PB_sync_0 = 1'b0;
reg PB_sync_1 = 1'b0;
reg PB_state = 1'b0;
reg [21:0] PB_cnt;
wire PB_cnt_max = &PB_cnt;
wire PB_idle = (PB_state == PB_sync_1);

always @(posedge sys_clk) PB_sync_0 <= ~key;
always @(posedge sys_clk) PB_sync_1 <= PB_sync_0;

always @(posedge sys_clk)
begin
        if (PB_idle)
                PB_cnt <= 0;
        else
        begin
                PB_cnt <= PB_cnt + 22'd1;
                if (PB_cnt_max)
                        PB_state <= ~PB_state;
        end
end

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

VCBDmSE shift(ce, digit[3:0], PB_state, TC, s, CEO);

seven_seg display(sys_clk, scathod, ssegment, digit);

endmodule
