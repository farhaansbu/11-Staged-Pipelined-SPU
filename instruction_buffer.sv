`timescale 1ns/1ps

module instruction_buffer (
    input  logic[0:8]  program_counter,          // 512 entries needs 9 bits
    output logic[0:31] instruction_1,
    output logic[0:31] instruction_2,
    output logic[0:8] pc_1,
    output logic[0:8] pc_2
);

    logic [0:7] imem[2048];
    logic [0:31] temp_instr [0:511];

    initial begin
        
        $readmemb("instructions.txt", temp_instr);
        for (int i = 0; i < 512; i++) begin
            imem[i*4 + 0] = temp_instr[i][0:7];
            imem[i*4 + 1] = temp_instr[i][8:15];
            imem[i*4 + 2] = temp_instr[i][16:23];
            imem[i*4 + 3] = temp_instr[i][24:31];
        end
    end

    always_comb begin
        for (int i = 0; i < 512; i++) begin
            instruction_1[i * 8 +: 8] = imem[program_counter + i];
            instruction_2[i * 8 +: 8] = imem[program_counter + 4 + i];
        end

        pc_1 = program_counter;
        pc_2 = program_counter + 4;
    end

endmodule