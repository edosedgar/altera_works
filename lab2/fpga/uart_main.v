module uart_main(
        input             sys_clk,
        input [3:0]       key,
        input             UART_RX,
        input             SPI_MISO,
        output wire [3:0] scathod,
        output wire [6:0] ssegment,
        output wire [3:0] led,
        output wire       UART_TX,
        output wire       SPI_SCK,
        output wire       SPI_MOSI,
        output wire       SPI_SS
);

localparam MAX_BYTE      = 8'hFF;
localparam BASE_ADDR     = 16'h4900;

// Main state machine wires and parameters
localparam main_NULL     = 8'd0;
localparam main_WAIT_RX  = 8'd1;
localparam main_UART_RX  = 8'd2;
localparam main_UART_TX  = 8'd3;
localparam main_WAIT_TX  = 8'd4;
localparam main_TAKE2CRC = 8'd5;
localparam main_WAIT_CRC = 8'd6;
localparam main_COMMAND  = 8'd7;
localparam main_LENGTH   = 8'd8;
localparam main_ADDRESS  = 8'd9;
localparam main_DATA     = 8'd10;
localparam main_CRC      = 8'd11;
localparam main_CHECKCRC = 8'd12;
localparam main_ERRSEND  = 8'd13;
localparam main_CONFMEM  = 8'd14;
localparam main_READDEV  = 8'd15;
localparam main_WRITEDEV = 8'd16;
localparam main_SENDCOM  = 8'd17;
localparam main_SENDADR  = 8'd18;
localparam main_SENDDAT  = 8'd19;
localparam main_SENDCRC  = 8'd20;
localparam main_OPTCHK   = 8'd21;
localparam main_SENDLEN  = 8'd22;

// Error codes
localparam errno_NOERROR  = 8'hFF;
localparam errno_CRCERROR = 8'hFE;
localparam errno_INVCOM   = 8'hFD;
localparam errno_INVADDR  = 8'hFC;
localparam errno_INVLEN   = 8'hFB;

// Command names
localparam com_WRITEREG = 8'h00;
localparam com_READREG  = 8'h80;
localparam com_WRITEMEM = 8'h01;
localparam com_READMEM  = 8'h81;

// Main wires and latches
reg [7:0]  f_state_mach      = main_WAIT_RX;
reg [7:0]  fsm_process       = main_COMMAND;
reg [7:0]  crc_ret           = main_WAIT_RX;
reg [7:0]  tx_ret            = main_WAIT_RX;
reg [7:0]  received_byte     = 8'd0;
reg [7:0]  command           = 8'd0;
reg [7:0]  data_len          = 8'd0;
reg [15:0] address           = 16'd0;
reg [1:0]  addr_byte_num     = 2'd0;
reg [7:0]  data[0:MAX_BYTE];
reg [7:0]  data_byte_num     = 8'd0;
reg [1:0]  crc_byte_num      = 2'd0;
reg [7:0]  errno             = errno_NOERROR;

// Digit indicator wires
wire [15:0] digit_wire;

// UART wires
wire uart_done_rx;
wire uart_done_tx;
wire [7:0] uart_packet;
reg  [7:0] tx_data = 8'b0;
reg  uart_tx_pulse = 1'b0;

// CRC-16 wires
reg [7:0] crc_byte_next = 8'd0;
reg crc_pulse = 1'b0;
reg crc_reset = 1'b0;
wire crc_done;
wire [15:0] crc_out;

// Memory wires
reg mem_pulse       = 1'b0;
reg mem_regmem      = 1'b0;
reg mem_rw          = 1'b0;
reg [15:0] mem_addr = 16'h0000;
reg [7:0] mem_in    = 8'h00;
wire mem_done;
wire [7:0] mem_out;

always @(posedge sys_clk)
begin
        case (f_state_mach)
        main_WAIT_RX:
        begin
                if (uart_done_rx)
                begin
                        f_state_mach <= fsm_process;
                        received_byte <= uart_packet;
                end
        end
        main_COMMAND:
        begin
                crc_reset <= ~crc_reset;
                data_byte_num <= 8'd0;
                addr_byte_num <= 2'd0;
                crc_byte_num <= 2'd0;
                command <= received_byte;
                fsm_process <= main_LENGTH;
                f_state_mach <= main_TAKE2CRC;
        end
        main_LENGTH:
        begin
                data_len <= received_byte;
                fsm_process <= main_ADDRESS;
                f_state_mach <= main_TAKE2CRC;
        end
        main_ADDRESS:
        begin
                if (addr_byte_num == 2'b01)
                begin
                        address[7:0] <= received_byte;
                        fsm_process <= main_DATA;
                end
                else
                begin
                        address[15:8] <= received_byte;
                        addr_byte_num <= addr_byte_num + 2'b01;
                end
                f_state_mach <= main_TAKE2CRC;
        end
        main_DATA:
        begin
                if (data_byte_num < data_len && command != com_READREG &&
                    command != com_READMEM)
                begin
                        data[data_byte_num] <= received_byte;
                        data_byte_num <= data_byte_num + 8'b1;
                        f_state_mach <= main_TAKE2CRC;
                end
                else
                begin
                        f_state_mach <= main_CRC;
                end
        end
        main_CRC:
        begin
                if (crc_byte_num == 2'd1)
                begin
                        crc_ret <= main_CHECKCRC;
                end
                else
                begin
                        crc_byte_num <= crc_byte_num + 2'd1;
                        crc_ret <= main_WAIT_RX;
                        fsm_process <= main_CRC;
                end
                f_state_mach <= main_TAKE2CRC;
        end
        main_CHECKCRC:
        begin
                if (crc_out != 16'd0)
                begin
                        errno <= errno_CRCERROR;
                        f_state_mach <= main_ERRSEND;
                end
                else
                begin
                        f_state_mach <= main_OPTCHK;
                end
        end
        main_ERRSEND:
        begin
                tx_data <= errno;
                f_state_mach <= main_UART_TX;
                fsm_process <= main_COMMAND;
                tx_ret <= main_WAIT_RX;
                crc_ret <= main_WAIT_RX;
        end
        main_OPTCHK:
        begin
                if (data_len > MAX_BYTE || address < BASE_ADDR ||
                    address >= BASE_ADDR + 16'h00FF)
                begin
                        if (data_len > MAX_BYTE)
                                errno <= errno_INVLEN;
                        else
                                errno <= errno_INVADDR;
                        f_state_mach <= main_ERRSEND;
                end
                else
                        f_state_mach <= main_CONFMEM;
        end
        main_CONFMEM:
        begin
                case (command)
                com_WRITEREG:
                begin
                        mem_regmem <= 1'b0;
                        mem_rw <= 1'b1;
                        f_state_mach <= main_WRITEDEV;
                end
                com_READREG:
                begin
                        mem_regmem <= 1'b0;
                        mem_rw <= 1'b0;
                        f_state_mach <= main_READDEV;
                end
                com_WRITEMEM:
                begin
                        mem_regmem <= 1'b1;
                        mem_rw <= 1'b1;
                        f_state_mach <= main_WRITEDEV;
                end
                com_READMEM:
                begin
                        mem_regmem <= 1'b1;
                        mem_rw <= 1'b0;
                        f_state_mach <= main_READDEV;
                end
                default:
                begin
                        errno <= errno_INVCOM;
                        f_state_mach <= main_ERRSEND;
                end
                endcase
                data_byte_num <= 8'h00;
        end
        main_READDEV:
        begin
                if (mem_done || data_byte_num == 8'h00)
                begin
                        if (data_byte_num != 8'h00)
                        begin
                                data[data_byte_num - 8'h01] <= mem_out;
                        end
                        if (data_byte_num < data_len)
                        begin
                                mem_addr <= address + data_byte_num;
                                mem_pulse <= ~mem_pulse;
                        end
                        data_byte_num <= data_byte_num + 8'h01;
                end
                if (data_byte_num > data_len)
                begin
                        f_state_mach <= main_SENDCOM;
                end
        end
        main_WRITEDEV:
        begin
                if (mem_done || data_byte_num == 8'h00)
                begin
                        mem_in <= data[data_byte_num];
                        mem_addr <= address + data_byte_num;
                        mem_pulse <= ~mem_pulse;
                        data_byte_num <= data_byte_num + 8'h01;
                end
                if (data_byte_num == data_len)
                begin
                        f_state_mach <= main_SENDCOM;
                end
        end
        main_SENDCOM:
        begin
                crc_reset <= ~crc_reset;
                received_byte <= command;
                tx_data <= command;
                crc_ret <= main_SENDLEN;
                tx_ret <= main_TAKE2CRC;
                f_state_mach <= main_UART_TX;
                data_byte_num <= 8'h00;
                crc_byte_num <= 2'b00;
                addr_byte_num <= 2'b00;
        end
        main_SENDLEN:
        begin
                received_byte <= data_len;
                tx_data <= data_len;
                crc_ret <= main_SENDADR;
                tx_ret <= main_TAKE2CRC;
                f_state_mach <= main_UART_TX;
        end
        main_SENDADR:
        begin
                if (addr_byte_num == 2'b01)
                begin
                        received_byte <= address[7:0];
                        tx_data <= address[7:0];
                        crc_ret <= main_SENDDAT;
                end
                else
                begin
                        received_byte <= address[15:8];
                        tx_data <= address[15:8];
                        crc_ret <= main_SENDADR;
                        addr_byte_num <= addr_byte_num + 2'b01;
                end
                f_state_mach <= main_UART_TX;
                tx_ret <= main_TAKE2CRC;
        end
        main_SENDDAT:
        begin
                if (data_byte_num < data_len && command != com_WRITEREG &&
                    command != com_WRITEMEM)
                begin
                        received_byte <= data[data_byte_num];
                        tx_data <= data[data_byte_num];
                        crc_ret <= main_SENDDAT;
                        tx_ret <= main_TAKE2CRC;
                        f_state_mach <= main_UART_TX;
                        data_byte_num <= data_byte_num + 8'b1;
                end
                else
                begin
                        f_state_mach <= main_SENDCRC;
                end
        end
        main_SENDCRC:
        begin
                if (crc_byte_num == 2'd1)
                begin
                        tx_data <= crc_out[7:0];
                        tx_ret <= main_WAIT_RX;
                        crc_ret <= main_WAIT_RX;
                        fsm_process <= main_COMMAND;
                end
                else
                begin
                        tx_data <= crc_out[15:8];
                        tx_ret <= main_SENDCRC;
                        crc_byte_num <= crc_byte_num + 2'd1;
                end
                f_state_mach <= main_UART_TX;
        end
        main_TAKE2CRC:
        begin
                crc_byte_next <= received_byte;
                crc_pulse <= ~crc_pulse;
                f_state_mach <= main_WAIT_CRC;
        end
        main_WAIT_CRC:
        begin
                if (crc_done == 1'b1)
                begin
                        f_state_mach <= crc_ret;
                end
        end
        main_UART_TX:
        begin
                uart_tx_pulse <= ~uart_tx_pulse;
                f_state_mach <= main_WAIT_TX;
        end
        main_WAIT_TX:
        begin
                if (uart_done_tx)
                begin
                        f_state_mach <= tx_ret;
                end
        end
        endcase
end

uart_receiver #(.UART_BAUD_RATE(115200)) u_receiver(
        .i_sys_clk(sys_clk),
        .i_UART_RX(UART_RX),
        .o_uart_done(uart_done_rx),
        .o_rx_byte(uart_packet));

uart_transmitter #(.UART_BAUD_RATE(115200)) u_transmitter(
        .i_sys_clk(sys_clk),
        .i_tx_byte(tx_data),
        .i_activate(uart_tx_pulse),
        .o_uart_tx(UART_TX),
        .o_uart_done(uart_done_tx));

crc16_check #(.POLYNOMIAL(16'h1021)) u_crc16(
        .i_sys_clk(sys_clk),
        .i_byte_in(crc_byte_next),
        .i_take(crc_pulse),
        .i_reset(crc_reset),
        .o_ready(crc_done),
        .o_crc16(crc_out));

mem_reg #(.BASE_ADDRESS(BASE_ADDR)) peripheral(
        .i_sys_clk(sys_clk),
        .i_apulse(mem_pulse),
        .i_regmem(mem_regmem),
        .i_rw(mem_rw),
        .i_address(mem_addr),
        .i_byte(mem_in),
        .i_key(key),
        .i_spi_miso(SPI_MISO),
        .o_byte(mem_out),
        .o_digit(digit_wire),
        .o_led(led),
        .o_ready(mem_done),
        .o_spi_mosi(SPI_MOSI),
        .o_spi_sck(SPI_SCK),
        .o_spi_ss(SPI_SS));

seven_seg digit_display(
        .i_sys_clk(sys_clk),
        .i_digit(digit_wire),
        .o_scathod(scathod),
        .o_ssegment(ssegment));

endmodule
