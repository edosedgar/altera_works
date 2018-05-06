/*
 * The SPI module hardcoded to SPI mode 0:
 *      CPOL = 0;
 *      CPHA = 0;
 */
module spi_transceiver
#(
        parameter SPI_SPEED_HZ = 8_000_000
) (
        input            i_sys_clk,
        input [7:0]      i_byte,
        input            i_activate,
        input            i_spi_miso,
        output reg       o_byte_done,
        output reg [7:0] o_byte,
        output reg       o_spi_sck = 1'b0,
        output reg       o_spi_mosi = 1'b0
);

localparam SPI_EDGE_CYCLES = 50_000_000/SPI_SPEED_HZ;

localparam spi_IDLE             = 4'b0000;
localparam spi_PRERAISE_SCK     = 4'b0001;
localparam spi_RAISE_SCK        = 4'b0010;
localparam spi_POSTRAISE_SCK    = 4'b0011;
localparam spi_NOTIFY           = 4'b0100;

reg [4:0] transmitter_state = spi_IDLE;
reg [15:0] spi_cycles = 16'b0;
reg [2:0]  spi_bit    = 3'd7;
reg [7:0]  spi_data   = 8'b0;
reg activate_idle     = 1'b0;
reg [7:0] spi_out_reg = 8'b0;
reg miso_pin0         = 1'b0;
reg spi_miso          = 1'b0;

//It addresses problems caused by metastability
always @(posedge i_sys_clk)
begin
        miso_pin0 <= i_spi_miso;
        spi_miso <= miso_pin0;
end

always @(posedge i_sys_clk)
begin
        $display("Current state %b %d", transmitter_state, o_spi_mosi);
        case (transmitter_state)
        spi_IDLE:
        begin
                spi_cycles <= 16'b0;
                spi_bit <= 3'd7;
                o_byte_done <= 1'b0;

                if (i_activate != activate_idle)
                begin
                        spi_data <= i_byte;
                        transmitter_state <= spi_PRERAISE_SCK;
                        o_spi_sck <= 1'b0;
                end
        end
        spi_PRERAISE_SCK:
        begin
                if (spi_cycles < SPI_EDGE_CYCLES / 2)
                begin
                        o_spi_mosi <= spi_data[spi_bit];
                        o_spi_sck <= 1'b0;
                        spi_cycles <= spi_cycles + 16'b1;
                end
                else
                        transmitter_state <= spi_RAISE_SCK;
        end
        spi_RAISE_SCK:
        begin
                if (spi_cycles == (SPI_EDGE_CYCLES / 2))
                begin
                        o_spi_sck <= 1'b1;
                        spi_out_reg[spi_bit] <= spi_miso;
                        spi_cycles <= spi_cycles + 16'b1;
                end
                else
                        transmitter_state <= spi_POSTRAISE_SCK;
        end
        spi_POSTRAISE_SCK:
        begin
                if (spi_cycles == SPI_EDGE_CYCLES - 1)
                begin
                        spi_cycles <= 16'b0;
                        if (spi_bit == 3'd0)
                                transmitter_state <= spi_NOTIFY;
                        else
                        begin
                                spi_bit <= spi_bit - 3'b1;
                                transmitter_state <= spi_PRERAISE_SCK;
                        end
                        o_spi_sck <= 1'b0;
                end
                else
                        spi_cycles <= spi_cycles + 16'b1;
        end
        spi_NOTIFY:
        begin
                activate_idle <= ~activate_idle;
                o_byte_done <= 1'b1;
                transmitter_state <= spi_IDLE;
                o_byte <= spi_out_reg;
        end
        endcase
end

endmodule
