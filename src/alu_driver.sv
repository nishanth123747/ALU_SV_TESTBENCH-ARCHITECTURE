`include "defines.sv"

class alu_driver;
  alu_transaction drv_trans;
  mailbox #(alu_transaction) mbx_gd;
  mailbox #(alu_transaction) mbx_dr;
  virtual alu_if.DRV vif;
     bit flag;

  covergroup cg_drv;

    MODE_CP: coverpoint drv_trans.MODE {
      bins mode_0 = {0};
      bins mode_1 = {1};
    }

    CMD_CP: coverpoint drv_trans.CMD {
      bins cmd_vals[] = {[0:15]};
    }

    INP_VALID_CP: coverpoint drv_trans.INP_VALID {
      bins invalid = {2'b00};
      bins opa_valid = {2'b01};
      bins opb_valid = {2'b10};
      bins both_valid = {2'b11};

    }

    CE_CP: coverpoint drv_trans.CE {
      bins clock_enable[] = {[0:1]};

    }


    CIN_CP: coverpoint drv_trans.CIN {
      bins cin[] = {[0:1]};

    }

       CMO_CP: coverpoint drv_trans.CMD {
         bins cmd[] = {[0:15]};

    }

  CMD_ARTH_CP: coverpoint drv_trans.CMD iff(drv_trans.MODE == 1) {
    bins add        = {4'd0};
    bins sub        = {4'd1};
    bins add_cin    = {4'd2};
    bins sub_cin    = {4'd3};
    bins inc_a      = {4'd4};
    bins dec_a      = {4'd5};
    bins inc_b      = {4'd6};
    bins dec_b      = {4'd7};
    bins cmp_ab     = {4'd8};
    bins mul_inc    = {4'd9};
   bins mul_shift  = {4'd10};
    ignore_bins invalid ={[11:15]};
  }

 CMD_LOGIC_CP:coverpoint drv_trans.CMD iff (drv_trans.MODE == 0)
 {
bins and_op = {4'd0};
bins nand_op = {4'd1};
bins or_op = {4'd2};
bins nor_op = {4'd3};
bins xor_op = {4'd4};
bins xnor_op = {4'd5};
bins not_a = {4'd6};
bins not_b = {4'd7};
bins shr1_a = {4'd8};
bins shl1_a = {4'd9};
bins shr1_b = {4'd10};
bins shl1_b = {4'd11};
bins rol_a_b = {4'd12};
bins ror_a_b = {4'd13};
   ignore_bins invalid_cmd={[14:15]};
 }

OPA_CP: coverpoint drv_trans.OPA {
bins zero   = {0};
 bins smaller  = {[1 : (2**(`WIDTH/2))-1]};
bins largeer  = {[2**(`WIDTH/2) : (2**`WIDTH)-1]}; }

OPB_CP: coverpoint drv_trans.OPB {
bins zero   = {0};
 bins smaller  = {[1 : (2**(`WIDTH/2))-1]};
bins largeer  = {[2**(`WIDTH/2) : (2**`WIDTH)-1]}; }

 CMD_X_INP_VALID: cross drv_trans.CMD, drv_trans.INP_VALID;
 CMD_X_MODE: cross drv_trans.CMD, drv_trans.MODE;

  endgroup

  function new(mailbox #(alu_transaction) mbx_gd,
               mailbox #(alu_transaction) mbx_dr,
               virtual alu_if.DRV vif);
    this.mbx_gd = mbx_gd;
    this.mbx_dr = mbx_dr;
    this.vif    = vif;
    cg_drv =new();
  endfunction

  task start();
    $display("DRIVER started at %0t", $time);
    repeat(1) @(vif.drv_cb);

    for (int i = 0; i < `no_of_trans; i++) begin
      drv_trans = new();
      mbx_gd.get(drv_trans);


      // operation requires 2 operands
      if ((drv_trans.MODE == 1'b1 && drv_trans.CMD inside {0, 1, 2, 3, 8, 9, 10}) ||
          (drv_trans.MODE == 1'b0 && drv_trans.CMD inside {0, 1, 2, 3, 4, 5, 12, 13})) begin

        //2 operand operation with inp_valid(01 or 10)
        if (drv_trans.INP_VALID == 2'b01 || drv_trans.INP_VALID == 2'b10) begin
          vif.drv_cb.OPA        <= drv_trans.OPA;
          vif.drv_cb.OPB        <= drv_trans.OPB;
          vif.drv_cb.CIN        <= drv_trans.CIN;
          vif.drv_cb.MODE       <= drv_trans.MODE;
          vif.drv_cb.CE         <= drv_trans.CE;
          vif.drv_cb.CMD        <= drv_trans.CMD;
          vif.drv_cb.INP_VALID  <= drv_trans.INP_VALID;
          mbx_dr.put(drv_trans);
             cg_drv.sample();
          $display("DRIVER1: OPA=%0d, OPB=%0d, CIN=%0d, CE=%0d, MODE=%0d, CMD=%0d, INP_VALID=%b AT %0t",
                  drv_trans.OPA,  drv_trans.OPB, drv_trans.CIN,  drv_trans.CE,
                   drv_trans.MODE, drv_trans.CMD,  drv_trans.INP_VALID, $time);
          $display("Current Input Functional Coverage = %.2f%%", cg_drv.get_coverage());
          // disable randomization for CMD, CE, MODE
          drv_trans.CMD.rand_mode(0);
          drv_trans.CE.rand_mode(0);
          drv_trans.MODE.rand_mode(0);



          // wait to 16 cycles for INP_VALID = 11
          for (int j = 0; j < 16; j++) begin
            repeat(1)@(vif.drv_cb)//begin

            // randomize only INP_VALID and operands
              void'(drv_trans.randomize());
          vif.drv_cb.OPA        <= drv_trans.OPA;
          vif.drv_cb.OPB        <= drv_trans.OPB;
          vif.drv_cb.CIN        <= drv_trans.CIN;
          vif.drv_cb.INP_VALID  <= drv_trans.INP_VALID;
          mbx_dr.put(drv_trans);

            // if both operands are valid
            if (drv_trans.INP_VALID == 2'b11) begin
              flag = 1;
              break;
            end
          end
         // end
          // re-enable randomization
          drv_trans.CMD.rand_mode(1);
          drv_trans.CE.rand_mode(1);
          drv_trans.MODE.rand_mode(1);

          if (!flag) begin
            $display("INP_VALID=11 not received within 16 cycles");
          end
        end

 // two operand operation 11 and 00
        else if (drv_trans.INP_VALID == 2'b11 || drv_trans.INP_VALID == 2'b00) begin
          repeat(1) @(vif.drv_cb)begin
          vif.drv_cb.OPA        <= drv_trans.OPA;
          vif.drv_cb.OPB        <= drv_trans.OPB;
          vif.drv_cb.CIN        <= drv_trans.CIN;
          vif.drv_cb.MODE       <= drv_trans.MODE;
          vif.drv_cb.CE         <= drv_trans.CE;
          vif.drv_cb.CMD        <= drv_trans.CMD;
          vif.drv_cb.INP_VALID  <= drv_trans.INP_VALID;
            repeat(2) @(vif.drv_cb);
             cg_drv.sample();
            $display("DRIVER3:OPA=%0d, OPB=%0d, CIN=%0d, CE=%0d, MODE=%0d, CMD=%0d, INP_VALID=%b AT %0t",
                  drv_trans.OPA,  drv_trans.OPB, drv_trans.CIN,  drv_trans.CE,
                   drv_trans.MODE, drv_trans.CMD,  drv_trans.INP_VALID, $time);
             $display("Current Input Functional Coverage = %.2f%%", cg_drv.get_coverage());


          mbx_dr.put(drv_trans);
        end
      end
      end

      //  single operand operation
      else begin
          repeat(1) @(vif.drv_cb)begin
        vif.drv_cb.OPA        <= drv_trans.OPA;
        vif.drv_cb.OPB        <= drv_trans.OPB;
        vif.drv_cb.CIN        <= drv_trans.CIN;
        vif.drv_cb.MODE       <= drv_trans.MODE;
        vif.drv_cb.CE         <= drv_trans.CE;
        vif.drv_cb.CMD        <= drv_trans.CMD;
        vif.drv_cb.INP_VALID  <= drv_trans.INP_VALID;if (drv_trans.MODE == 1'b1 && (drv_trans.CMD == 4'd9 || drv_trans.CMD == 4'd10)) begin
          repeat(2) @(vif.drv_cb); // Extra cycle for multiply operations
          $display("DRIVER4 (MUL): Extra cycle wait for CMD=%0d at %0t", drv_trans.CMD, $time);
        end

             @(vif.drv_cb);
             cg_drv.sample();

            $display("DRIVER4:OPA=%0d, OPB=%0d, CIN=%0d, CE=%0d, MODE=%0d, CMD=%0d, INP_VALID=%b AT %0t",
                  drv_trans.OPA,  drv_trans.OPB, drv_trans.CIN,  drv_trans.CE,
                   drv_trans.MODE, drv_trans.CMD,  drv_trans.INP_VALID, $time);
             $display("Current Input Functional Coverage = %.2f%%", cg_drv.get_coverage());


        mbx_dr.put(drv_trans);
      end
    end
    end
    $display("DRIVER completed transactions at %0t", $time);
  endtask

endclass
