module mem_reg
#(
        parameter BASE_ADDRESS = 16'h4900
) (
        input              i_sys_clk,
        input              i_apulse,
        input              i_regmem,
        input              i_rw,
        input [15:0]       i_address,
        input [7:0]        i_byte,
        input [3:0]        i_key,
        input              i_spi_miso,
        output reg  [7:0]  o_byte = 8'h00,
        output wire [15:0] o_digit,
        output wire [3:0]  o_led,
        output reg         o_ready = 1'b0,
        output wire        o_spi_mosi,
        output wire        o_spi_sck,
        output wire        o_spi_ss
);

localparam dev_REG      = 1'b0;
localparam dev_MEM      = 1'b1;

localparam mode_READ    = 1'b0;
localparam mode_WRITE   = 1'b1;

localparam mem_IDLE     = 4'd0;
localparam mem_PROCESS  = 4'd1;
localparam mem_MEMORY   = 4'd2;
localparam mem_REG      = 4'd3;
localparam mem_NOTIFY   = 4'd4;
localparam mem_MEMWAIT  = 4'd5;

reg [3:0] fsm_memory    = mem_IDLE;

/* Digit registers */
reg [15:0] digit = 16'd0;
assign o_digit   = digit;

/* Led registers */
reg [3:0] led    = 4'd0;
assign o_led     = ~led;

/* Key */
wire [3:0] key;

/* Mode */
reg dev            = dev_REG;
reg mode           = mode_READ;
reg [15:0] address = BASE_ADDRESS;
reg [7:0] byte     = 8'b0;

reg apulse_old = 1'b0;

/* MMC necessities */
reg [15:0] mmc_address = 16'd0;
reg mmc_rw = 1'b0;
wire [7:0] mmc_out;
reg [7:0] mmc_in;

reg mmc_on = 1'b0;
wire mmc_done;

always @(posedge i_sys_clk)
begin
        case (fsm_memory)
        mem_IDLE:
        begin
                o_ready <= 1'b0;

                if (i_apulse != apulse_old)
                begin
                        apulse_old <= i_apulse;
                        dev <= i_regmem;
                        mode <= i_rw;
                        address <= i_address;
                        byte <= byte;
                        fsm_memory <= mem_PROCESS;
                        o_byte <= 8'h00;
                end
        end
        mem_PROCESS:
        begin
                if (dev == dev_REG)
                begin
                        fsm_memory <= mem_REG;
                end
                else
                begin
                        fsm_memory <= mem_MEMORY;
                end
        end
        mem_MEMORY:
        begin
                mmc_address <= address - BASE_ADDRESS;
                mmc_rw <= i_rw;
                mmc_in <= i_byte;
                mmc_on <= ~mmc_on;

                fsm_memory <= mem_MEMWAIT;
        end
        mem_MEMWAIT:
        begin
                if (mmc_done == 1'b1)
                begin
                        if (!i_rw)
                                o_byte <= mmc_out;
                        fsm_memory <= mem_NOTIFY;
                end
        end
        mem_REG:
        begin
                if (i_rw == mode_READ)
                begin
                        case (address - BASE_ADDRESS)
                        16'h0000:
                        begin
                                o_byte[3:0] <= led;
                        end
                        16'h0001:
                        begin
                                o_byte <= digit[15:8];
                        end
                        16'h0002:
                        begin
                                o_byte <= digit[7:0];
                        end
                        16'h0003:
                        begin
                                o_byte[3:0] <= ~key;
                        end
                        endcase
                end
                else
                begin
                        case (address - BASE_ADDRESS)
                        16'h0000:
                        begin
                                led <= i_byte[3:0];
                        end
                        16'h0001:
                        begin
                                digit[15:8] <= i_byte;
                        end
                        16'h0002:
                        begin
                                digit[7:0] <= i_byte;
                        end
                        endcase
                end
                fsm_memory <= mem_NOTIFY;
        end
        mem_NOTIFY:
        begin
                o_ready <= 1'b1;
                fsm_memory <= mem_IDLE;
        end
        endcase
end

chatter_button key1(
        .i_sys_clk(i_sys_clk),
        .i_key(i_key[0]),
        .o_signal(key[0]));

chatter_button key2(
        .i_sys_clk(i_sys_clk),
        .i_key(i_key[1]),
        .o_signal(key[1]));

chatter_button key3(
        .i_sys_clk(i_sys_clk),
        .i_key(i_key[2]),
        .o_signal(key[2]));

chatter_button key4(
        .i_sys_clk(i_sys_clk),
        .i_key(i_key[3]),
        .o_signal(key[3]));

mmc_driver sd_driver(
        .i_sys_clk(i_sys_clk),
        .i_address(mmc_address),
        .i_in(mmc_in),
        .i_rw(mmc_rw),
        .i_activate(mmc_on),
        .i_spi_miso(i_spi_miso),
        .o_out(mmc_out),
        .o_spi_mosi(o_spi_mosi),
        .o_spi_sck(o_spi_sck),
        .o_spi_ss(o_spi_ss),
        .o_done(mmc_done));

endmodule
