typedef logic [0:6] addr; //by defualt logic is already unsigned
typedef logic [0:127] data;

//should output - srcA, srcB, srcC   (actual values)
/*//forward metadata
- destination register (rd)
- unit_id
- control signals
*/

module sourceOperand(
    //inputs
    input logic register_write1, register_write2,

    /*  Only need this for register file */
    //input addr read_addr1_1, read_addr1_2, read_addr1_3,
    //input addr read_addr2_1, read_addr2_2,  read_addr2_3,

    //control signals
    input logic immFlag1, immFlag2, 
    input logic thirdReg_operand1, thirdReg_operand2, 
    //sign extension/zero extension is handled in decode unit 

    //Chat says its not necessary for now: input logic isLoad_Store2, //local store only has 1 unit so it has only 1 instruction at a time (at the odd pipe)
    input logic [2:0] unit_id1, unit_id2,

    input logic use_srcA1, use_srcB1, use_srcC1,
    input logic use_srcA2, use_srcB2, use_srcC2,
    
    //immediate values
    input data imm1, imm2, //IMPORTANT: might have to change this since immediates have different lengths depending on inst. type
    input data read_data1_1, read_data1_2, read_data1_3,
    input data read_data2_1, read_data2_2, read_data2_3,

    // Metadata (pass-through) 
    input addr write_addr1, write_addr2, //values we're changing
    //input data write_data1, write_data2, (this is changed in execute unit so doesn't matter

    // Outputs
    output data srcA1, srcB1, srcC1,
    output data srcA2, srcB2, srcC2,

    output logic register_write1_out, register_write2_out,
    output logic [2:0] unit_id1_out, unit_id2_out,
    output addr dest_reg1_out, dest_reg2_out
);

always_comb begin
    //first instruction operands 
    srcA1 = (use_srcA1) ? read_data1_1 : 128'b0;
    srcB1 = (use_srcB1) ? ((immFlag1) ? imm1 : read_data1_2) : 128'b0;
    srcC1 = (use_srcC1) ? read_data1_3 : 128'b0;

    //second instruction operands 
    srcA2 = (use_srcA2) ? read_data2_1 : 128'b0;
    srcB2 = (use_srcB2) ? ((immFlag2) ? imm2 : read_data2_2) : 128'b0;
    srcC2 = (use_srcC2) ? read_data2_3 : 128'b0;

    //bypass through
    unit_id1_out = unit_id1;
    unit_id2_out = unit_id2;

    dest_reg1_out = write_addr1;
    dest_reg2_out = write_addr2;

    register_write1_out = register_write1;
    register_write2_out = register_write2;

end //comb end 

endmodule

