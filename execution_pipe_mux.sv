import instruction_pkg::*;

module execution_pipe_mux #(
    parameter int NUM_INPUTS = 3

)(
    input unit_result_packet[0:NUM_INPUTS-1] input_packets,
    output unit_result_packet output_packet
);

always_comb begin : execution_pipe_mux_body
    output_packet = '{default: 0};

    for (int i = 0; i < NUM_INPUTS; ++i) begin
        if (input_packets[i].present_bit == 1) begin
            output_packet = input_packets[i];
            break;
        end
    end
end



endmodule