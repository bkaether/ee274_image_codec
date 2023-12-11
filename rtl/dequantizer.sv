module dequantizer #(
    parameter BLOCK_SIZE = 8,
    parameter COEFF_WIDTH = 9
) (
    input  wire signed [COEFF_WIDTH-1:0] quantized_coeffs [BLOCK_SIZE-1:0][BLOCK_SIZE-1:0],

    output wire signed [COEFF_WIDTH+6:0] dequantized_coeffs [BLOCK_SIZE-1:0][BLOCK_SIZE-1:0]
);

    // rounded quantization matrix shift values
    reg [2:0] shift_values [BLOCK_SIZE-1:0][BLOCK_SIZE-1:0];

    generate
        genvar i, j;
        for (i = 0; i < BLOCK_SIZE; i = i + 1) begin
            for (j = 0; j < BLOCK_SIZE; j = j + 1) begin
                assign dequantized_coeffs[i][j] = (quantized_coeffs[i][j] <<< shift_values[i][j]);
            end
        end
    endgenerate

    initial begin
        $readmemb("quantization.mem", shift_values);
    end
    
endmodule