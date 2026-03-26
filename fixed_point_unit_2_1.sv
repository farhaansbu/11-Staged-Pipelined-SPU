module simple_fixed_2_1;

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