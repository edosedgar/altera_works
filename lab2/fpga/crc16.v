module crc16_check
#(
        parameter POLYNOMIAL = 16'h4002
) (
        input             i_sys_clk,
        input [7:0]       i_byte_in,
        input             i_take,
        input             i_reset,
        output reg        o_ready,
        output reg [15:0] o_crc16 = 16'd0
);

localparam crc_IDLE   = 2'b00;
localparam crc_LOAD   = 2'b01;
localparam crc_NOTIFY = 2'b10;

reg [1:0] crc_state = crc_IDLE;
reg [7:0] raw_byte = 8'b0;
reg i_take_idle = 1'b0;
reg i_reset_idle = 1'b0;
reg [2:0] bit_num = 3'b0;

always @(posedge i_sys_clk)
begin
        case (crc_state)
        crc_IDLE:
        begin
                o_ready <= 1'b0;

                if (i_reset != i_reset_idle)
                begin
                        i_reset_idle <= i_reset;
                        o_crc16 <= 16'hFFFF;
                        o_ready <= 1'b0;
                end

                if (i_take != i_take_idle)
                begin
                        if (i_reset == i_reset_idle)
                        begin
                                i_take_idle <= i_take;
                                raw_byte <= i_byte_in;
                                bit_num <= 3'd7;
                                crc_state <= crc_LOAD;
                        end
                end
        end
        crc_LOAD:
        begin
                o_crc16[0]  <= raw_byte[bit_num] ^ o_crc16[15];
                o_crc16[1]  <= o_crc16[0];
                o_crc16[2]  <= o_crc16[1];
                o_crc16[3]  <= o_crc16[2];
                o_crc16[4]  <= o_crc16[3];
                o_crc16[5]  <= o_crc16[4] ^ raw_byte[bit_num] ^ o_crc16[15];
                o_crc16[6]  <= o_crc16[5];
                o_crc16[7]  <= o_crc16[6];
                o_crc16[8]  <= o_crc16[7];
                o_crc16[9]  <= o_crc16[8];
                o_crc16[10] <= o_crc16[9];
                o_crc16[11] <= o_crc16[10];
                o_crc16[12] <= o_crc16[11] ^ raw_byte[bit_num] ^ o_crc16[15];
                o_crc16[13] <= o_crc16[12];
                o_crc16[14] <= o_crc16[13];
                o_crc16[15] <= o_crc16[14];

                if (bit_num == 3'd0)
                begin
                        crc_state <= crc_NOTIFY;
                end
                else
                begin
                        bit_num <= bit_num - 3'd1;
                end
        end
        crc_NOTIFY:
        begin
                o_ready <= 1'b1;
                crc_state <= crc_IDLE;
        end
        endcase
end
endmodule
