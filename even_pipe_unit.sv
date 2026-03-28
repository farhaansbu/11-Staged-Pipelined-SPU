module even_pipe_unit (

    input logic clk,

    input logic [0:127] even_source_a,
    input logic [0:127] even_source_b,
    input logic [0:127] even_source_c,
    input logic [0:6] even_write_address,
    input opcode_t even_opcode,
    input logic[0:2] even_unit_id,

    output unit_result_packet even_output_to_write_back

);


always_comb begin : even_pipe_body

    // Pass inputs to each unit, each unit_first_stage will check for unit_id and then generate a present_bit to pass to next stage

end




endmodule