import instruction_pkg::*;

module branch_unit(
    input logic clk,

    input logic [0:127] odd_source_a,
    input logic [0:127] odd_source_b,
    input logic [0:127] odd_source_c,
    input logic [0:6] odd_write_address,
    input opcode_t odd_opcode,
    input logic[0:2] odd_unit_id,
    input logic reg_write,
    input logic odd_first,

    output unit_result_packet output_packet,
    output logic flush_all,
    output logic flush_after
);

logic[0:127] rt_for_set_link;

always_ff @(posedge clk) begin

    if (odd_unit_id != 7) begin // Unit id doesn't match
        output_packet.present_bit <= 0;
        flush_all <= 0; 
        flush_after <= 0;
    end

    else begin
        // Record unit id, write addr, other control signals
        output_packet.unit_id <= odd_unit_id;
        output_packet.reg_write_addr <= odd_write_address;
        output_packet.reg_write_flag <= reg_write;
        output_packet.present_bit <= 1;
        output_packet.ready_stage_number <= 2;
        output_packet.current_stage_number <= 2;
        flush_all = 0;
        flush_after = 0;

        // Calculate result
        case (odd_opcode)

        OP_BRANCH_RELATIVE: begin
            output_packet.branch_addr <= branch_relative(odd_source_a[0:15], odd_source_c[0:10]);
            if (odd_first) begin
                flush_all = 1;
            end else begin
                flush_after = 1;
            end
        end

        OP_BRANCH_ABSOLUTE: begin
            output_packet.branch_addr <= branch_absolute(odd_source_a[0:15]);
            if (odd_first) begin
                flush_all = 1;
            end else begin
                flush_after = 1;
            end
        end

        OP_BRANCH_INDIRECT: begin
            output_packet.branch_addr <= branch_indirect(odd_source_a);
            if (odd_first) begin
                flush_all = 1;
            end else begin
                flush_after = 1;
            end
        end

        OP_BRANCH_RELATIVE_AND_SET_LINK: begin
            output_packet.branch_addr <= branch_relative_and_set_link(odd_source_a[0:15], rt_for_set_link, odd_source_c[0:10]);
            if (odd_first) begin
                flush_all = 1;
            end else begin
                flush_after = 1;
            end
            output_packet.result <= rt_for_set_link;
        end

        OP_BRANCH_ABSOLUTE_AND_SET_LINK: begin
            output_packet.branch_addr <= branch_absolute_and_set_link(odd_source_a[0:15], rt_for_set_link, odd_source_c[0:10]);
            if (odd_first) begin
                flush_all = 1;
            end else begin
                flush_after = 1;
            end
            output_packet.result <= rt_for_set_link;
        end

        OP_BRANCH_INDIRECT_AND_SET_LINK: begin
            output_packet.branch_addr <= branch_indirect_and_set_link(rt_for_set_link, odd_source_a, odd_source_c[0:10]);
            if (odd_first) begin
                flush_all = 1;
            end else begin
                flush_after = 1;
            end
            output_packet.result <= rt_for_set_link;
        end

        OP_BRANCH_IF_ZERO_WORD: begin
            output_packet.branch_addr <= branch_if_zero_word(odd_source_a[0:15], odd_source_b, odd_source_c[0:10]);
        end

        OP_BRANCH_IF_ZERO_HALFWORD: begin
            output_packet.branch_addr <= branch_if_zero_halfword(odd_source_a[0:15], odd_source_b, odd_source_c[0:10]);
        end

        OP_BRANCH_IF_NOT_ZERO_WORD: begin
            output_packet.branch_addr <= branch_if_not_zero_word(odd_source_a[0:15], odd_source_b, odd_source_c[0:10]);
        end

        OP_BRANCH_IF_NOT_ZERO_HALFWORD: begin
            output_packet.branch_addr <= branch_if_not_zero_halfword(odd_source_a[0:15], odd_source_b, odd_source_c[0:10]);
        end

        OP_BRANCH_INDIRECT_IF_ZERO: begin
            output_packet.branch_addr <= branch_indirect_if_zero(odd_source_a, odd_source_b, odd_source_c[0:10]);
        end

        OP_BRANCH_INDIRECT_IF_ZERO_HALFWORD: begin
            output_packet.branch_addr <= branch_indirect_if_zero_halfword(odd_source_a, odd_source_b, odd_source_c[0:10]);
        end

        OP_BRANCH_INDIRECT_IF_NOT_ZERO: begin
            output_packet.branch_addr <= branch_indirect_if_not_zero(odd_source_a, odd_source_b, odd_source_c[0:10]);
        end

        OP_BRANCH_INDIRECT_IF_NOT_ZERO_HALFWORD: begin
            output_packet.branch_addr <= branch_indirect_if_not_zero_halfword(odd_source_a, odd_source_b, odd_source_c[0:10]);
        end

        default: ;

        endcase

    end
end

localparam logic[0:32] LSLR = 32'h0000_7FFF;    // max size of memory 32 KB (32768 bytes)


function automatic logic[0:31] branch_relative (input logic[0:15] i16, input logic signed[0:10] program_counter);
    logic signed[0:31] imm32 = {{14{i16[0]}}, i16, 2'b0};   
    logic signed[0:31] branch_addr = (program_counter + imm32) & LSLR;
    return branch_addr;
endfunction : branch_relative

function automatic logic[0:31] branch_absolute (input logic[0:15] i16);
    logic[0:31] imm32 = {{14{i16[0]}}, i16, 2'b0};
    logic[0:31] branch_addr = imm32 & LSLR;
    return branch_addr; 
endfunction : branch_absolute

function automatic logic[0:31] branch_indirect (input logic[0:127] ra);
    logic[0:31] branch_addr = ra[0:31] & LSLR & 32'hFFFF_FFFC;
    return branch_addr; 
endfunction : branch_indirect

function automatic logic[0:31] branch_relative_and_set_link (input logic[0:15] i16, ref logic[0:127] rt, input logic signed[0:10] program_counter);
    logic signed[0:31] imm32 = {{14{i16[0]}}, i16, 2'b0};
    logic signed[0:31] branch_addr = (program_counter + imm32) & LSLR;

    rt[0:31] = (program_counter + 4) & LSLR;
    rt[32:127] = '0;
    return branch_addr;
endfunction : branch_relative_and_set_link


function automatic logic[0:31] branch_absolute_and_set_link (input logic[0:15] i16, ref logic[0:127] rt, input logic[0:10] program_counter);
    logic[0:31] imm32 = {{14{i16[0]}}, i16, 2'b0};
    logic[0:31] branch_addr = imm32 & LSLR;

    rt[0:31] = (program_counter + 4) & LSLR;
    rt[32:127] = '0;
    return branch_addr; 
endfunction : branch_absolute_and_set_link


function automatic logic[0:31] branch_indirect_and_set_link (ref logic[0:127] rt, input logic[0:127] ra, input logic[0:10] program_counter);
    logic[0:31] branch_addr = ra[0:31] & LSLR & 32'hFFFF_FFFC;

    rt[0:31] = (program_counter + 4) & LSLR;
    rt[32:127] = '0;
    return branch_addr; 
endfunction : branch_indirect_and_set_link


function automatic logic[0:31] branch_if_zero_word (input logic[0:15] i16, input logic[0:127] rt, input logic[0:10] program_counter);
    logic[0:31] imm32 = {{14{i16[0]}}, i16, 2'b0};
    logic[0:31] branch_addr;

    if (rt[0:31] == 0) begin
        branch_addr = (program_counter + imm32) & LSLR & 32'hFFFF_FFFC;
        if (odd_first) begin
                flush_all = 1;
        end else begin
                flush_after = 1;
        end
    end else begin
        branch_addr = (program_counter + 4) & LSLR;
    end

    return branch_addr;
endfunction : branch_if_zero_word

function automatic logic[0:31] branch_if_zero_halfword (input logic[0:15] i16, input logic[0:127] rt, input logic[0:10] program_counter);
    logic[0:31] imm32 = {{14{i16[0]}}, i16, 2'b0};
    logic[0:31] branch_addr;

    if (rt[16:31] == 0) begin
        branch_addr = (program_counter + imm32) & LSLR & 32'hFFFF_FFFC;
        if (odd_first) begin
                flush_all = 1;
        end else begin
                flush_after = 1;
        end
    end else begin
        branch_addr = (program_counter + 4) & LSLR;
    end

    return branch_addr;
endfunction : branch_if_zero_halfword

function automatic logic[0:31] branch_if_not_zero_word (input logic[0:15] i16, input logic[0:127] rt, input logic[0:10] program_counter);
    logic[0:31] imm32 = {{14{i16[0]}}, i16, 2'b0};
    logic[0:31] branch_addr;

    if (rt[0:31] != 0) begin
        branch_addr = (program_counter + imm32) & LSLR & 32'hFFFF_FFFC;
        if (odd_first) begin
                flush_all = 1;
        end else begin
                flush_after = 1;
        end
    end else begin
        branch_addr = (program_counter + 4) & LSLR;
    end

    return branch_addr;
endfunction : branch_if_not_zero_word

function automatic logic[0:31] branch_if_not_zero_halfword (input logic[0:15] i16, input logic[0:127] rt, input logic[0:10] program_counter);
    logic[0:31] imm32 = {{14{i16[0]}}, i16, 2'b0};
    logic[0:31] branch_addr;

    if (rt[16:31] != 0) begin
        branch_addr = (program_counter + imm32) & LSLR & 32'hFFFF_FFFC;
        if (odd_first) begin
                flush_all = 1;
        end else begin
                flush_after = 1;
        end
    end else begin
        branch_addr = (program_counter + 4) & LSLR;
    end

    return branch_addr;
endfunction : branch_if_not_zero_halfword


function automatic logic[0:31] branch_indirect_if_zero (input logic[0:127] ra, input logic[0:127] rt, input logic[0:10] program_counter);
    logic[0:31] branch_addr;

    if (rt[0:31] == 0) begin
        branch_addr = ra[0:31] & LSLR & 32'hFFFF_FFFC;
        if (odd_first) begin
                flush_all = 1;
        end else begin
                flush_after = 1;
        end
    end else begin
        branch_addr = (program_counter + 4) & LSLR;
    end
    return branch_addr;
endfunction : branch_indirect_if_zero

function automatic logic[0:31] branch_indirect_if_zero_halfword (input logic[0:127] ra, input logic[0:127] rt, input logic[0:10] program_counter);
    logic[0:31] branch_addr;

    if (rt[16:31] == 0) begin
        branch_addr = ra[0:31] & LSLR & 32'hFFFF_FFFC;
        if (odd_first) begin
                flush_all = 1;
        end else begin
                flush_after = 1;
        end
    end else begin
        branch_addr = (program_counter + 4) & LSLR;
    end
    return branch_addr;
endfunction : branch_indirect_if_zero_halfword

function automatic logic[0:31] branch_indirect_if_not_zero (input logic[0:127] ra, input logic[0:127] rt, input logic[0:10] program_counter);
    logic[0:31] branch_addr;

    if (rt[0:31] != 0) begin
        branch_addr = ra[0:31] & LSLR & 32'hFFFF_FFFC;
        if (odd_first) begin
                flush_all = 1;
        end else begin
                flush_after = 1;
        end
    end else begin
        branch_addr = (program_counter + 4) & LSLR;
    end
    return branch_addr;
endfunction : branch_indirect_if_not_zero

function automatic logic[0:31] branch_indirect_if_not_zero_halfword (input logic[0:127] ra, input logic[0:127] rt, input logic[0:10] program_counter);
    logic[0:31] branch_addr;

    if (rt[16:31] != 0) begin
        branch_addr = ra[0:31] & LSLR & 32'hFFFF_FFFC;
        if (odd_first) begin
                flush_all = 1;
        end else begin
                flush_after = 1;
        end
    end else begin
        branch_addr = (program_counter + 4) & LSLR;
    end
    return branch_addr;
endfunction : branch_indirect_if_not_zero_halfword



endmodule