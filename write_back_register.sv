import instruction_pkg::*;

module wb_register (
    
    input logic clk,
    input unit_result_packet input_packet,

    output unit_result_packet output_packet
);

always_ff @(posedge clk) begin
    output_packet <= input_packet;
end

endmodule

