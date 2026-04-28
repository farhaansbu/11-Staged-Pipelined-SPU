`timescale 1ns/1ps

module tb_instruction_buffer;

    logic [0:8] program_counter;

    logic [0:31] instruction_1;
    logic [0:31] instruction_2;
    logic [0:8] pc_1;
    logic [0:8] pc_2;

    // DUT
    instruction_buffer dut (
        .program_counter(program_counter),
        .instruction_1(instruction_1),
        .instruction_2(instruction_2),
        .pc_1(pc_1),
        .pc_2(pc_2)
    );

    initial begin
        $display("=== Starting Instruction Buffer Test ===");

        // wait for file load
        #1;

        // test a few addresses
        for (int i = 0; i < 32; i += 8) begin
            program_counter = i;
            #1;

            $display("PC=%0d | PC1=%0d PC2=%0d | INST1=%h INST2=%h",
                program_counter, pc_1, pc_2, instruction_1, instruction_2);
        end

        $finish;
    end

endmodule