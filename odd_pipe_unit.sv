import instruction_pkg::*;

module odd_pipe_unit (
    input logic clk,
    input logic flush_stage_1,

    input logic [0:127] odd_source_a,
    input logic [0:127] odd_source_b,
    input logic [0:127] odd_source_c,
    input logic [0:6] odd_write_address,
    input opcode_t odd_opcode,
    input logic[0:2] odd_unit_id,
    input logic odd_reg_write,
    input logic odd_first,

    output logic flush_all,
    output logic flush_after,
    output unit_result_packet odd_output_to_write_back,
    output unit_result_packet odd_stage_1_forwarded_res,
    output unit_result_packet odd_stage_2_forwarded_res, // After second stage, 3rd cycle
    output unit_result_packet odd_stage_3_forwarded_res,
    output unit_result_packet odd_stage_4_forwarded_res,
    output unit_result_packet odd_stage_5_forwarded_res,
    output unit_result_packet odd_stage_6_forwarded_res
);

unit_result_packet perm_1_output;
unit_result_packet perm_2_output;
unit_result_packet perm_3_output;

unit_result_packet ls_1_output;
unit_result_packet ls_2_output;
unit_result_packet ls_3_output;
unit_result_packet ls_4_output;
unit_result_packet ls_5_output;
unit_result_packet ls_6_output;

unit_result_packet fw_odd_4_output;
unit_result_packet fw_odd_5_output;
unit_result_packet fw_odd_6_output;

unit_result_packet odd_stage_6_mux_output;


// Branch unit
branch_unit branch_1 (
    .clk(clk),
    .flush_stage_1(flush_stage_1),
    .odd_source_a(odd_source_a),
    .odd_source_b(odd_source_b),
    .odd_source_c(odd_source_c),
    .odd_write_address(odd_write_address),
    .odd_opcode(odd_opcode),
    .odd_unit_id(odd_unit_id),
    .reg_write(odd_reg_write),
    .odd_first(odd_first),
    .output_packet(odd_stage_1_forwarded_res),
    .flush_all(flush_all),
    .flush_after(flush_after)
);

// Permute
permute_unit permute_1 (
    .clk(clk),
    .flush_stage_1(flush_stage_1),
    .odd_source_a(odd_source_a),
    .odd_source_b(odd_source_b),
    .odd_source_c(odd_source_c),
    .odd_write_address(odd_write_address),
    .odd_opcode(odd_opcode),
    .odd_unit_id(odd_unit_id),
    .reg_write(odd_reg_write),
    .output_packet(perm_1_output)
);

execution_pipe_register permute_2 (
    .clk(clk),
    .unit_packet(perm_1_output),
    .unit_packet_q(perm_2_output)
);

execution_pipe_register permute_3 (
    .clk(clk),
    .unit_packet(perm_2_output),
    .unit_packet_q(perm_3_output)
);

// Forwarding pipeline registers
execution_pipe_register forward_odd4 (
    .clk(clk),
    .unit_packet(perm_3_output),
    .unit_packet_q(fw_odd_4_output)
);

execution_pipe_register forward_odd5 (
    .clk(clk),
    .unit_packet(fw_odd_4_output),
    .unit_packet_q(fw_odd_5_output)
);

execution_pipe_register forward_odd6 (
    .clk(clk),
    .unit_packet(fw_odd_5_output),
    .unit_packet_q(fw_odd_6_output)
);

// Local Store Unit
local_store_unit local_store_1(
    .clk(clk),
    .flush_stage_1(flush_stage_1),
    .odd_source_a(odd_source_a),
    .odd_source_b(odd_source_b),
    .odd_source_c(odd_source_c),
    .odd_write_address(odd_write_address),
    .odd_opcode(odd_opcode),
    .odd_unit_id(odd_unit_id),
    .reg_write(odd_reg_write),
    .output_packet(ls_1_output)
);

execution_pipe_register ls_2 (
    .clk(clk),
    .unit_packet(ls_1_output),
    .unit_packet_q(ls_2_output)
);

execution_pipe_register ls_3 (
    .clk(clk),
    .unit_packet(ls_2_output),
    .unit_packet_q(ls_3_output)
);
execution_pipe_register ls_4 (
    .clk(clk),
    .unit_packet(ls_3_output),
    .unit_packet_q(ls_4_output)
);
execution_pipe_register ls_5 (
    .clk(clk),
    .unit_packet(ls_4_output),
    .unit_packet_q(ls_5_output)
);

execution_pipe_register ls_6 (
    .clk(clk),
    .unit_packet(ls_5_output),
    .unit_packet_q(ls_6_output)
);

execution_pipe_mux #(.NUM_INPUTS(2)) fw_odd_7_mux (
    .input_packets('{ls_6_output, fw_odd_6_output}),
    .output_packet(odd_stage_6_mux_output)
);

execution_pipe_register forward_odd7 (
    .clk(clk),
    .unit_packet(odd_stage_6_mux_output),
    .unit_packet_q(odd_output_to_write_back)
);



always_comb begin : odd_pipe_body

    odd_stage_3_forwarded_res = perm_3_output;
    odd_stage_4_forwarded_res = fw_odd_4_output;
    odd_stage_5_forwarded_res = fw_odd_5_output;
    odd_stage_6_forwarded_res = odd_stage_6_mux_output;

end








endmodule



