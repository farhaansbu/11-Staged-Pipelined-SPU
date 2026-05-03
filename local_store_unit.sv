import instruction_pkg::*;

module local_store_unit (
    input logic clk,
    input logic flush_stage_1,

    input logic [0:127] odd_source_a,
    input logic [0:127] odd_source_b,
    input logic [0:127] odd_source_c,
    input logic [0:6] odd_write_address,
    input opcode_t odd_opcode,
    input logic[0:2] odd_unit_id,
    input logic reg_write,

    output unit_result_packet output_packet

);

logic[0:7] local_store[0:32768];
initial begin
        for (int i = 0; i < 32768; i++) begin
            local_store[i] = '0;
        end
end

always_ff @(posedge clk) begin

    if (odd_unit_id != 6) begin // Unit id doesn't match
        output_packet.present_bit <= 0;
    end

    else begin
        // Record unit id, write addr, other control signals
        output_packet.unit_id <= odd_unit_id;
        output_packet.reg_write_addr <= odd_write_address;
        output_packet.present_bit <= 1;
        output_packet.ready_stage_number <= 7;
        output_packet.current_stage_number <= 2;
        
        if (flush_stage_1) begin
            output_packet.reg_write_flag <= 0;
        end
        else begin
            output_packet.reg_write_flag <= reg_write;
            // Calculate result
            case (odd_opcode)

                OP_LOAD_QUADWORD_X: begin
                    output_packet.result <= load_quadword_x(odd_source_a, odd_source_b);
                end

                OP_LOAD_QUADWORD_D: begin
                    output_packet.result <= load_quadword_d(odd_source_a, odd_source_b[0:9]);
                end

                OP_LOAD_QUADWORD_A: begin
                    output_packet.result <= load_quadword_a(odd_source_a[0:15]);
                end

                OP_STORE_QUADWORD_X: begin
                    store_quadword_x(odd_source_a, odd_source_b, odd_source_c);
                end

                OP_STORE_QUADWORD_D: begin
                    store_quadword_d(odd_source_a, odd_source_b[0:9], odd_source_c);
                end
                
                OP_STORE_QUADWORD_A: begin
                    store_quadword_a(odd_source_a[0:15], odd_source_c);
                end

                default: ;

            endcase
        end


    end
end


localparam logic[0:32] LSLR = 32'h0000_7FFF;    // max size of memory 32 KB (32768 bytes)






function automatic logic[0:127] load_quadword_x (input logic[0:127] ra, input logic[0:127] rb);
    logic[0:127] loaded_data;
    logic[0:31] addr = (rb[0:31] + ra[0:31]) & LSLR & 32'hFFFF_FFF0;

    for (int i = 0; i < 16; i++) begin
        loaded_data[i * 8 +: 8] = local_store[addr + i];
    end
    return loaded_data;
endfunction : load_quadword_x

function automatic logic[0:127] load_quadword_d (input logic[0:127] ra, input logic[0:9] i10);
    logic[0:127] loaded_data;
    logic[0:31] imm32 = {{18{i10[0]}}, i10, 4'b0};
    logic[0:31] addr = (imm32 + ra[0:31]) & LSLR & 32'hFFFF_FFF0;

    for (int i = 0; i < 16; i++) begin
        loaded_data[i * 8 +: 8] = local_store[addr + i];
    end
    return loaded_data;
endfunction : load_quadword_d

function automatic logic[0:127] load_quadword_a (input logic[0:15] i16);
    logic[0:127] loaded_data;
    logic[0:31] imm32 = {{14{i16[0]}}, i16, 2'b0};
    logic[0:31] addr = imm32 & LSLR & 32'hFFFF_FFF0;

    for (int i = 0; i < 16; i++) begin
        loaded_data[i * 8 +: 8] = local_store[addr + i];
    end
    return loaded_data;
endfunction : load_quadword_a

function automatic void store_quadword_d (input logic[0:127] ra, input logic[0:9] i10, input logic[0:127] rt);

    logic[0:31] imm32 = {{18{i10[0]}}, i10, 4'b0};
    logic[0:31] addr = (imm32 + ra[0:31]) & LSLR & 32'hFFFF_FFF0;

    for (int i = 0; i < 16; i++) begin
        local_store[addr + i] = rt[i * 8 +: 8]; 
    end
endfunction : store_quadword_d


function automatic void store_quadword_x (input logic[0:127] ra, input logic[0:127] rb, input logic[0:127] rt);

    logic[0:31] addr = (rb[0:31] + ra[0:31]) & LSLR & 32'hFFFF_FFF0;

    for (int i = 0; i < 16; i++) begin
        local_store[addr + i] = rt[i * 8 +: 8]; 
    end
    
endfunction : store_quadword_x

function automatic void store_quadword_a (input logic[0:15] i16, input logic[0:127] rt);

    logic[0:31] imm32 = {{14{i16[0]}}, i16, 2'b0};
    logic[0:31] addr = imm32 & LSLR & 32'hFFFF_FFF0;

    for (int i = 0; i < 16; i++) begin
        local_store[addr + i] = rt[i * 8 +: 8]; 
    end
   
endfunction : store_quadword_a

endmodule