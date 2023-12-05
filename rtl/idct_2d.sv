module idct_2d #(
    parameter BLOCK_SIZE = 8
) (
    input  wire [31:0] dct_block [BLOCK_SIZE][BLOCK_SIZE],
    output wire [31:0] reconstructed_block [BLOCK_SIZE][BLOCK_SIZE]
);
    
endmodule