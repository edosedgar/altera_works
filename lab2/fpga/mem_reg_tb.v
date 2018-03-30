module test;

initial
begin
        $dumpfile("crc_16.vcd");
        $dumpvars(0, test);
        # 2 dev = 1;
        # 0 mode = 1;
        # 0 address = 16'h4901;
        # 0 byte_input = 8'h34;
        # 1 pulse = !pulse;

        # 7 dev = 1;
        # 0 mode = 1;
        # 0 address = 16'h4950;
        # 0 byte_input = 8'h11;
        # 1 pulse = !pulse;

        # 7 dev = 0;
        # 0 mode = 0;
        # 0 address = 16'h4903;
        # 1 pulse = !pulse;

        # 25 $finish;
end

reg clk = 0;
reg pulse = 0;
reg dev = 0;
reg mode = 0;
reg [15:0] address = 16'h0000;
reg [7:0] byte_input = 8'h00;
wire [7:0] byte_out;
reg [3:0] key_input = 4'b1010;
wire [15:0] digit;
wire [3:0] led;
wire ready;

always #1
begin
        clk = !clk;
        $monitor ("Time step %t, clk = %d, dev = %d, mode = %d, addr = %h, b_in = %h, p = %d, b_out = %h, digit = %h, o_r = %d",
                  $time, clk, dev, mode, address, byte_input, pulse, byte_out, digit, ready);
end

mem_reg #(.BASE_ADDRESS(16'h4900)) dev_mem(
        .i_sys_clk(clk),
        .i_apulse(pulse),
        .i_regmem(dev),
        .i_rw(mode),
        .i_address(address),
        .i_byte(byte_input),
        .i_key(key_input),
        .o_byte(byte_out),
        .o_digit(digit),
        .o_led(led),
        .o_ready(ready));

endmodule

