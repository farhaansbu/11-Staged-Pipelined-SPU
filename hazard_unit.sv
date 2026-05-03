

module hazard_unit(

    input logic flush_all,
    input logic flush_after,

    output logic branch_signal,
    output logic flush_if_id,
    output logic flush_id_rf,
    output logic flush_rf_ex,
    output logic flush_ex_1,
    output logic flush_even_2

);

    always_comb begin : hazard_unit_body

        branch_signal = 0;
        flush_if_id = 0;
        flush_id_rf = 0;
        flush_rf_ex = 0;
        flush_ex_1 = 0;
        flush_even_2 = 0;

        // Control Hazards
        if (flush_all || flush_after) begin
            branch_signal = 1;
            flush_if_id = 1;
            flush_id_rf = 1;
            flush_rf_ex = 1;
            flush_ex_1 = 1;

            if (flush_all) begin
                flush_even_2 = 1;
            end
            
        end
    end

endmodule




