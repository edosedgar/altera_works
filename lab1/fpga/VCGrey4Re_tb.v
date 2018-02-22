module test;

initial
begin
     $dumpfile("VCGrey4Re.vcd");
     $dumpvars(0, test);
     # 30 $finish;
end

reg ce = 1;
wire TC;
reg clk = 0;
wire CEO;
reg R = 0;
wire [3:0] out;
VCGrey4RE counter (clk, out, ce, CEO, R, TC);

always #1
begin
        clk = !clk;
        $monitor("Time step %t, clk = %0d, out = 0x%h, TC = 0x%h, CEO = 0x%h",
                 $stime, clk, out, TC, CEO);
end

endmodule
