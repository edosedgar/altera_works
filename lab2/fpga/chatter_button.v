module chatter_button
(
        input       i_sys_clk,
        input       i_key,
        output wire o_signal
);

/* Button */
reg PB_sync_0     = 1'b0;
reg PB_sync_1     = 1'b0;
reg PB_state      = 1'b0;
reg [21:0] PB_cnt = 22'd0;
wire PB_cnt_max   = &PB_cnt;

assign o_signal = PB_state;

always @(posedge i_sys_clk) PB_sync_0 <= i_key;
always @(posedge i_sys_clk) PB_sync_1 <= PB_sync_0;

always @(posedge i_sys_clk)
begin
        if (PB_sync_1 == PB_state)
                PB_cnt <= 0;
        else
        begin
                PB_cnt <= PB_cnt + 22'd1;
                if (PB_cnt_max)
                        PB_state <= ~PB_state;
        end
end

endmodule
