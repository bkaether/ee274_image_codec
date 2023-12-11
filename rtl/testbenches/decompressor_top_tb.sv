module decompressor_top_tb();
    reg clk;
    reg rst_n;
    reg start_img;
    reg signed [8:0] image_quantized_coeffs  [479:0][639:0];

    reg signed [62:0] reconstructed_image_out [479:0][639:0];
    reg img_done;

    always #5 clk = ~clk;

    decompressor_top decompressor_top_i (
        .clk(clk),
        .rst_n(rst_n),
        .start_img(start_img),
        .image_quantized_coeffs(image_quantized_coeffs),

        .reconstructed_image_out(reconstructed_image_out),
        .img_done(img_done)
    );

    initial begin
        $readmemh("full_image_comp_out_hw.mem", image_quantized_coeffs);
        clk <= 0;
        rst_n = 1;
        start_img <= 0;
        #20
        rst_n = 0;
        #20
        rst_n = 1;
        #20
        start_img <= 1;
        #20
        start_img <= 0;
        #700
        $writememh("../../../../../github/ee274_image_codec/memfiles/hw_output/full_image_reconstructed_hw.mem", reconstructed_image_out);
        $display("Test finished");
        $finish();
    end

endmodule