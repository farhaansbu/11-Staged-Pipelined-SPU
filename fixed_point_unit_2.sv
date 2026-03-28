import instruction_pkg::*;

module simple_fixed_2_1(
    input logic clk,

    input logic [0:127] source_a,
    input logic [0:127] source_b,
    input logic [0:127] source_c,
    input logic [0:6] write_address,
    input opcode_t opcode,
    input logic[0:2] even_unit_id,

    output unit_result_packet output_packet
);

always_ff @(posedge clk) begin

    if (even_unit_id != 2) begin // Unit id doesn't match
        output_packet.present_bit <= 0;
    end

    else begin
        // Record unit id, write addr, other control signals
        output_packet.unit_id <= even_unit_id;
        output_packet.reg_write_addr <= write_address;
        output_packet.reg_write_flag <= 1;
        output_packet.present_bit <= 1;
        output_packet.ready_stage_number <= 4;
        output_packet.current_stage_number <= 2;

        // Calculate result
        case (opcode)

            OP_SHIFT_LEFT_WORD: output_packet.result <= shift_left_word(source_a, source_b);
            OP_SHIFT_LEFT_HALFWORD: output_packet.result <= shift_left_halfword(source_a, source_b);
            OP_SHIFT_LEFT_WORD_IMMEDIATE: output_packet.result <= shift_left_word_immediate(source_a, source_b[0:6]);
            OP_SHIFT_LEFT_HALFWORD_IMMEDIATE: output_packet.result <= shift_left_halfword_immediate(source_a, source_b[0:6]);
            OP_ROTATE_WORD: output_packet.result <= rotate_word(source_a, source_b);
            OP_ROTATE_HALFWORD: output_packet.result <= rotate_halfword(source_a, source_b);
            OP_ROTATE_WORD_IMMEDIATE: output_packet.result <= rotate_word_immediate(source_a, source_b[0:6]);
            OP_ROTATE_HALFWORD_IMMEDIATE: output_packet.result <= rotate_halfword_immediate(source_a, source_b[0:6]);
            OP_ROTATE_AND_MASK_WORD: output_packet.result <= rotate_and_mask_word(source_a, source_b);
            OP_ROTATE_AND_MASK_HALFWORD: output_packet.result <= rotate_and_mask_halfword(source_a, source_b);
            OP_ROTATE_AND_MASK_ALGEBRAIC_WORD: output_packet.result <= rotate_and_mask_algebraic_word(source_a, source_b);
            OP_ROTATE_AND_MASK_ALGEBRAIC_HALFWORD: output_packet.result <= rotate_and_mask_algebraic_halfword(source_a, source_b);
              
        endcase
    end    

end

localparam WORD_BITS = 32;
localparam HALFWORD_BITS = 16;

function automatic logic[0:127] shift_left_word (input logic[0:127] ra, input logic [0:127] rb);
logic[0:127] rt;

for (int i = 0; i < 4; ++i) begin
    int index = i * WORD_BITS;
    integer shift_count = rb[index+26 +: 6];
    if (shift_count > 31) begin
        rt[index +: WORD_BITS] = '0;
    end else begin
        rt[index +: WORD_BITS] = ra[index +: WORD_BITS] << shift_count;
    end
end
return rt;
endfunction : shift_left_word

function automatic logic[0:127] shift_left_halfword (input logic[0:127] ra, input logic [0:127] rb);
logic[0:127] rt;

for (int i = 0; i < 8; ++i) begin
    int index = i * HALFWORD_BITS;
    integer shift_count = rb[index+11 +: 5];
    if (shift_count > 15) begin
        rt[index +: HALFWORD_BITS] = '0;
    end else begin
        rt[index +: HALFWORD_BITS] = ra[index +: HALFWORD_BITS] << shift_count;
    end
end
return rt;
endfunction : shift_left_halfword

function automatic logic[0:127] shift_left_word_immediate (input logic[0:127] ra, input logic[0:6] i7);
logic[0:127] rt;

for (int i = 0; i < 4; ++i) begin
    int index = i * WORD_BITS;
    integer shift_count = i7[1 +: 6];
    if (shift_count > 31) begin
        rt[index +: WORD_BITS] = '0;
    end else begin
        rt[index +: WORD_BITS] = ra[index +: WORD_BITS] << shift_count;
    end
end
return rt;
endfunction : shift_left_word_immediate

function automatic logic[0:127] shift_left_halfword_immediate (input logic[0:127] ra, input logic[0:6] i7);
logic[0:127] rt;

for (int i = 0; i < 8; ++i) begin
    int index = i * HALFWORD_BITS;
    integer shift_count = i7[2 +: 5];
    if (shift_count > 15) begin
        rt[index +: HALFWORD_BITS] = '0;
    end else begin
        rt[index +: HALFWORD_BITS] = ra[index +: HALFWORD_BITS] << shift_count;
    end
end
return rt;
endfunction : shift_left_halfword_immediate

function automatic logic[0:127] rotate_word (input logic[0:127] ra, input logic [0:127] rb);
logic[0:127] rt;

for (int i = 0; i < 4; ++i) begin
    int index = i * WORD_BITS;
    integer rotate_count = rb[index+27 +: 5];
    
    rt[index +: WORD_BITS] = {ra[index +: WORD_BITS], ra[index +: WORD_BITS]}[0 + rotate_count +: WORD_BITS];
end
return rt;
endfunction : rotate_word

function automatic logic[0:127] rotate_halfword (input logic[0:127] ra, input logic [0:127] rb);
logic[0:127] rt;

for (int i = 0; i < 8; ++i) begin
    int index = i * HALFWORD_BITS;
    integer rotate_count = rb[index+12 +: 4];
    
    rt[index +: HALFWORD_BITS] = {ra[index +: HALFWORD_BITS], ra[index +: HALFWORD_BITS]}[0 + rotate_count +: HALFWORD_BITS];
end
return rt;
endfunction : rotate_halfword

function automatic logic[0:127] rotate_word_immediate (input logic[0:127] ra, input logic [0:6] i7);
logic[0:127] rt;
integer rotate_count = i7[2:6];

for (int i = 0; i < 4; ++i) begin
    int index = i * WORD_BITS;
    rt[index +: WORD_BITS] = {ra[index +: WORD_BITS], ra[index +: WORD_BITS]}[0 + rotate_count +: WORD_BITS];
end
return rt;
endfunction : rotate_word_immediate

function automatic logic[0:127] rotate_halfword_immediate (input logic[0:127] ra, input logic [0:6] i7);
logic[0:127] rt;
integer rotate_count = i7[3:6];

for (int i = 0; i < 8; ++i) begin
    int index = i * HALFWORD_BITS; 
    rt[index +: HALFWORD_BITS] = {ra[index +: HALFWORD_BITS], ra[index +: HALFWORD_BITS]}[0 + rotate_count +: HALFWORD_BITS];
end
return rt;
endfunction : rotate_halfword_immediate

function automatic logic[0:127] rotate_and_mask_word (input logic[0:127] ra, input logic [0:127] rb);
logic[0:127] rt;

for (int i = 0; i < 4; ++i) begin
    int index = i * WORD_BITS;
    integer shift_count = (0 - rb) % 64;
    if (shift_count > 31) begin
        rt[index +: WORD_BITS] = '0;
    end else begin
        rt[index +: WORD_BITS] = ra[index +: WORD_BITS] >> shift_count;
    end
end
return rt;
endfunction : rotate_and_mask_word

function automatic logic[0:127] rotate_and_mask_halfword (input logic[0:127] ra, input logic [0:127] rb);
logic[0:127] rt;

for (int i = 0; i < 8; ++i) begin
    int index = i * HALFWORD_BITS;
    integer shift_count = (0 - rb) % 32;
    if (shift_count > 15) begin
        rt[index +: HALFWORD_BITS] = '0;
    end else begin
        rt[index +: HALFWORD_BITS] = ra[index +: HALFWORD_BITS] >> shift_count;
    end
end
return rt;
endfunction : rotate_and_mask_halfword

function automatic logic[0:127] rotate_and_mask_algebraic_word (input logic[0:127] ra, input logic [0:127] rb);
logic[0:127] rt;

for (int i = 0; i < 4; ++i) begin
    int index = i * WORD_BITS;
    integer shift_count = (0 - rb) % 64;
    if (shift_count > 31) begin
        rt[index +: WORD_BITS] = {WORD_BITS{ra[index]}};
    end else begin
        rt[index +: WORD_BITS] = ra[index +: WORD_BITS] >>> shift_count;
    end
end
return rt;
endfunction : rotate_and_mask_algebraic_word

function automatic logic[0:127] rotate_and_mask_algebraic_halfword (input logic[0:127] ra, input logic [0:127] rb);
logic[0:127] rt;

for (int i = 0; i < 8; ++i) begin
    int index = i * HALFWORD_BITS;
    integer shift_count = (0 - rb) % 32;
    if (shift_count > 15) begin
        rt[index +: HALFWORD_BITS] = {HALFWORD_BITS{ra[index]}};
    end else begin
        rt[index +: WORD_BITS] = ra[index +: HALFWORD_BITS] >>> shift_count;
    end
end
return rt;
endfunction : rotate_and_mask_algebraic_halfword





endmodule