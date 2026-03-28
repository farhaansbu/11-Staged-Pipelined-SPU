module branch_unit;

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

function automatic logic[0:31] branch_relative_and_set_link (ref logic[0:127] rt, input logic[0:15] i16, input logic signed[0:10] program_counter);
    logic signed[0:31] imm32 = {{14{i16[0]}}, i16, 2'b0};
    logic signed[0:31] branch_addr = (program_counter + imm32) & LSLR;

    rt[0:31] = (program_counter + 4) & LSLR;
    rt[32:127] = '0;
    return branch_addr;
endfunction : branch_relative_and_set_link


function automatic logic[0:31] branch_absolute_and_set_link (ref logic[0:127] rt, input logic[0:15] i16, input logic[0:10] program_counter);
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


function automatic logic[0:31] branch_if_zero_word (input logic[0:127] rt, input logic[0:15] i16, input logic[0:10] program_counter);
    logic[0:31] imm32 = {{14{i16[0]}}, i16, 2'b0};
    logic[0:31] branch_addr;

    if (rt[0:31] == 0) begin
        branch_addr = (program_counter + imm32) & LSLR & 32'hFFFF_FFFC;
    end else begin
        branch_addr = (program_counter + 4) & LSLR;
    end

    return branch_addr;
endfunction : branch_if_zero_word

function automatic logic[0:31] branch_if_zero_halfword (input logic[0:127] rt, input logic[0:15] i16, input logic[0:10] program_counter);
    logic[0:31] imm32 = {{14{i16[0]}}, i16, 2'b0};
    logic[0:31] branch_addr;

    if (rt[16:31] == 0) begin
        branch_addr = (program_counter + imm32) & LSLR & 32'hFFFF_FFFC;
    end else begin
        branch_addr = (program_counter + 4) & LSLR;
    end

    return branch_addr;
endfunction : branch_if_zero_halfword

function automatic logic[0:31] branch_if_not_zero_word (input logic[0:127] rt, input logic[0:15] i16, input logic[0:10] program_counter);
    logic[0:31] imm32 = {{14{i16[0]}}, i16, 2'b0};
    logic[0:31] branch_addr;

    if (rt[0:31] != 0) begin
        branch_addr = (program_counter + imm32) & LSLR & 32'hFFFF_FFFC;
    end else begin
        branch_addr = (program_counter + 4) & LSLR;
    end

    return branch_addr;
endfunction : branch_if_not_zero_word

function automatic logic[0:31] branch_if_not_zero_halfword (input logic[0:127] rt, input logic[0:15] i16, input logic[0:10] program_counter);
    logic[0:31] imm32 = {{14{i16[0]}}, i16, 2'b0};
    logic[0:31] branch_addr;

    if (rt[16:31] != 0) begin
        branch_addr = (program_counter + imm32) & LSLR & 32'hFFFF_FFFC;
    end else begin
        branch_addr = (program_counter + 4) & LSLR;
    end

    return branch_addr;
endfunction : branch_if_not_zero_halfword


function automatic logic[0:31] branch_indirect_if_zero (input logic[0:127] rt, input logic[0:127] ra, input logic[0:10] program_counter);
    logic[0:31] branch_addr;

    if (rt[0:31] == 0) begin
        branch_addr = ra[0:31] & LSLR & 32'hFFFF_FFFC;
    end else begin
        branch_addr = (program_counter + 4) & LSLR;
    end
    return branch_addr;
endfunction : branch_indirect_if_zero

function automatic logic[0:31] branch_indirect_if_zero_halfword (input logic[0:127] rt, input logic[0:127] ra, input logic[0:10] program_counter);
    logic[0:31] branch_addr;

    if (rt[16:31] == 0) begin
        branch_addr = ra[0:31] & LSLR & 32'hFFFF_FFFC;
    end else begin
        branch_addr = (program_counter + 4) & LSLR;
    end
    return branch_addr;
endfunction : branch_indirect_if_zero_halfword

function automatic logic[0:31] branch_indirect_if_not_zero (input logic[0:127] rt, input logic[0:127] ra, input logic[0:10] program_counter);
    logic[0:31] branch_addr;

    if (rt[0:31] != 0) begin
        branch_addr = ra[0:31] & LSLR & 32'hFFFF_FFFC;
    end else begin
        branch_addr = (program_counter + 4) & LSLR;
    end
    return branch_addr;
endfunction : branch_indirect_if_not_zero

function automatic logic[0:31] branch_indirect_if_not_zero_halfword (input logic[0:127] rt, input logic[0:127] ra, input logic[0:10] program_counter);
    logic[0:31] branch_addr;

    if (rt[16:31] != 0) begin
        branch_addr = ra[0:31] & LSLR & 32'hFFFF_FFFC;
    end else begin
        branch_addr = (program_counter + 4) & LSLR;
    end
    return branch_addr;
endfunction : branch_indirect_if_not_zero_halfword



endmodule