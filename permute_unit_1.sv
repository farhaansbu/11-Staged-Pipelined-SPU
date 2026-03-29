import instruction_pkg::*;

module permute_unit(
    
    input logic clk,

    input logic [0:127] odd_source_a,
    input logic [0:127] odd_source_b,
    input logic [0:127] odd_source_c,
    input logic [0:6] odd_write_address,
    input opcode_t odd_opcode,
    input logic[0:2] odd_unit_id,

    output unit_result_packet output_packet
);

always_ff @(posedge clk) begin

    if (odd_unit_id != 5) begin // Unit id doesn't match
        output_packet.present_bit <= 0;
    end

    else begin
        // Record unit id, write addr, other control signals
        output_packet.unit_id <= odd_unit_id;
        output_packet.reg_write_addr <= odd_write_address;
        output_packet.reg_write_flag <= 1;
        output_packet.present_bit <= 1;
        output_packet.ready_stage_number <= 4;
        output_packet.current_stage_number <= 2;

        // Calculate result
        case (odd_opcode)

            //OP_ADD_WORD: output_packet.result <= add_word(source_a, source_b);
            OP_SHIFT_LEFT_QUADWORD_BY_BYTES: output_packet.result <= shift_left_quadword_by_bytes(odd_source_a, odd_source_b);
            OP_SHIFT_LEFT_QUADWORD_BY_BYTES_IMMEDIATE: output_packet.result <= shift_left_quadword_by_bytes(odd_source_a, odd_source_b[0:6]);
            OP_SHIFT_LEFT_QUADWORD_BY_BITS: output_packet.result <= shift_left_quadword_by_bits(odd_source_a, odd_source_b);
            OP_ROTATE_QUADWORD_BY_BYTES: output_packet.result <= rotate_quadword_by_bytes(odd_source_a, odd_source_b);
            OP_ROTATE_QUADWORD_BY_BYTES_IMMEDIATE: output_packet.result <= rotate_quadword_by_bytes_immediate(odd_source_a, odd_source_b[0:6]);
            OP_ROTATE_QUADWORD_BY_BITS: output_packet.result <= rotate_quadword_by_bits(odd_source_a, odd_source_b);
            OP_ROTATE_AND_MASK_QUADWORD_BY_BYTES: output_packet.result <= rotate_and_mask_quadword_by_bytes(odd_source_a, odd_source_b);
            default: ;
            
        endcase
    end
    

end

localparam BITS_BITS = 1;
localparam BYTE_BITS = 8;
localparam WORD_BITS = 32;
localparam HALFWORD_BITS = 16;

function automatic logic [0:127] shift_left_quadword_by_bytes (input logic [0:127] ra, input logic [0:127] rb);
    logic[0:127]rt;
    logic [0:4] s; //byte shift amount 

    s = rb[27:31];
    for (int b = 0; b <= 15; ++b) begin   
        if((b+s) <16) begin
            rt[b*BYTE_BITS +: BYTE_BITS] = ra[(b+s)*BYTE_BITS +: BYTE_BITS];
        end else begin
            rt[b*BYTE_BITS +: BYTE_BITS] = 8'b0;
        end
end

return rt;
endfunction : shift_left_quadword_by_bytes

function automatic logic [0:127] shift_left_quadword_by_bytes_immediate (input logic [0:127] ra, input logic [0:6] imm7);
    logic[0:127]rt;
    logic [0:6] s; //byte shift amount 

    s = imm7[2:6];  //keep bits 13-17 (2-6) of immediate

    for (int b = 0; b <= 15; ++b) begin   
        if((b+int'(s)) <16) begin
            rt[b*BYTE_BITS +: BYTE_BITS] = ra[(b+int'(s))*BYTE_BITS +: BYTE_BITS];
        end else begin
            rt[b*BYTE_BITS +: BYTE_BITS] = 8'b0;
        end
end

return rt;
endfunction : shift_left_quadword_by_bytes_immediate

function automatic logic [0:127] shift_left_quadword_by_bits (input logic [0:127] ra, input logic [0:127] rb);
    logic[0:127]rt;
    logic [0:2] s; //bit shift amount 

    s = rb[29:31];
    for (int b = 0; b <= 127; ++b) begin   
        if((b+int'(s)) <128) begin
            rt[b*BITS_BITS+: BITS_BITS] = ra[(b+int'(s))*BITS_BITS +: BITS_BITS];
        end else begin
            rt[b*BITS_BITS +: BITS_BITS] = 1'b0;
        end
end

return rt;
endfunction : shift_left_quadword_by_bits

function automatic logic [0:127] rotate_quadword_by_bytes (
    input logic [0:127] ra,
    input logic [0:127] rb
);
    logic [0:127] rt;
    logic [0:3] s; // 4 bits, rightmost 4 bits of RB preferred slot
    s = rb[28:31];

    for (int b = 0; b <= 15; ++b) begin
        if ((b + int'(s)) < 16) begin
            rt[b*BYTE_BITS +: BYTE_BITS] = ra[(b + int'(s))*BYTE_BITS +: BYTE_BITS];
        end else begin
            rt[b*BYTE_BITS +: BYTE_BITS] = ra[(b + int'(s) - 16)*BYTE_BITS +: BYTE_BITS];
        end
    end
    return rt;
endfunction : rotate_quadword_by_bytes

function automatic logic [0:127] rotate_quadword_by_bytes_immediate (
    input logic [0:127] ra,
    input logic [0:6] imm7
);
    logic [0:127] rt;
    logic [0:3] s; // rightmost 4 bits of I7
    s = imm7[3:6]; // bits 14-17 of I7 field = bits 3-6 of 7-bit immediate

    for (int b = 0; b <= 15; ++b) begin
        if ((b + int'(s)) < 16) begin
            rt[b*BYTE_BITS +: BYTE_BITS] = ra[(b + int'(s))*BYTE_BITS +: BYTE_BITS];
        end else begin
            rt[b*BYTE_BITS +: BYTE_BITS] = ra[(b + int'(s) - 16)*BYTE_BITS +: BYTE_BITS];
        end
    end
    return rt;
endfunction : rotate_quadword_by_bytes_immediate

function automatic logic [0:127] rotate_quadword_by_bits (
    input logic [0:127] ra,
    input logic [0:127] rb
);
    logic [0:127] rt;
    logic [0:2] s; // 3 bits, bits 29-31 of RB
    s = rb[29:31];

    for (int b = 0; b <= 127; ++b) begin
        if ((b + int'(s)) < 128) begin
            rt[b*BITS_BITS +: BITS_BITS] = ra[(b + int'(s))*BITS_BITS +: BITS_BITS];
        end else begin
            rt[b*BITS_BITS +: BITS_BITS] = ra[(b + int'(s) - 128)*BITS_BITS +: BITS_BITS];
        end
    end
    return rt;
endfunction : rotate_quadword_by_bits


function automatic logic [0:127] rotate_and_mask_quadword_by_bytes (
    input logic [0:127] ra,
    input logic [0:127] rb
);
    logic [0:127] rt;
    logic [0:4] s; // 5 bits, max value 31
    s = (5'd0 - rb[27:31]) & 5'h1F; // negation mod 32

    for (int b = 0; b <= 15; ++b) begin
        if (b >= int'(s)) begin
            rt[b*BYTE_BITS +: BYTE_BITS] = ra[(b - int'(s))*BYTE_BITS +: BYTE_BITS];
        end else begin
            rt[b*BYTE_BITS +: BYTE_BITS] = 8'h00; // zero fill left
        end
    end
    return rt;
endfunction : rotate_and_mask_quadword_by_bytes

endmodule