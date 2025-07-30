`include "alu_design.sv"
`include "alu_pkg.sv"
`include "alu_interface.sv"

module top;

  import alu_pkg::*;

  bit CLK;
  bit RST;


  initial begin
    CLK = 0;
    forever #5 CLK = ~CLK;
  end

  initial begin
   $dumpfile("waveform.vcd");
   $dumpvars(1, top);
end


  initial begin
     @(posedge CLK);
    RST = 1;
    repeat(2) @(posedge CLK);
    RST = 0;
  end


  alu_if intrf(CLK, RST);


  alu DUV(
    .OPA       (intrf.OPA),
    .OPB       (intrf.OPB),
    .CIN       (intrf.CIN),
    .CE        (intrf.CE),
    .MODE      (intrf.MODE),
    .CLK       (CLK),
    .RST       (RST),
    .CMD       (intrf.CMD),
    .INP_VALID (intrf.INP_VALID),
    .COUT      (intrf.COUT),
    .OFLOW     (intrf.OFLOW),
    .G         (intrf.G),
    .E         (intrf.E),
    .L         (intrf.L),
    .ERR       (intrf.ERR),
    .RES       (intrf.RES)
  );


  alu_test tb = new(intrf.DRV, intrf.MON, intrf.REF_SB);
  test_regression tb_regression = new(intrf.DRV,intrf.MON,intrf.REF_SB);
  alu_test1 tb1=new(intrf.DRV,intrf.MON,intrf.REF_SB);
  alu_test2 tb2=new(intrf.DRV,intrf.MON,intrf.REF_SB);
  alu_test3 tb3=new(intrf.DRV,intrf.MON,intrf.REF_SB);
  alu_test4 tb4=new(intrf.DRV,intrf.MON,intrf.REF_SB);
   alu_test5 tb5=new(intrf.DRV,intrf.MON,intrf.REF_SB);
  alu_test6 tb6=new(intrf.DRV,intrf.MON,intrf.REF_SB);

    initial begin
      $display("=== ALU TEST BENCH STARTED ===");
      tb_regression.run();
      tb.run();
      $display("=== ALU TEST BENCH COMPLETED ===");
      $finish();
    end

endmodule
