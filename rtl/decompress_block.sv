module decompress_block #(
    parameter BLOCK_SIZE = 8,
    parameter COEFF_WIDTH = 9,
    parameter RECONST_OUT_WIDTH = 54
) (
    input  wire clk,
    input  wire rst_n,
    input  wire start_block,
    input  wire signed [COEFF_WIDTH-1:0] quantized_coeffs [BLOCK_SIZE-1:0][BLOCK_SIZE-1:0],

    output reg  signed [RECONST_OUT_WIDTH+8:0] reconstructed_block_out [BLOCK_SIZE-1:0][BLOCK_SIZE-1:0],
    output wire block_done
);

    wire signed [COEFF_WIDTH+6:0] dequantized_coeffs [BLOCK_SIZE-1:0][BLOCK_SIZE-1:0];

    dequantizer #(
        .BLOCK_SIZE(BLOCK_SIZE),
        .COEFF_WIDTH(COEFF_WIDTH)
    ) dequantizer_i (
        .quantized_coeffs(quantized_coeffs),
        .dequantized_coeffs(dequantized_coeffs)
    );

    idct_2d #(
        .BLOCK_SIZE(BLOCK_SIZE),
        .COEFF_WIDTH(COEFF_WIDTH),
        .RECONST_OUT_WIDTH(RECONST_OUT_WIDTH)
    ) idct_2d_i (
        .clk(clk),
        .rst_n(rst_n),
        .start_block(start_block),
        .dequantized_coeffs(dequantized_coeffs),

        .reconstructed_block_out(reconstructed_block_out),
        .block_done(block_done)
    );
    
endmodule