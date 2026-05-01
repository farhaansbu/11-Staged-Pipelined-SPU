module register_file(

   input logic reset,

   input logic[0:6] even_read_addr_1,
   input logic[0:6] even_read_addr_2,
   input logic[0:6] even_read_addr_3,
   input logic[0:6] even_write_addr,
   input logic[0:127] even_write_data,
   input logic even_reg_write,

   input logic[0:6] odd_read_addr_1,
   input logic[0:6] odd_read_addr_2,
   input logic[0:6] odd_read_addr_3,
   input logic[0:6] odd_write_addr,
   input logic[0:127] odd_write_data,
   input logic odd_reg_write,


   output logic[0:127] even_read_data_1,
   output logic[0:127] even_read_data_2,
   output logic[0:127] even_read_data_3,
   
   output logic[0:127] odd_read_data_1,
   output logic[0:127] odd_read_data_2,
   output logic[0:127] odd_read_data_3
);

//register array (first part is defined with data type)
logic [0:127] reg_file[0:127];

initial begin
    for (int i = 0; i < 127; i++) begin
        for (int j = 0; j < 4; ++j) begin
            int index;
            index = j * 32;
            reg_file[i][index +: 32] = i;
        end
    end
end

always_comb begin : register_file_body

    // Write to registers
    if (even_reg_write) begin
        reg_file[even_write_addr] = even_write_data;
    end

    if (odd_reg_write) begin
        reg_file[odd_write_addr] = odd_write_data;
    end

    // Read register data
    even_read_data_1 = reg_file[even_read_addr_1];
    even_read_data_2 = reg_file[even_read_addr_2];
    even_read_data_3 = reg_file[even_read_addr_3];

    odd_read_data_1 = reg_file[odd_read_addr_1];
    odd_read_data_2 = reg_file[odd_read_addr_2];
    odd_read_data_3 = reg_file[odd_read_addr_3];

    // if (reset == 1) begin
    //     for (int i = 0; i < 128; i++) begin
    //         reg_file[i] <= 128'b0; //non blocking executes in parallel
    //     end 
    // end
    
    
end




endmodule