module hazard_unit(

    input logic branch_signal,
    input logic[0:9] branch_addr

    output logic flush_fetch,
    output logic flush_decode,
    output logic flush rf_,
    output logic flush_exec_1,
    output logic flush_ 
);

endmodule


always_comb begin : hazard_unit_body

    // Control Hazards
    if (branch_signal == 1) begin
        // If branch instruction was first
        if (branch_addr[7] == 0) begin
            // Flush instructions between fetch and exec stage 1

        end

        /// If branch instruction was second
        else if (branch_addr[7] == 1) begin
            // Flush instructions between fetch and rf stage, let other instruction keep finishing
        end

    end




end


