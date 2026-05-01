import instruction_pkg::*;
// First 7 stages of execution

module execution_unit(
    input logic clk,

    input logic [0:127] even_source_a,
    input logic [0:127] even_source_b,
    input logic [0:127] even_source_c,
    input logic [0:6] even_write_address,
    input opcode_t even_opcode,
    input logic[0:2] even_unit_id,
    input logic even_reg_write,

    input logic [0:127] odd_source_a,
    input logic [0:127] odd_source_b,
    input logic [0:127] odd_source_c,
    input logic [0:6] odd_write_address,
    input opcode_t odd_opcode,
    input logic[0:2] odd_unit_id,
    input logic odd_reg_write,
    input logic odd_first,

    output unit_result_packet even_output_to_write_back,
    output unit_result_packet odd_output_to_write_back,

    output unit_result_packet even_stage_2_forwarded_res, // After second stage, 3rd cycle
    output unit_result_packet even_stage_3_forwarded_res,
    output unit_result_packet even_stage_4_forwarded_res,
    output unit_result_packet even_stage_5_forwarded_res,
    output unit_result_packet even_stage_6_forwarded_res,

    output logic flush_all,
    output logic flush_after,
    output unit_result_packet odd_stage_1_forwarded_res, 
    output unit_result_packet odd_stage_2_forwarded_res,
    output unit_result_packet odd_stage_3_forwarded_res,
    output unit_result_packet odd_stage_4_forwarded_res,
    output unit_result_packet odd_stage_5_forwarded_res,
    output unit_result_packet odd_stage_6_forwarded_res
);

even_pipe_unit even_pipe(
    .clk(clk),
    .even_source_a(even_source_a),
    .even_source_b(even_source_b),
    .even_source_c(even_source_c),
    .even_write_address(even_write_address),
    .even_opcode(even_opcode),
    .even_unit_id(even_unit_id),
    .even_reg_write(even_reg_write),
    .even_output_to_write_back(even_output_to_write_back),
    .even_stage_2_forwarded_res(even_stage_2_forwarded_res),
    .even_stage_3_forwarded_res(even_stage_3_forwarded_res),
    .even_stage_4_forwarded_res(even_stage_4_forwarded_res),
    .even_stage_5_forwarded_res(even_stage_5_forwarded_res),
    .even_stage_6_forwarded_res(even_stage_6_forwarded_res)
);

odd_pipe_unit odd_pipe(
    .clk(clk),
    .odd_source_a(odd_source_a),
    .odd_source_b(odd_source_b),
    .odd_source_c(odd_source_c),
    .odd_write_address(odd_write_address),
    .odd_opcode(odd_opcode),
    .odd_unit_id(odd_unit_id),
    .odd_reg_write(odd_reg_write),
    .flush_all(flush_all),
    .flush_after(flush_after),
    .odd_first(odd_first),
    .odd_output_to_write_back(odd_output_to_write_back),
    .odd_stage_1_forwarded_res(odd_stage_1_forwarded_res),
    .odd_stage_2_forwarded_res(odd_stage_2_forwarded_res),
    .odd_stage_3_forwarded_res(odd_stage_3_forwarded_res),
    .odd_stage_4_forwarded_res(odd_stage_4_forwarded_res),
    .odd_stage_5_forwarded_res(odd_stage_5_forwarded_res),
    .odd_stage_6_forwarded_res(odd_stage_6_forwarded_res)
);





endmodule