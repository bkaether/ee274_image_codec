module quantizer #(
    parameter BLOCK_SIZE = 8,
    parameter DCT_OUT_WIDTH = 54,
    parameter COEFF_WIDTH = 9
) (
    input signed [DCT_OUT_WIDTH-1:0] dct_block_out [BLOCK_SIZE-1:0][BLOCK_SIZE-1:0],

    output wire signed [COEFF_WIDTH-1:0] quantized_coeffs [BLOCK_SIZE-1:0][BLOCK_SIZE-1:0]
);

    // rounded quantization matrix shift values
    reg [2:0] shift_values [BLOCK_SIZE-1:0][BLOCK_SIZE-1:0];

    generate
        genvar i, j;
        for (i = 0; i < BLOCK_SIZE; i = i + 1) begin
            for (j = 0; j < BLOCK_SIZE; j = j + 1) begin
                wire signed [DCT_OUT_WIDTH-1:0] unrounded = (dct_block_out[i][j] >>> (shift_values[i][j] + 31));
                wire signed [DCT_OUT_WIDTH-1:0] unclipped = unrounded[0] ? ((unrounded >>> 1) + 1) : (unrounded >>> 1);
                assign quantized_coeffs[i][j] = unclipped[COEFF_WIDTH-1:0];
            end
        end
    endgenerate

    initial begin
        $readmemb("quantization.mem", shift_values);
    end
    
endmodule