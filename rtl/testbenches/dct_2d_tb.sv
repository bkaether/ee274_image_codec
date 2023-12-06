module dct_2d_tb();
    reg clk;
    reg rst_n;
    reg start_block;
    reg signed [8:0] block [7:0][7:0];

    wire signed [51:0] dct_block_out [7:0][7:0];
    wire block_done;

    always #5 clk = ~clk;

    dct_2d dct_2d_i (
        .clk(clk),
        .rst_n(rst_n),
        .start_block(start_block),
        .block(block),

        .dct_block_out(dct_block_out),
        .block_done(block_done)
    );

    initial begin
        $readmemb("../memfiles/first_block.mem", block);
        $display("Test finished");
        $finish();
    end

endmodule