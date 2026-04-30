import instruction_pkg::*;

module simple_fixed_1_1(

    input logic clk,

    input logic [0:127] source_a,
    input logic [0:127] source_b,
    input logic [0:127] source_c,
    input logic [0:6] write_address,
    input opcode_t opcode,
    input logic[0:2] even_unit_id,
    input logic reg_write,

    output unit_result_packet output_packet

);


always_ff @(posedge clk) begin

    if (even_unit_id != 1) begin // Unit id doesn't match
        output_packet.present_bit <= 0;
    end

    else begin
        // Record unit id, write addr, other control signals
        output_packet.unit_id <= even_unit_id;
        output_packet.reg_write_addr <= write_address;
        output_packet.reg_write_flag <= reg_write;
        output_packet.present_bit <= 1;
        output_packet.ready_stage_number <= 3;
        output_packet.current_stage_number <= 2;

        // Calculate result
        case (opcode)

            OP_ADD_WORD: output_packet.result <= add_word(source_a, source_b);
            OP_ADD_HALFWORD: output_packet.result <= add_halfword(source_a, source_b);
            OP_ADD_EXTENDED: output_packet.result <= add_extended(source_a, source_b, source_c);
            OP_SUBTRACT_FROM_WORD: output_packet.result <= subtract_from_word(source_a, source_b);
            OP_SUBTRACT_FROM_HALFWORD: output_packet.result <= subtract_from_halfword(source_b, source_b);
            OP_SUBTRACT_FROM_EXTENDED: output_packet.result <= subtract_from_extended(source_a, source_b, source_c);
            OP_CARRY_GENERATE: output_packet.result <= carry_generate(source_a, source_b);
            OP_BORROW_GENERATE: output_packet.result <= borrow_generate(source_a, source_b);
            OP_ADD_WORD_IMMEDIATE: output_packet.result <= add_word_immediate(source_a, source_b[0:9]);
            OP_ADD_HALFWORD_IMMEDIATE: output_packet.result <= add_halfword_immediate(source_a, source_b[0:9]);
            OP_SUBTRACT_FROM_WORD_IMMEDIATE: output_packet.result <= subtract_from_word_immediate(source_a, source_b[0:9]);
            OP_SUBTRACT_FROM_HALFWORD_IMMEDIATE: output_packet.result <= subtract_from_halfword_immediate(source_a, source_b[0:9]);
            OP_COUNT_LEADING_ZEROS: output_packet.result <= count_leading_zeros(source_a);
            OP_FORM_SELECT_MASK_FOR_HALFWORDS: output_packet.result <= form_select_mask_for_halfwords(source_a);
            OP_FORM_SELECT_MASK_FOR_WORDS: output_packet.result <= form_select_mask_for_words(source_a);
            OP_AND: output_packet.result <= and_op(source_a, source_b);
            OP_AND_WORD_IMMEDIATE: output_packet.result <= and_word_immediate(source_a, source_b[0:9]);
            OP_AND_HALFWORD_IMMEDIATE: output_packet.result <= and_halfword_immediate(source_a, source_b[0:9]);
            OP_OR: output_packet.result <= or_op(source_a, source_b);
            OP_OR_WORD_IMMEDIATE: output_packet.result <= or_word_immediate(source_a, source_b[0:9]);
            OP_OR_HALFWORD_IMMEDIATE: output_packet.result <= or_halfword_immediate(source_a, source_b[0:9]);
            OP_EXCLUSIVE_OR: output_packet.result <= xor_op(source_a, source_b);
            OP_EXCLUSIVE_OR_WORD_IMMEDIATE: output_packet.result <= xor_word_immediate(source_a, source_b[0:9]);
            OP_EXCLUSIVE_OR_HALFWORD_IMMEDIATE: output_packet.result <= xor_halfword_immediate(source_a, source_b[0:9]);
            OP_NAND: output_packet.result <= nand_op(source_a, source_b);
            OP_NOR: output_packet.result <= nor_op(source_a, source_b);
            OP_COMPARE_EQUAL_WORD: output_packet.result <= compare_equal_word(source_a, source_b);
            OP_COMPARE_EQUAL_HALFWORD: output_packet.result <= compare_equal_halfword(source_a, source_b);
            OP_COMPARE_GREATER_THAN_WORD: output_packet.result <= compare_greater_than_word(source_a, source_b);
            OP_COMPARE_GREATER_THAN_HALFWORD: output_packet.result <= compare_greater_than_halfword(source_a, source_b);
            OP_COMPARE_LOGICAL_GREATER_THAN_WORD: output_packet.result <= compare_logical_greater_than_word(source_a, source_b);
            OP_COMPARE_LOGICAL_GREATER_THAN_HALFWORD: output_packet.result <= compare_logical_greater_than_halfword(source_a, source_b);
            OP_COMPARE_EQUAL_WORD_IMMEDIATE: output_packet.result <= compare_equal_word_immediate(source_a, source_b[0:9]);
            OP_COMPARE_EQUAL_HALFWORD_IMMEDIATE: output_packet.result <= compare_equal_halfword_immediate(source_a, source_b[0:9]);
            OP_COMPARE_GREATER_THAN_WORD_IMMEDIATE: output_packet.result <= compare_greater_than_word_immediate(source_a, source_b[0:9]);
            OP_COMPARE_GREATER_THAN_HALFWORD_IMMEDIATE: output_packet.result <= compare_greater_than_halfword_immediate(source_a, source_b[0:9]);
            OP_COMPARE_LOGICAL_GREATER_THAN_WORD_IMMEDIATE: output_packet.result <= compare_logical_greater_than_word_immediate(source_a, source_b[0:9]);
            OP_COMPARE_LOGICAL_GREATER_THAN_HALFWORD_IMMEDIATE: output_packet.result <= compare_logical_greater_than_halfword_immediate(source_a, source_b[0:9]);
            OP_IMMEDIATE_LOAD_WORD: output_packet.result <= immediate_load_word(source_a[0:15]);
            OP_IMMEDIATE_LOAD_HALFWORD: output_packet.result <= immediate_load_halfword(source_a[0:15]);
            OP_IMMEDIATE_LOAD_ADDRESS: output_packet.result <= immediate_load_address(source_a[0:17]);
            OP_IMMEDIATE_LOAD_HALFWORD_UPPER: output_packet.result <= immediate_load_halfword_upper(source_a[0:15]);
            OP_IMMEDIATE_OR_HALFWORD_LOWER: output_packet.result <= immediate_or_halfword_lower(source_a[0:15], source_b);
            default: ;
        endcase
    end
    

end





localparam WORD_BITS = 32;
localparam HALFWORD_BITS = 16;


function automatic logic[0:127] add_word (input logic[0:127] ra, input logic[0:127] rb);
logic[0:127] rt;
for (int i = 0; i < 4; ++i) begin
    int index = i * WORD_BITS;
    rt[index +: WORD_BITS] = ra[index +: WORD_BITS] + rb[index +: WORD_BITS];
end
return rt;
endfunction : add_word  

function automatic logic[0:127] add_halfword (input logic[0:127] ra, input logic[0:127] rb);
logic[0:127] rt;
for (int i = 0; i < 8; ++i) begin
    int index = i * HALFWORD_BITS;
    rt[index +: HALFWORD_BITS] = ra[index +: HALFWORD_BITS] + rb[index +: HALFWORD_BITS];
end
return rt;
endfunction : add_halfword

function automatic logic[0:127] add_extended (input logic[0:127] ra, input logic[0:127] rb, input logic[0:127] rt_in);
logic[0:127] rt_out;

for (int i = 0; i < 4; ++i) begin
    int index = i * WORD_BITS;
    logic carry_in = rt_in[index + WORD_BITS - 1];
    rt_out[index +: WORD_BITS] = ra[index +: WORD_BITS] + rb[index +: WORD_BITS] + carry_in;
end
return rt_out;
endfunction : add_extended 


function automatic logic[0:127] subtract_from_word (input logic[0:127] ra, input logic[0:127] rb);
logic[0:127] rt;
for (int i = 0; i < 4; ++i) begin
    int index = i * WORD_BITS;
    rt[index +: WORD_BITS] = rb[index +: WORD_BITS] - ra[index +: WORD_BITS];
end
return rt;
endfunction : subtract_from_word

function automatic logic[0:127] subtract_from_halfword (input logic[0:127] ra, input logic[0:127] rb);
logic[0:127] rt;
for (int i = 0; i < 8; ++i) begin
    int index = i * HALFWORD_BITS;
    rt[index +: HALFWORD_BITS] = rb[index +: HALFWORD_BITS] - ra[index +: HALFWORD_BITS];
end
return rt;
endfunction : subtract_from_halfword

function automatic logic[0:127] subtract_from_extended (input logic[0:127] ra, input logic[0:127] rb, input logic[0:127] rt_in);
logic[0:127] rt_out;

for (int i = 0; i < 4; ++i) begin
    int index = i * WORD_BITS;
    logic carry_in = rt_in[index + WORD_BITS - 1];
    rt_out[index +: WORD_BITS] = rb[index +: WORD_BITS] + (~ra[index +: WORD_BITS]) + carry_in;
end
return rt_out;
endfunction : subtract_from_extended 

function automatic logic[0:127] carry_generate (input logic[0:127] ra, input logic[0:127] rb);
logic[0:127] rt;
logic[0:32] temp;
for (int i = 0; i < 4; ++i) begin
    int index = i * WORD_BITS;
    temp = ra[index +: WORD_BITS] + rb[index +: WORD_BITS];
    rt[index +: WORD_BITS] = '0;
    rt[index + 31] = temp[0];
end
return rt;
endfunction : carry_generate

function automatic logic[0:127] borrow_generate (input logic[0:127] ra, input logic[0:127] rb);
logic[0:127] rt;
for (int i = 0; i < 4; ++i) begin
    int index = i * WORD_BITS;

    rt[index +: WORD_BITS] = '0;
    if (rb >= ra) begin
        rt[index + 31] = 1;
    end
end
return rt;
endfunction : borrow_generate

function automatic logic[0:127] add_word_immediate (input logic[0:127] ra, input logic[0:9] i10);
logic[0:127] rt;
logic[0:31] imm32 = {{22{i10[0]}}, i10};

for (int i = 0; i < 4; ++i) begin
    int index = i * WORD_BITS;
    rt[index +: WORD_BITS] = ra[index +: WORD_BITS] + imm32;
end
return rt;
endfunction : add_word_immediate

function automatic logic[0:127] add_halfword_immediate (input logic[0:127] ra, input logic[0:9] i10);
logic[0:127] rt;
logic[0:15] imm16 = {{6{i10[0]}}, i10};

for (int i = 0; i < 8; ++i) begin
    int index = i * HALFWORD_BITS;
    rt[index +: HALFWORD_BITS] = ra[index +: HALFWORD_BITS] + imm16;
end
return rt;
endfunction : add_halfword_immediate

function automatic logic[0:127] subtract_from_word_immediate (input logic[0:127] ra, input logic[0:9] i10);
logic[0:127] rt;
logic[0:31] imm32 = {{22{i10[0]}}, i10};

for (int i = 0; i < 4; ++i) begin
    int index = i * WORD_BITS;
    rt[index +: WORD_BITS] = imm32 - ra[index +: WORD_BITS];
end
return rt;
endfunction : subtract_from_word_immediate

function automatic logic[0:127] subtract_from_halfword_immediate (input logic[0:127] ra, input logic[0:9] i10);
logic[0:127] rt;
logic[0:15] imm16 = {{6{i10[0]}}, i10};

for (int i = 0; i < 8; ++i) begin
    int index = i * HALFWORD_BITS;
    rt[index +: HALFWORD_BITS] = imm16 - ra[index +: HALFWORD_BITS];
end
return rt;
endfunction : subtract_from_halfword_immediate

function automatic logic[0:127] count_leading_zeros(input logic[0:127] ra);
logic[0:127] rt;

for (int i = 0; i < 4; ++i) begin
    int count = 0;
    int index = i * WORD_BITS;
    for (int j = 0; j < 32; ++j) begin
        if (ra[index + j] == 1) begin
            break;
        end else begin
            count += 1;
        end
    end
    rt[index +: WORD_BITS] = count;
end
return rt;
endfunction : count_leading_zeros

function automatic logic[0:127] form_select_mask_for_halfwords(input logic[0:127] ra);
logic[0:127] rt;

int preferred_slot_index = 24;
for (int i = 0; i < 8; ++i) begin
    int index = i * HALFWORD_BITS;
    if (ra[preferred_slot_index + i] == 0) begin
        rt[index +: HALFWORD_BITS] = '0;
    end else begin
        rt[index +: HALFWORD_BITS] = '1;
    end
end
return rt;
endfunction : form_select_mask_for_halfwords

function automatic logic[0:127] form_select_mask_for_words(input logic[0:127] ra);
logic[0:127] rt;

int preferred_slot_index = 28;
for (int i = 0; i < 4; ++i) begin
    int index = i * WORD_BITS;
    if (ra[preferred_slot_index + i] == 0) begin
        rt[index +: WORD_BITS] = '0;
    end else begin
        rt[index +: WORD_BITS] = '1;
    end
end
return rt;
endfunction : form_select_mask_for_words

function automatic logic[0:127] and_op(input logic[0:127] ra, input logic[0:127] rb);
return ra & rb;
endfunction : and_op

function automatic logic[0:127] and_word_immediate(input logic[0:127] ra, input logic[0:9] i10);
logic[0:127] rt;
logic[0:31] imm32 = {{22{i10[0]}}, i10};
for (int i = 0; i < 4; ++i) begin
    int index = i * WORD_BITS;
    rt[index +: WORD_BITS] = ra[index +: WORD_BITS] & imm32;
end
return rt;
endfunction : and_word_immediate

function automatic logic[0:127] and_halfword_immediate(input logic[0:127] ra, input logic[0:9] i10);
logic[0:127] rt;
logic[0:31] imm16 = {{6{i10[0]}}, i10};
for (int i = 0; i < 8; ++i) begin
    int index = i * HALFWORD_BITS;
    rt[index +: HALFWORD_BITS] = ra[index +: HALFWORD_BITS] & imm16;
end
return rt;
endfunction : and_halfword_immediate

function automatic logic[0:127] or_op(input logic[0:127] ra, input logic[0:127] rb);
return ra | rb;
endfunction : or_op

function automatic logic[0:127] or_word_immediate(input logic[0:127] ra, input logic[0:9] i10);
logic[0:127] rt;
logic[0:31] imm32 = {{22{i10[0]}}, i10};
for (int i = 0; i < 4; ++i) begin
    int index = i * WORD_BITS;
    rt[index +: WORD_BITS] = ra[index +: WORD_BITS] | imm32;
end
return rt;
endfunction : or_word_immediate

function automatic logic[0:127] or_halfword_immediate(input logic[0:127] ra, input logic[0:9]i10);
logic[0:127] rt;
logic[0:31] imm16 = {{6{i10[0]}}, i10};
for (int i = 0; i < 8; ++i) begin
    int index = i * HALFWORD_BITS;
    rt[index +: HALFWORD_BITS] = ra[index +: HALFWORD_BITS] | imm16;
end
return rt;
endfunction : or_halfword_immediate

function automatic logic[0:127] xor_op(input logic[0:127] ra, input logic[0:127] rb);
return ra ^ rb;
endfunction : xor_op

function automatic logic[0:127] xor_word_immediate(input logic[0:127] ra, input logic[0:9] i10);
logic[0:127] rt;
logic[0:31] imm32 = {{22{i10[0]}}, i10};
for (int i = 0; i < 4; ++i) begin
    int index = i * WORD_BITS;
    rt[index +: WORD_BITS] = ra[index +: WORD_BITS] ^ imm32;
end
return rt;
endfunction : xor_word_immediate

function automatic logic[0:127] xor_halfword_immediate(input logic[0:127] ra, input logic[0:9] i10);
logic[0:127] rt;
logic[0:31] imm16 = {{6{i10[0]}}, i10};
for (int i = 0; i < 8; ++i) begin
    int index = i * HALFWORD_BITS;
    rt[index +: HALFWORD_BITS] = ra[index +: HALFWORD_BITS] ^ imm16;
end
return rt;
endfunction : xor_halfword_immediate

function automatic logic[0:127] nand_op(input logic[0:127] ra, input logic[0:127] rb);
return ~(ra & rb);
endfunction : nand_op

function automatic logic[0:127] nor_op(input logic[0:127] ra, input logic[0:127] rb);
return ~(ra | rb);
endfunction : nor_op

function automatic logic [0:127] compare_equal_word(input logic[0:127] ra, input logic[0:127] rb);
logic[0:127] rt;
for (int i = 0; i < 4; ++i) begin
    int index = i * WORD_BITS;
    if (ra[index +: WORD_BITS] == rb[index +: WORD_BITS]) begin
        rt[index +: WORD_BITS] = '1;
    end else begin
        rt[index +: WORD_BITS] = '0;
    end
end
return rt;
endfunction : compare_equal_word

function automatic logic [0:127] compare_equal_halfword(input logic[0:127] ra, input logic[0:127] rb);
logic[0:127] rt;
for (int i = 0; i < 8; ++i) begin
    int index = i * HALFWORD_BITS;
    if (ra[index +: HALFWORD_BITS] == rb[index +: HALFWORD_BITS]) begin
        rt[index +: HALFWORD_BITS] = '1;
    end else begin
        rt[index +: HALFWORD_BITS] = '0;
    end
end
return rt;
endfunction : compare_equal_halfword

function automatic logic [0:127] compare_greater_than_word(input logic[0:127] ra, input logic[0:127] rb);
logic[0:127] rt;
logic signed[0:31] a_s, b_s;

for (int i = 0; i < 4; ++i) begin
    int index = i * WORD_BITS;
    a_s = ra[index +: WORD_BITS];
    b_s = rb[index +: WORD_BITS];

    if (a_s > b_s) begin
        rt[index +: WORD_BITS] = '1;
    end else begin
        rt[index +: WORD_BITS] = '0;
    end
end
return rt;
endfunction : compare_greater_than_word

function automatic logic [0:127] compare_greater_than_halfword(input logic[0:127] ra, input logic[0:127] rb);
logic[0:127] rt;
logic signed[0:15] a_s, b_s;

for (int i = 0; i < 8; ++i) begin
    int index = i * HALFWORD_BITS;
    a_s = ra[index +: HALFWORD_BITS];
    b_s = rb[index +: HALFWORD_BITS];

    if (a_s > b_s) begin
        rt[index +: HALFWORD_BITS] = '1;
    end else begin
        rt[index +: HALFWORD_BITS] = '0;
    end
end
return rt;
endfunction : compare_greater_than_halfword

function automatic logic [0:127] compare_logical_greater_than_word(input logic[0:127] ra, input logic[0:127] rb);
logic[0:127] rt;
for (int i = 0; i < 4; ++i) begin
    int index = i * WORD_BITS;

    if (ra[index +: WORD_BITS] > rb[index +: WORD_BITS]) begin
        rt[index +: WORD_BITS] = '1;
    end else begin
        rt[index +: WORD_BITS] = '0;
    end
end
return rt;
endfunction : compare_logical_greater_than_word

function automatic logic [0:127] compare_logical_greater_than_halfword(input logic[0:127] ra, input logic[0:127] rb);
logic[0:127] rt;
for (int i = 0; i < 8; ++i) begin
    int index = i * HALFWORD_BITS;
    
    if (ra[index +: HALFWORD_BITS] > rb[index +: HALFWORD_BITS]) begin
        rt[index +: HALFWORD_BITS] = '1;
    end else begin
        rt[index +: HALFWORD_BITS] = '0;
    end
end
return rt;
endfunction : compare_logical_greater_than_halfword

function automatic logic [0:127] compare_equal_word_immediate(input logic[0:127] ra, input logic[0:9] i10);
logic[0:127] rt;
logic signed[0:31] imm32 = {{22{i10[0]}}, i10};
logic signed[0:31] a_s;

for (int i = 0; i < 4; ++i) begin
    int index = i * WORD_BITS;
    a_s = ra[index +: WORD_BITS];

    if (a_s == imm32) begin
        rt[index +: WORD_BITS] = '1;
    end else begin
        rt[index +: WORD_BITS] = '0;
    end
end
return rt;
endfunction : compare_equal_word_immediate

function automatic logic [0:127] compare_equal_halfword_immediate(input logic[0:127] ra, input logic[0:9] i10);
logic[0:127] rt;
logic signed[0:15] imm16 = {{6{i10[0]}}, i10};
logic signed[0:15] a_s;

for (int i = 0; i < 8; ++i) begin
    int index = i * HALFWORD_BITS;
    a_s = ra[index +: HALFWORD_BITS];

    if (a_s == imm16) begin
        rt[index +: HALFWORD_BITS] = '1;
    end else begin
        rt[index +: HALFWORD_BITS] = '0;
    end
end
return rt;
endfunction : compare_equal_halfword_immediate

function automatic logic [0:127] compare_greater_than_word_immediate(input logic[0:127] ra, input logic[0:9] i10);
logic[0:127] rt;
logic signed[0:31] imm32 = {{22{i10[0]}}, i10};
logic signed[0:31] a_s;

for (int i = 0; i < 4; ++i) begin
    int index = i * WORD_BITS;
    a_s = ra[index +: WORD_BITS];

    if (a_s > imm32) begin
        rt[index +: WORD_BITS] = '1;
    end else begin
        rt[index +: WORD_BITS] = '0;
    end
end
return rt;
endfunction : compare_greater_than_word_immediate

function automatic logic [0:127] compare_greater_than_halfword_immediate(input logic[0:127] ra, input logic[0:9] i10);
logic[0:127] rt;
logic signed[0:15] imm16 = {{6{i10[0]}}, i10};
logic signed[0:15] a_s;

for (int i = 0; i < 8; ++i) begin
    int index = i * HALFWORD_BITS;
    a_s = ra[index +: HALFWORD_BITS];

    if (a_s > imm16) begin
        rt[index +: HALFWORD_BITS] = '1;
    end else begin
        rt[index +: HALFWORD_BITS] = '0;
    end
end
return rt;
endfunction : compare_greater_than_halfword_immediate

function automatic logic [0:127] compare_logical_greater_than_halfword_immediate(input logic[0:127] ra, input logic[0:9] i10);
logic[0:127] rt;
logic[0:15] imm16 = {{6{i10[0]}}, i10};

for (int i = 0; i < 8; ++i) begin
    int index = i * HALFWORD_BITS;

    if (ra[index +: HALFWORD_BITS] > imm16) begin
        rt[index +: HALFWORD_BITS] = '1;
    end else begin
        rt[index +: HALFWORD_BITS] = '0;
    end
end
return rt;
endfunction : compare_logical_greater_than_halfword_immediate

function automatic logic [0:127] compare_logical_greater_than_word_immediate(input logic[0:127] ra, input logic[0:9] i10);
logic[0:127] rt;
logic[0:31] imm32 = {{22{i10[0]}}, i10};

for (int i = 0; i < 4; ++i) begin
    int index = i * WORD_BITS;

    if (ra[index +: WORD_BITS] > imm32) begin
        rt[index +: WORD_BITS] = '1;
    end else begin
        rt[index +: WORD_BITS] = '0;
    end
end
return rt;
endfunction : compare_logical_greater_than_word_immediate

function automatic logic [0:127] immediate_load_word(input logic[0:15] i16);
logic[0:127] rt;
logic[0:31] imm32 = {{16{i16[0]}}, i16};

for (int i = 0; i < 4; ++i) begin
    int index = i * WORD_BITS;
    rt[index +: WORD_BITS] = imm32;
end
return rt;
endfunction : immediate_load_word

function automatic logic [0:127] immediate_load_halfword(input logic[0:15] i16);
logic[0:127] rt;

for (int i = 0; i < 8; ++i) begin
    int index = i * HALFWORD_BITS;
    rt[index +: HALFWORD_BITS] = i16;
end
return rt;
endfunction : immediate_load_halfword

function automatic logic[0:127] immediate_load_address(input logic [0:17] i18);
logic[0:127] rt;
logic[0:31] imm32 = {14'b0, i18};

for (int i = 0; i < 4; ++i) begin
    int index = i * WORD_BITS;
    rt[index +: WORD_BITS] = imm32;
end
return rt;
endfunction : immediate_load_address

function automatic logic [0:127] immediate_load_halfword_upper(input logic[0:15] i16);
logic[0:127] rt;
logic[0:31] imm32 = {i16, 16'b0};

for (int i = 0; i < 4; ++i) begin
    int index = i * WORD_BITS;
    rt[index +: WORD_BITS] = imm32;
end
return rt;
endfunction : immediate_load_halfword_upper

function automatic logic [0:127] immediate_or_halfword_lower(input logic[0:15] i16, input logic[0:127] rt_in);
logic[0:127] rt_out;
logic[0:31] imm32;

for (int i = 0; i < 4; ++i) begin
    int index = i * WORD_BITS;
    imm32 = {rt_in[index +: HALFWORD_BITS], i16};
    rt_out[index +: WORD_BITS] = imm32;
end
return rt_out;
endfunction : immediate_or_halfword_lower



typedef enum logic [7:0] {
    OP_ADD_WORD,
    OP_ADD_HALFWORD,
    OP_ADD_EXTENDED
} op_t;

endmodule



