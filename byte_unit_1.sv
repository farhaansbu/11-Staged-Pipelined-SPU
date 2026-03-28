/*

Use the unit id to assign a unit and pipe (Even: FP1, FX1 (SIMPLE FIXED 2), BYTE, FX1 (SIMPLE FIXED 2), LS, BRANCH)
Package to output: (unit_id, result, dest_reg, ready_stage, RegWr)
// */


module byte_unit;

localparam BYTE_BITS = 8;
localparam WORD_BITS = 32;
localparam HALFWORD_BITS = 16;

/*Average Bytes */
/*
- this function takes sum of RA and RB + 1 (for averaging)
- there are 16 bytes in 128 bit register 
- handled overflow since ISA said without loss of precision
*/
function automatic logic[0:127] average_bytes (input logic[0:127] ra, input logic[0:127] rb);
logic[0:127] rt;
logic[0:8] sum; //9 bits for overflow 

for (int j = 0; j <= 15; ++j) begin   
    sum = {1'b0, ra[j*BYTE_BITS +: BYTE_BITS]} + {1'b0, rb[j*BYTE_BITS +: BYTE_BITS]} + 9'd1;
    rt[j*BYTE_BITS +: BYTE_BITS] = sum[1:8]; // divide by 2
end
return rt;
endfunction : average_bytes  


/* Sum Bytes into Halfwords */
/*
- add 4 bytes of RB place result in bytes 0 and 1 of RT
- add 4 bytes of RA result in bytes 2 and 3 of RT
*/ 

function automatic logic [0:127] sum_bytes_into_halfwords (input logic [0:127] ra, input logic [0:127] rb);
    logic [0:127] rt;
    logic [0:15] sum_rb, sum_ra; // 16-bit to hold sum of 4 unsigned bytes (max 4*255 = 1020)

    for (int w = 0; w < 4; w++) begin
        sum_rb = 16'd0;
        sum_ra = 16'd0;

        // sum 4 bytes from RB and RA for this word slot
        for (int b = 0; b < 4; b++) begin
            sum_rb = sum_rb + {8'b0, rb[(w*4 + b)*BYTE_BITS +: BYTE_BITS]}; // zero extend
            sum_ra = sum_ra + {8'b0, ra[(w*4 + b)*BYTE_BITS +: BYTE_BITS]}; 
        end

        // RB sum → upper halfword (bytes 0:1 of word)
        rt[w*WORD_BITS +: HALFWORD_BITS] = sum_rb;
        // RA sum → lower halfword (bytes 2:3 of word)
        rt[w*WORD_BITS + HALFWORD_BITS +: HALFWORD_BITS] = sum_ra;
    end
    return rt;
endfunction : sum_bytes_into_halfwords

/* Absolute Difference of Bytes */
/*
- 16 byte slots RA is subtracted RB 
- Absolute value of result is placed in RT
*/ 

function automatic logic [0:127] absolute_difference_of_bytes (input logic [0:127] ra, input logic [0:127] rb);
    logic [0:127] rt;

    for (int j = 0; j <= 15; ++j) begin   
        if(rb[j*BYTE_BITS +: BYTE_BITS] > ra[j*BYTE_BITS +: BYTE_BITS]) begin
            rt[j*BYTE_BITS +: BYTE_BITS] = rb[j*BYTE_BITS +: BYTE_BITS] - ra[j*BYTE_BITS +: BYTE_BITS];
        end else begin
            rt[j*BYTE_BITS +: BYTE_BITS] = ra[j*BYTE_BITS +: BYTE_BITS] - rb[j*BYTE_BITS +: BYTE_BITS];
        end
end
return rt;
endfunction : absolute_difference_of_bytes

/* Count ones in Bytes */
/*
- count number of 2's in RA and write it to Rt
*/ 

function automatic logic [0:127] count_ones_in_bytes (input logic [0:127] ra);
    logic [0:127] rt;
    logic [0:3] count; // max value is 8, needs 4 bits

    for (int j = 0; j <= 15; ++j) begin
        count = 4'd0;
        
        for (int m = 0; m <= 7; ++m) begin
            if (ra[j*BYTE_BITS + m] == 1'b1) begin
                count = count + 4'd1;
            end
        end
        rt[j*BYTE_BITS +: BYTE_BITS] = {4'b0, count}; // zero-extend to 8 bits
    end
return rt;
endfunction : count_ones_in_bytes

endmodule

