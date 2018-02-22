module test;

initial
begin
     $dumpfile("VCB4Re.vcd");
     $dumpvars(0,test);
     # 31 $finish;
end

reg clk = 0;
wire [3:0] out;
reg R = 0;
reg ce = 1;
wire TC;
wire CEO;
VCB4RE counter (ce, out, clk, TC, R, CEO);

always #1
begin
        clk = !clk;
        $monitor("Time step %t, clk = %0d, out = 0x%h, TC = 0x%h, CEO = 0x%h",
                 $stime, clk, out, TC, CEO);
end

endmodule
