module compress_block #(
    parameter BLOCK_SIZE = 8,
    parameter DCT_OUT_WIDTH = 52
) (
    input  wire clk,
    input  wire rst_n,
    input  wire start_block,
    input  wire signed [8:0] block [BLOCK_SIZE-1:0][BLOCK_SIZE-1:0], // Q9.0

    output wire signed [DCT_OUT_WIDTH-1:0] quantized_coeffs [BLOCK_SIZE-1:0][BLOCK_SIZE-1:0],
    output wire block_done
);

    // forward DCT block output
    reg signed [DCT_OUT_WIDTH-1:0] dct_block_out [BLOCK_SIZE-1:0][BLOCK_SIZE-1:0]; // Q18.16 + Q1.8 + Q1.8 = Q20.32

    dct_2d #(
        .BLOCK_SIZE(BLOCK_SIZE),
        .DCT_OUT_WIDTH(DCT_OUT_WIDTH)
    ) dct_2d_i (
        .clk(clk),
        .rst_n(rst_n),
        .start_block(start_block),
        .block(block),

        .dct_block_out(dct_block_out),
        .block_done(block_done)
    );

    quantizer #(
        .BLOCK_SIZE(BLOCK_SIZE),
        .DCT_OUT_WIDTH(DCT_OUT_WIDTH)
    ) quantizer_i (
        .dct_block_out(dct_block_out),
        .quantized_coeffs(quantized_coeffs)
    );
    
endmodule