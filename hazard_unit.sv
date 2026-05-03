import instruction_pkg::*;

module hazard_unit(

    input logic flush_all,
    input logic flush_after,
    input logic[0:31] instruction_1,
    input logic[0:31] instruction_2,
    input logic[0:10] pc_1,
    input logic[0:10] pc_2,

    //decoder outputs
    input logic[0:6] even_read_addr_a,
    input logic[0:6] even_read_addr_b,
    input logic[0:6] even_read_addr_c,
    input instruction_type even_instruction_type,
    input opcode_t even_opcode,

    input logic[0:6] odd_read_addr_a,
    input logic[0:6] odd_read_addr_b,
    input logic[0:6] odd_read_addr_c,
    input instruction_type odd_instruction_type,
    input opcode_t odd_opcode,
    
    // Output of id_rf stage
    input logic[0:6] id_rf_even_rt_addr,
    input logic id_rf_even_reg_write,
    input logic[0:6] id_rf_odd_rt_addr,
    input logic id_rf_odd_reg_write,

    // Output of rf_exec_ stage
    input logic[0:6] rf_ex_even_rt_addr,
    input logic rf_ex_even_reg_write,
    input logic[0:6] rf_ex_odd_rt_addr,
    input logic rf_ex_odd_reg_write,

    //Pipe outputs
    input unit_result_packet even_stage_results[0:6],
    input unit_result_packet odd_stage_results[0:6],


    // Hazard control signals
    output logic data_hazard_signal,
    output logic branch_signal,
    output logic flush_if_id,
    output logic flush_id_rf,
    output logic flush_rf_ex,
    output logic flush_ex_1,
    output logic flush_even_2,

    output logic[0:31] instruction_refetch_1,
    output logic[0:31] instruction_refetch_2,
    output logic[0:9] refetch_pc1,
    output logic[0:9] refetch_pc2

);

    logic temp_present_bit;
    logic temp_reg_write;
    logic[0:6] temp_write_addr;
    logic[0:3] temp_ready_stage_number;
    logic[0:3] temp_current_stage_number;

    always_comb begin : hazard_unit_body

        data_hazard_signal = 0;
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

        // Check for data hazards
        check_even();
        check_odd();

        instruction_refetch_1 = instruction_1;
        instruction_refetch_2 = instruction_2;
        refetch_pc1 = pc_1;
        refetch_pc2 = pc_2;


    end

function automatic void check_even();

    // Data Hazards For Even Instruction
        if (even_opcode != OP_NO_OP_EVEN && even_opcode != OP_NO_OP_HARDWARE && even_opcode != OP_STOP_AND_SIGNAL) begin

            // Check even instruction with even output of rf_ex stage
            if (rf_ex_even_reg_write) begin
                temp_write_addr = rf_ex_even_rt_addr;
                 // Analyze current instruction thats about to be executed
                if (even_instruction_type == RI18 || even_instruction_type == RI16) begin
                    if (even_opcode == OP_IMMEDIATE_OR_HALFWORD_LOWER) begin
                        if (even_read_addr_b == temp_write_addr) begin
                            data_hazard_signal = 1;
                        end
                    end
                end

                // All instruction types have at least reg_A as source
                else if (even_read_addr_a == temp_write_addr) begin
                    data_hazard_signal = 1;
                end
            
                // Two source registers
                if (even_instruction_type == RR) begin
                    if (even_opcode != OP_COUNT_LEADING_ZEROS && even_opcode != OP_FORM_SELECT_MASK_FOR_HALFWORDS &&
                        even_opcode != OP_FORM_SELECT_MASK_FOR_HALFWORDS && even_opcode != OP_COUNT_ONES_IN_BYTES) begin

                        if (even_read_addr_b == temp_write_addr) begin
                            data_hazard_signal = 1;
                        end
                    end
                end

                // Three source registers
                else if (even_instruction_type == RRR) begin
                    if (even_read_addr_b == temp_write_addr) begin
                        data_hazard_signal = 1;
                    end

                    if (even_read_addr_c == temp_write_addr) begin
                        data_hazard_signal = 1;
                    end

                end
            end

            // Check even instruction with even output of id_rf stage
            if (id_rf_even_reg_write) begin
                temp_write_addr = id_rf_even_rt_addr;
                 // Analyze current instruction thats about to be executed
                if (even_instruction_type == RI18 || even_instruction_type == RI16) begin
                    if (even_opcode == OP_IMMEDIATE_OR_HALFWORD_LOWER) begin
                        if (even_read_addr_b == temp_write_addr) begin
                            data_hazard_signal = 1;
                        end
                    end
                end

                // All instruction types have at least reg_A as source
                else if (even_read_addr_a == temp_write_addr) begin
                    data_hazard_signal = 1;
                end
            
                // Two source registers
                if (even_instruction_type == RR) begin
                    if (even_opcode != OP_COUNT_LEADING_ZEROS && even_opcode != OP_FORM_SELECT_MASK_FOR_HALFWORDS &&
                        even_opcode != OP_FORM_SELECT_MASK_FOR_HALFWORDS && even_opcode != OP_COUNT_ONES_IN_BYTES) begin

                        if (even_read_addr_b == temp_write_addr) begin
                            data_hazard_signal = 1;
                        end

                    end
                    
                end

                // Three source registers
                else if (even_instruction_type == RRR) begin
                    if (even_read_addr_b == temp_write_addr) begin
                        data_hazard_signal = 1;
                    end

                    if (even_read_addr_c == temp_write_addr) begin
                        data_hazard_signal = 1;
                    end

                end
            end

            // Check with instructions in even execution pipe
            for (int i = 0; i < 6; ++i) begin
                // Extract informaiton about instruction at each execution stage
                temp_reg_write = even_stage_results[i].reg_write_flag;
                temp_present_bit = even_stage_results[i].present_bit;
                temp_ready_stage_number = even_stage_results[i].ready_stage_number;
                temp_current_stage_number = even_stage_results[i].current_stage_number;

                if (temp_current_stage_number < temp_ready_stage_number) begin
                    data_hazard_signal = 1;
                    break;
                end

                if (temp_reg_write == 0 || temp_present_bit == 0) begin
                    continue;
                end

                temp_write_addr = even_stage_results[i].reg_write_addr;

                // Analyze current instruction thats about to be executed
                if (even_instruction_type == RI18 || even_instruction_type == RI16) begin
                    if (even_opcode == OP_IMMEDIATE_OR_HALFWORD_LOWER) begin
                        if (even_read_addr_b == temp_write_addr) begin
                            data_hazard_signal = 1;
                            break;
                        end
                    end
                    continue;
                end

                // All instruction types have at least reg_A as source
                if (even_read_addr_a == temp_write_addr) begin
                    data_hazard_signal = 1;
                    break;
                end
            
                // Two source registers
                if (even_instruction_type == RR) begin
                    if (even_opcode != OP_COUNT_LEADING_ZEROS && even_opcode != OP_FORM_SELECT_MASK_FOR_HALFWORDS &&
                        even_opcode != OP_FORM_SELECT_MASK_FOR_HALFWORDS && even_opcode != OP_COUNT_ONES_IN_BYTES) begin

                        if (even_read_addr_b == temp_write_addr) begin
                            data_hazard_signal = 1;
                            break;
                        end

                    end
                    
                end

                // Three source registers
                else if (even_instruction_type == RRR) begin
                    if (even_read_addr_b == temp_write_addr) begin
                        data_hazard_signal = 1;
                        break;
                    end

                    if (even_read_addr_c == temp_write_addr) begin
                        data_hazard_signal = 1;
                        break;
                    end

                end
            end

            // Check even instruction with odd output of rf_ex stage
            if (rf_ex_odd_reg_write) begin
                temp_write_addr = rf_ex_odd_rt_addr;
                 // Analyze current instruction thats about to be executed
                if (even_instruction_type == RI18 || even_instruction_type == RI16) begin
                    if (even_opcode == OP_IMMEDIATE_OR_HALFWORD_LOWER) begin
                        if (even_read_addr_b == temp_write_addr) begin
                            data_hazard_signal = 1;
                        end
                    end
                end

                // All instruction types have at least reg_A as source
                else if (even_read_addr_a == temp_write_addr) begin
                    data_hazard_signal = 1;
                end
            
                // Two source registers
                if (even_instruction_type == RR) begin
                    if (even_opcode != OP_COUNT_LEADING_ZEROS && even_opcode != OP_FORM_SELECT_MASK_FOR_HALFWORDS &&
                        even_opcode != OP_FORM_SELECT_MASK_FOR_HALFWORDS && even_opcode != OP_COUNT_ONES_IN_BYTES) begin

                        if (even_read_addr_b == temp_write_addr) begin
                            data_hazard_signal = 1;
                        end

                    end
                    
                end

                // Three source registers
                else if (even_instruction_type == RRR) begin
                    if (even_read_addr_b == temp_write_addr) begin
                        data_hazard_signal = 1;
                    end

                    if (even_read_addr_c == temp_write_addr) begin
                        data_hazard_signal = 1;
                    end

                end
            end

            // Check even instruction with odd output of id_rf stage
            if (id_rf_odd_reg_write) begin
                temp_write_addr = id_rf_odd_rt_addr;
                 // Analyze current instruction thats about to be executed
                if (even_instruction_type == RI18 || even_instruction_type == RI16) begin
                    if (even_opcode == OP_IMMEDIATE_OR_HALFWORD_LOWER) begin
                        if (even_read_addr_b == temp_write_addr) begin
                            data_hazard_signal = 1;
                        end
                    end
                end

                // All instruction types have at least reg_A as source
                else if (even_read_addr_a == temp_write_addr) begin
                    data_hazard_signal = 1;
                end
            
                // Two source registers
                if (even_instruction_type == RR) begin
                    if (even_opcode != OP_COUNT_LEADING_ZEROS && even_opcode != OP_FORM_SELECT_MASK_FOR_HALFWORDS &&
                        even_opcode != OP_FORM_SELECT_MASK_FOR_HALFWORDS && even_opcode != OP_COUNT_ONES_IN_BYTES) begin

                        if (even_read_addr_b == temp_write_addr) begin
                            data_hazard_signal = 1;
                        end

                    end
                    
                end

                // Three source registers
                else if (even_instruction_type == RRR) begin
                    if (even_read_addr_b == temp_write_addr) begin
                        data_hazard_signal = 1;
                    end

                    if (even_read_addr_c == temp_write_addr) begin
                        data_hazard_signal = 1;
                    end

                end
            end

            // Check with instructions in odd execution pipe
            for (int i = 0; i < 6; ++i) begin
                // Extract informaiton about instruction at each execution stage
                temp_reg_write = odd_stage_results[i].reg_write_flag;
                temp_present_bit = odd_stage_results[i].present_bit;
                temp_ready_stage_number = odd_stage_results[i].ready_stage_number;
                temp_current_stage_number = odd_stage_results[i].current_stage_number;

                if (temp_current_stage_number < temp_ready_stage_number) begin
                    data_hazard_signal = 1;
                    break;
                end

                if (temp_reg_write == 0 || temp_present_bit == 0) begin
                    continue;
                end

                temp_write_addr = odd_stage_results[i].reg_write_addr;

                // Analyze current instruction thats about to be executed
                if (even_instruction_type == RI18 || even_instruction_type == RI16) begin
                    if (even_opcode == OP_IMMEDIATE_OR_HALFWORD_LOWER) begin
                        if (even_read_addr_b == temp_write_addr) begin
                            data_hazard_signal = 1;
                            break;
                        end
                    end
                    continue;
                end

                // All instruction types have at least reg_A as source
                if (even_read_addr_a == temp_write_addr) begin
                    data_hazard_signal = 1;
                    break;
                end
            
                // Two source registers
                if (even_instruction_type == RR) begin
                    if (even_opcode != OP_COUNT_LEADING_ZEROS && even_opcode != OP_FORM_SELECT_MASK_FOR_HALFWORDS &&
                        even_opcode != OP_FORM_SELECT_MASK_FOR_HALFWORDS && even_opcode != OP_COUNT_ONES_IN_BYTES) begin

                        if (even_read_addr_b == temp_write_addr) begin
                            data_hazard_signal = 1;
                            break;
                        end

                    end
                    
                end

                // Three source registers
                else if (even_instruction_type == RRR) begin
                    if (even_read_addr_b == temp_write_addr) begin
                        data_hazard_signal = 1;
                        break;
                    end

                    if (even_read_addr_c == temp_write_addr) begin
                        data_hazard_signal = 1;
                        break;
                    end

                end
            end

        end

endfunction : check_even

function automatic void check_odd();

    // Data Hazards For Odd Instruction
        if (odd_opcode != OP_NO_OP_ODD && odd_opcode != OP_NO_OP_HARDWARE && odd_opcode != OP_STOP_AND_SIGNAL) begin

            // Check odd instruction with even output of rf_ex stage
            if (rf_ex_even_reg_write) begin
                temp_write_addr = rf_ex_even_rt_addr;
                // Analyze current instruction thats about to be executed
                if (odd_instruction_type == RI18 || (odd_instruction_type == RI16 && odd_opcode != OP_STORE_QUADWORD_A)) begin
                end

                // All instruction types have at least reg_A as source
                else if (odd_read_addr_a == temp_write_addr) begin
                    data_hazard_signal = 1;
                end
                
                // All other instruction types for odd pipe have at most a second source register
                if (odd_instruction_type == RR) begin
                    if (odd_opcode != OP_BRANCH_INDIRECT && odd_opcode != OP_BRANCH_INDIRECT_AND_SET_LINK) begin
                        if (odd_read_addr_b == temp_write_addr) begin
                            data_hazard_signal = 1;
                        end
                    end
                end

                // Add checks for store operations, edgecase
                if (odd_opcode == OP_STORE_QUADWORD_D || odd_opcode == OP_STORE_QUADWORD_A || odd_opcode == OP_STORE_QUADWORD_X) begin
                    if (odd_read_addr_c == temp_write_addr) begin
                        data_hazard_signal = 1;
                    end
                end

                // Add checks for branch operations, edgecase
                if (odd_opcode == OP_BRANCH_IF_ZERO_WORD || odd_opcode == OP_BRANCH_IF_ZERO_HALFWORD ||
                odd_opcode == OP_BRANCH_IF_NOT_ZERO_WORD || odd_opcode == OP_BRANCH_IF_NOT_ZERO_HALFWORD) begin
                    if (odd_read_addr_b == temp_write_addr) begin
                        data_hazard_signal = 1;
                    end
                end

            end

            // Check even instruction with even output of id_rf stage
            if (id_rf_even_reg_write) begin
                temp_write_addr = id_rf_even_rt_addr;
                // Analyze current instruction thats about to be executed
                if (odd_instruction_type == RI18 || (odd_instruction_type == RI16 && odd_opcode != OP_STORE_QUADWORD_A)) begin
                end

                // All instruction types have at least reg_A as source
                else if (odd_read_addr_a == temp_write_addr) begin
                    data_hazard_signal = 1;
                end
                
                // All other instruction types for odd pipe have at most a second source register
                if (odd_instruction_type == RR) begin
                    if (odd_opcode != OP_BRANCH_INDIRECT && odd_opcode != OP_BRANCH_INDIRECT_AND_SET_LINK) begin
                        if (odd_read_addr_b == temp_write_addr) begin
                            data_hazard_signal = 1;
                        end
                    end
                end

                // Add checks for store operations, edgecase
                if (odd_opcode == OP_STORE_QUADWORD_D || odd_opcode == OP_STORE_QUADWORD_A || odd_opcode == OP_STORE_QUADWORD_X) begin
                    if (odd_read_addr_c == temp_write_addr) begin
                        data_hazard_signal = 1;
                    end
                end

                // Add checks for branch operations, edgecase
                if (odd_opcode == OP_BRANCH_IF_ZERO_WORD || odd_opcode == OP_BRANCH_IF_ZERO_HALFWORD ||
                odd_opcode == OP_BRANCH_IF_NOT_ZERO_WORD || odd_opcode == OP_BRANCH_IF_NOT_ZERO_HALFWORD) begin
                    if (odd_read_addr_b == temp_write_addr) begin
                        data_hazard_signal = 1;
                    end
                end
            end

            // Check with instructions in even execution pipe
            for (int i = 0; i < 6; ++i) begin
                // Extract informaiton about instruction at each execution stage
                temp_reg_write = even_stage_results[i].reg_write_flag;
                temp_present_bit = even_stage_results[i].present_bit;
                temp_ready_stage_number = even_stage_results[i].ready_stage_number;
                temp_current_stage_number = even_stage_results[i].current_stage_number;

                if (temp_current_stage_number < temp_ready_stage_number) begin
                    data_hazard_signal = 1;
                    break;
                end

                if (temp_reg_write == 0 || temp_present_bit == 0) begin
                    continue;
                end

                temp_write_addr = even_stage_results[i].reg_write_addr;
                
                // Analyze current instruction thats about to be executed
                if (odd_instruction_type == RI18 || (odd_instruction_type == RI16 && odd_opcode != OP_STORE_QUADWORD_A)) begin
                end

                // All instruction types have at least reg_A as source
                else if (odd_read_addr_a == temp_write_addr) begin
                    data_hazard_signal = 1;
                end
                
                // All other instruction types for odd pipe have at most a second source register
                if (odd_instruction_type == RR) begin
                    if (odd_opcode != OP_BRANCH_INDIRECT && odd_opcode != OP_BRANCH_INDIRECT_AND_SET_LINK) begin
                        if (odd_read_addr_b == temp_write_addr) begin
                            data_hazard_signal = 1;
                        end
                    end
                end

                // Add checks for store operations, edgecase
                if (odd_opcode == OP_STORE_QUADWORD_D || odd_opcode == OP_STORE_QUADWORD_A || odd_opcode == OP_STORE_QUADWORD_X) begin
                    if (odd_read_addr_c == temp_write_addr) begin
                        data_hazard_signal = 1;
                    end
                end

                // Add checks for branch operations, edgecase
                if (odd_opcode == OP_BRANCH_IF_ZERO_WORD || odd_opcode == OP_BRANCH_IF_ZERO_HALFWORD ||
                odd_opcode == OP_BRANCH_IF_NOT_ZERO_WORD || odd_opcode == OP_BRANCH_IF_NOT_ZERO_HALFWORD) begin
                    if (odd_read_addr_b == temp_write_addr) begin
                        data_hazard_signal = 1;
                    end
                end
            end

            // Check odd instruction with odd output of rf_ex stage
            if (rf_ex_odd_reg_write) begin
                temp_write_addr = rf_ex_odd_rt_addr;
                // Analyze current instruction thats about to be executed
                if (odd_instruction_type == RI18 || (odd_instruction_type == RI16 && odd_opcode != OP_STORE_QUADWORD_A)) begin
                end

                // All instruction types have at least reg_A as source
                else if (odd_read_addr_a == temp_write_addr) begin
                    data_hazard_signal = 1;
                end
                
                // All other instruction types for odd pipe have at most a second source register
                if (odd_instruction_type == RR) begin
                    if (odd_opcode != OP_BRANCH_INDIRECT && odd_opcode != OP_BRANCH_INDIRECT_AND_SET_LINK) begin
                        if (odd_read_addr_b == temp_write_addr) begin
                            data_hazard_signal = 1;
                        end
                    end
                end

                // Add checks for store operations, edgecase
                if (odd_opcode == OP_STORE_QUADWORD_D || odd_opcode == OP_STORE_QUADWORD_A || odd_opcode == OP_STORE_QUADWORD_X) begin
                    if (odd_read_addr_c == temp_write_addr) begin
                        data_hazard_signal = 1;
                    end
                end

                // Add checks for branch operations, edgecase
                if (odd_opcode == OP_BRANCH_IF_ZERO_WORD || odd_opcode == OP_BRANCH_IF_ZERO_HALFWORD ||
                odd_opcode == OP_BRANCH_IF_NOT_ZERO_WORD || odd_opcode == OP_BRANCH_IF_NOT_ZERO_HALFWORD) begin
                    if (odd_read_addr_b == temp_write_addr) begin
                        data_hazard_signal = 1;
                    end
                end

            end

            // Check even instruction with odd output of id_rf stage
            if (id_rf_odd_reg_write) begin
                temp_write_addr = id_rf_odd_rt_addr;
                // Analyze current instruction thats about to be executed
                if (odd_instruction_type == RI18 || (odd_instruction_type == RI16 && odd_opcode != OP_STORE_QUADWORD_A)) begin
                end

                // All instruction types have at least reg_A as source
                else if (odd_read_addr_a == temp_write_addr) begin
                    data_hazard_signal = 1;
                end
                
                // All other instruction types for odd pipe have at most a second source register
                if (odd_instruction_type == RR) begin
                    if (odd_opcode != OP_BRANCH_INDIRECT && odd_opcode != OP_BRANCH_INDIRECT_AND_SET_LINK) begin
                        if (odd_read_addr_b == temp_write_addr) begin
                            data_hazard_signal = 1;
                        end
                    end
                end

                // Add checks for store operations, edgecase
                if (odd_opcode == OP_STORE_QUADWORD_D || odd_opcode == OP_STORE_QUADWORD_A || odd_opcode == OP_STORE_QUADWORD_X) begin
                    if (odd_read_addr_c == temp_write_addr) begin
                        data_hazard_signal = 1;
                    end
                end

                // Add checks for branch operations, edgecase
                if (odd_opcode == OP_BRANCH_IF_ZERO_WORD || odd_opcode == OP_BRANCH_IF_ZERO_HALFWORD ||
                odd_opcode == OP_BRANCH_IF_NOT_ZERO_WORD || odd_opcode == OP_BRANCH_IF_NOT_ZERO_HALFWORD) begin
                    if (odd_read_addr_b == temp_write_addr) begin
                        data_hazard_signal = 1;
                    end
                end
            end

            // Check with instructions in odd execution pipe
            for (int i = 0; i < 6; ++i) begin
                // Extract informaiton about instruction at each execution stage
                temp_reg_write = odd_stage_results[i].reg_write_flag;
                temp_present_bit = odd_stage_results[i].present_bit;
                temp_ready_stage_number = odd_stage_results[i].ready_stage_number;
                temp_current_stage_number = odd_stage_results[i].current_stage_number;

                if (temp_current_stage_number < temp_ready_stage_number) begin
                    data_hazard_signal = 1;
                    break;
                end

                if (temp_reg_write == 0 || temp_present_bit == 0) begin
                    continue;
                end

                temp_write_addr = odd_stage_results[i].reg_write_addr;
                
                // Analyze current instruction thats about to be executed
                if (odd_instruction_type == RI18 || (odd_instruction_type == RI16 && odd_opcode != OP_STORE_QUADWORD_A)) begin
                end

                // All instruction types have at least reg_A as source
                else if (odd_read_addr_a == temp_write_addr) begin
                    data_hazard_signal = 1;
                end
                
                // All other instruction types for odd pipe have at most a second source register
                if (odd_instruction_type == RR) begin
                    if (odd_opcode != OP_BRANCH_INDIRECT && odd_opcode != OP_BRANCH_INDIRECT_AND_SET_LINK) begin
                        if (odd_read_addr_b == temp_write_addr) begin
                            data_hazard_signal = 1;
                        end
                    end
                end

                // Add checks for store operations, edgecase
                if (odd_opcode == OP_STORE_QUADWORD_D || odd_opcode == OP_STORE_QUADWORD_A || odd_opcode == OP_STORE_QUADWORD_X) begin
                    if (odd_read_addr_c == temp_write_addr) begin
                        data_hazard_signal = 1;
                    end
                end

                // Add checks for branch operations, edgecase
                if (odd_opcode == OP_BRANCH_IF_ZERO_WORD || odd_opcode == OP_BRANCH_IF_ZERO_HALFWORD ||
                odd_opcode == OP_BRANCH_IF_NOT_ZERO_WORD || odd_opcode == OP_BRANCH_IF_NOT_ZERO_HALFWORD) begin
                    if (odd_read_addr_b == temp_write_addr) begin
                        data_hazard_signal = 1;
                    end
                end
            end


        end

            


endfunction : check_odd

endmodule




