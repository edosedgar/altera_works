/*
 * Render segment display
 */
module display_seg4(
        input sys_clk,
        output [6:0] ssegment_out,
        output [3:0] scathod_out,
        input [3:0] digit1,
        input [3:0] digit2,
        input [3:0] digit3,
        input [3:0] digit4
);
        reg [6:0] ssegment;
        reg [3:0] scathod;
        reg [12:0] count;
        reg [1:0] showing_digit;
        wire [3:0] digit[4];
        assign digit[0] = digit1;
        assign digit[1] = digit2;
        assign digit[2] = digit3;
        assign digit[3] = digit4;

        always @(posedge sys_clk)
        begin
                count <= count + 12'd1;
                if (count == 12'b1111_11111111)
                begin
                        ssegment = 7'b0000000;
                        case (showing_digit)
                        2'b00: scathod = ~4'b0001;
                        2'b01: scathod = ~4'b0010;
                        2'b10: scathod = ~4'b0100;
                        2'b11: scathod = ~4'b1000;
                        endcase
                        case (digit[showing_digit])
                        //                  GFEDCBA
                        4'h0: ssegment = 7'b0111111;
                        4'h1: ssegment = 7'b0000110;
                        4'h2: ssegment = 7'b1011011;
                        4'h3: ssegment = 7'b1001111;
                        4'h4: ssegment = 7'b1100110;
                        4'h5: ssegment = 7'b1101101;
                        4'h6: ssegment = 7'b1111101;
                        4'h7: ssegment = 7'b0000111;
                        4'h8: ssegment = 7'b1111111;
                        4'h9: ssegment = 7'b1101111;
                        4'ha: ssegment = 7'b1110111;
                        4'hb: ssegment = 7'b1111100;
                        4'hc: ssegment = 7'b0111001;
                        4'hd: ssegment = 7'b1011110;
                        4'he: ssegment = 7'b1111001;
                        4'hf: ssegment = 7'b1110001;
                        //                  GFEDCBA
                        endcase
                        showing_digit = showing_digit + 2'b1;
                end
        end

        assign ssegment_out = ssegment;
        assign scathod_out = scathod;
endmodule

/*
 * VGA component: vsync
 */
module vsync(
        input line_clk,
        output vsync_out,
        output blank_out,
        output [9:0] y_coord_out
);
        reg [10:0] count = 10'd0;
        reg vsync  = 0;
        reg blank  = 0;
        reg [9:0] y_coord = 0;
        localparam VSBL_AREA_LNS = 600;
        localparam FRONT_PORCH_LNS = 37;
        localparam SYNC_PULSE_LNS = 6;
        localparam BACK_PORCH_LNS = 23;
        localparam WHOLE_LINE_LNS = VSBL_AREA_LNS  + FRONT_PORCH_LNS +
                                    SYNC_PULSE_LNS + BACK_PORCH_LNS;

        always @(posedge line_clk)
                if (count < WHOLE_LINE_LNS)
                        count <= count + 1;
                else
                        count <= 0;

        always @(posedge line_clk)
                blank <= (count < VSBL_AREA_LNS) ? 0 : 1;

        always @(posedge line_clk)
                y_coord <= (count < VSBL_AREA_LNS) ? count : 10'b11_1111_1111;

        always @(posedge line_clk)
                vsync <= (count >= VSBL_AREA_LNS + FRONT_PORCH_LNS &&
                          count <  VSBL_AREA_LNS + FRONT_PORCH_LNS + SYNC_PULSE_LNS
                         ) ? 0 : 1;

        assign vsync_out  = vsync;
        assign blank_out  = blank;
        assign y_coord_out = y_coord;
endmodule

/*
 * VGA component: hsync
 */
module hsync(
        input sys_clk,
        output hsync_out,
        output blank_out,
        output newline_out,
        output [9:0] x_coord_out
);
        reg [10:0] count = 10'd0;
        reg hsync = 0;
        reg blank = 0;
        reg newline = 0;
        reg [9:0] x_coord = 0;
        localparam VSBL_AREA_CLK = 800;
        localparam FRONT_PORCH_CLK = 56;
        localparam SYNC_PULSE_CLK = 120;
        localparam BACK_PORCH_CLK = 64;
        localparam WHOLE_LINE_CLK = VSBL_AREA_CLK  + FRONT_PORCH_CLK +
                                    SYNC_PULSE_CLK + BACK_PORCH_CLK;

        always @(posedge sys_clk)
                if (count < WHOLE_LINE_CLK)
                        count <= count + 1;
                else
                        count <= 0;

        always @(posedge sys_clk)
                newline <= (count == 0) ? 1 : 0;

        always @(posedge sys_clk)
                blank <= (count < VSBL_AREA_CLK) ? 0 : 1;

        always @(posedge sys_clk)
                x_coord <= (count < VSBL_AREA_CLK) ? count : 10'b11_1111_1111;

        always @(posedge sys_clk)
                hsync <= (count >= VSBL_AREA_CLK + FRONT_PORCH_CLK &&
                          count <  VSBL_AREA_CLK + FRONT_PORCH_CLK + SYNC_PULSE_CLK
                         ) ? 0 : 1;

        assign hsync_out    = hsync;
        assign blank_out    = blank;
        assign newline_out  = newline;
        assign x_coord_out  = x_coord;
endmodule

/*
 * VGA component: pixel color
 */
module color_out(
        input sys_clk,
        input [2:0] color,
        input blank,
        output red_out,
        output green_out,
        output blue_out
);
        reg red_c = 0;
        reg green_c = 0;
        reg blue_c = 0;

        always @(posedge sys_clk)
        begin
                red_c   <= !blank ? color[2] : 0;
                green_c <= !blank ? color[1] : 0;
                blue_c  <= !blank ? color[0] : 0;
        end

        assign red_out = red_c;
        assign green_out = green_c;
        assign blue_out = blue_c;
endmodule

/*
 * Main module
 */
module countpro(
        input sys_clk,
        input key,
        output reg [2:0] led,
        output [6:0] ssegment,
        output [3:0] scathod,
        output VSync,
        output HSync,
        output Rchannel,
        output Gchannel,
        output Bchannel
);
        localparam C_BLUE = 3'b001;
        localparam C_RED = 3'b100;
        localparam C_GREEN = 3'b010;
        localparam C_YELLOW = 3'b110;
        localparam C_MAGENTA = 3'b011;
        localparam C_PURPLE = 3'b101;
        localparam C_BLACK = 3'b000;
        localparam C_WHITE = 3'b111;

        reg [32:0] count;
        reg [3:0] digit[4];
        reg [2:0] cur_color;
        wire [9:0] xcoord;
        wire [9:0] ycoord;
        wire line_clk, blank, hblank, vblank;
        reg video_mem [0:99] [0:74];
        reg [6:0] startx, starty, width, height;
        reg color, render;
        reg [3:0] state = 0;
        reg [63:0] count2 = 0;

        hsync hs(sys_clk, HSync, hblank, line_clk, xcoord);
        vsync vs(line_clk, VSync, vblank, ycoord);
        color_out cg(sys_clk, cur_color, blank, Rchannel, Gchannel, Bchannel);
        display_seg4 ds(sys_clk, ssegment, scathod, digit[0], digit[1], digit[2],
                        digit[3]);

        assign blank = hblank || vblank;

        always @(posedge sys_clk)
        begin
                count <= count + 1;
                if (count == 32'd500_000)
                begin
                        if (digit[1] == 4'hf && digit[2] == 4'hf && digit[3] == 4'hf)
                        begin
                                digit[0] = digit[0] + 1;
                        end
                        if (digit[2] == 4'hf && digit[3] == 4'hf)
                        begin
                                digit[1] = digit[1] + 1;
                        end
                        if (digit[3] == 4'hf)
                        begin
                                digit[2] = digit[2] + 1;
                        end
                        digit[3] = digit[3] + 1;
                        count <= 0;
                end

        end

        always @(posedge sys_clk)
        begin
                count2 <= count2 + 1;

                //cur_color <=  ((xcoord / 8) % 2 == 0 && (ycoord / 8) % 2 == 0
                //               && !blank) ? xcoord[2:0] : C_BLACK;
                case (count2/100_000_000)
                64'd0:
                        cur_color <= (!blank ) ? 3'b100 : C_BLACK;
                64'd1:
                        cur_color <= (!blank ) ? 3'b010 : C_BLACK;
                64'd2:
                        cur_color <= (!blank ) ? 3'b001 : C_BLACK;
                64'd3:
                        cur_color <= (!blank ) ? 3'b111 : C_BLACK;
                64'd4:
                        cur_color <= (!blank ) ? 3'b000 : C_BLACK;
                64'd5:
                        cur_color <= (!blank && xcoord % 2) ? 3'b111: C_BLACK;
                64'd6:
                        cur_color <= (!blank && xcoord % 2 == 0 && ycoord % 2 == 0) ?
                                      3'b111: C_BLACK;
                64'd7:
                        count2 <= 0;
                endcase
        end
endmodule
