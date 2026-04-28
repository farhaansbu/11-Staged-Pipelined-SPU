import instruction_pkg::*;

module decoder(

    input logic[0:31] instruction_1,
    input logic[0:8] program_counter_1,
    input logic[0:31] instruction_2,
    input logic[0:8] program_counter_2,


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
    output logic odd_reg_write

);

logic[0:2] unit_id_1;
logic[0:2] unit_id_2;

always_comb begin : decoder_body

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
        end
        else begin
            odd_unit_id = unit_id_2;
        end
   end

   // If instruction1 is odd
    if (unit_id_1 >= 5 && unit_id_1 <= 7) begin
        odd_unit_id = unit_id_1;
        // If both odd
        if (unit_id_2 >= 5 && unit_id_2 <= 7) begin
            even_unit_id = 0;
        end
        else begin
            even_unit_id = unit_id_2;
        end
   end


end


function automatic void decode_instruction (input logic[0:31] instruction, input logic[0:8] pc, ref logic[0:2] unit_id); 


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

    else if (instruction[0:7] == 8'b0011_0100) begin  //stqd
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

    else if (instruction[0:8] == 9'b0_0110_0000) begin //brsl
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







    // Check for RR/RI7 type (11 bit opcode)




endfunction : deecode_instruction


endmodule