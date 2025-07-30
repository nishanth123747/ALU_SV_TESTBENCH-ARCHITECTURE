`include "defines.sv"

class alu_scoreboard;
   alu_transaction ref2sb_trans, mon2sb_trans;
   mailbox #(alu_transaction) mbx_rs; // from ref model
   mailbox #(alu_transaction) mbx_ms; // from monitor

   // Overall counters only
   static int MATCH, MISMATCH ;
   static int total_transactions;

   function new(mailbox #(alu_transaction) mbx_rs,
                mailbox #(alu_transaction) mbx_ms);
      this.mbx_rs = mbx_rs;
      this.mbx_ms = mbx_ms;
   endfunction

   task start();
     for (int i = 0; i < `no_of_trans; i++) begin
       ref2sb_trans = new();
       mon2sb_trans = new();

       fork
         begin
           mbx_rs.get(ref2sb_trans);
           $display("[SCOREBOARD: REF] RES=%0d COUT=%0d OFLOW=%0d ERR=%0d E=%0d L=%0d G=%0d @%0t",
                    ref2sb_trans.RES, ref2sb_trans.COUT, ref2sb_trans.OFLOW,
                    ref2sb_trans.ERR, ref2sb_trans.E, ref2sb_trans.L,
                    ref2sb_trans.G, $time);
         end
         begin
           mbx_ms.get(mon2sb_trans);
           $display("[SCOREBOARD: MON] RES=%0d COUT=%0d OFLOW=%0d ERR=%0d E=%0d L=%0d G=%0d @%0t",
                    mon2sb_trans.RES, mon2sb_trans.COUT, mon2sb_trans.OFLOW,
                    mon2sb_trans.ERR, mon2sb_trans.E, mon2sb_trans.L,
                    mon2sb_trans.G, $time);
         end
       join

       total_transactions++;
       compare_report();
     end

     // Print final summary
     print_final_summary();
   endtask

   task compare_report();
     if (ref2sb_trans.RES   == mon2sb_trans.RES   &&
         ref2sb_trans.COUT  == mon2sb_trans.COUT  &&
         ref2sb_trans.OFLOW == mon2sb_trans.OFLOW &&
         ref2sb_trans.ERR   == mon2sb_trans.ERR   &&
         ref2sb_trans.E     == mon2sb_trans.E     &&
         ref2sb_trans.L     == mon2sb_trans.L     &&
         ref2sb_trans.G     == mon2sb_trans.G) begin
       MATCH++;
       $display("[MATCH] Outputs matched successfully. MATCH COUNT = %0d\n", MATCH);
     end else begin
       MISMATCH++;
       $display("[MISMATCH] Outputs mismatch. MISMATCH COUNT = %0d", MISMATCH);
       $display("  REF: RES=%0d COUT=%0d OFLOW=%0d ERR=%0d E=%0d L=%0d G=%0d",
                ref2sb_trans.RES, ref2sb_trans.COUT, ref2sb_trans.OFLOW,
                ref2sb_trans.ERR, ref2sb_trans.E, ref2sb_trans.L, ref2sb_trans.G);
       $display("  MON: RES=%0d COUT=%0d OFLOW=%0d ERR=%0d E=%0d L=%0d G=%0d\n",
                mon2sb_trans.RES, mon2sb_trans.COUT, mon2sb_trans.OFLOW,
                mon2sb_trans.ERR, mon2sb_trans.E, mon2sb_trans.L, mon2sb_trans.G);
     end
   endtask

   task print_final_summary();
     real success_rate = (total_transactions > 0) ?
                        (real'(MATCH) / real'(total_transactions)) * 100.0 : 0.0;

     $display("=== FINAL SCOREBOARD REPORT ===");
     $display("TOTAL TRANSACTIONS = %0d", total_transactions);
     $display("TOTAL MATCHES      = %0d", MATCH);
     $display("TOTAL MISMATCHES   = %0d", MISMATCH);
     $display("SUCCESS RATE       = %.2f%%", success_rate);

     if (MISMATCH == 0) begin
       $display("TEST PASSED: All transactions matched!");
     end else
         $display("TEST FAILED: All transactions matched!");
   endtask

endclass
