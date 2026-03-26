module fixed_point_1;

localparam WORD_BITS = 32;
localparam shortreal S_max = 6.8e+38;
localparam shortreal S_min = 1.2e-38;


// helper functions
function automatic real abs_real(real x);
    if (x >= 0.0) begin
      abs_real = x;
    end else begin
      abs_real = -1.0 * x;
    end
endfunction

function automatic shortreal abs_shortreal(shortreal x);
    if (x >= 0.0) begin
      abs_shortreal = x;
    end else begin
      abs_shortreal = -1.0 * x;
    end
endfunction

function automatic shortreal saturate_real(real result);
    if (result > 0 && abs_real(result) > S_max) begin
        saturate_real = S_max;
    end 
    else if (result < 0 && abs_real(result) > S_max) begin
        saturate_real = S_max * -1.0;
    end
    else if (result > 0 && abs_real(result) < S_min) begin
        saturate_real = S_min;
    end 
    else if (result < 0 && abs_real(result) < S_min) begin
        saturate_real = S_min * -1.0;
    end
endfunction

function automatic logic[0:127] multiply (input logic[0:127] ra, input logic[0:127] rb);
    logic[0:127] rt;

    for (int i = 0; i < 4; ++i) begin
        int index = i * WORD_BITS;
        logic signed[0:15] a_s = ra[index+16 +: 16];
        logic signed[0:15] b_s = rb[index+16 +: 16];
        logic signed[0:31] product = a_s * b_s;
        rt[index +: WORD_BITS] = product;
    end
    return rt;
endfunction : multiply

function automatic logic[0:127] multiply_unsigned (input logic[0:127] ra, input logic[0:127] rb);
    logic[0:127] rt;

    for (int i = 0; i < 4; ++i) begin
        int index = i * WORD_BITS;
        rt[index +: WORD_BITS] = ra[index+16 +: 16] * rb[index+16 +: 16];    
    end
    return rt;
endfunction : multiply_unsigned

function automatic logic[0:127] multiply_immediate (input logic[0:127] ra, input logic[0:9] i10);
    logic[0:127] rt;
    logic signed[0:15] imm16 = {{6{i10[0]}}, i10};

    for (int i = 0; i < 4; ++i) begin
        int index = i * WORD_BITS;
        logic signed[0:15] a_s = ra[index+16 +: 16];
        logic signed[0:31] product = a_s * imm16;
        rt[index +: WORD_BITS] = product;   
    end
    return rt;
endfunction : multiply_immediate

function automatic logic[0:127] multiply_unsigned_immediate (input logic[0:127] ra, input logic[0:9] i10);
    logic[0:127] rt;
    logic[0:15] imm16 = {{6{i10[0]}}, i10};

    for (int i = 0; i < 4; ++i) begin
        int index = i * WORD_BITS;
        rt[index +: WORD_BITS] = ra[index+16 +: 16] * imm16;
    end
    return rt;
endfunction : multiply_unsigned_immediate

function automatic logic[0:127] multiply_and_add (input logic[0:127] ra, input logic[0:127] rb, input logic[0:127] rc);
    logic[0:127] rt;

    for (int i = 0; i < 4; ++i) begin
        int index = i * WORD_BITS;
        logic signed[0:15] a_s = ra[index+16 +: 16];
        logic signed[0:15] b_s = rb[index+16 +: 16];
        logic signed[0:31] product = a_s * b_s;
        logic signed [0:31] add_term = rc[index +: 32];
        rt[index +: WORD_BITS] = unsigned'(product + add_term);
    end
    return rt;
endfunction : multiply_and_add

function automatic logic[0:127] floating_add (input logic[0:127] ra, input logic[0:127] rb);
    logic[0:127] rt;

    for (int i = 0; i < 4; ++i) begin
        int index = i * WORD_BITS;
        shortreal a_flt = $bitstoshortreal(ra[index +: WORD_BITS]);
        shortreal b_flt = $bitstoshortreal(rb[index +: WORD_BITS]);
        real result = a_flt + b_flt;
        rt[index +: WORD_BITS] = $shortrealtobits(saturate_real(result));
    end
    return rt;
endfunction : floating_add

function automatic logic[0:127] floating_subtract (input logic[0:127] ra, input logic[0:127] rb);
    logic[0:127] rt;

    for (int i = 0; i < 4; ++i) begin
        int index = i * WORD_BITS;
        shortreal a_flt = $bitstoshortreal(ra[index +: WORD_BITS]);
        shortreal b_flt = $bitstoshortreal(rb[index +: WORD_BITS]);
        real result = a_flt - b_flt;
        rt[index +: WORD_BITS] = $shortrealtobits(saturate_real(result));
    end
    return rt;
endfunction : floating_subtract

function automatic logic[0:127] floating_multiply (input logic[0:127] ra, input logic[0:127] rb);
    logic[0:127] rt;

    for (int i = 0; i < 4; ++i) begin
        int index = i * WORD_BITS;
        shortreal a_flt = $bitstoshortreal(ra[index +: WORD_BITS]);
        shortreal b_flt = $bitstoshortreal(rb[index +: WORD_BITS]);
        real result = a_flt * b_flt;
        rt[index +: WORD_BITS] = $shortrealtobits(saturate_real(result));
    end
    return rt;
endfunction : floating_multiply

function automatic logic[0:127] floating_multiply_and_add (input logic[0:127] ra, input logic[0:127] rb, input logic[0:127] rc);
    logic[0:127] rt;

    for (int i = 0; i < 4; ++i) begin
        int index = i * WORD_BITS;
        shortreal a_flt = $bitstoshortreal(ra[index +: WORD_BITS]);
        shortreal b_flt = $bitstoshortreal(rb[index +: WORD_BITS]);
        shortreal c_flt = $bitstoshortreal(rc[index +: WORD_BITS]);
        real result = a_flt * b_flt + c_flt;
        rt[index +: WORD_BITS] = $shortrealtobits(saturate_real(result));
    end
    return rt;
endfunction : floating_multiply_and_add

function automatic logic[0:127] floating_negative_multiply_and_subtract (input logic[0:127] ra, input logic[0:127] rb, input logic[0:127] rc);
    logic[0:127] rt;

    for (int i = 0; i < 4; ++i) begin
        int index = i * WORD_BITS;
        shortreal a_flt = $bitstoshortreal(ra[index +: WORD_BITS]);
        shortreal b_flt = $bitstoshortreal(rb[index +: WORD_BITS]);
        shortreal c_flt = $bitstoshortreal(rc[index +: WORD_BITS]);
        real result = c_flt - (a_flt * b_flt);
        rt[index +: WORD_BITS] = $shortrealtobits(saturate_real(result));
    end
    return rt;
endfunction : floating_negative_multiply_and_subtract

function automatic logic[0:127] floating_multiply_and_subtract (input logic[0:127] ra, input logic[0:127] rb, input logic[0:127] rc);
    logic[0:127] rt;

    for (int i = 0; i < 4; ++i) begin
        int index = i * WORD_BITS;
        shortreal a_flt = $bitstoshortreal(ra[index +: WORD_BITS]);
        shortreal b_flt = $bitstoshortreal(rb[index +: WORD_BITS]);
        shortreal c_flt = $bitstoshortreal(rc[index +: WORD_BITS]);
        real result = (a_flt * b_flt) - c_flt;
        rt[index +: WORD_BITS] = $shortrealtobits(saturate_real(result));
    end
    return rt;
endfunction : floating_multiply_and_subtract

function automatic logic[0:127] floating_compare_equal (input logic[0:127] ra, input logic[0:127] rb);
    logic[0:127] rt;

    for (int i = 0; i < 4; ++i) begin
        int index = i * WORD_BITS;

        logic[0:31] a_bits = ra[index +: WORD_BITS];
        logic[0:31] b_bits = rb[index +: WORD_BITS];

        shortreal a_flt = $bitstoshortreal(a_bits);
        shortreal b_flt = $bitstoshortreal(b_bits);

        logic a_is_zero = ((a_bits & 32'h7FFF_FFFF) == 32'h0000_0000);
        logic b_is_zero = ((b_bits & 32'h7FFF_FFFF) == 32'h0000_0000);

        if ((a_is_zero && b_is_zero) || (a_flt == b_flt)) begin
            rt[index +: WORD_BITS] = '1;
        end else begin
            rt[index +: WORD_BITS] = '0;
        end
    end
    return rt;
endfunction : floating_compare_equal

function automatic logic[0:127] floating_compare_magnitude_equal (input logic[0:127] ra, input logic[0:127] rb);
    logic[0:127] rt;

    for (int i = 0; i < 4; ++i) begin
         int index = i * WORD_BITS;
        logic [31:0] a_bits = ra[index +: WORD_BITS];
        logic [31:0] b_bits = rb[index +: WORD_BITS];

        if ( (a_bits & 32'h7FFF_FFFF) == (b_bits & 32'h7FFF_FFFF) ) // Ignore sign bit
            rt[index +: WORD_BITS] = '1;
        else
            rt[index +: WORD_BITS] = '0;
    end
    return rt;
endfunction : floating_compare_magnitude_equal

function automatic logic[0:127] floating_compare_greater_than (input logic[0:127] ra, input logic[0:127] rb);
    logic[0:127] rt;

    for (int i = 0; i < 4; ++i) begin
        int index = i * WORD_BITS;

        logic[0:31] a_bits = ra[index +: WORD_BITS];
        logic[0:31] b_bits = rb[index +: WORD_BITS];

        shortreal a_flt = $bitstoshortreal(a_bits);
        shortreal b_flt = $bitstoshortreal(b_bits);

        logic a_is_zero = ((a_bits & 32'h7FFF_FFFF) == 32'h0000_0000);
        logic b_is_zero = ((b_bits & 32'h7FFF_FFFF) == 32'h0000_0000);

        if (a_is_zero && b_is_zero) begin
            rt[index +: WORD_BITS] = '0;
        end
        else if (a_flt > b_flt) begin
            rt[index +: WORD_BITS] = '1;
        end else begin
            rt[index +: WORD_BITS] = '0;
        end
    end
    return rt;
endfunction : floating_compare_greater_than

function automatic logic[0:127] floating_compare_magnitude_greater_than (input logic[0:127] ra, input logic[0:127] rb);
    logic[0:127] rt;

    for (int i = 0; i < 4; ++i) begin
        int index = i * WORD_BITS;

        logic[0:31] a_bits = ra[index +: WORD_BITS];
        logic[0:31] b_bits = rb[index +: WORD_BITS];

        shortreal a_flt = $bitstoshortreal(a_bits);
        shortreal b_flt = $bitstoshortreal(b_bits);

        logic a_is_zero = ((a_bits & 32'h7FFF_FFFF) == 32'h0000_0000);
        logic b_is_zero = ((b_bits & 32'h7FFF_FFFF) == 32'h0000_0000);

        if (a_is_zero && b_is_zero) begin
            rt[index +: WORD_BITS] = '0;
        end
        else if (abs_shortreal(a_flt) > abs_shortreal(b_flt)) begin
            rt[index +: WORD_BITS] = '1;
        end else begin
            rt[index +: WORD_BITS] = '0;
        end
    end
    return rt;
endfunction : floating_compare_magnitude_greater_than

endmodule