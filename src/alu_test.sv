`include "defines.sv"

class alu_test;
  virtual alu_if drv_vif;
  virtual alu_if mon_vif;
  virtual alu_if ref_vif;
  alu_environment env;

  function new(virtual alu_if drv_vif,
               virtual alu_if mon_vif,
               virtual alu_if ref_vif);
    this.drv_vif = drv_vif;
    this.mon_vif = mon_vif;
    this.ref_vif = ref_vif;
  endfunction

  task run();
    env = new(drv_vif, mon_vif, ref_vif);
    env.build();
    env.start();
  endtask
endclass

class alu_test1 extends alu_test;
  alu_transaction1 trans;

  function new(virtual alu_if drv_vif,
               virtual alu_if mon_vif,
               virtual alu_if ref_vif);
    super.new(drv_vif,mon_vif,ref_vif);
  endfunction

  task run();
    env = new(drv_vif, mon_vif, ref_vif);
    env.build();
    trans = new();
    env.gen.blueprint = trans;
    env.start();
  endtask
endclass

class alu_test2 extends alu_test;
  alu_transaction2 trans;

  function new(virtual alu_if drv_vif,
               virtual alu_if mon_vif,
               virtual alu_if ref_vif);
    super.new(drv_vif,mon_vif,ref_vif);
  endfunction

  task run();
    env = new(drv_vif, mon_vif, ref_vif);
    env.build();
    trans = new();
    env.gen.blueprint = trans;
    env.start();
  endtask
endclass

class alu_test3 extends alu_test;
  alu_transaction3 trans;

  function new(virtual alu_if drv_vif,
               virtual alu_if mon_vif,
               virtual alu_if ref_vif);
    super.new(drv_vif,mon_vif,ref_vif);
  endfunction

  task run();
    env = new(drv_vif, mon_vif, ref_vif);
    env.build();
    trans = new();
    env.gen.blueprint = trans;
    env.start();
  endtask
endclass

class alu_test4 extends alu_test;
  alu_transaction4 trans;

  function new(virtual alu_if drv_vif,
               virtual alu_if mon_vif,
               virtual alu_if ref_vif);
    super.new(drv_vif,mon_vif,ref_vif);
  endfunction

  task run();
    env = new(drv_vif, mon_vif, ref_vif);
    env.build();
    trans = new();
    env.gen.blueprint = trans;
    env.start();
  endtask
endclass

class alu_test5 extends alu_test;
  alu_transaction5 trans;

  function new(virtual alu_if drv_vif,
               virtual alu_if mon_vif,
               virtual alu_if ref_vif);
    super.new(drv_vif,mon_vif,ref_vif);
  endfunction

  task run();
    env = new(drv_vif, mon_vif, ref_vif);
    env.build();
    trans = new();
    env.gen.blueprint = trans;
    env.start();
  endtask
endclass

class alu_test6 extends alu_test;
  alu_transaction6 trans;

  function new(virtual alu_if drv_vif,
               virtual alu_if mon_vif,
               virtual alu_if ref_vif);
    super.new(drv_vif,mon_vif,ref_vif);
  endfunction

  task run();
    env = new(drv_vif, mon_vif, ref_vif);
    env.build();
    trans = new();
    env.gen.blueprint = trans;
    env.start();
  endtask
endclass

class test_regression extends alu_test;
  alu_transaction trans0;
  alu_transaction1 trans1;
  alu_transaction2 trans2;
  alu_transaction3 trans3;
  alu_transaction4 trans4;
  alu_transaction5 trans5;
  alu_transaction6 trans6;
  function new(virtual alu_if drv_vif,
               virtual alu_if mon_vif,
               virtual alu_if ref_vif);
    super.new(drv_vif,mon_vif,ref_vif);
  endfunction

  task run();

  //test 1
    env = new(drv_vif, mon_vif, ref_vif);
    env.build();
    trans0 = new();
    env.gen.blueprint = trans0;
    env.start();

   // repeat(10) @(posedge drv_vif.CLK);

    // Test 2

    env = new(drv_vif, mon_vif, ref_vif);
    env.build();
    trans1 = new();
    env.gen.blueprint = trans1;
    env.start();



    //test 3

    env = new(drv_vif, mon_vif, ref_vif);
    env.build();
    trans2 = new();
    env.gen.blueprint = trans2;
    env.start();



    // test 4

    env = new(drv_vif, mon_vif, ref_vif);
    env.build();
    trans3 = new();
    env.gen.blueprint = trans3;
    env.start();
    //test 5

    env = new(drv_vif, mon_vif, ref_vif);
    env.build();
    trans4 = new();
    env.gen.blueprint = trans4;
    env.start();
    //test 6

    env = new(drv_vif, mon_vif, ref_vif);
    env.build();
    trans5 = new();
    env.gen.blueprint = trans5;
    env.start();

    //test 7
       env = new(drv_vif, mon_vif, ref_vif);
    env.build();
    trans6 = new();
    env.gen.blueprint = trans6;
    env.start();

    $display("=== REGRESSION TEST COMPLETED ===");
  endtask
endclass
