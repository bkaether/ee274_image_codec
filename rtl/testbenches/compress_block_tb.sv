module compress_block_tb();
    reg clk;
    reg rst_n;
    reg start_block;
    reg signed [8:0] block [7:0][7:0];

    reg signed [51:0] quantized_coeffs [7:0][7:0];
    reg block_done;

    always #5 clk = ~clk;

    compress_block compress_block_i (
        .clk(clk),
        .rst_n(rst_n),
        .start_block(start_block),
        .block(block),

        .quantized_coeffs(quantized_coeffs),
        .block_done(block_done)
    );

    initial begin
        $readmemb("first_block.mem", block);
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
        $writememh("../../../../../github/ee274_image_codec/memfiles/hw_output/b1_coeffs_out_hw.mem", quantized_coeffs);
        $display("Test finished");
        $finish();
    end

endmodule