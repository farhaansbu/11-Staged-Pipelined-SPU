module local_store_unit;

localparam logic[0:32] LSLR = 32'h0000_7FFF;    // max size of memory 32 KB (32768 bytes)

logic[0:7] local_store[0:32768];

function automatic logic[0:127] load_quadword_d (input logic[0:127] ra, input logic[0:9] i10);
    logic[0:127] loaded_data;
    logic[0:31] imm32 = {{18{i10[0]}}, i10, 4'b0};
    logic[0:31] addr = (imm32 + ra[0:31]) & LSLR & 32'hFFFF_FFF0;

    for (int i = 0; i < 16; i++) begin
        loaded_data[i * 8 +: 8] = local_store[addr + i];
    end
    return loaded_data;
endfunction

endmodule