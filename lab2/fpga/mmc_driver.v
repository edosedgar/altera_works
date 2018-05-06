module mmc_driver (
        input            i_sys_clk,
        input [15:0]     i_address,
        input [7:0]      i_in,
        input            i_rw,
        input            i_activate,
        input            i_spi_miso,
        output reg [7:0] o_out,
        output wire      o_spi_mosi,
        output wire      o_spi_sck,
        output reg       o_spi_ss,
        output reg       o_done
);

localparam mmc_1MS       = 4'd0;
localparam mmc_ENTER_SPI = 4'd1;
localparam mmc_CMD0      = 4'd2;
localparam mmc_IDLE      = 4'd3;
localparam mmc_CMD17     = 4'd4;
localparam mmc_READ      = 4'd5;
localparam mmc_SPI_WAIT  = 4'd6;
localparam mmc_TX_DELAY  = 4'd7;
localparam mmc_CMD1      = 4'd8;
localparam mmc_CMD58     = 4'd9;
localparam mmc_CMD24     = 4'd10;
localparam mmc_NOTIFY    = 4'd11;

/* SPI necessities */
reg [4:0] mmc_state  = mmc_1MS;
reg [4:0] mmc_tx_ret = mmc_1MS;

reg [7:0]  spi_tx_byte = 8'd0;
reg        spi_switch  = 1'b0;
wire       spi_tx_done;
wire [7:0] spi_rx_byte;

reg [8:0]  counter       = 9'd0;
reg [7:0]  pulse_counter = 8'd0;
reg [5:0]  tx_wait       = 6'd0;

reg [7:0]  ocr_reg[3:0];
reg [7:0]  status_reg    = 8'd0;
reg [7:0]  resp_counter  = 8'd0;

reg [9:0]  byte_block    = 10'd0;

reg        old_activate  = 1'b0;
reg [15:0] mmc_address   = 16'd0;
reg [7:0]  mmc_byte      = 8'd0;

reg [7:0]  cmd1_retry    = 8'd0;

/* Split io_data into two entities */

always @(posedge i_sys_clk)
begin
        case (mmc_state)
        mmc_1MS:
        begin
                counter <= counter + 9'd1;
                if (counter > 9'd100)
                begin
                        mmc_state <= mmc_ENTER_SPI;
                        counter <= 9'd0;
                        o_spi_ss <= 1'b1;
                end
        end
        mmc_ENTER_SPI:
        begin
                if (counter != 9'd10)
                begin
                        mmc_state <= mmc_SPI_WAIT;
                        mmc_tx_ret <= mmc_ENTER_SPI;

                        spi_tx_byte <= 8'hFF;
                        spi_switch <= ~spi_switch;

                        counter <= counter + 9'd1;
                end
                else
                begin
                        mmc_state <= mmc_CMD0;
                        counter <= 9'd0;
                        o_spi_ss <= 1'b0;
                end
        end
        mmc_CMD0:
        begin
                /*
                 * Software reset
                 * The data to be sent: 0x40:0x00-0x00-0x00-0x00:0x95
                 */
                case (counter)
                (9'd0):
                begin
                        mmc_state <= mmc_SPI_WAIT;
                        mmc_tx_ret <= mmc_CMD0;

                        spi_tx_byte <= 8'h40;
                        spi_switch <= ~spi_switch;
                        counter <= counter + 9'd1;
                end
                (9'd1):
                begin
                        mmc_state <= mmc_SPI_WAIT;
                        mmc_tx_ret <= mmc_CMD0;

                        spi_tx_byte <= 8'h00;
                        spi_switch <= ~spi_switch;
                        counter <= counter + 9'd1;
                end
                (9'd2):
                begin
                        mmc_state <= mmc_SPI_WAIT;
                        mmc_tx_ret <= mmc_CMD0;

                        spi_tx_byte <= 8'h00;
                        spi_switch <= ~spi_switch;
                        counter <= counter + 9'd1;
                end
                (9'd3):
                begin
                        mmc_state <= mmc_SPI_WAIT;
                        mmc_tx_ret <= mmc_CMD0;

                        spi_tx_byte <= 8'h00;
                        spi_switch <= ~spi_switch;
                        counter <= counter + 9'd1;
                end
                (9'd4):
                begin
                        mmc_state <= mmc_SPI_WAIT;
                        mmc_tx_ret <= mmc_CMD0;

                        spi_tx_byte <= 8'h00;
                        spi_switch <= ~spi_switch;
                        counter <= counter + 9'd1;
                end
                (9'd5):
                begin
                        mmc_state <= mmc_SPI_WAIT;
                        mmc_tx_ret <= mmc_CMD0;

                        spi_tx_byte <= 8'h95;
                        spi_switch <= ~spi_switch;
                        counter <= counter + 9'd1;
                end
                (9'd6):
                begin
                        if (spi_rx_byte == 8'h1)
                        begin
                                pulse_counter <= 8'h00;
                                mmc_state <= mmc_TX_DELAY;
                                mmc_tx_ret <= mmc_CMD1;
                                o_spi_ss <= 1'b1;
                                counter <= 9'd0;
                        end
                        else
                        if (pulse_counter == 8'hFF)
                        begin
                                pulse_counter <= 8'h00;
                                mmc_state <= mmc_1MS;
                                o_spi_ss <= 1'b1;
                                counter <= 9'd0;
                        end
                        else
                        begin
                                mmc_tx_ret <= mmc_CMD0;
                                mmc_state <= mmc_SPI_WAIT;
                                spi_tx_byte <= 8'hFF;
                                spi_switch <= ~spi_switch;
                                pulse_counter <= pulse_counter + 8'd1;
                        end
                end
                endcase
        end
        mmc_CMD1:
        begin
                /*
                 * Activates the card’s initialization process
                 * The data to be sent: 0x48:0x00-0x00-0x00-0x00:0x87
                 */
                case (counter)
                (9'd0):
                begin
                        o_spi_ss <= 1'b0;
                        mmc_state <= mmc_SPI_WAIT;
                        mmc_tx_ret <= mmc_CMD1;

                        spi_tx_byte <= 8'h41;
                        spi_switch <= ~spi_switch;
                        counter <= counter + 9'd1;
                end
                (9'd1):
                begin
                        mmc_state <= mmc_SPI_WAIT;
                        mmc_tx_ret <= mmc_CMD1;

                        spi_tx_byte <= 8'h00;
                        spi_switch <= ~spi_switch;
                        counter <= counter + 9'd1;
                end
                (9'd2):
                begin
                        mmc_state <= mmc_SPI_WAIT;
                        mmc_tx_ret <= mmc_CMD1;

                        spi_tx_byte <= 8'h00;
                        spi_switch <= ~spi_switch;
                        counter <= counter + 9'd1;
                end
                (9'd3):
                begin
                        mmc_state <= mmc_SPI_WAIT;
                        mmc_tx_ret <= mmc_CMD1;

                        spi_tx_byte <= 8'h00;
                        spi_switch <= ~spi_switch;
                        counter <= counter + 9'd1;
                end
                (9'd4):
                begin
                        mmc_state <= mmc_SPI_WAIT;
                        mmc_tx_ret <= mmc_CMD1;

                        spi_tx_byte <= 8'h00;
                        spi_switch <= ~spi_switch;
                        counter <= counter + 9'd1;
                end
                (9'd5):
                begin
                        mmc_state <= mmc_SPI_WAIT;
                        mmc_tx_ret <= mmc_CMD1;

                        spi_tx_byte <= 8'hFF;
                        spi_switch <= ~spi_switch;
                        counter <= counter + 9'd1;
                end
                (9'd6):
                begin
                        if (spi_rx_byte == 8'h00)
                        begin
                                mmc_tx_ret <= mmc_CMD58;
                                mmc_state <= mmc_TX_DELAY;

                                pulse_counter <= 8'h00;
                                o_spi_ss <= 1'b1;
                                counter <= 9'd0;
                        end
                        else
                        if (pulse_counter == 8'hFF)
                        begin
                                if (cmd1_retry == 8'h10)
                                begin
                                        mmc_state <= mmc_1MS;
                                        cmd1_retry <= 8'd0;
                                end
                                else
                                begin
                                        mmc_tx_ret <= mmc_CMD1;
                                        mmc_state <= mmc_TX_DELAY;
                                        cmd1_retry <= cmd1_retry + 8'd1;
                                end

                                pulse_counter <= 8'h00;
                                o_spi_ss <= 1'b1;
                                counter <= 9'd0;
                        end
                        else
                        begin
                                mmc_tx_ret <= mmc_CMD1;
                                mmc_state <= mmc_SPI_WAIT;

                                spi_tx_byte <= 8'hFF;
                                spi_switch <= ~spi_switch;
                                pulse_counter <= pulse_counter + 8'd1;
                        end
                end
                endcase
        end
        mmc_CMD58:
        begin
                /*
                 * Reads the OCR register of a card
                 * The data to be sent: 0x7A:0x00-0x00-0x00-0x00:0xFF
                 */
                case (counter)
                (9'd0):
                begin
                        o_spi_ss <= 1'b0;
                        mmc_state <= mmc_SPI_WAIT;
                        mmc_tx_ret <= mmc_CMD58;

                        spi_tx_byte <= 8'h7A;
                        spi_switch <= ~spi_switch;
                        counter <= counter + 9'd1;
                end
                (9'd1):
                begin
                        mmc_state <= mmc_SPI_WAIT;
                        mmc_tx_ret <= mmc_CMD58;

                        spi_tx_byte <= 8'h00;
                        spi_switch <= ~spi_switch;
                        counter <= counter + 9'd1;
                end
                (9'd2):
                begin
                        mmc_state <= mmc_SPI_WAIT;
                        mmc_tx_ret <= mmc_CMD58;

                        spi_tx_byte <= 8'h00;
                        spi_switch <= ~spi_switch;
                        counter <= counter + 9'd1;
                end
                (9'd3):
                begin
                        mmc_state <= mmc_SPI_WAIT;
                        mmc_tx_ret <= mmc_CMD58;

                        spi_tx_byte <= 8'h00;
                        spi_switch <= ~spi_switch;
                        counter <= counter + 9'd1;
                end
                (9'd4):
                begin
                        mmc_state <= mmc_SPI_WAIT;
                        mmc_tx_ret <= mmc_CMD58;

                        spi_tx_byte <= 8'h00;
                        spi_switch <= ~spi_switch;
                        counter <= counter + 9'd1;
                end
                (9'd5):
                begin
                        mmc_state <= mmc_SPI_WAIT;
                        mmc_tx_ret <= mmc_CMD58;

                        spi_tx_byte <= 8'hFF;
                        spi_switch <= ~spi_switch;
                        counter <= counter + 9'd1;
                end
                (9'd6):
                begin
                        if (spi_rx_byte != 8'hFF)
                        begin
                                counter <= counter + 9'd1;
                                mmc_state <= mmc_CMD58;
                        end
                        else
                        if (pulse_counter == 8'hFF)
                        begin
                                mmc_state <= mmc_1MS;

                                pulse_counter <= 8'h00;
                                o_spi_ss <= 1'b1;
                                counter <= 9'd0;
                        end
                        else
                        begin
                                mmc_tx_ret <= mmc_CMD58;
                                mmc_state <= mmc_SPI_WAIT;

                                spi_tx_byte <= 8'hFF;
                                spi_switch <= ~spi_switch;
                                pulse_counter <= pulse_counter + 8'd1;
                        end
                end
                (9'd7):
                begin
                        if (resp_counter == 8'd0)
                        begin
                                status_reg <= spi_rx_byte;
                                resp_counter <= resp_counter + 8'd1;

                                mmc_tx_ret <= mmc_CMD58;
                                mmc_state <= mmc_SPI_WAIT;

                                spi_tx_byte <= 8'hFF;
                                spi_switch <= ~spi_switch;
                        end
                        else
                        begin
                                ocr_reg[resp_counter] <= spi_rx_byte;
                                if (resp_counter != 8'd4)
                                begin
                                        resp_counter <= resp_counter + 8'd1;

                                        mmc_tx_ret <= mmc_CMD58;
                                        mmc_state <= mmc_SPI_WAIT;

                                        spi_tx_byte <= 8'hFF;
                                        spi_switch <= ~spi_switch;
                                end
                                else
                                begin
                                        mmc_tx_ret <= mmc_IDLE;
                                        mmc_state <= mmc_TX_DELAY;

                                        resp_counter <= 8'd0;
                                        pulse_counter <= 8'h00;
                                        o_spi_ss <= 1'b1;
                                        counter <= 9'd0;
                                end
                        end
                end
                endcase
        end
        mmc_IDLE:
        begin
                o_done <= 1'b0;

                if (i_activate != old_activate)
                begin
                        mmc_address <= i_address;
                        mmc_byte <= i_in;
                        if (i_rw)
                                mmc_state <= mmc_CMD24;
                        else
                                mmc_state <= mmc_CMD17;
                end
                else
                        mmc_state <= mmc_CMD58;
        end
        mmc_CMD17:
        begin
                /*
                 * Reads a block of the size selected by the
                 * SET_BLOCKLEN command
                 * The data to be sent: 0x51:Address:0xFF
                 */
                case (counter)
                (9'd0):
                begin
                        o_spi_ss <= 1'b0;
                        mmc_state <= mmc_SPI_WAIT;
                        mmc_tx_ret <= mmc_CMD17;

                        spi_tx_byte <= 8'h51;
                        spi_switch <= ~spi_switch;
                        counter <= counter + 9'd1;
                end
                (9'd1):
                begin
                        mmc_state <= mmc_SPI_WAIT;
                        mmc_tx_ret <= mmc_CMD17;

                        spi_tx_byte <= 8'h00;
                        spi_switch <= ~spi_switch;
                        counter <= counter + 9'd1;
                end
                (9'd2):
                begin
                        mmc_state <= mmc_SPI_WAIT;
                        mmc_tx_ret <= mmc_CMD17;

                        spi_tx_byte <= 8'h00;
                        spi_switch <= ~spi_switch;
                        counter <= counter + 9'd1;
                end
                (9'd3):
                begin
                        mmc_state <= mmc_SPI_WAIT;
                        mmc_tx_ret <= mmc_CMD17;

                        spi_tx_byte <= mmc_address[15:8] & 8'hFE;
                        spi_switch <= ~spi_switch;
                        counter <= counter + 9'd1;
                end
                (9'd4):
                begin
                        mmc_state <= mmc_SPI_WAIT;
                        mmc_tx_ret <= mmc_CMD17;

                        spi_tx_byte <= 8'h00;
                        spi_switch <= ~spi_switch;
                        counter <= counter + 9'd1;
                end
                (9'd5):
                begin
                        mmc_state <= mmc_SPI_WAIT;
                        mmc_tx_ret <= mmc_CMD17;

                        spi_tx_byte <= 8'hFF;
                        spi_switch <= ~spi_switch;
                        counter <= counter + 9'd1;
                end
                (9'd6):
                begin
                        if (spi_rx_byte == 8'hFE)
                        begin
                                counter <= counter + 9'd1;

                                mmc_state <= mmc_SPI_WAIT;
                                mmc_tx_ret <= mmc_CMD17;

                                spi_tx_byte <= 8'hFF;
                                spi_switch <= ~spi_switch;
                        end
                        else
                        if (pulse_counter == 8'hFF)
                        begin
                                mmc_state <= mmc_1MS;

                                pulse_counter <= 8'h00;
                                o_spi_ss <= 1'b1;
                                counter <= 9'd0;
                        end
                        else
                        begin
                                mmc_tx_ret <= mmc_CMD17;
                                mmc_state <= mmc_SPI_WAIT;

                                spi_tx_byte <= 8'hFF;
                                spi_switch <= ~spi_switch;
                                pulse_counter <= pulse_counter + 8'd1;
                        end
                end
                (9'd7):
                begin
                        if (byte_block == mmc_address[8:0])
                                o_out <= spi_rx_byte;

                        if (byte_block <= 10'h200)
                        begin
                                mmc_tx_ret <= mmc_CMD17;
                                mmc_state <= mmc_SPI_WAIT;

                                spi_tx_byte <= 8'hFF;
                                spi_switch <= ~spi_switch;
                                byte_block <= byte_block + 10'd1;
                        end
                        else
                        begin
                                o_spi_ss <= 1'b1;
                                counter <= 10'd0;
                                byte_block <= 10'd0;

                                mmc_state <= mmc_NOTIFY;
                        end
                end
                endcase
        end
        mmc_CMD24:
        begin
                /*
                 * Writes a block of the size selected
                 * by the SET_BLOCKLEN command
                 */
                mmc_state <= mmc_NOTIFY;
        end
        mmc_NOTIFY:
        begin
                old_activate <= ~old_activate;
                o_done <= 1'b1;
                mmc_state <= mmc_IDLE;
        end
        mmc_SPI_WAIT:
        begin
                if (spi_tx_done == 1'b1)
                        mmc_state <= mmc_TX_DELAY;
        end
        mmc_TX_DELAY:
        begin
                tx_wait <= tx_wait + 6'd1;
                if (tx_wait == 6'd63)
                begin
                        mmc_state <= mmc_tx_ret;
                        tx_wait <= 6'd0;
                end
        end
        endcase
end

spi_transceiver #(.SPI_SPEED_HZ(1_000_000)) spi_rxtx(
        .i_sys_clk(i_sys_clk),
        .i_byte(spi_tx_byte),
        .i_activate(spi_switch),
        .i_spi_miso(i_spi_miso),
        .o_byte_done(spi_tx_done),
        .o_byte(spi_rx_byte),
        .o_spi_sck(o_spi_sck),
        .o_spi_mosi(o_spi_mosi));

endmodule
