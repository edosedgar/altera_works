module test;

initial
begin
     $dumpfile("VCBDmCLED.vcd");
     $dumpvars(0, test);
     # 30 up = 0;
     # 30 $finish;
end

reg clk = 0;
wire [3:0] out;
reg s = 0;
reg ce = 1;
reg up = 1;
reg [3:0] di = 0;
reg L = 0;
reg clr = 0;
wire TC;
wire CEO;
VCBmCLED counter (ce, out, up, CEO, di, TC, L, clk, clr);

always #1
begin
        clk = !clk;
        $monitor("Time step %t, clk = %0d, out = 0x%h, TC = 0x%h, CEO = 0x%h, up = 0x%h",
                 $stime, clk, out, TC, CEO, up);
end

endmodule
