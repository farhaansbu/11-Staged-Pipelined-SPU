import instruction_pkg::*;

module rf_ex_reg (
    
    input logic clk,
    input logic flush,
    
    input logic[0:6] even_write_addr,
    input logic[0:127] even_source_a,
    input logic[0:127] even_source_b,
    input logic[0:127] even_source_c,
    input opcode_t even_opcode,
    input logic[0:2] even_unit_id,
    input logic even_reg_write,

    
    input logic[0:6] odd_write_addr,
    input logic[0:127] odd_source_a,
    input logic[0:127] odd_source_b,
    input logic[0:127] odd_source_c,
    input opcode_t odd_opcode,
    input logic[0:2] odd_unit_id,
    input logic odd_reg_write,
    input logic odd_first,

    output logic[0:6] even_write_addr_q,
    output logic[0:127] even_source_a_q,
    output logic[0:127] even_source_b_q,
    output logic[0:127] even_source_c_q,
    output opcode_t even_opcode_q,
    output logic[0:2] even_unit_id_q,
    output logic even_reg_write_q,

    
    output logic[0:6] odd_write_addr_q,
    output logic[0:127] odd_source_a_q,
    output logic[0:127] odd_source_b_q,
    output logic[0:127] odd_source_c_q,
    output opcode_t odd_opcode_q,
    output logic[0:2] odd_unit_id_q,
    output logic odd_reg_write_q,
    output logic odd_first_q

);

always_ff @(posedge clk) begin

    if (flush) begin
        even_opcode_q <= OP_NO_OP_HARDWARE;
        even_reg_write_q <= 0;
        even_unit_id_q <= 0;

        odd_opcode_q <= OP_NO_OP_HARDWARE;
        odd_reg_write_q <= 0;
        odd_unit_id_q <= 0;
    end

    else begin
            even_write_addr_q <= even_write_addr;
            even_source_a_q <= even_source_a;
            even_source_b_q <= even_source_b;
            even_source_c_q <= even_source_c;
            even_opcode_q <= even_opcode;
            even_unit_id_q <= even_unit_id;
            even_reg_write_q <= even_reg_write;

            odd_write_addr_q <= odd_write_addr;
            odd_source_a_q <= odd_source_a;
            odd_source_b_q <= odd_source_b;
            odd_source_c_q <= odd_source_c;
            odd_opcode_q <= odd_opcode;
            odd_unit_id_q <= odd_unit_id;
            odd_reg_write_q <= odd_reg_write;
            odd_first_q <= odd_first;
    end


end


endmodule

