module uart_transmitter
#(
        parameter UART_BAUD_RATE = 115200
) (
        input       i_sys_clk,
        input [7:0] i_tx_byte,
        input       i_activate,
        output reg  o_uart_tx,
        output reg  o_uart_done
);

localparam UART_EDGE_CYCLES = 50_000_000/UART_BAUD_RATE;

localparam uart_IDLE      = 4'b0000;
localparam uart_START_BIT = 4'b0001;
localparam uart_TRANSMIT  = 4'b0010;
localparam uart_STOP_BIT  = 4'b0011;
localparam uart_NOTIFY    = 4'b0100;

reg [4:0]  transmitter_state = uart_IDLE;
reg [15:0] uart_cycles    = 16'b0;
reg [2:0]  uart_bit       = 3'b0;
reg [7:0]  uart_data      = 8'b0;
reg activate_idle         = 1'b0;

always @(posedge i_sys_clk)
begin
        case (transmitter_state)
        uart_IDLE:
        begin
                o_uart_done <= 1'b0;
                uart_cycles <= 16'b0;
                uart_bit    <= 3'b0;
                uart_data   <= 8'b0;
                o_uart_tx   <= 1'b1;

                if (i_activate != activate_idle)
                begin
                        transmitter_state <= uart_START_BIT;
                        uart_data <= i_tx_byte;
                end
                else
                        transmitter_state <= uart_IDLE;
        end
        uart_START_BIT:
        begin
                if (uart_cycles == (UART_EDGE_CYCLES - 1))
                begin
                        transmitter_state <= uart_TRANSMIT;
                        uart_cycles <= 16'b0;
                end
                else
                begin
                        o_uart_tx <= 1'b0;
                        uart_cycles <= uart_cycles + 16'b1;
                end
        end
        uart_TRANSMIT:
        begin
                if (uart_cycles == UART_EDGE_CYCLES - 1)
                begin
                        if (uart_bit == 3'd7)
                        begin
                                uart_bit <= 0;
                                transmitter_state <= uart_STOP_BIT;
                        end
                        uart_bit <= uart_bit + 1'b1;
                        uart_cycles <= 16'b0;
                end
                else
                begin
                        if (uart_data & (8'b1 << uart_bit))
                                o_uart_tx <= 1'b1;
                        else
                                o_uart_tx <= 1'b0;
                        uart_cycles <= uart_cycles + 16'b1;
                end
        end
        uart_STOP_BIT:
        begin
                if (uart_cycles == UART_EDGE_CYCLES - 1)
                begin
                        transmitter_state <= uart_NOTIFY;
                        uart_cycles <= 16'b0;
                end
                else
                begin
                        uart_cycles <= uart_cycles + 16'b1;
                        o_uart_tx <= 1'b1;
                end
        end
        uart_NOTIFY:
        begin
                activate_idle <= ~activate_idle;
                o_uart_done <= 1'b1;
                transmitter_state <= uart_IDLE;
        end
        endcase
end

endmodule
