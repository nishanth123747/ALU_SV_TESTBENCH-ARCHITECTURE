`include "defines.sv"

class alu_transaction;
  rand bit [`WIDTH-1:0] OPA, OPB;
  rand bit   CIN;
  rand bit   CE;
  rand bit MODE;
  rand bit [1:0]        INP_VALID;
  rand bit [`CMD_WIDTH-1:0] CMD;
  bit [`WIDTH:0] RES;
  bit COUT, OFLOW, G, E, L, ERR;

  constraint cmd_base {
    CMD dist{[0:3],[8:10]};
  }

  constraint ce_base {
     CE inside { 1};
  }

  constraint mode_base {
     MODE inside { 1};
  }

  constraint inp_valid_base {
   INP_VALID inside {2'b11};
  }

  constraint opa_base {
    OPA inside {[0:(2**`WIDTH)-1]};
  }

  constraint opb_base {
     OPB inside {[0:(2**`WIDTH)-1]};
  }

  function new();
  endfunction

  virtual function alu_transaction copy();
    copy = new();
    copy.OPA        = this.OPA;
    copy.OPB        = this.OPB;
    copy.CIN        = this.CIN;
    copy.CE         = this.CE;
    copy.MODE       = this.MODE;
    copy.INP_VALID  = this.INP_VALID;
    copy.CMD        = this.CMD;
    return copy;
  endfunction
endclass

class alu_transaction1 extends alu_transaction;
   constraint logical__mode_cmd_c {
       CMD dist {[0:5]:=3,12:=2,13:=2};
       MODE inside {0};
       INP_VALID inside {3};
   }



  function new();
    super.new();
    cmd_base.constraint_mode(0);
    mode_base.constraint_mode(0);
   inp_valid_base.constraint_mode(0);

  endfunction

  virtual function alu_transaction copy();
    alu_transaction1 copy1;
    copy1 = new();
    copy1.OPA        = this.OPA;
    copy1.OPB        = this.OPB;
    copy1.CIN        = this.CIN;
    copy1.CE         = this.CE;
    copy1.MODE       = this.MODE;
    copy1.INP_VALID  = this.INP_VALID;
    copy1.CMD        = this.CMD;
    return copy1;
  endfunction
endclass

class alu_transaction2 extends alu_transaction;
     constraint single_op {
         INP_VALID inside {2'b01};
         if (MODE == 1)
         CMD inside {4, 5};
           else
           CMD inside {6, 8, 9};
                             }
 function new();
    super.new();
    // Turn off base constraints that conflict with this class's constraints
    cmd_base.constraint_mode(0);
    mode_base.constraint_mode(0);
    inp_valid_base.constraint_mode(0);
  endfunction

   virtual function alu_transaction copy();
    alu_transaction2 copy2;
    copy2 = new();
    copy2.OPA        = this.OPA;
    copy2.OPB        = this.OPB;
    copy2.CIN        = this.CIN;
    copy2.CE         = this.CE;
    copy2.MODE       = this.MODE;
    copy2.INP_VALID  = this.INP_VALID;
    copy2.CMD        = this.CMD;
    return copy2;
  endfunction
endclass

class alu_transaction3 extends alu_transaction;

    constraint single_op {
        INP_VALID inside {2'b10};
        MODE dist {1 := 50, 0 := 50};
            if (MODE == 1) {
             CMD inside {6, 7};
               } else {
                 CMD inside {7, 10, 11};
                                    }
    }

    function new();
    super.new();
    // Turn off base constraints that conflict with this class's constraints
    inp_valid_base.constraint_mode(0);
    cmd_base.constraint_mode(0);
    mode_base.constraint_mode(0);

  endfunction

  virtual function alu_transaction copy();
    alu_transaction3 copy3;
    copy3 = new();
    copy3.OPA        = this.OPA;
    copy3.OPB        = this.OPB;
    copy3.CIN        = this.CIN;
    copy3.CE         = this.CE;
    copy3.MODE       = this.MODE;
    copy3.INP_VALID  = this.INP_VALID;
    copy3.CMD        = this.CMD;
    return copy3;
  endfunction
endclass

class alu_transaction4 extends alu_transaction;

constraint inp_valid_invalid_c {
  INP_VALID dist {0:=1,1:=3,2:=3,3:=4};
  MODE  dist{1:=50,0:=50};
  CE dist{1:=50,0:=50};
  CIN dist{1:=50,1:=50};
}

  function new();
    super.new();
    // Turn off base constraints that conflict with this class's constraints
    inp_valid_base.constraint_mode(0);
    mode_base.constraint_mode(0);
      ce_base.constraint_mode(0);

  endfunction

  virtual function alu_transaction copy();
    alu_transaction4 copy4;
    copy4 = new();
    copy4.OPA        = this.OPA;
    copy4.OPB        = this.OPB;
    copy4.CIN        = this.CIN;
    copy4.CE         = this.CE;
    copy4.MODE       = this.MODE;
    copy4.INP_VALID  = this.INP_VALID;
    copy4.CMD        = this.CMD;
    return copy4;
  endfunction
endclass

class alu_transaction5 extends alu_transaction;

constraint cross_cmd_inp {
  CMD inside {[0:15]};
  INP_VALID dist {2'b00:=25,2'b01:=25, 2'b10:=25, 2'b11:=25};
}

constraint cross_opa_opb {
  OPA inside {[0:(2**`WIDTH)-1]};
  OPB inside {[0:(2**`WIDTH)-1]};
}

  function new();
    super.new();
    // Turn off base constraints that conflict with this class's constraints
    cmd_base.constraint_mode(0);
    inp_valid_base.constraint_mode(0);
    opa_base.constraint_mode(0);
    opb_base.constraint_mode(0);
  endfunction

  virtual function alu_transaction copy();
    alu_transaction5 copy5;
    copy5 = new();
    copy5.OPA        = this.OPA;
    copy5.OPB        = this.OPB;
    copy5.CIN        = this.CIN;
    copy5.CE         = this.CE;
    copy5.MODE       = this.MODE;
    copy5.INP_VALID  = this.INP_VALID;
    copy5.CMD        = this.CMD;
    return copy5;
  endfunction
endclass

class alu_transaction6 extends alu_transaction;

  constraint inp_valid_derived4 {
    INP_VALID inside {2'b00,2'b11};
  }

  constraint cmd_derived4 {
    CMD inside {0};
  }

  constraint ce_derived4 {
    CE inside {1};
  }

  constraint mode_derived4 {
    MODE inside {0};
  }

  function new();
    super.new();
    cmd_base.constraint_mode(0);
    inp_valid_base.constraint_mode(0);
    mode_base.constraint_mode(0);
    ce_base.constraint_mode(0);
  endfunction

  virtual function alu_transaction copy();
    alu_transaction6 copy6;
    copy6 = new();
    copy6.OPA        = this.OPA;
    copy6.OPB        = this.OPB;
    copy6.CIN        = this.CIN;
    copy6.CE         = this.CE;
    copy6.MODE       = this.MODE;
    copy6.INP_VALID  = this.INP_VALID;
    copy6.CMD        = this.CMD;
    return copy6;
  endfunction
endclass
