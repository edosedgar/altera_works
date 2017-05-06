module countpro(sys_clk, led, key, scathod, ssegment);

input sys_clk;
input key;
output [2:0] led;
output reg [6:0] ssegment;
output reg [3:0] scathod;
reg [22:0] count;
reg [2:0] led;
reg [3:0] digit[4];
reg [16:0] dyn_indic_count;
reg [1:0] showing_digit;
integer i;

always @(posedge sys_clk)
begin
        count <= count + 1;
        if (count == 22'b11_1111_1111_1111_1111_1110)
        begin
                led[2] = led[2] ^ 1'b1;
                if (digit[1] == 4'hf)
                begin
                        digit[0] = digit[0] + 1;
                end
                if (digit[2] == 4'hf)
                begin
                        digit[1] = digit[1] + 1;
                end
                if (digit[3] == 4'hf)
                begin
                        digit[2] = digit[2] + 1;
                end
                digit[3] = digit[3] + 1;
        end
end

always @(negedge key)
begin
        led[1] = led[1] ^ 1'b1;
end


/*
 * Module to show digits, those are placed in the digit regs.
 */
always @(posedge sys_clk)
begin
        dyn_indic_count <= dyn_indic_count + 1;
        if (dyn_indic_count == 16'b11111111_11111111)
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
                4'hc: ssegment = 7'b1111001;
                4'hd: ssegment = 7'b1011110;
                4'he: ssegment = 7'b1111001;
                4'hf: ssegment = 7'b1110001;
                endcase
                showing_digit = showing_digit + 1;
        end
end

endmodule
