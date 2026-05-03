import instruction_pkg::*;


module execution_pipe_register (
    

    input logic clk,
    input logic flush,
    input unit_result_packet unit_packet,

    output unit_result_packet unit_packet_q

);

always_ff @(posedge clk) begin

    if (flush) begin
        unit_packet_q = '{default: 0};
    end
    else begin
        unit_packet_q = unit_packet;
        unit_packet_q.current_stage_number += 1;
    end


end



endmodule

