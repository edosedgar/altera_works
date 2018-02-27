module seven_seg(sys_clk, scathod, ssegment, digit);

input sys_clk;
output reg [6:0] ssegment = 0;
output reg [3:0] scathod = 0;
input [15:0] digit;

reg [3:0] out_seg = 0;
reg [11:0] dyn_indic_count = 0;
reg [1:0] showing_digit = 0;

always @(posedge sys_clk)
begin
        dyn_indic_count <= dyn_indic_count + 1'b1;
        if (dyn_indic_count == 12'b1111_1111_1111)
        begin
                showing_digit <= showing_digit + 1'b1;
        end
        case (showing_digit)
        2'b00:
        begin
                out_seg <= digit[3:0];
                scathod <= 4'b0111;
        end
        2'b01:
        begin
                out_seg <= digit[7:4];
                scathod <= 4'b1011;
        end
        2'b10:
        begin
                out_seg <= digit[11:8];
                scathod <= 4'b1101;
        end
        2'b11:
        begin
                out_seg <= digit[15:12];
                scathod <= 4'b1110;
        end
        endcase
end

always @(*)
begin
        case (out_seg)
        //                   GFEDCBA
        4'h0: ssegment <= 7'b0111111;
        4'h1: ssegment <= 7'b0000110;
        4'h2: ssegment <= 7'b1011011;
        4'h3: ssegment <= 7'b1001111;
        4'h4: ssegment <= 7'b1100110;
        4'h5: ssegment <= 7'b1101101;
        4'h6: ssegment <= 7'b1111101;
        4'h7: ssegment <= 7'b0000111;
        4'h8: ssegment <= 7'b1111111;
        4'h9: ssegment <= 7'b1101111;
        4'ha: ssegment <= 7'b1110111;
        4'hb: ssegment <= 7'b1111100;
        4'hc: ssegment <= 7'b0111001;
        4'hd: ssegment <= 7'b1011110;
        4'he: ssegment <= 7'b1111001;
        4'hf: ssegment <= 7'b1110001;
        endcase
end
endmodule
