`include "defines.sv"

class alu_environment;


  virtual alu_if.DRV drv_vif;
  virtual alu_if.MON mon_vif;
  virtual alu_if.REF_SB ref_vif;

  mailbox #(alu_transaction) mbx_gd;
  mailbox #(alu_transaction) mbx_dr;
  mailbox #(alu_transaction) mbx_rs;
  mailbox #(alu_transaction) mbx_ms;

  alu_generator           gen;
  alu_driver              drv;
  alu_monitor             mon;
  alu_reference_model     ref_sb;
  alu_scoreboard          scb;


  function new (virtual alu_if.DRV drv_vif,
                virtual alu_if.MON mon_vif,
                virtual alu_if.REF_SB ref_vif);
    this.drv_vif = drv_vif;
    this.mon_vif = mon_vif;
    this.ref_vif = ref_vif;
  endfunction

  task build();
    mbx_gd = new();
    mbx_dr = new();
    mbx_rs = new();
    mbx_ms = new();

    gen    = new(mbx_gd);
    drv    = new(mbx_gd, mbx_dr, drv_vif);
    mon    = new(mon_vif, mbx_ms);
    ref_sb = new(mbx_dr, mbx_rs, ref_vif);
    scb    = new(mbx_rs, mbx_ms);
  endtask

  task start();
    fork
      gen.start();
      drv.start();
      mon.start();
      ref_sb.start();
      scb.start();
    join

    scb.compare_report();
  endtask

endclass
