module hazard_unit(

    input logic flush_all,
    input logic flush_after,

    output logic branch_signal,
    output logic flush_fetch,
    output logic flush_decode,
    output logic flush rf_,
    output logic flush_exec_1,
);

endmodule


always_comb begin : hazard_unit_body

    // Control Hazards
    if (flush_all || flush_after) begin
        branch_signal = 1;

        //
    end
   




end


