import instruction_pkg::*;

module forwarding_unit (

    input logic[0:6] even_read_addr_a,
    input logic[0:6] even_read_addr_b,
    input logic[0:6] even_read_addr_c,
    input logic[0:2] even_unit_id,
    input opcode_t even_opcode,
    input instruction_type even_instruction_type,
    input unit_result_packet[0:5] even_pipe_forwarded_results,

    input logic[0:6] odd_read_addr_a,
    input logic[0:6] odd_read_addr_b,
    input logic[0:6] odd_read_addr_c,
    input logic[0:2] odd_unit_id,
    //input unit_result_packet odd_branch_forwarded_result,
    input unit_result_packet[0:4] odd_pipe_forwarded_results,
    input opcode_t odd_opcode,
    input instruction_type odd_instruction_type,

    output logic even_forwarding_signal_a,
    output logic[0:127] even_forwarded_data_a,
    output logic even_forwarding_signal_b,
    output logic[0:127] even_forwarded_data_b,
    output logic even_forwarding_signal_c,
    output logic[0:127] even_forwarded_data_c,

    output logic odd_forwarding_signal_a,
    output logic[0:127] odd_forwarded_data_a,
    output logic odd_forwarding_signal_b,
    output logic[0:127] odd_forwarded_data_b,
    output logic odd_forwarding_signal_c,
    output logic[0:127] odd_forwarded_data_c
);

logic[0:6] temp_write_addr;
logic temp_present_bit;
logic temp_reg_write;
logic[0:127] temp_result;

always_comb begin : forwarding_unit_body

    even_forwarding_signal_a = 0;
    even_forwarding_signal_b = 0;
    even_forwarding_signal_c = 0;

    odd_forwarding_signal_a = 0;
    odd_forwarding_signal_b = 0;
    odd_forwarding_signal_c = 0;

    
    if (even_unit_id != 0) begin

        // Check even instruction with even pipe
        for (int i = 0; i < 6; ++i) begin
            // Extract informaiton about forwarded instruction
            temp_reg_write = even_pipe_forwarded_results[i].reg_write_flag;
            temp_present_bit = even_pipe_forwarded_results[i].present_bit;
            if (temp_reg_write == 0 || temp_present_bit == 0) begin
                continue;
            end

            temp_write_addr = even_pipe_forwarded_results[i].reg_write_addr;
            temp_result = even_pipe_forwarded_results[i].result;

            // Analyze current instruction thats about to be executed
            if (even_instruction_type == RI18 || even_instruction_type == RI16) begin
                if (even_opcode == OP_IMMEDIATE_OR_HALFWORD_LOWER) begin
                    if (even_read_addr_b == temp_write_addr) begin
                        even_forwarding_signal_b = 1;
                        even_forwarded_data_b = temp_result;
                    end
                end
                continue;
            end

            // All instruction types have at least reg_A as source
            if (even_read_addr_a == temp_write_addr) begin
                even_forwarding_signal_a = 1;
                even_forwarded_data_a = temp_result;
            end
        
            // Two source registers
            if (even_instruction_type == RR) begin
                if (even_read_addr_b == temp_write_addr) begin
                    even_forwarding_signal_b = 1;
                    even_forwarded_data_b = temp_result;
                end
            end

            // Three source registers
            else if (even_instruction_type == RRR) begin
                if (even_read_addr_b == temp_write_addr) begin
                    even_forwarding_signal_b = 1;
                    even_forwarded_data_b = temp_result;
                end

                if (even_read_addr_c == temp_write_addr) begin
                    even_forwarding_signal_c = 1;
                    even_forwarded_data_c = temp_result;
                end

            end
        end

        // Check even instruction with odd pipe
        for (int i = 0; i < 5; ++i) begin
            // Extract informaiton about forwarded instruction
            temp_reg_write = odd_pipe_forwarded_results[i].reg_write_flag;
            temp_present_bit = odd_pipe_forwarded_results[i].present_bit;
            if (temp_reg_write == 0 || temp_present_bit == 0) begin
                continue;
            end
            temp_write_addr = odd_pipe_forwarded_results[i].reg_write_addr;
            temp_result = odd_pipe_forwarded_results[i].result;

            // Analyze current instruction thats about to be executed
            if (even_instruction_type == RI18 || even_instruction_type == RI16) begin
                if (even_opcode == OP_IMMEDIATE_OR_HALFWORD_LOWER) begin
                    if (even_read_addr_b == temp_write_addr) begin
                        even_forwarding_signal_b = 1;
                        even_forwarded_data_b = temp_result;
                    end
                end
                continue;
            end

            // All instruction types have at least reg_A as source
            if (even_read_addr_a == temp_write_addr) begin
                even_forwarding_signal_a = 1;
                even_forwarded_data_a = temp_result;
            end
            
            // Two source registers
            if (even_instruction_type == RR) begin
                if (even_read_addr_b == temp_write_addr) begin
                    even_forwarding_signal_b = 1;
                    even_forwarded_data_b = temp_result;
                end
            end

            // Three source registers
            else if (even_instruction_type == RRR) begin
                if (even_read_addr_b == temp_write_addr) begin
                    even_forwarding_signal_b = 1;
                    even_forwarded_data_b = temp_result;
                end

                if (even_read_addr_c == temp_write_addr) begin
                    even_forwarding_signal_c = 1;
                    even_forwarded_data_c = temp_result;
                end

            end
        end
    end
    
    if (odd_unit_id != 0) begin

        // Check odd instruction with even pipe
        for (int i = 0; i < 6; ++i) begin

            // Extract informaiton about forwarded instruction
            temp_reg_write = even_pipe_forwarded_results[i].reg_write_flag;
            temp_present_bit = even_pipe_forwarded_results[i].present_bit;
            if (temp_reg_write == 0 || temp_present_bit == 0) begin
                continue;
            end
            temp_write_addr = even_pipe_forwarded_results[i].reg_write_addr;
            temp_result = even_pipe_forwarded_results[i].result;

            // Analyze current instruction thats about to be executed
            if (odd_instruction_type == RI18 || (odd_instruction_type == RI16 && odd_opcode != OP_STORE_QUADWORD_A)) begin
                continue;
            end

            // All instruction types have at least reg_A as source
            if (odd_read_addr_a == temp_write_addr) begin
                odd_forwarding_signal_a = 1;
                odd_forwarded_data_a = temp_result;
            end
            
            // All other instruction types for odd pipe have at most a second source register
            if (odd_instruction_type == RR) begin
                if (odd_read_addr_b == temp_write_addr) begin
                    odd_forwarding_signal_b = 1;
                    odd_forwarded_data_b = temp_result;
                end
            end

            // Add checks for store operations, edgecase
            if (odd_opcode == OP_STORE_QUADWORD_D || odd_opcode == OP_STORE_QUADWORD_A || odd_opcode == OP_STORE_QUADWORD_X) begin
                    if (odd_read_addr_c == temp_write_addr) begin
                        odd_forwarding_signal_c = 1;
                        odd_forwarded_data_c = temp_result;
                    end
            end
        end

        // Check odd instruction with odd pipe
        for (int i = 0; i < 5; ++i) begin
            // Extract informaiton about forwarded instruction
            temp_reg_write = odd_pipe_forwarded_results[i].reg_write_flag;
            temp_present_bit = odd_pipe_forwarded_results[i].present_bit;
            if (temp_reg_write == 0 || temp_present_bit == 0) begin
                continue;
            end
            temp_write_addr = odd_pipe_forwarded_results[i].reg_write_addr;
            temp_result = odd_pipe_forwarded_results[i].result;

            // Analyze current instruction thats about to be executed
            if (odd_instruction_type == RI18 || (odd_instruction_type == RI16 && odd_opcode != OP_STORE_QUADWORD_A)) begin
                continue;
            end

            // All instruction types have at least reg_A as source
            if (odd_read_addr_a == temp_write_addr) begin
                odd_forwarding_signal_a = 1;
                odd_forwarded_data_a = temp_result;
            end
            
            // All other instruction types for odd pipe have at most a second source register
            if (odd_instruction_type == RR) begin
                if (odd_read_addr_b == temp_write_addr) begin
                    odd_forwarding_signal_b = 1;
                    odd_forwarded_data_b = temp_result;
                end
            end
            
            // Add checks for store operations, edgecase
            if (odd_opcode == OP_STORE_QUADWORD_D || odd_opcode == OP_STORE_QUADWORD_A || odd_opcode == OP_STORE_QUADWORD_X) begin
                    if (odd_read_addr_c == temp_write_addr) begin
                        odd_forwarding_signal_c = 1;
                        odd_forwarded_data_c = temp_result;
                    end
            end

        end
    end

end

endmodule