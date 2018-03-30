module test;

initial
begin
        $dumpfile("crc_16.vcd");
        $dumpvars(0,test);
        # 2 crc_reset = ~crc_reset;
        # 1 crc_byte_next = 8'h80;
        # 0 crc_pulse = ~crc_pulse;
        # 25 crc_byte_next = 8'h01;
        # 0 crc_pulse = ~crc_pulse;
        # 25 crc_byte_next = 8'h80;
        # 0 crc_pulse = ~crc_pulse;
        # 25 crc_byte_next = 8'h80;
        # 0 crc_pulse = ~crc_pulse;
        # 25 crc_byte_next = 8'h20;
        # 0 crc_pulse = ~crc_pulse;
        # 25 crc_byte_next = 8'h41;
        # 0 crc_pulse = ~crc_pulse;
        # 25 crc_byte_next = 8'hC9;
        # 0 crc_pulse = ~crc_pulse;
        # 25 $finish;
end

reg  clk = 0;
reg  [7:0] crc_byte_next = 1'b0;
reg  crc_pulse = 1'b0;
reg  crc_reset = 1'b0;
wire crc_done;
wire [15:0] crc_out;

always #1
begin
        clk = !clk;
        $monitor("Time step %t, clk = %d, crc_byte_next = 0x%h, crc_pulse = %d, crc_reset = %d, crc_done = %d, crc_out = 0x%h",
                 $stime, clk, crc_byte_next, crc_pulse, crc_reset, crc_done, crc_out);
end

crc16_check #(.POLYNOMIAL(16'h1021)) u_crc16(
        .i_sys_clk(clk),
        .i_byte_in(crc_byte_next),
        .i_take(crc_pulse),
        .i_reset(crc_reset),
        .o_ready(crc_done),
        .o_crc16(crc_out));

endmodule
