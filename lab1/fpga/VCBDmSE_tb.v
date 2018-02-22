module test;

initial
begin
     $dumpfile("VCBDmSE.vcd");
     $dumpvars(0, test);
     # 32 $finish;
end

reg clk = 0;
wire [3:0] out;
reg s = 0;
reg ce = 1;
wire TC;
wire CEO;
VCBDmSE counter (ce, out, clk, TC, s, CEO);

always #1
begin
        clk = !clk;
        $monitor("Time step %t, clk = %0d, out = 0x%h, TC = 0x%h, CEO = 0x%h",
                 $stime, clk, out, TC, CEO);
end

endmodule
