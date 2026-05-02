import instruction_pkg::*;

module single_precision_1(

    input logic clk,
    input logic flush_stage_1,

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

    if (even_unit_id != 3) begin // Unit id doesn't match
        output_packet.present_bit <= 0;
    end

    else begin
        // Record unit id, write addr, other control signals
        output_packet.unit_id <= even_unit_id;
        output_packet.reg_write_addr <= write_address;
        if (flush_stage_1) begin
            output_packet.reg_write_flag <= 0;
        end
        else begin
            output_packet.reg_write_flag <= reg_write;
        end
        output_packet.present_bit <= 1;
        output_packet.current_stage_number <= 2;

        // Calculate result
        case (opcode)
            OP_MULTIPLY: begin
                output_packet.ready_stage_number <= 8;
                output_packet.result <= multiply(source_a, source_b);
            end

            OP_MULTIPLY_UNSIGNED: begin
                output_packet.ready_stage_number <= 8;
                output_packet.result <= multiply_unsigned(source_a, source_b);
            end

            OP_MULTIPLY_IMMEDIATE: begin
                output_packet.ready_stage_number <= 8;
                output_packet.result <= multiply_immediate(source_a, source_b[0:9]);
            end

            OP_MULTIPLY_UNSIGNED_IMMEDIATE: begin
                output_packet.ready_stage_number <= 8;
                output_packet.result <= multiply_unsigned_immediate(source_a, source_b[0:9]);
            end

            OP_MULTIPLY_AND_ADD: begin
                output_packet.ready_stage_number <= 8;
                output_packet.result <= multiply_and_add(source_a, source_b, source_c);
            end

            OP_FLOATING_ADD: begin
                output_packet.ready_stage_number <= 7;
                output_packet.result <= floating_add(source_a, source_b);
            end

            OP_FLOATING_SUBTRACT: begin
                output_packet.ready_stage_number <= 7;
                output_packet.result <= floating_subtract(source_a, source_b);
            end

            OP_FLOATING_MULTIPLY: begin
                output_packet.ready_stage_number <= 7;
                output_packet.result <= floating_multiply(source_a, source_b);
            end

            OP_FLOATING_MULTIPLY_AND_ADD: begin
                output_packet.ready_stage_number <= 7;
                output_packet.result <= floating_multiply_and_add(source_a, source_b, source_c);
            end

            OP_FLOATING_NEGATIVE_MULTIPLY_AND_SUBTRACT: begin
                output_packet.ready_stage_number <= 7;
                output_packet.result <= floating_negative_multiply_and_subtract(source_a, source_b, source_c);
            end

            OP_FLOATING_MULTIPLY_AND_SUBTRACT: begin
                output_packet.ready_stage_number <= 7;
                output_packet.result <= floating_multiply_and_subtract(source_a, source_b, source_c);
            end

            OP_FLOATING_COMPARE_EQUAL: begin
                output_packet.ready_stage_number <= 7;
                output_packet.result <= floating_compare_equal(source_a, source_b);
            end

            OP_FLOATING_COMPARE_MAGNITUDE_EQUAL: begin
                output_packet.ready_stage_number <= 7;
                output_packet.result <= floating_compare_magnitude_equal(source_a, source_b);
            end

            OP_FLOATING_COMPARE_GREATER_THAN: begin
                output_packet.ready_stage_number <= 7;
                output_packet.result <= floating_compare_greater_than(source_a, source_b);
            end

            OP_FLOATING_COMPARE_MAGNITUDE_GREATER_THAN: begin
                output_packet.ready_stage_number <= 7;
                output_packet.result <= floating_compare_magnitude_greater_than(source_a, source_b);
            end

            default: ;
            
        endcase
    end
end

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
        shortreal result = a_flt + b_flt;
        rt[index +: WORD_BITS] = $shortrealtobits((result));
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