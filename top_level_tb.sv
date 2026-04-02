    import instruction_pkg::*;

module tbench();
    logic clk;

    logic reset;

    logic[0:6] even_ra_addr;
    logic[0:6] even_rb_addr;
    logic[0:6] even_rc_addr;
    logic[0:6] even_rt_addr;
    instruction_type even_instruction_type;
    opcode_t even_opcode;
    logic even_register_write;
    logic[0:2] even_unit_id;
    logic[0:10] even_program_counter;
    logic[0:17] even_immediate;

    logic[0:6] odd_ra_addr;
    logic[0:6] odd_rb_addr;
    logic[0:6] odd_rc_addr;
    logic[0:6] odd_rt_addr;
    instruction_type odd_instruction_type;
    opcode_t odd_opcode;
    logic odd_register_write;
    logic[0:2] odd_unit_id;
    logic[0:10] odd_program_counter;
    logic[0:17] odd_immediate;

top_level dut(
    .clk(clk),
    .reset(reset),

    .even_ra_addr(even_ra_addr),
    .even_rb_addr(even_rb_addr),
    .even_rc_addr(even_rc_addr),
    .even_rt_addr(even_rt_addr),
    .even_instruction_type(even_instruction_type),
    .even_opcode(even_opcode),
    .even_unit_id(even_unit_id),
    .even_program_counter(even_program_counter),
    .even_immediate(even_immediate),

    .odd_ra_addr(odd_ra_addr),
    .odd_rb_addr(odd_rb_addr),
    .odd_rc_addr(odd_rc_addr),
    .odd_rt_addr(odd_rt_addr),
    .odd_instruction_type(odd_instruction_type),
    .odd_opcode(odd_opcode),
    .odd_unit_id(odd_unit_id),
    .odd_program_counter(odd_program_counter),
    .odd_immediate(odd_immediate)
);

/* Clock generation */

initial clk = 0;
always #5 clk = ~clk; //toggles clk

/*  TESTING     */
initial begin
      // Monitor key signals
      $monitor($time,
         " | EvenRA=%0d EvenRB=%0d | EvenRC=%0d EvenRT=%0d | EvenOpcode=%0d",
        even_ra_addr,
        even_rb_addr,
        even_rc_addr,
        even_rt_addr,
        even_opcode, 
      );

    /*  Initialize signals */
    reset = 1;
    repeat (2) @(posedge clk);
    reset = 0;

    @(negedge clk);
    // Load some value into r2
    even_ra_addr = 1;
    //even_rb_addr = 2;
    //even_rc_addr = 3;
    even_rt_addr = 2;
    even_opcode = OP_IMMEDIATE_LOAD_WORD;
    even_unit_id = 1;
    even_immediate = 5;

    even_instruction_type = RI16;
   
   
    @(negedge clk);
    



    // Load some value into r4
  
    even_ra_addr = 3;
    //even_rb_addr = 6;
    //even_rc_addr = 7;
    even_rt_addr = 4;
    even_opcode = OP_IMMEDIATE_LOAD_WORD;
    even_unit_id = 1;
    even_immediate = 8;

    even_instruction_type = RI16;

    repeat (3) @(negedge clk);

    // Add the two values
   /*Simple Fixed 1 Instructions */

    // even_ra_addr = 7; 
    // //even_rb_addr = 4; //2
    // even_rc_addr = 4;
    // //even_rt_addr = 5;
    // even_opcode = OP_STORE_QUADWORD_D;
    // even_unit_id = 1;
    // even_immediate = 0;

    // even_instruction_type = RR;

 /*Local Store Instructions */
    odd_ra_addr = 7; 
    //even_rb_addr = 4; //2
    odd_rc_addr = 4;
    //even_rt_addr = 5;
    odd_opcode = OP_STORE_QUADWORD_D;
    odd_unit_id = 6;
    odd_immediate = 0;

    odd_instruction_type = RI10;

    repeat (20) @(posedge clk);
    

    // @(posedge clk);
    // @(posedge clk);
    // reset = 0;
    // odd_ra_addr = 7;
    // //even_rb_addr = 6;
    // odd_rc_addr = 8;
    // //even_rt_addr = 16;
    // odd_opcode = OP_STORE_QUADWORD_D;
    // odd_unit_id = 6;
    // odd_immediate = 0;

    // odd_instruction_type = RI10;
   
    // @(posedge clk);
    // @(posedge clk);
    // reset = 0;
    // odd_ra_addr = 9;
    // odd_program_counter = 2;
    // //even_rb_addr = 6;
    // odd_rc_addr = 10;
    // //even_rt_addr = 16;
    // odd_opcode = OP_BRANCH_RELATIVE;
    // odd_unit_id = 7;
    // odd_immediate = 3;

    // odd_instruction_type = RI16;

  

    $finish;
   
   

  

//    @(posedge clk);
//       // =====================
//       // Finish
//       // =====================
//       @(posedge clk);
//       $finish;
//    end

end

endmodule