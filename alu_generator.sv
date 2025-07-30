`include "defines.sv"

class alu_generator;

  alu_transaction blueprint;
  mailbox #(alu_transaction) mbx_gd;

  function new(mailbox #(alu_transaction) mbx_gd);
    this.mbx_gd = mbx_gd;
    blueprint = new();
  endfunction

  task start();
    for (int i = 0; i < `no_of_trans; i++) begin
      if (blueprint.randomize()) begin
        mbx_gd.put(blueprint.copy());
        $display("GENERATOR: OPA=%0d, OPB=%0d, CIN=%0d, CE=%0d, MODE=%0d, CMD=%0d, INP_VALID=%b @ %0t",
                  blueprint.OPA, blueprint.OPB, blueprint.CIN, blueprint.CE,
                  blueprint.MODE, blueprint.CMD, blueprint.INP_VALID, $time);
      end else begin
        $display("GENERATOR: Randomization failed at iteration %0d", i);
      end
    end
  endtask

endclass
