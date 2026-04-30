module if_id_reg (

    input logic clk,
    input logic[0:31] instruction_1_d,
    input logic[0:10] program_counter_1_d,
    input logic[0:31] instruction_2_d,
    input logic[0:10] program_counter_2_d,

    output logic[0:31] instruction_1_q,
    output logic[0:10] program_counter_1_q,
    output logic[0:31] instruction_2_q,
    output logic[0:10] program_counter_2_q

);

always_ff @(posedge clk) begin

    instruction_1_q <= instruction_1_d;
    program_counter_1_q <= program_counter_1_d;

    instruction_2_q <= instruction_2_d;
    program_counter_2_q <= program_counter_2_d;

end

endmodule