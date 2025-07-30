`include "defines.sv"
interface alu_if (input bit CLK ,input bit RST);

  logic CE, CIN, MODE;
  logic [1:0] INP_VALID;
  logic [`WIDTH-1:0] OPA, OPB;
  logic [`CMD_WIDTH-1:0] CMD;
  logic ERR, OFLOW, COUT, G, L, E;

  clocking drv_cb @(posedge CLK);
    default input #0 output #0;

    output INP_VALID, MODE, CMD, CE, OPA, OPB, CIN;
  endclocking


  clocking mon_cb @(posedge CLK);
    default input #0 output #0;
    input ERR, OFLOW, COUT, G, L, E, RES;
  endclocking


  clocking ref_cb @(posedge CLK);
    default input #0 output #0;
    input RST;
  endclocking


  modport DRV(clocking drv_cb);
  modport MON(clocking mon_cb);
    modport REF_SB(clocking ref_cb,input RST);
    //1.RESET
property RESET_BEHAVIOR;
  @(posedge CLK) RST |-> ##1(RES === {(`WIDTH+1){1'bz}} && COUT === 1'bz &&
                              OFLOW === 1'bz && G === 1'bz && L === 1'bz &&
                              E === 1'bz);
endproperty
assert property (RESET_BEHAVIOR) else $error("Reset behavior failed");


    //2. ROR/ROL error
    assert property (@(posedge CLK) disable iff(RST) (CE && MODE && (CMD == `ROR|| CMD == `ROL) && $countones(OPB) > 4) |=> ##[1:3] ERR )
        $display("ROR ERROR assertion PASSED at time %0t", $time);
    else
        $info("NO ERROR FLAG RAISED");

    //3. CMD out of range
    assert property (@(posedge CLK) (MODE && CMD > 10) |=> ERR)
        $display("CMD out of range for arithmetic assertion PASSED at time %0t", $time);
    else
        $info("CMD INVALID ERR NOT RAISED");

    //4. CMD out of range logical
    assert property (@(posedge CLK) (!MODE && CMD > 13) |=> ERR)
        $display("CMD out of range for logical assertion PASSED at time %0t", $time);
    else
        $info("CMD INVALID ERR NOT RAISED");
    // 5. INP_VALID 00 case
    assert property (@(posedge CLK) (INP_VALID == 2'b00) |=> ERR )
        $display("INP_VALID 00  assertion PASSED at time %0t", $time);
    else
        $info("ERROR NOT raised");
endinterface
