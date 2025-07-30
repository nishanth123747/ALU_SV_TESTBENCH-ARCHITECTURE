`include "defines.sv"
class alu_reference_model;
    alu_transaction ref_trans;
  mailbox #(alu_transaction) mbx_dr;
  mailbox #(alu_transaction) mbx_rs;
    virtual alu_if.REF_SB vif;

  function new(mailbox #(alu_transaction) mbx_dr,mailbox #(alu_transaction) mbx_rs,virtual alu_if.REF_SB vif);
        this.mbx_dr = mbx_dr;
        this.mbx_rs = mbx_rs;
        this.vif = vif;
    endfunction

    task start();
        ref_trans = new();
        for(int i = 0; i<`no_of_trans ; i++)begin
            mbx_dr.get(ref_trans);

           if(is_two_operand_operation(ref_trans))begin
                wait_for_valid_11(ref_trans);
            end

          else if(ref_trans.CMD == `MUL_IN || ref_trans.CMD == `MUL_S)begin
            repeat(2)@(vif.ref_cb);
                compute_result(ref_trans);
                display_and_send_result(ref_trans);
            end

            else begin
              @(vif.ref_cb);
                compute_result(ref_trans);
                display_and_send_result(ref_trans);
            end
        end
    endtask

    function bit is_two_operand_operation(alu_transaction ref_trans);
        if(ref_trans.MODE == 1'b1)begin
          if(ref_trans.INP_VALID == 2'b01 || ref_trans.INP_VALID == 2'b10)begin
                case(ref_trans.CMD)
                    `ADD,`SUB,`ADD_IN,`SUB_IN,`CMP,`MUL_IN,`MUL_S : return 1;
                  default : return 0;
                endcase
            end
        end

        else begin
          if(ref_trans.INP_VALID == 2'b01 || ref_trans.INP_VALID == 2'b10)begin
                case(ref_trans.CMD)
                    `AND,`NAND,`OR,`NOR,`XOR,`XNOR : return 1;
                  default : return 0;
                endcase
            end
        end
    endfunction

    task wait_for_valid_11(alu_transaction ref_trans);
        alu_transaction temp_trans;
        int cycle_count = 0;
        bit found_valid_11 = 1'b0;

      $display("Two operand operation detected with INP_VALID = %0d ,waiting for INP_VALID = 2'b11",ref_trans.INP_VALID);

        temp_trans = new();

      while(cycle_count < 16 && !found_valid_11)begin
            mbx_dr.get(temp_trans);
            cycle_count++;
            if(temp_trans.INP_VALID == 2'b11)begin
                $display("INP_VALID = 2'b11 received at cycle = %0d",cycle_count);
                found_valid_11 = 1'b1;
                compute_result(temp_trans);
                display_and_send_result(temp_trans);
                return;
            end

            else begin
                $display("Received INP_VALID = %0d at cycle = %0d,waiting for 11",temp_trans.INP_VALID,cycle_count);
            end
        end

      if(!found_valid_11 == 1'b0)begin
            $display("INP_VALID = 11 not found");
            temp_trans.RES = {`WIDTH+1{1'b0}};
            temp_trans.COUT = 1'b0;
            temp_trans.OFLOW = 1'b0;
            temp_trans.ERR = 1'b1;
            temp_trans.G = 1'b0;
            temp_trans.E = 1'b0;
            temp_trans.L = 1'b0;

          display_and_send_result(temp_trans);
        end
    endtask

    task display_and_send_result(alu_transaction ref_trans);

        $display("REFERENCE MODEL OUTPUT : INP_VALID = %0d, CE = %0d, CIN = %0d, OPA = %0d, OPB = %0d, CMD = %0d, MODE = %0d, RES = %0d, COUT  = %0d, ERR = %0d, OFLOW = %0d, G = %0d, E = %0d, L = %0d",ref_trans.INP_VALID,ref_trans.CE,ref_trans.CIN,ref_trans.OPA,ref_trans.OPB,ref_trans.CMD,ref_trans.MODE,ref_trans.RES,ref_trans.COUT,ref_trans.ERR,ref_trans.OFLOW,ref_trans.G,ref_trans.E,ref_trans.L);
        mbx_rs.put(ref_trans);

    endtask

    task compute_result(alu_transaction ref_trans);
      if(vif.ref_cb.RST == 1'b1)begin
          ref_trans.RES = {`WIDTH+1{1'bz}};
            ref_trans.COUT = 1'bz;
            ref_trans.ERR = 1'bz;
            ref_trans.OFLOW = 1'bz;
            ref_trans.G = 1'bz;
            ref_trans.E = 1'bz;
            ref_trans.L = 1'bz;
        end

      else if(ref_trans.CE == 1'b1)begin
        ref_trans.RES = {`WIDTH+1{1'bz}};
            ref_trans.COUT = 1'bz;
            ref_trans.ERR = 1'bz;
            ref_trans.OFLOW = 1'bz;
            ref_trans.G = 1'bz;
            ref_trans.E = 1'bz;
            ref_trans.L = 1'bz;
            if(ref_trans.MODE == 1'b1)begin
                if(ref_trans.INP_VALID == 2'b00)begin
                    ref_trans.ERR = 1'b1;
                end

              else if(ref_trans.INP_VALID == 2'b01)begin
                    case(ref_trans.CMD)
                        `INC_A : begin
                                    ref_trans.RES = ref_trans.OPA + 1;
                                    ref_trans.COUT = ref_trans.RES[`WIDTH];
                                 end
                        `DEC_A : begin
                                    ref_trans.RES = ref_trans.OPA - 1;
                                    ref_trans.OFLOW = (ref_trans.OPA == 0) ? 1'b1 : 1'b0;
                                 end
                        default : ref_trans.ERR = 1'b1;
                    endcase
                end

                else if(ref_trans.INP_VALID == 2'b10)begin
                    case(ref_trans.CMD)
                        `INC_B : begin
                                    ref_trans.RES = ref_trans.OPB + 1;
                                    ref_trans.COUT = ref_trans.RES[`WIDTH];
                                 end
                        `DEC_B : begin
                                    ref_trans.RES = ref_trans.OPB - 1;
                                    ref_trans.OFLOW = (ref_trans.OPB == 0) ? 1'b1 : 1'b0;
                                 end
                        default : ref_trans.ERR = 1'b1;
                    endcase
                end
                else if(ref_trans.INP_VALID == 2'b11)begin
                    case(ref_trans.CMD)
                          `ADD : begin
                                    ref_trans.RES = ref_trans.OPA + ref_trans.OPB;
                                    ref_trans.COUT = ref_trans.RES[`WIDTH];
                                 end
                          `SUB : begin
                                    ref_trans.RES = ref_trans.OPA - ref_trans.OPB;
                                    ref_trans.OFLOW = (ref_trans.OPA < ref_trans.OPB) ? 1'b1 : 1'b0;
                                 end
                      `ADD_IN : begin
                                    ref_trans.RES  = ref_trans.OPA + ref_trans.OPB + ref_trans.CIN;
                                    ref_trans.COUT = ref_trans.RES[`WIDTH];
                                 end
                      `SUB_IN : begin
                                    ref_trans.RES = ref_trans.OPA - ref_trans.OPB - ref_trans.CIN;
                                    ref_trans.OFLOW = (ref_trans.OPA < ref_trans.OPB || (ref_trans.OPA == ref_trans.OPB && ref_trans.CIN)) ? 1'b1 : 1'b0;
                                 end
                        `INC_A : begin
                                    ref_trans.RES = ref_trans.OPA + 1;
                          ref_trans.COUT = ref_trans.RES[`WIDTH];
                                 end
                        `DEC_A : begin
                                    ref_trans.RES = ref_trans.OPA - 1;
                                    ref_trans.OFLOW = (ref_trans.OPA == 0) ? 1'b1 : 1'b0;
                                 end
                        `INC_B : begin
                                    ref_trans.RES = ref_trans.OPB + 1;
                                    ref_trans.COUT = ref_trans.RES[`WIDTH];
                                 end
                        `DEC_A : begin
                                    ref_trans.RES = ref_trans.OPB - 1;
                                    ref_trans.OFLOW = (ref_trans.OPB == 0) ? 1'b1 : 1'b0;
                                 end
                         `CMP :  begin
                                    if(ref_trans.OPA == ref_trans.OPB)begin
                                          ref_trans.E = 1'b1;
                                    end
                                    else if(ref_trans.OPA > ref_trans.OPB)begin
                                          ref_trans.G = 1'b1;
                                    end
                                    else begin
                                          ref_trans.L = 1'b1;
                                    end
                                 end

                    `MUL_IN :   begin
                                    ref_trans.OPA = ref_trans.OPA + 1;
                                    ref_trans.OPB = ref_trans.OPB + 1;
                                    ref_trans.RES = ref_trans.OPA * ref_trans.OPB;
                                 end
                    `MUL_S : begin
                                    ref_trans.OPA = ref_trans.OPA << 1;
                                    ref_trans.RES = ref_trans.OPA * ref_trans.OPB;
                                 end
                       default : ref_trans.ERR = 1'b1;
                    endcase
                 end
                end
              else begin
                  if(ref_trans.INP_VALID == 2'b00)begin
                        ref_trans.ERR = 1'b1;
                  end
                  else if(ref_trans.INP_VALID == 2'b01)begin
                      case(ref_trans.CMD)
                         `NOT_A : begin
                                     ref_trans.RES = {1'b0,~(ref_trans.OPA)};
                                  end
                        `SHR1_A : begin
                                     ref_trans.RES = {1'b0,ref_trans.OPA >> 1};
                                  end
                        `SHL1_A : begin
                                     ref_trans.RES = {1'b0,ref_trans.OPA << 1};
                                  end
                          default : ref_trans.ERR = 1'b1;
                      endcase
                  end
                  else if(ref_trans.INP_VALID == 2'b10)begin
                      case(ref_trans.CMD)
                         `NOT_B : begin
                                     ref_trans.RES = {1'b0,~(ref_trans.OPB)};
                                  end
                        `SHR1_B : begin
                                     ref_trans.RES = {1'b0,ref_trans.OPB >> 1};
                                  end
                        `SHL1_B : begin
                                     ref_trans.RES = {1'b0,ref_trans.OPB << 1};
                                  end
                        default : ref_trans.ERR = 1'b1;
                      endcase
                  end
                  else if(ref_trans.INP_VALID == 2'b11)begin
                      case(ref_trans.CMD)
                         `AND : begin
                                   ref_trans.RES = {1'b0,ref_trans.OPA & ref_trans.OPB};
                                end
                        `NAND : begin
                                   ref_trans.RES = {1'b0,~(ref_trans.OPA & ref_trans.OPB)};
                                end
                          `OR : begin
                                   ref_trans.RES = {1'b0,ref_trans.OPA | ref_trans.OPB};
                                end
                         `NOR : begin
                                   ref_trans.RES = {1'b0,~(ref_trans.OPA | ref_trans.OPB)};
                                end
                         `XOR : begin
                                   ref_trans.RES = {1'b0,ref_trans.OPA ^ ref_trans.OPB};
                                end
                        `XNOR : begin
                                   ref_trans.RES = {1'b0,~(ref_trans.OPA ^ ref_trans.OPB)};
                                end
                        `NOT_A :begin
                                   ref_trans.RES = {1'b0,~(ref_trans.OPA)};
                                end
                      `SHR1_A : begin
                                   ref_trans.RES = {1'b0,ref_trans.OPA >> 1};
                                end
                      `SHL1_A : begin
                                   ref_trans.RES = {1'b0,ref_trans.OPA << 1};
                                end
                        `NOT_B :begin
                                   ref_trans.RES = {1'b0,~(ref_trans.OPB)};
                                end
                      `SHR1_B : begin
                                   ref_trans.RES = {1'b0,ref_trans.OPB >> 1};
                                end
                      `SHL1_B : begin
                                   ref_trans.RES = {1'b0,ref_trans.OPB << 1};
                                end
                     `ROL : begin
                                   ref_trans.RES = {1'b0,(ref_trans.OPA << ref_trans.OPB[`ROR_WIDTH-1:0] | ref_trans.OPA >> (`WIDTH - (ref_trans.OPB[`ROR_WIDTH-1])))};
                                   ref_trans.ERR = (ref_trans.OPB > {`ROR_WIDTH + 1{1'b1}});
                                end
                     `ROR : begin
                                   ref_trans.ERR = {1'b0,(ref_trans.OPA >> ref_trans.OPB[`ROR_WIDTH -1:0] | ref_trans.OPA << (`WIDTH - (ref_trans.OPB[`ROR_WIDTH -1])))};
                                   ref_trans.ERR = (ref_trans.OPB > {`ROR_WIDTH + 1{1'b1}});
                                end
                        default : ref_trans.ERR = 1'b1;
                      endcase
                  end
         end
         //else begin
           //   default : ref_trans.ERR = 1'b1;

         //end
      end
    endtask
endclass
