import instruction_pkg::*;

module top_level (

     // Inputs
    input logic clk,
    input logic reset,

    input logic[0:6] even_ra_addr,
    input logic[0:6] even_rb_addr,
    input logic[0:6] even_rc_addr,
    input logic[0:6] even_rt_addr,
    input instruction_type even_instruction_type,
    input opcode_t even_opcode,
    input logic[0:2] even_unit_id,
    input logic[0:10] even_program_counter,
    input logic[0:17] even_immediate,

    input logic[0:6] odd_ra_addr,
    input logic[0:6] odd_rb_addr,
    input logic[0:6] odd_rc_addr,
    input logic[0:6] odd_rt_addr,
    input instruction_type odd_instruction_type,
    input opcode_t odd_opcode,
    input logic[0:2] odd_unit_id,
    input logic[0:10] odd_program_counter,
    input logic[0:17] odd_immediate

);

// id_if outputs
logic[0:6] id_rf_reg_output_even_ra_addr_q;
logic[0:6] id_rf_reg_output_even_rb_addr_q;
logic[0:6] id_rf_reg_output_even_rc_addr_q;
logic[0:6] id_rf_reg_output_even_rt_addr_q;
instruction_type id_rf_reg_output_even_instruction_type_q;
opcode_t id_rf_reg_output_even_opcode_q;
logic[0:2] id_rf_reg_output_even_unit_id_q;
logic[0:10] id_rf_reg_output_even_program_counter_q;
logic[0:17] id_rf_reg_output_even_immediate_q;
logic[0:6] id_rf_reg_output_odd_ra_addr_q;
logic[0:6] id_rf_reg_output_odd_rb_addr_q;
logic[0:6] id_rf_reg_output_odd_rc_addr_q;
logic[0:6] id_rf_reg_output_odd_rt_addr_q;
instruction_type id_rf_reg_output_odd_instruction_type_q;
opcode_t id_rf_reg_output_odd_opcode_q;
logic[0:2] id_rf_reg_output_odd_unit_id_q;
logic[0:10] id_rf_reg_output_odd_program_counter_q;
logic[0:17] id_rf_reg_output_odd_immediate_q; 

// reg_file_outputs
logic[0:127] rf_output_even_read_data_1;
logic[0:127] rf_output_even_read_data_2;
logic[0:127] rf_output_even_read_data_3;
logic[0:127] rf_output_odd_read_data_1;
logic[0:127] rf_output_odd_read_data_2;
logic[0:127] rf_output_odd_read_data_3;

// forwarding unit outputs
logic fu_out_even_forwarding_signal_a;
logic[0:127] fu_out_even_forwarded_data_a;
logic fu_out_even_forwarding_signal_b;
logic[0:127] fu_out_even_forwarded_data_b;
logic fu_out_even_forwarding_signal_c;
logic[0:127] fu_out_even_forwarded_data_c;

logic fu_out_odd_forwarding_signal_a;
logic[0:127] fu_out_odd_forwarded_data_a;
logic fu_out_odd_forwarding_signal_b;
logic[0:127] fu_out_odd_forwarded_data_b;
logic fu_out_odd_forwarding_signal_c;
logic[0:127] fu_out_odd_forwarded_data_c;

// sourcing operand unit outputs
logic [0:127] sourcing_unit_out_even_source_a;
logic [0:127] sourcing_unit_out_even_source_b;
logic [0:127] sourcing_unit_out_even_source_c;

logic [0:127] sourcing_unit_out_odd_source_a;
logic [0:127] sourcing_unit_out_odd_source_b;
logic [0:127] sourcing_unit_out_odd_source_c;

// rf_ex_reg outputs
logic[0:6] rf_ex_out_even_write_addr_q;
logic[0:127] rf_ex_out_even_source_a_q;
logic[0:127] rf_ex_out_even_source_b_q;
logic[0:127] rf_ex_out_even_source_c_q;
opcode_t rf_ex_out_even_opcode_q;
logic[0:2] rf_ex_out_even_unit_id_q;

logic[0:6] rf_ex_out_odd_write_addr_q;
logic[0:127] rf_ex_out_odd_source_a_q;
logic[0:127] rf_ex_out_odd_source_b_q;
logic[0:127] rf_ex_out_odd_source_c_q;
opcode_t rf_ex_out_odd_opcode_q;
logic[0:2] rf_ex_out_odd_unit_id_q;

// execution unit outputs
unit_result_packet exec_output_even_to_write_back;
unit_result_packet exec_output_odd_to_write_back;

unit_result_packet exec_output_even_stage_2_forwarded_res; // After second stage, 3rd cycle
unit_result_packet exec_output_even_stage_3_forwarded_res;
unit_result_packet exec_output_even_stage_4_forwarded_res;
unit_result_packet exec_output_even_stage_5_forwarded_res;
unit_result_packet exec_output_even_stage_6_forwarded_res;

unit_result_packet exec_output_odd_branch_forwarded_res;
unit_result_packet exec_output_odd_stage_3_forwarded_res;
unit_result_packet exec_output_odd_stage_4_forwarded_res;
unit_result_packet exec_output_odd_stage_5_forwarded_res;
unit_result_packet exec_output_odd_stage_6_forwarded_res;


// Write back stage outputs
unit_result_packet even_write_back_packet;
unit_result_packet odd_write_back_packet;


// Structural Design Instantiations

id_rf_reg dec_rf_reg (
    .clk(clk),

    .even_ra_addr(even_ra_addr),
    .even_rb_addr(even_rb_addr),
    .even_rc_addr(even_rc_addr),
    .even_rt_addr(even_rt_addr),
    .even_instruction_type(even_instruction_type),
    .even_opcode(even_opcode), 
    .even_unit_id(even_unit_id),
    .even_program_counter(even_program_counter),
    .even_immediate(even_immediate),

    .odd_ra_addr(odd_ra_addr),
    .odd_rb_addr(odd_rb_addr),
    .odd_rc_addr(odd_rc_addr),
    .odd_rt_addr(odd_rt_addr),
    .odd_instruction_type(odd_instruction_type),
    .odd_opcode(odd_opcode), 
    .odd_unit_id(odd_unit_id),
    .odd_program_counter(odd_program_counter),
    .odd_immediate(odd_immediate),

    .even_ra_addr_q(id_rf_reg_output_even_ra_addr_q),
    .even_rb_addr_q(id_rf_reg_output_even_rb_addr_q),
    .even_rc_addr_q(id_rf_reg_output_even_rc_addr_q),
    .even_rt_addr_q(id_rf_reg_output_even_rt_addr_q),
    .even_instruction_type_q(id_rf_reg_output_even_instruction_type_q),
    .even_opcode_q(id_rf_reg_output_even_opcode_q),
    .even_unit_id_q(id_rf_reg_output_even_unit_id_q),
    .even_program_counter_q(id_rf_reg_output_even_program_counter_q),
    .even_immediate_q(id_rf_reg_output_even_immediate_q),

    .odd_ra_addr_q(id_rf_reg_output_odd_ra_addr_q),
    .odd_rb_addr_q(id_rf_reg_output_odd_rb_addr_q),
    .odd_rc_addr_q(id_rf_reg_output_odd_rc_addr_q),
    .odd_rt_addr_q(id_rf_reg_output_odd_rt_addr_q),
    .odd_instruction_type_q(id_rf_reg_output_odd_instruction_type_q),
    .odd_opcode_q(id_rf_reg_output_odd_opcode_q),
    .odd_unit_id_q(id_rf_reg_output_odd_unit_id_q),
    .odd_program_counter_q(id_rf_reg_output_odd_program_counter_q),
    .odd_immediate_q(id_rf_reg_output_odd_immediate_q)      
);

register_file rf (
    .reset(reset),

    .even_read_addr_1(id_rf_reg_output_even_ra_addr_q),
    .even_read_addr_2(id_rf_reg_output_even_rb_addr_q),
    .even_read_addr_3(id_rf_reg_output_even_rc_addr_q),
    .even_write_addr(even_write_back_packet.reg_write_addr),
    .even_write_data(even_write_back_packet.result),
    .even_reg_write(even_write_back_packet.reg_write_flag),

    .odd_read_addr_1(id_rf_reg_output_odd_ra_addr_q),
    .odd_read_addr_2(id_rf_reg_output_odd_rb_addr_q),
    .odd_read_addr_3(id_rf_reg_output_odd_rc_addr_q),
    .odd_write_addr(odd_write_back_packet.reg_write_addr),
    .odd_write_data(odd_write_back_packet.result),
    .odd_reg_write(odd_write_back_packet.reg_write_flag),

    .even_read_data_1(rf_output_even_read_data_1),
    .even_read_data_2(rf_output_even_read_data_2),
    .even_read_data_3(rf_output_even_read_data_3),
    .odd_read_data_1(rf_output_odd_read_data_1),
    .odd_read_data_2(rf_output_odd_read_data_2),
    .odd_read_data_3(rf_output_odd_read_data_3)
);

forwarding_unit fw_unit (

    .even_read_addr_a(id_rf_reg_output_even_ra_addr_q),
    .even_read_addr_b(id_rf_reg_output_even_rb_addr_q),
    .even_read_addr_c(id_rf_reg_output_even_rc_addr_q),
    .even_unit_id(id_rf_reg_output_even_unit_id_q),
    .even_instruction_type(id_rf_reg_output_even_instruction_type_q),
    .even_pipe_forwarded_results('{exec_output_even_stage_2_forwarded_res,
                                   exec_output_even_stage_3_forwarded_res,
                                   exec_output_even_stage_4_forwarded_res,
                                   exec_output_even_stage_5_forwarded_res,
                                   exec_output_even_stage_6_forwarded_res,
                                   exec_output_even_to_write_back}),

    .odd_read_addr_a(id_rf_reg_output_odd_ra_addr_q),
    .odd_read_addr_b(id_rf_reg_output_odd_rb_addr_q),
    .odd_read_addr_c(id_rf_reg_output_odd_rc_addr_q),
    .odd_unit_id(id_rf_reg_output_odd_unit_id_q),
    .odd_instruction_type(id_rf_reg_output_odd_instruction_type_q),
    .odd_pipe_forwarded_results('{exec_output_odd_stage_3_forwarded_res,
                                  exec_output_odd_stage_4_forwarded_res,
                                  exec_output_odd_stage_5_forwarded_res,
                                  exec_output_odd_stage_6_forwarded_res,
                                  exec_output_odd_to_write_back}),
    .odd_opcode(id_rf_reg_output_odd_opcode_q),

    .even_forwarding_signal_a(fu_out_even_forwarding_signal_a),
    .even_forwarding_signal_b(fu_out_even_forwarding_signal_b),
    .even_forwarding_signal_c(fu_out_even_forwarding_signal_c),
    .even_forwarded_data_a(fu_out_even_forwarded_data_a),
    .even_forwarded_data_b(fu_out_even_forwarded_data_b),
    .even_forwarded_data_c(fu_out_even_forwarded_data_c),

    .odd_forwarding_signal_a(fu_out_odd_forwarding_signal_a),
    .odd_forwarding_signal_b(fu_out_odd_forwarding_signal_b),
    .odd_forwarding_signal_c(fu_out_odd_forwarding_signal_c),
    .odd_forwarded_data_a(fu_out_odd_forwarded_data_a),
    .odd_forwarded_data_b(fu_out_odd_forwarded_data_b),
    .odd_forwarded_data_c(fu_out_odd_forwarded_data_c)

);

source_operand_unit source_op_unit (

    .even_forwarding_signal_a(fu_out_even_forwarding_signal_a),
    .even_forwarding_signal_b(fu_out_even_forwarding_signal_b),
    .even_forwarding_signal_c(fu_out_even_forwarding_signal_c),

    .even_reg_data_a(rf_output_even_read_data_1),
    .even_reg_data_b(rf_output_even_read_data_2),
    .even_reg_data_c(rf_output_even_read_data_3),
    .even_forwarded_data_a(fu_out_even_forwarded_data_a),
    .even_forwarded_data_b(fu_out_even_forwarded_data_b),
    .even_forwarded_data_c(fu_out_even_forwarded_data_c),

    .even_immediate(id_rf_reg_output_even_immediate_q),
    .even_instruction_type(id_rf_reg_output_even_instruction_type_q),
    .even_opcode(id_rf_reg_output_even_opcode_q),

    .odd_forwarding_signal_a(fu_out_odd_forwarding_signal_a),
    .odd_forwarding_signal_b(fu_out_odd_forwarding_signal_b),
    .odd_forwarding_signal_c(fu_out_odd_forwarding_signal_c),

    .odd_reg_data_a(rf_output_odd_read_data_1),
    .odd_reg_data_b(rf_output_odd_read_data_2),
    .odd_reg_data_c(rf_output_odd_read_data_3),
    .odd_forwarded_data_a(fu_out_odd_forwarded_data_a),
    .odd_forwarded_data_b(fu_out_odd_forwarded_data_b),
    .odd_forwarded_data_c(fu_out_odd_forwarded_data_c),

    .odd_immediate(id_rf_reg_output_odd_immediate_q),
    .odd_instruction_type(id_rf_reg_output_odd_instruction_type_q),
    .odd_opcode(id_rf_reg_output_odd_opcode_q),
    .odd_unit_id(id_rf_reg_output_odd_unit_id_q),
    .odd_program_counter(id_rf_reg_output_odd_program_counter_q),

    .even_source_a(sourcing_unit_out_even_source_a),
    .even_source_b(sourcing_unit_out_even_source_b),
    .even_source_c(sourcing_unit_out_even_source_c),
    
    .odd_source_a(sourcing_unit_out_odd_source_a),
    .odd_source_b(sourcing_unit_out_odd_source_b),
    .odd_source_c(sourcing_unit_out_odd_source_c)
);

rf_ex_reg rf_exec_reg (

    .clk(clk),

    .even_write_addr(id_rf_reg_output_even_rt_addr_q),
    .even_source_a(sourcing_unit_out_even_source_a),
    .even_source_b(sourcing_unit_out_even_source_b),
    .even_source_c(sourcing_unit_out_even_source_c),
    .even_opcode(id_rf_reg_output_even_opcode_q),
    .even_unit_id(id_rf_reg_output_even_unit_id_q),

    .odd_write_addr(id_rf_reg_output_odd_rt_addr_q),
    .odd_source_a(sourcing_unit_out_odd_source_a),
    .odd_source_b(sourcing_unit_out_odd_source_b),
    .odd_source_c(sourcing_unit_out_odd_source_c),
    .odd_opcode(id_rf_reg_output_odd_opcode_q),
    .odd_unit_id(id_rf_reg_output_odd_unit_id_q),

    .even_write_addr_q(rf_ex_out_even_write_addr_q),
    .even_source_a_q(rf_ex_out_even_source_a_q),
    .even_source_b_q(rf_ex_out_even_source_b_q),
    .even_source_c_q(rf_ex_out_even_source_c_q),
    .even_opcode_q(rf_ex_out_even_opcode_q),
    .even_unit_id_q(rf_ex_out_even_unit_id_q),

    .odd_write_addr_q(rf_ex_out_odd_write_addr_q),
    .odd_source_a_q(rf_ex_out_odd_source_a_q),
    .odd_source_b_q(rf_ex_out_odd_source_b_q),
    .odd_source_c_q(rf_ex_out_odd_source_c_q),
    .odd_opcode_q(rf_ex_out_odd_opcode_q),
    .odd_unit_id_q(rf_ex_out_odd_unit_id_q)

);

execution_unit exec_unit(
    .clk(clk),

    .even_source_a(rf_ex_out_even_source_a_q),
    .even_source_b(rf_ex_out_even_source_b_q),
    .even_source_c(rf_ex_out_even_source_c_q),
    .even_write_address(rf_ex_out_even_write_addr_q),
    .even_opcode(rf_ex_out_even_opcode_q),
    .even_unit_id(rf_ex_out_even_unit_id_q),

    .odd_source_a(rf_ex_out_odd_source_a_q),
    .odd_source_b(rf_ex_out_odd_source_b_q),
    .odd_source_c(rf_ex_out_odd_source_c_q),
    .odd_write_address(rf_ex_out_odd_write_addr_q),
    .odd_opcode(rf_ex_out_odd_opcode_q),
    .odd_unit_id(rf_ex_out_odd_unit_id_q),

    .even_output_to_write_back(exec_output_even_to_write_back),
    .odd_output_to_write_back(exec_output_odd_to_write_back),

    .even_stage_2_forwarded_res(exec_output_even_stage_2_forwarded_res),
    .even_stage_3_forwarded_res(exec_output_even_stage_3_forwarded_res),
    .even_stage_4_forwarded_res(exec_output_even_stage_4_forwarded_res),
    .even_stage_5_forwarded_res(exec_output_even_stage_5_forwarded_res),
    .even_stage_6_forwarded_res(exec_output_even_stage_6_forwarded_res),

    .odd_branch_forwarded_res(exec_output_odd_branch_forwarded_res),
    .odd_stage_3_forwarded_res(exec_output_odd_stage_3_forwarded_res),
    .odd_stage_4_forwarded_res(exec_output_odd_stage_4_forwarded_res),
    .odd_stage_5_forwarded_res(exec_output_odd_stage_5_forwarded_res),
    .odd_stage_6_forwarded_res(exec_output_odd_stage_6_forwarded_res)
);

wb_register write_back_even(
    .clk(clk),

    .input_packet(exec_output_even_to_write_back),
    .output_packet(even_write_back_packet)
);

wb_register write_back_odd(
    .clk(clk),

    .input_packet(exec_output_odd_to_write_back),
    .output_packet(odd_write_back_packet)
);







endmodule