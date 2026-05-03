`timescale 1ns/1ps

module instruction_buffer (
    input logic clk,
    input logic reset,

    //signals that affect PC
    input logic same_pipe_hazard,
    input logic same_write_dest_hazard,
    input logic branch_signal,
    input logic data_hazard_signal,
    input logic concurrent_data_dependency_hazard_signal,
    input logic[0:10] branch_addr,

    output logic[0:31] instruction_1,
    output logic[0:31] instruction_2,
    output logic[0:10] pc_1,
    output logic[0:10] pc_2
);

    logic [0:7] imem[2048];
    logic [0:31] temp_instr [0:511];
    logic [0:10] program_counter;

    initial begin
        $readmemb("instructions1.txt", temp_instr);
        for (int i = 0; i < 512; i++) begin
            imem[i*4 + 0] = temp_instr[i][0:7];
            imem[i*4 + 1] = temp_instr[i][8:15];
            imem[i*4 + 2] = temp_instr[i][16:23];
            imem[i*4 + 3] = temp_instr[i][24:31];
        end
    end

    always_ff @(posedge clk or posedge reset) begin
        
        if (reset) begin
            program_counter <= 0;
            instruction_1 <= 0;
            instruction_2 <= 0;
            pc_1 <= 0;
            pc_2 <= 0;

        end else begin

            // If branching, jump to branch address first
            if (branch_signal == 1) begin
                program_counter = branch_addr;
            end

            else if (data_hazard_signal == 1) begin
                program_counter = program_counter - 8;
            end

            // If same pipe hazard, WAW hazard, or data dependency hazards between instructions being fetched
            else if (same_pipe_hazard == 1 || same_write_dest_hazard == 1 || concurrent_data_dependency_hazard_signal == 1) begin
                program_counter = program_counter - 4;
            end 

            
            // Get instructions needed
            for (int i = 0; i < 4; ++i) begin
                instruction_1[i*8 +: 8] <= imem[program_counter + i];
                instruction_2[i*8 +: 8] <= imem[program_counter + 4 + i];
            end
            
            pc_1 = program_counter;
            pc_2 = program_counter + 4;

            program_counter = program_counter + 8; // Increment PC


            
        end 

    end

endmodule