import instruction_pkg::*;

module tbench();
    logic clk;

    logic reset;

    // logic[0:6] even_ra_addr;
    // logic[0:6] even_rb_addr;
    // logic[0:6] even_rc_addr;
    // logic[0:6] even_rt_addr;
    // instruction_type even_instruction_type;
    // opcode_t even_opcode;
    // logic even_register_write;
    // logic[0:2] even_unit_id;
    // logic[0:10] even_program_counter;
    // logic[0:17] even_immediate;

    // logic[0:6] odd_ra_addr;
    // logic[0:6] odd_rb_addr;
    // logic[0:6] odd_rc_addr;
    // logic[0:6] odd_rt_addr;
    // instruction_type odd_instruction_type;
    // opcode_t odd_opcode;
    // logic odd_register_write;
    // logic[0:2] odd_unit_id;
    // logic[0:10] odd_program_counter;
    // logic[0:17] odd_immediate;

top_level dut(
    .clk(clk),
    .reset(reset)

    // .even_ra_addr(even_ra_addr),
    // .even_rb_addr(even_rb_addr),
    // .even_rc_addr(even_rc_addr),
    // .even_rt_addr(even_rt_addr),
    // .even_instruction_type(even_instruction_type),
    // .even_opcode(even_opcode),
    // .even_unit_id(even_unit_id),
    // .even_reg_write(even_register_write),
    // .even_program_counter(even_program_counter),
    // .even_immediate(even_immediate),

    // .odd_ra_addr(odd_ra_addr),
    // .odd_rb_addr(odd_rb_addr),
    // .odd_rc_addr(odd_rc_addr),
    // .odd_rt_addr(odd_rt_addr),
    // .odd_instruction_type(odd_instruction_type),
    // .odd_opcode(odd_opcode),
    // .odd_unit_id(odd_unit_id),
    // .odd_reg_write(odd_register_write),
    // .odd_program_counter(odd_program_counter),
    // .odd_immediate(odd_immediate)
);

/* Clock generation */

initial clk = 0;
always #5 clk = ~clk; //toggles clk

/*  TESTING     */
initial begin
    //   // Monitor key signals
    //   $monitor($time,
    //      " | EvenRA=%0d EvenRB=%0d | EvenRC=%0d EvenRT=%0d | EvenOpcode=%0d",
    //     even_ra_addr,
    //     even_rb_addr,
    //     even_rc_addr,
    //     even_rt_addr,
    //     even_opcode, 
    //   );

    /*  Initialize signals */
    reset = 1;
    repeat (2) @(posedge clk);
    reset = 0;

    // @(posedge clk);
    // reset = 0;
    // even_ra_addr = 3;
    // //even_rb_addr = 6;
    // //even_rc_addr = 7;
    // even_rt_addr = 1;
    // even_opcode = OP_IMMEDIATE_LOAD_WORD;
    // even_unit_id = 1;
    // even_immediate = 8;
    // even_instruction_type = RI16;

    // @(posedge clk);
    // reset = 0;
    // //even_ra_addr = 3;
    // even_rb_addr = 1;
    // //even_rc_addr = 7;
    // even_rt_addr = 2;
    // even_opcode = OP_IMMEDIATE_LOAD_WORD;
    // even_unit_id = 1;
    // even_immediate = 8;
    // even_instruction_type = RI16;

// @(posedge clk);
//     reset = 0;
//     even_ra_addr = 3;
//     //even_rb_addr = 6;
//     //even_rc_addr = 7;
//     even_rt_addr = 1;
//     even_opcode = OP_IMMEDIATE_LOAD_WORD;
//     even_unit_id = 1;
//     even_immediate = 4;
//     even_register_write = 1;
//     even_instruction_type = RI16;

//     @(posedge clk);
//     reset = 0;
//     even_ra_addr = 4;
//     //even_rb_addr = 6;
//     //even_rc_addr = 7;
//     even_rt_addr = 2;
//     even_opcode = OP_IMMEDIATE_LOAD_WORD;
//     even_unit_id = 1;
//     even_immediate = 5;
//     even_register_write = 1;
//     even_instruction_type = RI16;

// @(posedge clk);
//     reset = 0;
//     even_ra_addr = 4;
//     //even_rb_addr = 6;
//     //even_rc_addr = 7;
//     even_rt_addr = 3;
//     even_opcode = OP_IMMEDIATE_LOAD_WORD;
//     even_unit_id = 1;
//     even_immediate = 0;
//     even_instruction_type = RI16;

// @(posedge clk);
//     reset = 0;
//     even_ra_addr = 2; //5
//     even_rb_addr = 1; //4
//     even_rc_addr = 3; //1
//     even_rt_addr = 4; //4-5+1 = 0
//     even_opcode = OP_SUBTRACT_FROM_EXTENDED;
//     even_unit_id = 1;
//     even_instruction_type = RRR;
    

    // @(posedge clk);
    // reset = 0;
    // even_ra_addr = 4;
    // //even_rb_addr = 6;
    // //even_rc_addr = 7;
    // even_rt_addr = 2;
    // even_opcode = OP_IMMEDIATE_LOAD_HALFWORD;
    // even_unit_id = 1;
    // even_immediate = 7;
    // even_instruction_type = RI16;

  
    // @(posedge clk);
    // @(posedge clk);
    // @(posedge clk);
    // reset = 0;
    // even_ra_addr = 1; //4
    // even_rb_addr = 2; //2
    // //even_rc_addr = 7;
    // even_rt_addr = 3;
    // even_opcode = OP_COMPARE_LOGICAL_GREATER_THAN_HALFWORD_IMMEDIATE;
    // even_unit_id = 1;
    // even_instruction_type = RI10;
    // even_immediate = 5; 

    // @(posedge clk);
    // @(posedge clk);

    //permute (odd)RA shifted left by bits 27:31
    // odd_ra_addr = 1;
    // odd_rb_addr = 2;
    // //odd_rc_addr = 
    // odd_rt_addr = 5;
    // odd_instruction_type = RR;
    // odd_opcode = OP_SHIFT_LEFT_QUADWORD_BY_BYTES;
    // odd_unit_id = 5;
    // odd_immediate = 3;

    // @(posedge clk);
    // @(posedge clk);
    // reset = 0;
    // even_ra_addr = 1;
    // even_rt_addr = 2;
    // even_opcode = OP_IMMEDIATE_LOAD_HALFWORD_UPPER;
    // even_unit_id = 1;
    // even_immediate = 16'h4083; // upper 16 bits of 4.1 (0x40833333)
    // even_instruction_type = RI16;

    // @(posedge clk);
    // @(posedge clk);
    // // load lower 16 bits of 4.1
    // even_ra_addr = 3;
    // even_rb_addr = 5;
    // even_rt_addr = 5;
    // even_opcode = OP_IMMEDIATE_OR_HALFWORD_LOWER; // iohl
    // even_unit_id = 1;
    // even_immediate = 16'h3333;
    // even_instruction_type = RI16;

    // @(posedge clk);
    // @(posedge clk);
    // even_ra_addr = 2; // 4.1
    // even_rb_addr = 5; // 2.4
    // even_rt_addr = 6;
    // even_opcode = OP_OR;
    // even_unit_id = 1;
    // even_instruction_type = RR;

    // @(posedge clk);
    // @(posedge clk);
    // even_ra_addr = 7;
    // even_rt_addr = 8;
    // even_opcode = OP_IMMEDIATE_LOAD_HALFWORD_UPPER;
    // even_unit_id = 1;
    // even_immediate = 16'h4019; // upper 16 bits of 2.4 (0x4019999A)
    // even_instruction_type = RI16;

    // @(posedge clk);
    // @(posedge clk);
    // // load lower 16 bits of 2.4
    // even_ra_addr = 9;
    // even_rb_addr = 10;
    // even_rt_addr = 10;
    // even_opcode = OP_IMMEDIATE_OR_HALFWORD_LOWER; // iohl
    // even_unit_id = 1;
    // even_immediate = 16'h999A;
    // even_instruction_type = RI16;

    // @(posedge clk);
    // @(posedge clk);
    // even_ra_addr = 8; // 4.1
    // even_rb_addr = 10; // 2.4
    // even_rt_addr = 11;
    // even_opcode = OP_OR;
    // even_unit_id = 1;
    // even_instruction_type = RR;

    // /* Floating add test */
    // @(posedge clk);
    // @(posedge clk);
    // even_ra_addr = 6; // 4.1
    // even_rb_addr = 11; // 2.4
    // even_rt_addr = 12;
    // even_opcode = OP_FLOATING_ADD;
    // even_unit_id = 3;
    // even_instruction_type = RR;
    // Expected RT = 0x40D00000 replicated 4 times
    // 0x40D00000 = 6.5 in IEEE 754
    //RT: [40D00000][40D00000][40D00000][40D00000]



//     @(negedge clk);
//     // Load some value into r2
//     even_ra_addr = 1;
//     //even_rb_addr = 2;
//     //even_rc_addr = 3;
//     even_rt_addr = 2;
//     even_opcode = OP_IMMEDIATE_LOAD_WORD;
//     even_unit_id = 1;
//     even_immediate = 5;

//     even_instruction_type = RI16;
   
   
//     @(negedge clk);
    



//     // Load some value into r4
  
//     even_ra_addr = 3;
//     //even_rb_addr = 6;
//     //even_rc_addr = 7;
//     even_rt_addr = 4;
//     even_opcode = OP_IMMEDIATE_LOAD_WORD;
//     even_unit_id = 1;
//     even_immediate = 8;

//     even_instruction_type = RI16;

//     repeat (3) @(negedge clk);

//     // Add the two values
//    /*Simple Fixed 1 Instructions */

//     // even_ra_addr = 7; 
//     // //even_rb_addr = 4; //2
//     // even_rc_addr = 4;
//     // //even_rt_addr = 5;
//     // even_opcode = OP_STORE_QUADWORD_D;
//     // even_unit_id = 1;
//     // even_immediate = 0;

//     // even_instruction_type = RR;

//  /*Local Store Instructions */
//  // Store value from r4 into memory addr 0
//     odd_ra_addr = 7; 
//     //even_rb_addr = 4; //2
//     odd_rc_addr = 4;
//     //even_rt_addr = 5;
//     odd_opcode = OP_STORE_QUADWORD_D;
//     odd_unit_id = 6;
//     odd_immediate = 0;

//     odd_instruction_type = RI10;

//     @(negedge clk);


// // Load value from memory addr0 into r5
//     //odd_ra_addr = 7; 
//     //even_rb_addr = 4; //2
//     //odd_rc_addr = 4;
//     even_rt_addr = 5;
//     odd_opcode = OP_LOAD_QUADWORD_A;
//     odd_unit_id = 6;
//     odd_immediate = 0;

//     odd_instruction_type = RI16;


// // Add r5 and 
//     //odd_ra_addr = 7; 
//     //even_rb_addr = 4; //2
//     //odd_rc_addr = 4;
//     even_rt_addr = 5;
//     odd_opcode = OP_LOAD_QUADWORD_A;
//     odd_unit_id = 6;
//     odd_immediate = 0;

//     odd_instruction_type = RI16;






    repeat (40) @(posedge clk);
    

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