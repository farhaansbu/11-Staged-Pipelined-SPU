import instruction_pkg::*;

module source_operand_unit (

    input logic even_forwarding_signal_a,
    input logic even_forwarding_signal_b,
    input logic even_forwarding_signal_c,

    input logic[0:127] even_reg_data_a,
    input logic[0:127] even_reg_data_b,
    input logic[0:127] even_reg_data_c,
    input logic[0:127] even_forwarded_data_a,
    input logic[0:127] even_forwarded_data_b,
    input logic[0:127] even_forwarded_data_c,

    input logic[0:17] even_immediate,
    input instruction_type even_instruction_type,
    input opcode_t even_opcode,


    input logic odd_forwarding_signal_a,
    input logic odd_forwarding_signal_b,
    input logic odd_forwarding_signal_c,

    input logic[0:127] odd_reg_data_a,
    input logic[0:127] odd_reg_data_b,
    input logic[0:127] odd_reg_data_c,
    input logic[0:127] odd_forwarded_data_a,
    input logic[0:127] odd_forwarded_data_b,
    input logic[0:127] odd_forwarded_data_c,

    input logic[0:17] odd_immediate,
    input instruction_type odd_instruction_type,
    input logic[0:2] odd_unit_id,
    input logic[0:10] odd_program_counter,
    input opcode_t odd_opcode,

    output logic [0:127] even_source_a,
    output logic [0:127] even_source_b,
    output logic [0:127] even_source_c,

    output logic [0:127] odd_source_a,
    output logic [0:127] odd_source_b,
    output logic [0:127] odd_source_c

);

always_comb begin : source_operand_unit_body

    // Even sources
    if (even_instruction_type == RI18) begin
        even_source_a[0:17] = even_immediate;
        even_source_a[18:127] = '0;
    end

    else if (even_instruction_type == RI16) begin
        even_source_a[0:15] = even_immediate[2:17];
        even_source_a[16:127] = '0;
        if (even_opcode == OP_IMMEDIATE_OR_HALFWORD_LOWER) begin
            if (even_forwarding_signal_b == 1) begin
                even_source_b = even_forwarded_data_b;
            end
            else begin
                even_source_b = even_reg_data_b;
            end
        end
    end

    else if (even_instruction_type == RI10) begin
        if (even_forwarding_signal_a == 1) begin
            even_source_a = even_forwarded_data_a;
        end
        else begin
            even_source_a = even_reg_data_a;
        end
        even_source_b[0:9] = even_immediate[8:17];
        even_source_b[10:127] = '0;
    end

    else if (even_instruction_type == RI7) begin
        if (even_forwarding_signal_a == 1) begin
            even_source_a = even_forwarded_data_a;
        end
        else begin
            even_source_a = even_reg_data_a;
        end
        even_source_b[0:6] = even_immediate[11:17];
        even_source_b[7:127] = '0;
    end

    else if (even_instruction_type == RR) begin
        if (even_forwarding_signal_a == 1) begin
            even_source_a = even_forwarded_data_a;
        end
        else begin
            even_source_a = even_reg_data_a;
        end

        if (even_forwarding_signal_b == 1) begin
            even_source_b = even_forwarded_data_b;
        end
        else begin
            even_source_b = even_reg_data_b;
        end

    end
    
    else begin
        if (even_forwarding_signal_a == 1) begin
            even_source_a = even_forwarded_data_a;
        end
        else begin
            even_source_a = even_reg_data_a;
        end

        if (even_forwarding_signal_b == 1) begin
            even_source_b = even_forwarded_data_b;
        end
        else begin
            even_source_b = even_reg_data_b;
        end

        if (even_forwarding_signal_c == 1) begin
            even_source_c = even_forwarded_data_c;
        end
        else begin
            even_source_c = even_reg_data_c;
        end
    end

    // Odd sources
    if (odd_instruction_type == RI18) begin
        odd_source_a[0:17] = odd_immediate;
        odd_source_a[18:127] = '0;
    end

    else if (odd_instruction_type == RI16) begin
        odd_source_a[0:15] = odd_immediate[2:17];
        odd_source_a[16:127] = '0;
        if (odd_opcode == OP_STORE_QUADWORD_A) begin
            if (odd_forwarding_signal_c == 1) begin
                odd_source_c = odd_forwarded_data_c;
            end
            else begin
                odd_source_c = odd_reg_data_c;
            end
        end
    end

    else if (odd_instruction_type == RI10) begin
        if (odd_forwarding_signal_a == 1) begin
            odd_source_a = odd_forwarded_data_a;
        end
        else begin
            odd_source_a = odd_reg_data_a;
        end
        odd_source_b[0:9] = odd_immediate[8:17];
        odd_source_b[10:127] = '0;
        if (odd_opcode == OP_STORE_QUADWORD_D) begin
            if (odd_forwarding_signal_c == 1) begin
                odd_source_c = odd_forwarded_data_c;
            end
            else begin
                odd_source_c = odd_reg_data_c;
            end
        end
    end

    else if (odd_instruction_type == RI7) begin
        if (odd_forwarding_signal_a == 1) begin
            odd_source_a = odd_forwarded_data_a;
        end
        else begin
            odd_source_a = odd_reg_data_a;
        end
        odd_source_b[0:6] = odd_immediate[11:17];
        odd_source_b[7:127] = '0;
    end

    else begin
        if (odd_forwarding_signal_a == 1) begin
            odd_source_a = odd_forwarded_data_a;
        end
        else begin
            odd_source_a = odd_reg_data_a;
        end

        if (odd_forwarding_signal_b == 1) begin
            odd_source_b = odd_forwarded_data_b;
        end
        else begin
            odd_source_b = odd_reg_data_b;
        end

        if (odd_opcode == OP_STORE_QUADWORD_X) begin
            if (odd_forwarding_signal_c == 1) begin
                odd_source_c = odd_forwarded_data_c;
            end
            else begin
                odd_source_c = odd_reg_data_c;
            end
        end
    end

    if (odd_unit_id == 7) begin
        odd_source_c[0:10] = odd_program_counter;
        odd_source_c[11:127] = '0;
    end
    
end //comb end 

endmodule

