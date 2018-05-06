module test;

initial
begin
        $dumpfile("spi.vcd");
        $dumpvars(0,test);
        # 2 spi_switch = ~spi_switch;
        # 0 spi_tx_byte = 8'hF0;
        # 120 $finish;
end

reg  clk = 0;
reg  [7:0] spi_tx_byte = 8'hF0;
reg  spi_switch = 1'b0;
reg i_spi_miso = 1'b0;
wire spi_tx_done;
wire [7:0] spi_rx_byte;
wire o_spi_sck;
wire o_spi_mosi;

always #1
begin
        clk = !clk;
        $monitor("Time step %t, clk = %d, spi_byte_next = 0x%h, spi_switch = %d, spi_sck = %d, spi_mosi = %d, spi_done = %d",
                 $stime, clk, spi_tx_byte, spi_switch, o_spi_sck, o_spi_mosi, spi_tx_done);
end

spi_transceiver #(.SPI_SPEED_HZ(12_000_000)) spi_rxtx(
        .i_sys_clk(clk),
        .i_byte(spi_tx_byte),
        .i_activate(spi_switch),
        .i_spi_miso(i_spi_miso),
        .o_byte_done(spi_tx_done),
        .o_byte(spi_rx_byte),
        .o_spi_sck(o_spi_sck),
        .o_spi_mosi(o_spi_mosi));

endmodule
