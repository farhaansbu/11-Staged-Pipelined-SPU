module odd_pipe_unit (
    input logic clk,

    input logic [0:127] odd_source_a,
    input logic [0:127] odd_source_b,
    input logic [0:127] odd_source_c,
    input logic [0:6] odd_write_address,
    input opcode_t odd_opcode,
    input logic[0:2] odd_unit_id,

    output unit_result_packet odd_output_to_write_back,
    output unit_result_packet odd_branch_forwarded_res, // After second stage, 3rd cycle
    output unit_result_packet odd_stage_3_forwarded_res,
    output unit_result_packet odd_stage_4_forwarded_res,
    output unit_result_packet odd_stage_5_forwarded_res,
    output unit_result_packet odd_stage_6_forwarded_res
);



endmodule



