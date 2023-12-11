module decompress_block_tb();
    reg clk;
    reg rst_n;
    reg start_block;
    reg signed [8:0] quantized_coeffs [7:0][7:0];

    reg signed [62:0] reconstructed_block_out [7:0][7:0];
    reg block_done;

    always #5 clk = ~clk;

    decompress_block decompress_block_i (
        .clk(clk),
        .rst_n(rst_n),
        .start_block(start_block),
        .quantized_coeffs(quantized_coeffs),

        .reconstructed_block_out(reconstructed_block_out),
        .block_done(block_done)
    );

    initial begin
        $readmemh("b1_coeffs_out_hw.mem", quantized_coeffs);
        clk <= 0;
        rst_n = 1;
        start_block <= 0;
        #20
        rst_n = 0;
        #20
        rst_n = 1;
        #20
        start_block <= 1;
        #20
        start_block <= 0;
        #700
        $writememh("../../../../../github/ee274_image_codec/memfiles/hw_output/b1_reconstructed_out_hw.mem", reconstructed_block_out);
        $display("Test finished");
        $finish();
    end

endmodule