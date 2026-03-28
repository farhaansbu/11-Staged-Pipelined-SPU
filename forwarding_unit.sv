import instruction_pkg::*;

module forwarding_unit (

    input logic[0:6] even_read_addr_1,
    input logic[0:6] even_read_addr_2,
    input logic[0:6] even_read_addr_3,
    input opcode_t even_opcode,

    input logic[0:6] odd_read_addr_1,
    input logic[0:6] odd_read_addr_2,
    input logic[0:6] odd_read_addr_3,
    input opcode_t od_opcode



);

endmodule