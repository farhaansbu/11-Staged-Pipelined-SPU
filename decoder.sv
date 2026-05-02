import instruction_pkg::*;

module decoder(

    input logic[0:31] instruction_1,
    input logic[0:10] program_counter_1,
    input logic[0:31] instruction_2,
    input logic[0:10] program_counter_2,


    output logic[0:6] even_ra_addr,
    output logic[0:6] even_rb_addr,
    output logic[0:6] even_rc_addr,
    output logic[0:6] even_rt_addr,
    output instruction_type even_instruction_type,
    output opcode_t even_opcode,
    output logic[0:2] even_unit_id,
    output logic[0:10] even_program_counter,
    output logic[0:17] even_immediate,
    output logic even_reg_write,

    output logic[0:6] odd_ra_addr,
    output logic[0:6] odd_rb_addr,
    output logic[0:6] odd_rc_addr,
    output logic[0:6] odd_rt_addr,
    output instruction_type odd_instruction_type,
    output opcode_t odd_opcode,
    output logic[0:2] odd_unit_id,
    output logic[0:10] odd_program_counter,
    output logic[0:17] odd_immediate,
    output logic odd_reg_write,

    output logic odd_first,

    // Hazard signals
    output logic same_pipe_hazard,
    output logic same_write_dest_hazard

);

logic[0:2] unit_id_1;
logic[0:2] unit_id_2;
logic even_nop;
logic odd_nop;

always_comb begin : decoder_body

   odd_reg_write = 0;
   even_reg_write = 0;

   even_nop = 0;
   odd_nop = 0;
   same_pipe_hazard = 0;
   same_write_dest_hazard = 0;

   // Decode instruction 2
   decode_instruction(instruction_2, program_counter_2, unit_id_2);

   // Decode instruction 1
   decode_instruction(instruction_1, program_counter_1, unit_id_1);

   // instruction 2 is always later than 1, so if they are both odd/even, we want 
   // instruction 1's results to overwrrite 2, and we essentially want to stall 
   // the appropriate pipe and run instruction 2 next cycle


   // If instruction1 is even
   if (unit_id_1 >= 1 && unit_id_1 <= 4) begin
        even_unit_id = unit_id_1;
        // If both even
        if (unit_id_2 >= 1 && unit_id_2 <= 4) begin
            odd_unit_id = 0;
            odd_opcode = OP_NO_OP_HARDWARE;
            odd_reg_write = 0;
            same_pipe_hazard = 1;
        end
        else begin // Even + odd
            odd_unit_id = unit_id_2;
            // If both instructions have same write_dest
            if (even_reg_write && odd_reg_write && even_rt_addr == odd_rt_addr) begin
                // Stall odd instruction (make it no-op and refetch on next cycle)
                odd_opcode = OP_NO_OP_HARDWARE;
                odd_unit_id = 0;
                odd_reg_write = 0;
                same_write_dest_hazard = 1;
            end
        end
    end
   

   // If instruction1 is odd
    if (unit_id_1 >= 5 && unit_id_1 <= 7) begin
        odd_unit_id = unit_id_1;
        // If both odd
        if (unit_id_2 >= 5 && unit_id_2 <= 7) begin
            even_unit_id = 0;
            even_opcode = OP_NO_OP_HARDWARE;
            even_reg_write = 0;
            same_pipe_hazard = 1;
        end
        else begin // Odd + even
            even_unit_id = unit_id_2;
            // If both instructions have same write_dest
            if (even_reg_write && odd_reg_write && even_rt_addr == odd_rt_addr) begin
                // Stall odd instruction (make it no-op and refetch on next cycle)
                even_opcode = OP_NO_OP_HARDWARE;
                even_unit_id = 0;
                even_reg_write = 0;
                same_write_dest_hazard = 1;
            end
        end
   end

   // Set which instruction is first
   if (even_program_counter >= odd_program_counter) begin
        odd_first = 1;
   end else begin
        odd_first = 0;
   end

   // If both instructions are nop
   if (unit_id_1 == 0 && unit_id_2 == 0) begin
        // If both are odd/even, only one signal will be set
        if (odd_nop ^ even_nop) begin
            // set signal to move pc by 4 and refetch other instruction
            same_pipe_hazard = 1;
        end
   end


end


function automatic void decode_instruction (input logic[0:31] instruction, input logic[0:10] pc, ref logic[0:2] unit_id); 


    // Check for RRR type first (4 bit opcode)

    if (instruction[0:3] == 4'b1100) begin  //mpya
        unit_id = 3;
        even_instruction_type = RRR;
        even_opcode = OP_MULTIPLY_AND_ADD;
        even_rt_addr = instruction[4:10];
        even_ra_addr = instruction[18:24];
        even_rb_addr = instruction[11:17];
        even_rc_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

    else if (instruction[0:3] == 4'b1110) begin  //fma
        unit_id = 3;
        even_instruction_type = RRR;
        even_opcode = OP_FLOATING_MULTIPLY_AND_ADD;
        even_rt_addr = instruction[4:10];
        even_ra_addr = instruction[18:24];
        even_rb_addr = instruction[11:17];
        even_rc_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

    else if (instruction[0:3] == 4'b1101) begin  //fnms
        unit_id = 3;
        even_instruction_type = RRR;
        even_opcode = OP_FLOATING_NEGATIVE_MULTIPLY_AND_SUBTRACT;
        even_rt_addr = instruction[4:10];
        even_ra_addr = instruction[18:24];
        even_rb_addr = instruction[11:17];
        even_rc_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

    else if (instruction[0:3] == 4'b1111) begin  //fms
        unit_id = 3;
        even_instruction_type = RRR;
        even_opcode = OP_FLOATING_MULTIPLY_AND_SUBTRACT;
        even_rt_addr = instruction[4:10];
        even_ra_addr = instruction[18:24];
        even_rb_addr = instruction[11:17];
        even_rc_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

    else if (instruction[0:3] == 4'b1111) begin  //fma
        unit_id = 3;
        even_instruction_type = RRR;
        even_opcode = OP_FLOATING_MULTIPLY_AND_SUBTRACT;
        even_rt_addr = instruction[4:10];
        even_ra_addr = instruction[18:24];
        even_rb_addr = instruction[11:17];
        even_rc_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end


    // Check for RI18 type (7 bit opcode)

    else if (instruction[0:6] == 7'b010_0001) begin  //ila
        unit_id = 1;
        even_instruction_type = RI18;
        even_opcode = OP_IMMEDIATE_LOAD_ADDRESS;
        even_immediate = instruction[7:24];
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end


    // Check for RI10 type (8 bit opcode)

    else if (instruction[0:7] == 8'b0001_1100) begin  //ai
        unit_id = 1;
        even_instruction_type = RI10;
        even_opcode = OP_ADD_WORD_IMMEDIATE;
        even_ra_addr = instruction[18:24];
        even_immediate[8:17] = instruction[8:17];
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

    else if (instruction[0:7] == 8'b0001_1101) begin  //ahi
        unit_id = 1;
        even_instruction_type = RI10;
        even_opcode = OP_ADD_HALFWORD_IMMEDIATE;
        even_ra_addr = instruction[18:24];
        even_immediate[8:17] = instruction[8:17];
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

    else if (instruction[0:7] == 8'b0000_1100) begin  //sfi
        unit_id = 1;
        even_instruction_type = RI10;
        even_opcode = OP_SUBTRACT_FROM_WORD_IMMEDIATE;
        even_ra_addr = instruction[18:24];
        even_immediate[8:17] = instruction[8:17];
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

    else if (instruction[0:7] == 8'b0000_1101) begin  //sfhi
        unit_id = 1;
        even_instruction_type = RI10;
        even_opcode = OP_SUBTRACT_FROM_HALFWORD_IMMEDIATE;
        even_ra_addr = instruction[18:24];
        even_immediate[8:17] = instruction[8:17];
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

    else if (instruction[0:7] == 8'b0001_0100) begin  //andi
        unit_id = 1;
        even_instruction_type = RI10;
        even_opcode = OP_AND_WORD_IMMEDIATE;
        even_ra_addr = instruction[18:24];
        even_immediate[8:17] = instruction[8:17];
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

    else if (instruction[0:7] == 8'b0001_0101) begin  //andhi
        unit_id = 1;
        even_instruction_type = RI10;
        even_opcode = OP_AND_HALFWORD_IMMEDIATE;
        even_ra_addr = instruction[18:24];
        even_immediate[8:17] = instruction[8:17];
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

    else if (instruction[0:7] == 8'b0000_0100) begin  //ori
        unit_id = 1;
        even_instruction_type = RI10;
        even_opcode = OP_OR_WORD_IMMEDIATE;
        even_ra_addr = instruction[18:24];
        even_immediate[8:17] = instruction[8:17];
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

    else if (instruction[0:7] == 8'b0000_0101) begin  //orhi
        unit_id = 1;
        even_instruction_type = RI10;
        even_opcode = OP_OR_HALFWORD_IMMEDIATE;
        even_ra_addr = instruction[18:24];
        even_immediate[8:17] = instruction[8:17];
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

    else if (instruction[0:7] == 8'b0100_0100) begin  //xori
        unit_id = 1;
        even_instruction_type = RI10;
        even_opcode = OP_EXCLUSIVE_OR_WORD_IMMEDIATE;
        even_ra_addr = instruction[18:24];
        even_immediate[8:17] = instruction[8:17];
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

    else if (instruction[0:7] == 8'b0100_0101) begin  //xorhi
        unit_id = 1;
        even_instruction_type = RI10;
        even_opcode = OP_EXCLUSIVE_OR_HALFWORD_IMMEDIATE;
        even_ra_addr = instruction[18:24];
        even_immediate[8:17] = instruction[8:17];
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

    else if (instruction[0:7] == 8'b0111_1100) begin  //ceqi
        unit_id = 1;
        even_instruction_type = RI10;
        even_opcode = OP_COMPARE_EQUAL_WORD_IMMEDIATE;
        even_ra_addr = instruction[18:24];
        even_immediate[8:17] = instruction[8:17];
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

    else if (instruction[0:7] == 8'b0111_1101) begin  //ceqhi
        unit_id = 1;
        even_instruction_type = RI10;
        even_opcode = OP_COMPARE_EQUAL_HALFWORD_IMMEDIATE;
        even_ra_addr = instruction[18:24];
        even_immediate[8:17] = instruction[8:17];
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

    else if (instruction[0:7] == 8'b0100_1100) begin  //cgti
        unit_id = 1;
        even_instruction_type = RI10;
        even_opcode = OP_COMPARE_GREATER_THAN_WORD_IMMEDIATE;
        even_ra_addr = instruction[18:24];
        even_immediate[8:17] = instruction[8:17];
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

    else if (instruction[0:7] == 8'b0100_1101) begin  //cgthi
        unit_id = 1;
        even_instruction_type = RI10;
        even_opcode = OP_COMPARE_GREATER_THAN_HALFWORD_IMMEDIATE;
        even_ra_addr = instruction[18:24];
        even_immediate[8:17] = instruction[8:17];
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

    else if (instruction[0:7] == 8'b0101_1100) begin  //clgti
        unit_id = 1;
        even_instruction_type = RI10;
        even_opcode = OP_COMPARE_LOGICAL_GREATER_THAN_WORD_IMMEDIATE;
        even_ra_addr = instruction[18:24];
        even_immediate[8:17] = instruction[8:17];
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

    else if (instruction[0:7] == 8'b0101_1101) begin  //clgthi
        unit_id = 1;
        even_instruction_type = RI10;
        even_opcode = OP_COMPARE_LOGICAL_GREATER_THAN_HALFWORD_IMMEDIATE;
        even_ra_addr = instruction[18:24];
        even_immediate[8:17] = instruction[8:17];
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

    else if (instruction[0:7] == 8'b0111_0100) begin  //mpyi
        unit_id = 3;
        even_instruction_type = RI10;
        even_opcode = OP_MULTIPLY_IMMEDIATE;
        even_ra_addr = instruction[18:24];
        even_immediate[8:17] = instruction[8:17];
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

    else if (instruction[0:7] == 8'b0111_0101) begin  //mpyui
        unit_id = 3;
        even_instruction_type = RI10;
        even_opcode = OP_MULTIPLY_UNSIGNED_IMMEDIATE;
        even_ra_addr = instruction[18:24];
        even_immediate[8:17] = instruction[8:17];
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

    else if (instruction[0:7] == 8'b0011_0100) begin  //lqd
        unit_id = 6;
        odd_instruction_type = RI10;
        odd_opcode = OP_LOAD_QUADWORD_D;
        odd_ra_addr = instruction[18:24];
        odd_immediate[8:17] = instruction[8:17];
        odd_rt_addr = instruction[25:31];
        odd_program_counter = pc;
        odd_reg_write = 1;
    end

    else if (instruction[0:7] == 8'b0010_0100) begin  //stqd
        unit_id = 6;
        odd_instruction_type = RI10;
        odd_opcode = OP_STORE_QUADWORD_D;
        odd_ra_addr = instruction[18:24];
        odd_immediate[8:17] = instruction[8:17];
        odd_rc_addr = instruction[25:31]; // For stores, we read rt, so we will put rt into rc
        odd_program_counter = pc;
        odd_reg_write = 0;
    end



    // Check for RI16 type (9 bit opcode)

    else if (instruction[0:8] == 9'b0_1000_0001) begin //il
        unit_id = 1;
        even_instruction_type = RI16;
        even_opcode = OP_IMMEDIATE_LOAD_WORD;
        even_immediate[2:17] = instruction[9:24];
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

    else if (instruction[0:8] == 9'b0_1000_0011) begin //ilh
        unit_id = 1;
        even_instruction_type = RI16;
        even_opcode = OP_IMMEDIATE_LOAD_HALFWORD;
        even_immediate[2:17] = instruction[9:24];
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

    else if (instruction[0:8] == 9'b0_1000_0010) begin //ilhu
        unit_id = 1;
        even_instruction_type = RI16;
        even_opcode = OP_IMMEDIATE_LOAD_HALFWORD_UPPER;
        even_immediate[2:17] = instruction[9:24];
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

    else if (instruction[0:8] == 9'b0_1100_0001) begin //iohl
        unit_id = 1;
        even_instruction_type = RI16;
        even_opcode = OP_IMMEDIATE_OR_HALFWORD_LOWER;
        even_immediate[2:17] = instruction[9:24];
        even_rb_addr = instruction[25:31];      // iohl reads rt and writes rt, load rt into rb
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

    else if (instruction[0:8] == 9'b0_0110_0001) begin //lqa
        unit_id = 6;
        odd_instruction_type = RI16;
        odd_opcode = OP_LOAD_QUADWORD_A;
        odd_immediate[2:17] = instruction[9:24];
        odd_rt_addr = instruction[25:31];
        odd_program_counter = pc;
        odd_reg_write = 1;
    end

    else if (instruction[0:8] == 9'b0_0100_0001) begin //stqa
        unit_id = 6;
        odd_instruction_type = RI16;
        odd_opcode = OP_STORE_QUADWORD_A;
        odd_immediate[2:17] = instruction[9:24];
        odd_rc_addr = instruction[25:31]; //For stores, we read rt, so we will treat put rt into rc
        odd_program_counter = pc;
        odd_reg_write = 0;
    end

    else if (instruction[0:8] == 9'b0_0110_0100) begin //br
        unit_id = 7;
        odd_instruction_type = RI16;
        odd_opcode = OP_BRANCH_RELATIVE;
        odd_immediate[2:17] = instruction[9:24];
        odd_program_counter = pc;
        odd_reg_write = 0;
    end

    else if (instruction[0:8] == 9'b0_0110_0000) begin //bra
        unit_id = 7;
        odd_instruction_type = RI16;
        odd_opcode = OP_BRANCH_ABSOLUTE;
        odd_immediate[2:17] = instruction[9:24];
        odd_program_counter = pc;
        odd_reg_write = 0;
    end

    else if (instruction[0:8] == 9'b0_0110_0110) begin //brsl
        unit_id = 7;
        odd_instruction_type = RI16;
        odd_opcode = OP_BRANCH_RELATIVE_AND_SET_LINK;
        odd_immediate[2:17] = instruction[9:24];
        odd_rt_addr = instruction[25:31];
        odd_program_counter = pc;
        odd_reg_write = 1;
    end

    else if (instruction[0:8] == 9'b0_0110_0010) begin //brasl
        unit_id = 7;
        odd_instruction_type = RI16;
        odd_opcode = OP_BRANCH_ABSOLUTE_AND_SET_LINK;
        odd_immediate[2:17] = instruction[9:24];
        odd_rt_addr = instruction[25:31];
        odd_program_counter = pc;
        odd_reg_write = 1;
    end

    else if (instruction[0:8] == 9'b0_0100_0000) begin //brz
        unit_id = 7;
        odd_instruction_type = RI16;
        odd_opcode = OP_BRANCH_IF_ZERO_WORD;
        odd_immediate[2:17] = instruction[9:24];
        odd_rb_addr = instruction[25:31];
        odd_program_counter = pc;
        odd_reg_write = 0;
    end

    else if (instruction[0:8] == 9'b0_0100_0100) begin //brhz
        unit_id = 7;
        odd_instruction_type = RI16;
        odd_opcode = OP_BRANCH_IF_ZERO_HALFWORD;
        odd_immediate[2:17] = instruction[9:24];
        odd_rb_addr = instruction[25:31];
        odd_program_counter = pc;
        odd_reg_write = 0;  
    end

    else if (instruction[0:8] == 9'b0_0100_0010) begin //brnz
        unit_id = 7;
        odd_instruction_type = RI16;
        odd_opcode = OP_BRANCH_IF_NOT_ZERO_WORD;
        odd_immediate[2:17] = instruction[9:24];
        odd_rb_addr = instruction[25:31];
        odd_program_counter = pc;
        odd_reg_write = 0;
    end

    else if (instruction[0:8] == 9'b0_0100_0110) begin //brhnz
        unit_id = 7;
        odd_instruction_type = RI16;
        odd_opcode = OP_BRANCH_IF_NOT_ZERO_HALFWORD;
        odd_immediate[2:17] = instruction[9:24];
        odd_rb_addr = instruction[25:31];
        odd_program_counter = pc;
        odd_reg_write = 0;  
    end


    // Check for RR/RI7 type (11 bit opcode)
    /*  RI7's    (6 total) */ 

//1. shift left word immediate (shli)
    else if (instruction[0:10] == 11'b0000_1111_011) begin
        unit_id = 2;
        even_instruction_type = RI7;
        even_opcode = OP_SHIFT_LEFT_WORD_IMMEDIATE;
        even_immediate[8:17] = instruction[11:17];
        even_ra_addr = instruction[18:24];
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

//2. shift left halfword immediate (shlhi)
    else if (instruction[0:10] == 11'b0000_1111_111) begin
        unit_id = 2;
        even_instruction_type = RI7;
        even_opcode = OP_SHIFT_LEFT_HALFWORD_IMMEDIATE;
        even_immediate[11:17] = instruction[11:17];
        even_ra_addr = instruction[18:24];
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

//3. rotate word immediate (roti)
    else if (instruction[0:10] == 11'b0000_1111_000) begin
        unit_id = 2;
        even_instruction_type = RI7;
        even_opcode = OP_ROTATE_WORD_IMMEDIATE;
        even_immediate[11:17] = instruction[11:17];
        even_ra_addr = instruction[18:24];
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

// 4. rotate halfword immediate (rothi)
    else if (instruction[0:10] == 11'b0000_1111_100) begin
        unit_id = 2;
        even_instruction_type = RI7;
        even_opcode = OP_ROTATE_HALFWORD_IMMEDIATE;
        even_immediate[11:17] = instruction[11:17];
        even_ra_addr = instruction[18:24];
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

// 5. shift left quadword by bytes immediate (shlqbyi)
    else if (instruction[0:10] == 11'b0011_1111_111) begin
        unit_id = 5;
        odd_instruction_type = RI7;
        odd_opcode = OP_SHIFT_LEFT_QUADWORD_BY_BYTES_IMMEDIATE;
        odd_immediate[11:17] = instruction[11:17];
        odd_ra_addr = instruction[18:24];
        odd_rt_addr = instruction[25:31];
        odd_program_counter = pc;
        odd_reg_write = 1;
    end

// 6. rotate quadword by bytes immediate 
    else if (instruction[0:10] == 11'b0011_1111_100) begin
        unit_id = 5;
        odd_instruction_type = RI7;
        odd_opcode = OP_ROTATE_QUADWORD_BY_BYTES_IMMEDIATE;
        odd_immediate[11:17] = instruction[11:17];
        odd_ra_addr = instruction[18:24];
        odd_rt_addr = instruction[25:31];
        odd_program_counter = pc;
        odd_reg_write = 1;
    end


/*  RR's (extended is treated as RRR)  (46 total) */
//1. add word (a)
    else if (instruction[0:10] == 11'b0001_1000_000) begin  
        unit_id = 1;
        even_instruction_type = RR;
        even_opcode = OP_ADD_WORD;
        even_rb_addr = instruction[11:17];
        even_ra_addr = instruction[18:24];
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

//2. add halfword (ah)
    else if (instruction[0:10] == 11'b0001_1001_000) begin  
        unit_id = 1;
        even_instruction_type = RR;
        even_opcode = OP_ADD_HALFWORD;
        even_rb_addr = instruction[11:17];
        even_ra_addr = instruction[18:24];
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

// 3. add extended (addx)
    else if (instruction[0:10] == 11'b0110_1000_000) begin  
        unit_id = 1;
        even_instruction_type = RRR;
        even_opcode = OP_ADD_EXTENDED;
        even_rb_addr = instruction[11:17];
        even_ra_addr = instruction[18:24];
        even_rc_addr = instruction[25:31]; //reading rt 
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

// 4. subtract from word (sf) 
    else if (instruction[0:10] == 11'b0000_1000_000) begin  
        unit_id = 1;
        even_instruction_type = RR;
        even_opcode = OP_SUBTRACT_FROM_WORD;
        even_rb_addr = instruction[11:17];
        even_ra_addr = instruction[18:24];
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

// 5. subtract from halfword (sfh) 
    else if (instruction[0:10] == 11'b0000_1001_000) begin  
        unit_id = 1;
        even_instruction_type = RR;
        even_opcode = OP_SUBTRACT_FROM_HALFWORD;
        even_rb_addr = instruction[11:17];
        even_ra_addr = instruction[18:24];
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

// 6. subtract from extended (sfx) 
    else if (instruction[0:10] == 11'b0110_1000_001) begin  
        unit_id = 1;
        even_instruction_type = RRR;
        even_opcode = OP_SUBTRACT_FROM_EXTENDED;
        even_rb_addr = instruction[11:17];
        even_ra_addr = instruction[18:24];
        even_rc_addr = instruction[25:31]; //reading rt 
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

// 7. Carry Generate (cg)
    else if (instruction[0:10] == 11'b0001_1000_010) begin  
        unit_id = 1;
        even_instruction_type = RR;
        even_opcode = OP_CARRY_GENERATE;
        even_rb_addr = instruction[11:17];
        even_ra_addr = instruction[18:24]; 
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

// 8. Borrow Generate (bg)
    else if (instruction[0:10] == 11'b0000_1000_010) begin  
        unit_id = 1;
        even_instruction_type = RR;
        even_opcode = OP_BORROW_GENERATE;
        even_rb_addr = instruction[11:17];
        even_ra_addr = instruction[18:24]; 
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

// 9. And (and)
    else if (instruction[0:10] == 11'b0001_1000_001) begin  
        unit_id = 1;
        even_instruction_type = RR;
        even_opcode = OP_AND;
        even_rb_addr = instruction[11:17];
        even_ra_addr = instruction[18:24]; 
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

// 10. Or (or)
    else if (instruction[0:10] == 11'b0000_1000_001) begin  
        unit_id = 1;
        even_instruction_type = RR;
        even_opcode = OP_OR;
        even_rb_addr = instruction[11:17];
        even_ra_addr = instruction[18:24]; 
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

//11. exclusive or (xor)
    else if (instruction[0:10] == 11'b0100_1000_001) begin  
        unit_id = 1;
        even_instruction_type = RR;
        even_opcode = OP_EXCLUSIVE_OR;
        even_rb_addr = instruction[11:17];
        even_ra_addr = instruction[18:24]; 
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

//12. nand (nand)
    else if (instruction[0:10] == 11'b0001_1001_001) begin  
        unit_id = 1;
        even_instruction_type = RR;
        even_opcode = OP_NAND;
        even_rb_addr = instruction[11:17];
        even_ra_addr = instruction[18:24]; 
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

//13. nor (nor)
    else if (instruction[0:10] == 11'b0000_1001_001) begin  
        unit_id = 1;
        even_instruction_type = RR;
        even_opcode = OP_NOR;
        even_rb_addr = instruction[11:17];
        even_ra_addr = instruction[18:24]; 
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

//14. Compare Equal Word (ceq)
    else if (instruction[0:10] == 11'b0111_1000_000) begin  
        unit_id = 1;
        even_instruction_type = RR;
        even_opcode = OP_COMPARE_EQUAL_WORD;
        even_rb_addr = instruction[11:17];
        even_ra_addr = instruction[18:24]; 
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

//15. Compare Equal Halfword (ceqh)
    else if (instruction[0:10] == 11'b0111_1001_000) begin  
        unit_id = 1;
        even_instruction_type = RR;
        even_opcode = OP_COMPARE_EQUAL_HALFWORD;
        even_rb_addr = instruction[11:17];
        even_ra_addr = instruction[18:24]; 
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

//16. Compare Greater than Word (cgt)
    else if (instruction[0:10] == 11'b0100_1000_000) begin  
        unit_id = 1;
        even_instruction_type = RR;
        even_opcode = OP_COMPARE_GREATER_THAN_WORD;
        even_rb_addr = instruction[11:17];
        even_ra_addr = instruction[18:24]; 
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

//17. Compare Greater than Halfword (cgth)
    else if (instruction[0:10] == 11'b0100_1001_000) begin  
        unit_id = 1;
        even_instruction_type = RR;
        even_opcode = OP_COMPARE_GREATER_THAN_HALFWORD;
        even_rb_addr = instruction[11:17];
        even_ra_addr = instruction[18:24]; 
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

//18. Compare Logical Greater than Word
    else if (instruction[0:10] == 11'b0101_1000_000) begin  
        unit_id = 1;
        even_instruction_type = RR;
        even_opcode = OP_COMPARE_LOGICAL_GREATER_THAN_WORD;
        even_rb_addr = instruction[11:17];
        even_ra_addr = instruction[18:24]; 
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

//19. Compare Logical Greater than Halfword
    else if (instruction[0:10] == 11'b0101_1001_000) begin  
        unit_id = 1;
        even_instruction_type = RR;
        even_opcode = OP_COMPARE_LOGICAL_GREATER_THAN_HALFWORD;
        even_rb_addr = instruction[11:17];
        even_ra_addr = instruction[18:24]; 
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

//Simple Fixed 2 (RR type)
//20. Shift Left Word (shl)
    else if (instruction[0:10] == 11'b0000_1011_011) begin  
        unit_id = 2;
        even_instruction_type = RR;
        even_opcode = OP_SHIFT_LEFT_WORD;
        even_rb_addr = instruction[11:17];
        even_ra_addr = instruction[18:24]; 
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

//21. Shift Left Halfword (shlh)
    else if (instruction[0:10] == 11'b0000_1011_111) begin  
        unit_id = 2;
        even_instruction_type = RR;
        even_opcode = OP_SHIFT_LEFT_HALFWORD;
        even_rb_addr = instruction[11:17];
        even_ra_addr = instruction[18:24]; 
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

//22. Rotate Word (rot)
    else if (instruction[0:10] == 11'b0000_1011_000) begin  
        unit_id = 2;
        even_instruction_type = RR;
        even_opcode = OP_ROTATE_WORD;
        even_rb_addr = instruction[11:17];
        even_ra_addr = instruction[18:24]; 
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

//23. Rotate Halfword (roth)
    else if (instruction[0:10] == 11'b0000_1011_100) begin  
        unit_id = 2;
        even_instruction_type = RR;
        even_opcode = OP_ROTATE_HALFWORD;
        even_rb_addr = instruction[11:17];
        even_ra_addr = instruction[18:24]; 
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

//24. Rotate and Mask Word (rotm)
    else if (instruction[0:10] == 11'b0000_1011_001) begin  
        unit_id = 2;
        even_instruction_type = RR;
        even_opcode = OP_ROTATE_AND_MASK_WORD;
        even_rb_addr = instruction[11:17];
        even_ra_addr = instruction[18:24]; 
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

//25. Rotate and Mask Halfword (rothm)
    else if (instruction[0:10] == 11'b0000_1011_101) begin  
        unit_id = 2;
        even_instruction_type = RR;
        even_opcode = OP_ROTATE_AND_MASK_HALFWORD;
        even_rb_addr = instruction[11:17];
        even_ra_addr = instruction[18:24]; 
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

//26. Rotate and Mask Algebraic Word (rotma)
    else if (instruction[0:10] == 11'b0000_1011_010) begin  
        unit_id = 2;
        even_instruction_type = RR;
        even_opcode = OP_ROTATE_AND_MASK_ALGEBRAIC_WORD;
        even_rb_addr = instruction[11:17];
        even_ra_addr = instruction[18:24]; 
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

//27. Rotate and Mask Algebraic Halfword (rotmah)
    else if (instruction[0:10] == 11'b0000_1011_110) begin  
        unit_id = 2;
        even_instruction_type = RR;
        even_opcode = OP_ROTATE_AND_MASK_ALGEBRAIC_HALFWORD;
        even_rb_addr = instruction[11:17];
        even_ra_addr = instruction[18:24]; 
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

//Single Precision (RR Type)
//28. Multiply (mpy)
    else if (instruction[0:10] == 11'b0111_1000_100) begin  
        unit_id = 3;
        even_instruction_type = RR;
        even_opcode = OP_MULTIPLY;
        even_rb_addr = instruction[11:17];
        even_ra_addr = instruction[18:24]; 
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

//29. Multiply Unsigned (mpyu)
    else if (instruction[0:10] == 11'b0111_1001_100) begin  
        unit_id = 3;
        even_instruction_type = RR;
        even_opcode = OP_MULTIPLY_UNSIGNED;
        even_rb_addr = instruction[11:17];
        even_ra_addr = instruction[18:24]; 
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

//30. Floating Add (fa)
    else if (instruction[0:10] == 11'b0101_1000_100) begin  
        unit_id = 3;
        even_instruction_type = RR;
        even_opcode = OP_FLOATING_ADD;
        even_rb_addr = instruction[11:17];
        even_ra_addr = instruction[18:24]; 
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

//31. Floating Subtract (fs)
    else if (instruction[0:10] == 11'b0101_1000_101) begin  
        unit_id = 3;
        even_instruction_type = RR;
        even_opcode = OP_FLOATING_SUBTRACT;
        even_rb_addr = instruction[11:17];
        even_ra_addr = instruction[18:24]; 
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

//32. Floating Multiply (fm)
    else if (instruction[0:10] == 11'b0101_1000_110) begin  
        unit_id = 3;
        even_instruction_type = RR;
        even_opcode = OP_FLOATING_MULTIPLY;
        even_rb_addr = instruction[11:17];
        even_ra_addr = instruction[18:24]; 
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

//33. floating compare equal (fceq)
    else if (instruction[0:10] == 11'b0111_1000_010) begin  
        unit_id = 3;
        even_instruction_type = RR;
        even_opcode = OP_FLOATING_COMPARE_EQUAL;
        even_rb_addr = instruction[11:17];
        even_ra_addr = instruction[18:24]; 
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

//34. floating compare magnitude equal (fcmeq)
    else if (instruction[0:10] == 11'b0111_1001_010) begin  
        unit_id = 3;
        even_instruction_type = RR;
        even_opcode = OP_FLOATING_COMPARE_MAGNITUDE_EQUAL;
        even_rb_addr = instruction[11:17];
        even_ra_addr = instruction[18:24]; 
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

//35. floating compare greater than (fcgt)
    else if (instruction[0:10] == 11'b0101_1000_010) begin  
        unit_id = 3;
        even_instruction_type = RR;
        even_opcode = OP_FLOATING_COMPARE_GREATER_THAN;
        even_rb_addr = instruction[11:17];
        even_ra_addr = instruction[18:24]; 
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

//36. floating compare magnitude greater than (fcmgt)
    else if (instruction[0:10] == 11'b0101_1001_010) begin  
        unit_id = 3;
        even_instruction_type = RR;
        even_opcode = OP_FLOATING_COMPARE_MAGNITUDE_GREATER_THAN;
        even_rb_addr = instruction[11:17];
        even_ra_addr = instruction[18:24]; 
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

//Byte Unit
//37. Average Bytes (avgb)
    else if (instruction[0:10] == 11'b0001_1010_011) begin  
        unit_id = 4;
        even_instruction_type = RR;
        even_opcode = OP_AVERAGE_BYTES;
        even_rb_addr = instruction[11:17];
        even_ra_addr = instruction[18:24]; 
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

//38. Sum Bytes Into Halfwords (sumb)
    else if (instruction[0:10] == 11'b0100_1010_011) begin  
        unit_id = 4;
        even_instruction_type = RR;
        even_opcode = OP_SUM_BYTES_INTO_HALFWORDS;
        even_rb_addr = instruction[11:17];
        even_ra_addr = instruction[18:24]; 
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

//39. Absolute Differences of Bytes (absdb)
    else if (instruction[0:10] == 11'b0000_1010_011) begin  
        unit_id = 4;
        even_instruction_type = RR;
        even_opcode = OP_ABSOLUTE_DIFFERENCES_OF_BYTES;
        even_rb_addr = instruction[11:17];
        even_ra_addr = instruction[18:24]; 
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

//Permute Unit
//40. Shift Left Quadword By Bytes (shlqby)
    else if (instruction[0:10] == 11'b0011_1011_111) begin  
        unit_id = 5;
        odd_instruction_type = RR;
        odd_opcode = OP_SHIFT_LEFT_QUADWORD_BY_BYTES;
        odd_rb_addr = instruction[11:17];
        odd_ra_addr = instruction[18:24]; 
        odd_rt_addr = instruction[25:31];
        odd_program_counter = pc;
        odd_reg_write = 1;
    end

//41. Shift Left Quadword By Bits (shlqbi)
    else if (instruction[0:10] == 11'b0011_1011_011) begin  
        unit_id = 5;
        odd_instruction_type = RR;
        odd_opcode = OP_SHIFT_LEFT_QUADWORD_BY_BITS;
        odd_rb_addr = instruction[11:17];
        odd_ra_addr = instruction[18:24]; 
        odd_rt_addr = instruction[25:31];
        odd_program_counter = pc;
        odd_reg_write = 1;
    end

//42. Rotate Quadword By Bytes (rotqby)
    else if (instruction[0:10] == 11'b0011_1011_100) begin  
        unit_id = 5;
        odd_instruction_type = RR;
        odd_opcode = OP_ROTATE_QUADWORD_BY_BYTES;
        odd_rb_addr = instruction[11:17];
        odd_ra_addr = instruction[18:24]; 
        odd_rt_addr = instruction[25:31];
        odd_program_counter = pc;
        odd_reg_write = 1;
    end

//43. Rotate Quadword By Bits (rotqbi)
    else if (instruction[0:10] == 11'b0011_1011_000) begin  
        unit_id = 5;
        odd_instruction_type = RR;
        odd_opcode = OP_ROTATE_QUADWORD_BY_BITS;
        odd_rb_addr = instruction[11:17];
        odd_ra_addr = instruction[18:24]; 
        odd_rt_addr = instruction[25:31];
        odd_program_counter = pc;
        odd_reg_write = 1;
    end

//44. Rotate and Mask Quadword By Bytes (rotqmby)
    else if (instruction[0:10] == 11'b0011_1011_101) begin  
        unit_id = 5;
        odd_instruction_type = RR;
        odd_opcode = OP_ROTATE_AND_MASK_QUADWORD_BY_BYTES;
        odd_rb_addr = instruction[11:17];
        odd_ra_addr = instruction[18:24]; 
        odd_rt_addr = instruction[25:31];
        odd_program_counter = pc;
        odd_reg_write = 1;
    end

//local store 
//45. load quadword (x-form) (lqx)
    else if (instruction[0:10] == 11'b0011_1000_100) begin  
        unit_id = 6;
        odd_instruction_type = RR;
        odd_opcode = OP_LOAD_QUADWORD_X;
        odd_rb_addr = instruction[11:17];
        odd_ra_addr = instruction[18:24]; 
        odd_rt_addr = instruction[25:31];
        odd_program_counter = pc;
        odd_reg_write = 1;
    end

//46. store quadword (x-form) (stqx)
    else if (instruction[0:10] == 11'b0100_1000_100) begin  
        unit_id = 6;
        odd_instruction_type = RR;
        odd_opcode = OP_STORE_QUADWORD_X;
        odd_rb_addr = instruction[11:17];
        odd_ra_addr = instruction[18:24];
        odd_rc_addr = instruction[11:17];
        odd_rt_addr = instruction[25:31];
        odd_program_counter = pc;
        odd_reg_write = 0; //store doesnt write to memory
    end

//47. count ones in bytes
    else if (instruction[0:10] == 11'b0101_0110_100) begin  
        unit_id = 4;
        even_instruction_type = RR;
        even_opcode = OP_COUNT_ONES_IN_BYTES;
        //even_rb_addr = instruction[11:17];
        even_ra_addr = instruction[18:24]; 
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

//48. count leading zeroes
    else if (instruction[0:10] == 11'b0101_0100_101) begin  
        unit_id = 1;
        even_instruction_type = RR;
        even_opcode = OP_COUNT_LEADING_ZEROS;
        //even_rb_addr = instruction[11:17];
        even_ra_addr = instruction[18:24]; 
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end


//49. form select mask for halfwords
    else if (instruction[0:10] == 11'b0011_0110_101) begin  
        unit_id = 1;
        even_instruction_type = RR;
        even_opcode = OP_FORM_SELECT_MASK_FOR_HALFWORDS;
        //even_rb_addr = instruction[11:17];
        even_ra_addr = instruction[18:24]; 
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

//50. form select mask for words
    else if (instruction[0:10] == 11'b0011_0110_100) begin  
        unit_id = 1;
        even_instruction_type = RR;
        even_opcode = OP_FORM_SELECT_MASK_FOR_WORDS;
        //even_rb_addr = instruction[11:17];
        even_ra_addr = instruction[18:24]; 
        even_rt_addr = instruction[25:31];
        even_program_counter = pc;
        even_reg_write = 1;
    end

// branch indirect types
    // branch indirect and set link
    else if (instruction[0:10] == 11'b0011_0101_001) begin  
        unit_id = 7;
        odd_instruction_type = RR;
        odd_opcode = OP_BRANCH_INDIRECT_AND_SET_LINK;
        //even_rb_addr = instruction[11:17];
        odd_ra_addr = instruction[18:24]; 
        odd_rt_addr = instruction[25:31];
        odd_program_counter = pc;
        odd_reg_write = 1;
    end

    // branch indirect
    else if (instruction[0:10] == 11'b0011_0101_000) begin  
        unit_id = 7;
        odd_instruction_type = RR;
        odd_opcode = OP_BRANCH_INDIRECT;
        //even_rb_addr = instruction[11:17];
        odd_ra_addr = instruction[18:24]; 
        odd_rt_addr = instruction[25:31];
        odd_program_counter = pc;
        odd_reg_write = 0;
    end
    
    // branch indirect if zero
    else if (instruction[0:10] == 11'b0010_0101_000) begin  
        unit_id = 7;
        odd_instruction_type = RR;
        odd_opcode = OP_BRANCH_INDIRECT_IF_ZERO;
        //even_rb_addr = instruction[11:17];
        odd_ra_addr = instruction[18:24]; 
        odd_rb_addr = instruction[25:31];
        odd_program_counter = pc;
        odd_reg_write = 0;
    end

    // branch indirect if zero halfword
    else if (instruction[0:10] == 11'b0010_0101_010) begin  
        unit_id = 7;
        odd_instruction_type = RR;
        odd_opcode = OP_BRANCH_INDIRECT_IF_ZERO_HALFWORD;
        //even_rb_addr = instruction[11:17];
        odd_ra_addr = instruction[18:24]; 
        odd_rb_addr = instruction[25:31];
        odd_program_counter = pc;
        odd_reg_write = 0;
    end

    // branch indirect if not zero
    else if (instruction[0:10] == 11'b0010_0101_001) begin  
        unit_id = 7;
        odd_instruction_type = RR;
        odd_opcode = OP_BRANCH_INDIRECT_IF_NOT_ZERO;
        //even_rb_addr = instruction[11:17];
        odd_ra_addr = instruction[18:24]; 
        odd_rb_addr = instruction[25:31];
        odd_program_counter = pc;
        odd_reg_write = 0;
    end


    // branch indirect if not zero halfword
    else if (instruction[0:10] == 11'b0010_0101_011) begin  
        unit_id = 7;
        odd_instruction_type = RR;
        odd_opcode = OP_BRANCH_INDIRECT_IF_NOT_ZERO_HALFWORD;
        //even_rb_addr = instruction[11:17];
        odd_ra_addr = instruction[18:24]; 
        odd_rb_addr = instruction[25:31];
        odd_program_counter = pc;
        odd_reg_write = 0;
    end

// IMPLEMENT NO-OPs
// lnop
    else if (instruction[0:10] == 11'b0000_0000_001) begin  
        unit_id = 0;
        odd_opcode = OP_NO_OP_ODD;
        //even_rb_addr = instruction[11:17];
        odd_program_counter = pc;
        odd_reg_write = 0;
        odd_nop = 1;
    end


// nop
    else if (instruction[0:10] == 11'b0100_0000_001) begin  
        unit_id = 0;
        even_opcode = OP_NO_OP_EVEN;
        even_program_counter = pc;
        even_reg_write = 0;
        even_nop = 1;
    end
// hnop




endfunction : decode_instruction


endmodule