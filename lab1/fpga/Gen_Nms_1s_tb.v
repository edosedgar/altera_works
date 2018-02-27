module test;

initial
begin
     $dumpfile("Gen_Nms_1s.vcd");
     $dumpvars(0, test);
     # 50000000000 $finish;
end

reg clk = 0;
reg key = 0;
wire out;
countpro counter (clk, key, out);

always #1
begin
        clk = !clk;
        //$monitor("Time step %t, clk = %0d, out = 0x%h, TC = 0x%h, CEO = 0x%h",
        //         $stime, clk, out, TC, CEO);
end

endmodule
