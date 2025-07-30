`include "defines.sv"

class alu_monitor;
  alu_transaction mon_trans;
  mailbox #(alu_transaction) mbx_ms;
  virtual alu_if.MON vif;


  covergroup cg_mon;
    RESULT_CP: coverpoint mon_trans.RES {
      bins result[] = {[0 : (2**`WIDTH)-1]};
    }

    COUT_CP: coverpoint mon_trans.COUT {
      bins cout[] = {0, 1};
    }

    OFLOW_CP: coverpoint mon_trans.OFLOW {
      bins overflow[] = {0, 1};
    }

    E_CP: coverpoint mon_trans.E {
      bins equal[] = {0, 1};
    }

    G_CP: coverpoint mon_trans.G {
      bins greater[] = {0, 1};
    }

    L_CP: coverpoint mon_trans.L {
      bins less[] = {0, 1};
    }

    ERR_CP: coverpoint mon_trans.ERR {
      bins error[] = {0, 1};
    }
  endgroup

  function new(virtual alu_if.MON vif, mailbox #(alu_transaction) mbx_ms);
    this.mbx_ms = mbx_ms;
    this.vif = vif;
    cg_mon = new();
  endfunction

  task start();
    repeat(3) @(vif.mon_cb);

    for (int i = 0; i < `no_of_trans; i++) begin
      mon_trans = new();
      repeat(2) @(vif.mon_cb);

      $display("monitor start", $time);


      mon_trans.RES   = vif.mon_cb.RES;
      mon_trans.COUT  = vif.mon_cb.COUT;
      mon_trans.OFLOW = vif.mon_cb.OFLOW;
      mon_trans.ERR   = vif.mon_cb.ERR;
      mon_trans.E     = vif.mon_cb.E;
      mon_trans.L     = vif.mon_cb.L;
      mon_trans.G     = vif.mon_cb.G;


      cg_mon.sample();

      $display("MONITOR passing data to SCOREBOARD: RES=%0d, ERR=%0d, OFLOW=%0d,                                                                                                              COUT=%0d, G=%0d, L=%0d, E=%0d AT %0t",
               mon_trans.RES, mon_trans.ERR, mon_trans.OFLOW,
               mon_trans.COUT, mon_trans.G, mon_trans.L, mon_trans.E, $time);
 @(vif.mon_cb);

      mbx_ms.put(mon_trans);
      $display("Output Functional Coverage = %.2f%%", cg_mon.get_coverage());
    end
  endtask
endclass
