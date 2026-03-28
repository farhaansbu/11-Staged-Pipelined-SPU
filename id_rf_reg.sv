import instruction_pkg::*;

module id_rf_stage(

    // Inputs
    input logic clk,

    input logic[0:7] even_ra_addr,
    input logic[0:7] even_rb_addr,
    input logic[0:7] even_rc_addr,
    input logic[0:7] even_rt_addr,
    input instruction_type even_instruction_type,
    input opcode_t even_opcode,
    input logic even_register_write,
    input logic[0:2] even_unit_id,
    input logic[0:10] even_program_counter,

    input logic[0:7] odd_ra_addr,
    input logic[0:7] odd_rb_addr,
    input logic[0:7] odd_rc_addr,
    input logic[0:7] odd_rt_addr,
    input instruction_type odd_instruction_type,
    input opcode_t odd_opcode,
    input logic odd_register_write,
    input logic[0:2] odd_unit_id,
    input logic[0:10] odd_program_counter,


    // Outputs
    output logic[0:7] even_ra_addr_q,
    output logic[0:7] even_rb_addr_q,
    output logic[0:7] even_rc_addr_q,
    output logic[0:7] even_rt_addr_q,
    output instruction_type even_instruction_type_q,
    output opcode_t even_opcode_q,
    output logic even_register_write_q,
    output logic[0:2] even_unit_id_q,
    output logic[0:10] even_program_counter_q,

    output logic[0:7] odd_ra_addr_q,
    output logic[0:7] odd_rb_addr_q,
    output logic[0:7] odd_rc_addr_q,
    output logic[0:7] odd_rt_addr_q,
    output instruction_type odd_instruction_type_q,
    output opcode_t odd_opcode_q,
    output logic odd_register_write_q,
    output logic[0:2] odd_unit_id_q,
    output logic[0:10] odd_program_counter_q

);

always_ff @(posedge clk) begin
    even_ra_addr_q <= even_ra_addr;
    even_rb_addr_q <= even_rb_addr;
    even_rc_addr_q <= even_rc_addr;
    even_rt_addr_q <= even_rt_addr;
    even_instruction_type_q <= even_instruction_type;
    even_opcode_q <= even_opcode;
    even_register_write_q <= even_register_write;
    even_unit_id_q <= even_unit_id;
    even_program_counter_q <= even_program_counter;

    odd_ra_addr_q <= odd_ra_addr;
    odd_rb_addr_q <= odd_rb_addr;
    odd_rc_addr_q <= odd_rc_addr;
    odd_rt_addr_q <= odd_rt_addr;
    odd_instruction_type_q <= odd_instruction_type;
    odd_opcode_q <= odd_opcode;
    odd_register_write_q <= odd_register_write;
    odd_unit_id_q <= odd_unit_id;
    odd_program_counter_q <= odd_program_counter;

end


endmodule