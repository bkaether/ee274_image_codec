module compressor_top_seq_tb();
    reg clk;
    reg rst_n;
    reg start_img;
    reg signed [8:0] image [479:0][639:0];

    reg signed [53:0] quantized_coeffs_out [479:0][639:0];
    reg img_done;

    always #5 clk = ~clk;

    compressor_top_seq compressor_top_seq_i (
        .clk(clk),
        .rst_n(rst_n),
        .start_img(start_img),
        .image(image),

        .quantized_coeffs_out(quantized_coeffs_out),
        .img_done(img_done)
    );

    initial begin
        $readmemb("full_image.mem", image);
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
        #42000
        $writememh("../../../../../github/ee274_image_codec/memfiles/hw_output/full_image_comp_out_seq.mem", quantized_coeffs_out);
        $display("Test finished");
        $finish();
    end


endmodule