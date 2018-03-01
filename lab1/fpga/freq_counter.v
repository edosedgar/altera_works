module freq_counter(sys_clk, scathod, ssegment, led, key);

input sys_clk;
input key;
output wire [6:0] ssegment;
output wire [3:0] scathod;
output reg [2:0] led = 3'b111;

reg [63:0] count = 0;
wire [15:0] digit;
reg [15:0] reg_dig = 0;
assign digit = reg_dig;
wire signal;
/* Button */
reg PB_sync_0 = 1'b0;
reg PB_sync_1 = 1'b0;
reg PB_state = 1'b0;
reg [21:0] PB_cnt;
wire PB_cnt_max = &PB_cnt;
wire PB_idle = (PB_state == PB_sync_1);
/* Freq. counter */
reg count_en = 1'b0;
/* converter */
wire [3:0] hunds;
wire [3:0] tens;
wire [3:0] ones;

always @(posedge sys_clk)
begin
        PB_sync_0 <= ~key;
        PB_sync_1 <= PB_sync_0;
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
        count <= (count_en) ? count + 64'd1 : 64'd0;
end

always @(posedge signal)
begin
        if (count)
        begin
                reg_dig[3:0] <= ones;
                reg_dig[7:4] <= tens;
                reg_dig[11:8] <= hunds;
        end
        count_en <= count_en + 1'b1;
end

countpro generator(sys_clk, PB_state, signal);

seven_seg display(sys_clk, scathod, ssegment, digit);

bcd conv(count[8:0], hunds, tens, ones);

endmodule
