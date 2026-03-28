import instruction_pkg::*;


module execution_pipe_register #(
    parameter int CURRENT_STAGE_NUMBER = 2
) (
    

    input logic clk,
    input unit_result_packet unit_packet,

    output unit_result_packet unit_packet_q

);

always_ff @(posedge clk) begin

    unit_packet_q <= unit_packet;

end



endmodule

