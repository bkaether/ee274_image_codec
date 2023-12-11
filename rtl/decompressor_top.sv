module decompressor_top #(
    parameter IMG_ROWS = 480,
    parameter IMG_COLS = 640,
    parameter BLOCK_SIZE = 8,
    parameter LOG2_BLOCK_SIZE = 3,
    parameter COEFF_WIDTH = 9,
    parameter RECONST_OUT_WIDTH = 54
) (
    input  wire clk,
    input  wire rst_n,
    input  wire start_img,
    input  wire signed [COEFF_WIDTH-1:0] image_quantized_coeffs [IMG_ROWS-1:0][IMG_COLS-1:0],

    output reg  signed [RECONST_OUT_WIDTH+8:0] reconstructed_image_out [IMG_ROWS-1:0][IMG_COLS-1:0],
    output wire img_done
);

    `define STATE_IDLE        2'b00
    `define STATE_CALCULATING 2'b01
    `define STATE_DONE        2'b10

    localparam NUM_BLOCKS_IN_ROW = (IMG_COLS >> LOG2_BLOCK_SIZE);
    localparam NUM_BLOCKS_IN_COL = (IMG_ROWS >> LOG2_BLOCK_SIZE);

    // state signals
    wire [1:0] nxt_state;
    reg  [1:0] state;

    assign nxt_state = (state === `STATE_CALCULATING) ? (block_done[0][0]  ? `STATE_DONE : `STATE_CALCULATING) :
                       (state === `STATE_IDLE)        ? (start_img    ? `STATE_CALCULATING : `STATE_IDLE) :
                       (state === `STATE_DONE)        ? `STATE_IDLE : `STATE_IDLE;


    assign img_done = (state === `STATE_DONE);

    genvar i, j, ii, jj;

    // dct block cores
    wire start_blocks;
    wire block_done [NUM_BLOCKS_IN_COL-1:0][NUM_BLOCKS_IN_ROW-1:0];

    assign start_blocks = (state === `STATE_CALCULATING);

    generate
        for (i = 0; i < (NUM_BLOCKS_IN_COL); i = i + 1) begin
            for (j = 0; j < (NUM_BLOCKS_IN_ROW); j = j + 1) begin

                wire signed [COEFF_WIDTH-1:0] quantized_coeffs [BLOCK_SIZE-1:0][BLOCK_SIZE-1:0];
                wire signed [RECONST_OUT_WIDTH+8:0] reconstructed_block_out [BLOCK_SIZE-1:0][BLOCK_SIZE-1:0];

                for (ii = 0; ii < BLOCK_SIZE; ii = ii + 1) begin
                    for (jj = 0; jj < BLOCK_SIZE; jj = jj + 1) begin
                        assign quantized_coeffs[ii][jj] = image_quantized_coeffs[(i*BLOCK_SIZE) + ii][(j*BLOCK_SIZE)+jj];
                        assign reconstructed_image_out[(i*BLOCK_SIZE) + ii][(j*BLOCK_SIZE)+jj] = reconstructed_block_out[ii][jj];
                    end
                end

                decompress_block #(
                    .BLOCK_SIZE(BLOCK_SIZE),
                    .COEFF_WIDTH(COEFF_WIDTH),
                    .RECONST_OUT_WIDTH(RECONST_OUT_WIDTH)
                ) decompress_block_i (
                    .clk(clk),
                    .rst_n(rst_n),
                    .start_block(start_blocks),
                    .quantized_coeffs(quantized_coeffs),

                    .reconstructed_block_out(reconstructed_block_out),
                    .block_done(block_done[i][j])
                );
            end
        end
    endgenerate

    ff_en #(
        .WIDTH(2)
    ) state_ff (
        .clk(clk),
        .rst_n(rst_n),
        .en(1'b1),
        .rst_val('0),
        .D(nxt_state),

        .Q(state)
    );
    
endmodule