module uart_receiver
#(
        parameter UART_BAUD_RATE = 115200
) (
        input             i_sys_clk,
        input             i_UART_RX,
        output reg        o_uart_done,
        output reg [7:0]  o_rx_byte = 8'h00
);

localparam UART_EDGE_CYCLES = 50_000_000/UART_BAUD_RATE;

localparam uart_IDLE      = 4'b0000;
localparam uart_START_BIT = 4'b0001;
localparam uart_RECEIVE   = 4'b0010;
localparam uart_STOP_BIT  = 4'b0011;
localparam uart_NOTIFY    = 4'b0100;

reg        rx_pin0        = 1'b1;
reg        uart_rx        = 1'b1;
reg [4:0]  receiver_state = uart_IDLE;
reg [15:0] uart_cycles    = 16'b0;
reg [2:0]  uart_bit       = 3'b0;

//It removes problems caused by metastability
always @(posedge i_sys_clk)
begin
        rx_pin0 <= i_UART_RX;
        uart_rx <= rx_pin0;
end

always @(posedge i_sys_clk)
begin
        case (receiver_state)
        uart_IDLE:
        begin
                o_uart_done <= 1'b0;
                uart_cycles <= 16'b0;
                uart_bit    <= 3'b0;
                o_rx_byte   <= 8'b0;

                if (uart_rx == 1'b0)
                        receiver_state <= uart_START_BIT;
                else
                        receiver_state <= uart_IDLE;
        end
        uart_START_BIT:
        begin
                if (uart_cycles == (UART_EDGE_CYCLES - 1)/2)
                begin
                        if (uart_rx == 1'b0)
                        begin
                                receiver_state <= uart_RECEIVE;
                                uart_cycles <= 16'b0;
                        end
                        else
                                receiver_state <= uart_IDLE;
                end
                else
                        uart_cycles <= uart_cycles + 16'b1;
        end
        uart_RECEIVE:
        begin
                if (uart_cycles == UART_EDGE_CYCLES - 1)
                begin
                        if (uart_rx == 1'b1)
                                o_rx_byte <= o_rx_byte | (8'b1 << uart_bit);
                        if (uart_bit == 3'd7)
                        begin
                                uart_bit <= 0;
                                receiver_state <= uart_STOP_BIT;
                        end
                        uart_bit <= uart_bit + 1'b1;
                        uart_cycles <= 16'b0;
                end
                else
                        uart_cycles <= uart_cycles + 16'b1;
        end
        uart_STOP_BIT:
        begin
                if (uart_cycles == UART_EDGE_CYCLES - 1)
                begin
                        receiver_state <= uart_NOTIFY;
                        uart_cycles <= 16'b0;
                end
                else
                        uart_cycles <= uart_cycles + 16'b1;
        end
        uart_NOTIFY:
        begin
                o_uart_done <= 1'b1;
                receiver_state <= uart_IDLE;
        end
        endcase
end

endmodule
