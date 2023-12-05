module dct_2d #(
    parameter BLOCK_SIZE = 8
) (
    input  wire [31:0] block [BLOCK_SIZE][BLOCK_SIZE],
    output wire [31:0] dct_block [BLOCK_SIZE][BLOCK_SIZE]
);

reg [31:0] cosine_values [BLOCK_SIZE][BLOCK_SIZE];

initial begin
    $readmemh
end
    
endmodule