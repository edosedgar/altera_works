module seven_seg
(
        input            i_sys_clk,
        input [15:0]     i_digit,
        output reg [3:0] o_scathod,
        output reg [6:0] o_ssegment
);

reg [3:0] out_seg          = 4'd0;
reg [11:0] dyn_indic_count = 12'd0;
reg [1:0] showing_digit    = 2'd0;

always @(posedge i_sys_clk)
begin
        dyn_indic_count <= dyn_indic_count + 12'd1;
        if (dyn_indic_count == 12'b1111_1111_1111)
        begin
                showing_digit <= showing_digit + 2'd1;
        end
        case (showing_digit)
        2'b00:
        begin
                out_seg <= i_digit[3:0];
                o_scathod <= 4'b0111;
        end
        2'b01:
        begin
                out_seg <= i_digit[7:4];
                o_scathod <= 4'b1011;
        end
        2'b10:
        begin
                out_seg <= i_digit[11:8];
                o_scathod <= 4'b1101;
        end
        2'b11:
        begin
                out_seg <= i_digit[15:12];
                o_scathod <= 4'b1110;
        end
        endcase
end

always @(*)
begin
        case (out_seg)
        //                      GFEDCBA
        4'h0: o_ssegment <= ~7'b0111111;
        4'h1: o_ssegment <= ~7'b0000110;
        4'h2: o_ssegment <= ~7'b1011011;
        4'h3: o_ssegment <= ~7'b1001111;
        4'h4: o_ssegment <= ~7'b1100110;
        4'h5: o_ssegment <= ~7'b1101101;
        4'h6: o_ssegment <= ~7'b1111101;
        4'h7: o_ssegment <= ~7'b0000111;
        4'h8: o_ssegment <= ~7'b1111111;
        4'h9: o_ssegment <= ~7'b1101111;
        4'ha: o_ssegment <= ~7'b1110111;
        4'hb: o_ssegment <= ~7'b1111100;
        4'hc: o_ssegment <= ~7'b0111001;
        4'hd: o_ssegment <= ~7'b1011110;
        4'he: o_ssegment <= ~7'b1111001;
        4'hf: o_ssegment <= ~7'b1110001;
        endcase
end
endmodule
