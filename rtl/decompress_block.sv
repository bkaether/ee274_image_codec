module decompress_block #(
    parameter BLOCK_SIZE = 8,
    parameter DCT_OUT_WIDTH = 54
) (
    input  wire clk,
    input  wire rst_n,
    input  wire start_block,
    input  wire signed [DCT_OUT_WIDTH-1:0] quantized_coeffs [BLOCK_SIZE-1:0][BLOCK_SIZE-1:0],

    output reg signed [DCT_OUT_WIDTH-1:0] reconstructed_block_out [BLOCK_SIZE-1:0][BLOCK_SIZE-1:0],
    output wire block_done
);

    wire signed [DCT_OUT_WIDTH-1:0] dequantized_coeffs [BLOCK_SIZE-1:0][BLOCK_SIZE-1:0];

    dequantizer #(
        .BLOCK_SIZE(BLOCK_SIZE),
        .DCT_OUT_WIDTH(DCT_OUT_WIDTH)
    ) dequantizer_i (
        .quantized_coeffs(quantized_coeffs),
        .dequantized_coeffs(dequantized_coeffs)
    );

    idct_2d #(
        .BLOCK_SIZE(BLOCK_SIZE),
        .DCT_OUT_WIDTH(DCT_OUT_WIDTH)
    ) idct_2d_i (
        .clk(clk),
        .rst_n(rst_n),
        .start_block(start_block),
        .dequantized_coeffs(dequantized_coeffs),

        .reconstructed_block_out(reconstructed_block_out),
        .block_done(block_done)
    );
    
endmodule