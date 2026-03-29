
module even_pipe_unit (

    input logic clk,

    input logic [0:127] even_source_a,
    input logic [0:127] even_source_b,
    input logic [0:127] even_source_c,
    input logic [0:6] even_write_address,
    input opcode_t even_opcode,
    input logic[0:2] even_unit_id,

    output unit_result_packet even_output_to_write_back,
    output unit_result_packet even_stage_2_forwarded_res, // After second stage, 3rd cycle
    output unit_result_packet even_stage_3_forwarded_res,
    output unit_result_packet even_stage_4_forwarded_res,
    output unit_result_packet even_stage_5_forwarded_res,
    output unit_result_packet even_stage_6_forwarded_res

);

unit_result_packet fixed_1_1_output;
unit_result_packet fixed_1_2_output;

unit_result_packet fixed_2_1_output;
unit_result_packet fixed_2_2_output;
unit_result_packet fixed_2_3_output;

unit_result_packet sp_1_output;
unit_result_packet sp_2_output;
unit_result_packet sp_3_output;
unit_result_packet sp_4_output;
unit_result_packet sp_5_output;
unit_result_packet sp_6_output;
unit_result_packet sp_7_output;

unit_result_packet byte_1_output;
unit_result_packet byte_2_output;
unit_result_packet byte_3_output;

unit_result_packet fw_even_3_output;
unit_result_packet fw_even_4_output;
unit_result_packet fw_even_5_output;
unit_result_packet fw_even_6_output;
unit_result_packet fw_even_7_output;

unit_result_packet stage_3_mux_output;
unit_result_packet stage_6_mux_output;
unit_result_packet stage_7_mux_output;

// Fixed point 1 unit
simple_fixed_1_1 fixed_1_1 (
    .clk(clk),
    .source_a(even_source_a),
    .source_b(even_source_b),
    .source_c(even_source_c),
    .write_address(even_write_address),
    .opcode(even_opcode),
    .even_unit_id(even_unit_id),
    .output_packet(fixed_1_1_output)
);

execution_pipe_register fixed_1_2 (
    .clk(clk),
    .unit_packet(fixed_1_1_output),
    .unit_packet_q(fixed_1_2_output)
);

// Fixed point 2 unit
simple_fixed_2_1 fixed_2_1 (
    .clk(clk),
    .source_a(even_source_a),
    .source_b(even_source_b),
    .source_c(even_source_c),
    .write_address(even_write_address),
    .opcode(even_opcode),
    .even_unit_id(even_unit_id),
    .output_packet(fixed_2_1_output)
);

execution_pipe_register fixed_2_2 (
    .clk(clk),
    .unit_packet(fixed_2_1_output),
    .unit_packet_q(fixed_2_2_output)
);

execution_pipe_register fixed_2_3 (
    .clk(clk),
    .unit_packet(fixed_2_2_output),
    .unit_packet_q(fixed_2_3_output)
);

// Single Precision Unit
single_precision_1 sp_1 (
    .clk(clk),
    .source_a(even_source_a),
    .source_b(even_source_b),
    .source_c(even_source_c),
    .write_address(even_write_address),
    .opcode(even_opcode),
    .even_unit_id(even_unit_id),
    .output_packet(sp_1_output)
);

execution_pipe_register sp_2 (
    .clk(clk),
    .unit_packet(sp_1_output),
    .unit_packet_q(sp_2_output)
);

execution_pipe_register sp_3 (
    .clk(clk),
    .unit_packet(sp_2_output),
    .unit_packet_q(sp_3_output)
);

execution_pipe_register sp_4 (
    .clk(clk),
    .unit_packet(sp_3_output),
    .unit_packet_q(sp_4_output)
);

execution_pipe_register sp_5 (
    .clk(clk),
    .unit_packet(sp_4_output),
    .unit_packet_q(sp_5_output)
);

execution_pipe_register sp_6 (
    .clk(clk),
    .unit_packet(sp_5_output),
    .unit_packet_q(sp_6_output)
);

execution_pipe_register sp_7 (
    .clk(clk),
    .unit_packet(sp_6_output),
    .unit_packet_q(sp_7_output)
);

// Byte unit

byte_unit byte_1(
    .clk(clk),
    .source_a(even_source_a),
    .source_b(even_source_b),
    .source_c(even_source_c),
    .write_address(even_write_address),
    .opcode(even_opcode),
    .even_unit_id(even_unit_id),
    .output_packet(byte_1_output)
);

execution_pipe_register byte_2 (
    .clk(clk),
    .unit_packet(byte_1_output),
    .unit_packet_q(byte_2_output)
);

execution_pipe_register byte_3 (
    .clk(clk),
    .unit_packet(byte_2_output),
    .unit_packet_q(byte_3_output)
);


// Fowrwarding registers

execution_pipe_register forward_even3 (
    .clk(clk),
    .unit_packet(fixed_1_2_output),
    .unit_packet_q(fw_even_3_output)
);

execution_pipe_mux #(.NUM_INPUTS(3)) fw_even_4_mux (
    .input_packets('{fw_even_3_output, byte_3_output, fixed_2_3_output}),
    .output_packet(stage_3_mux_output)
);


execution_pipe_register forward_even4 (
    .clk(clk),
    .unit_packet(stage_3_mux_output),
    .unit_packet_q(fw_even_4_output)
);

execution_pipe_register forward_even5 (
    .clk(clk),
    .unit_packet(fw_even_4_output),
    .unit_packet_q(fw_even_5_output)
);


execution_pipe_register forward_even6 (
    .clk(clk),
    .unit_packet(fw_even_5_output),
    .unit_packet_q(fw_even_6_output)
);

execution_pipe_mux #(.NUM_INPUTS(2)) fw_even_7_mux (
    .input_packets('{sp_6_output, fw_even_6_output}),
    .output_packet(stage_6_mux_output)
);

execution_pipe_register forward_even7 (
    .clk(clk),
    .unit_packet(stage_6_mux_output),
    .unit_packet_q(stage_7_mux_output)
);

execution_pipe_mux #(.NUM_INPUTS(2)) fw_even_8_mux (
    .input_packets('{sp_7_output, stage_7_mux_output}),
    .output_packet(even_output_to_write_back)
);

always_comb begin : even_pipe_body

    even_stage_2_forwarded_res = fixed_1_2_output;
    even_stage_3_forwarded_res = stage_3_mux_output;
    even_stage_4_forwarded_res = fw_even_4_output;
    even_stage_5_forwarded_res = fw_even_5_output;
    even_stage_6_forwarded_res = stage_6_mux_output;

end




endmodule