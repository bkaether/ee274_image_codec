module compressor_top #(
    parameter IMG_ROWS = 480,
    parameter IMG_COLS = 640,
    parameter BLOCK_SIZE = 8,
    parameter LOG2_BLOCK_SIZE = 3,
    parameter DCT_OUT_WIDTH = 52,
    parameter ROW_CTR_WIDTH = 9
) (
    input  wire clk,
    input  wire rst_n,
    input  wire start_img,
    input  wire signed [8:0] image [IMG_ROWS-1:0][IMG_COLS-1:0], // Q9.0

    output reg signed [DCT_OUT_WIDTH-1:0] quantized_coeffs_out [IMG_ROWS-1:0][IMG_COLS-1:0],
    output wire img_done
);

    `define STATE_IDLE        2'b00
    `define STATE_CALCULATING 2'b01
    `define STATE_DONE        2'b10

    localparam NUM_BLOCKS_IN_ROW = (IMG_COLS >> BLOCK_SIZE);
    localparam NUM_BLOCKS_IN_COL = (IMG_ROWS >> BLOCK_SIZE);

    // state signals
    wire [1:0] nxt_state;
    reg  [1:0] state;

    // row counter signals
    // wire row_ctr_restart;
    // wire row_ctr_go;
    // wire [ROW_CTR_WIDTH-1:0] row_ctr_count;
    // wire row_ctr_done;

    // assign row_ctr_restart = (state === `STATE_IDLE);
    // assign row_ctr_go =      &block_done;

    // assign nxt_state = (state === `STATE_CALCULATING) ? (row_ctr_done ? `STATE_DONE : `STATE_CALCULATING) :
    //                    (state === `STATE_IDLE)        ? (start_img    ? `STATE_CALCULATING : `STATE_IDLE) :
    //                    (state === `STATE_DONE)        ? `STATE_IDLE : `STATE_IDLE;

    assign nxt_state = (state === `STATE_CALCULATING) ? (block_done[0][0]  ? `STATE_DONE : `STATE_CALCULATING) :
                       (state === `STATE_IDLE)        ? (start_img    ? `STATE_CALCULATING : `STATE_IDLE) :
                       (state === `STATE_DONE)        ? `STATE_IDLE : `STATE_IDLE;


    assign img_done = (state === `STATE_DONE);

    // genvar i, j, k, x, y;
    genvar i, j, ii, jj;

    // wire signed [DCT_OUT_WIDTH-1:0] nxt_quantized_coeffs [IMG_ROWS-1:0][IMG_COLS-1:0];

    // flops for final image
    // generate
    //     for (x = 0; x < IMG_ROWS; x = x + 1) begin
    //         for (y = 0; x < IMG_COLS; y = y + 1) begin
    //             assign nxt_quantized_coeffs[x][y] = 

    //             ff_en #(
    //                 .WIDTH(DCT_OUT_WIDTH)
    //             ) dct_ff (
    //                 .clk(clk),
    //                 .rst_n(rst_n),
    //                 .en(),
    //                 .rst_val('0),
    //                 .D(nxt_quantized_coeffs[i][j]),

    //                 .Q(quantized_coeffs_out[i][j])
    //             );
    //         end
    //     end
    // endgenerate

    // dct block cores
    wire start_blocks;
    wire block_done [NUM_BLOCKS_IN_COL-1:0][NUM_BLOCKS_IN_ROW-1:0];

    assign start_blocks = (state === `STATE_CALCULATING);

    // generate
    //     for (i = 0; i < (NUM_BLOCKS_IN_ROW); i = i + 1) begin

    //         wire signed [8:0] block [BLOCK_SIZE-1:0][BLOCK_SIZE-1:0], // Q9.0
    //         wire signed [DCT_OUT_WIDTH-1:0] quantized_coeffs [BLOCK_SIZE-1:0][BLOCK_SIZE-1:0]; // Q18.16 + Q1.8 + Q1.8 = Q20.32

    //         for (j = 0; j < BLOCK_SIZE; j = j + 1) begin
    //             for (k = 0; j < BLOCK_SIZE; k = k + 1) begin
    //                 assign block[j][k] = image[(i*BLOCK_SIZE) + j][(row_ctr_count*BLOCK_SIZE)+k];
    //             end
    //         end

    //         compress_block #(
    //             .BLOCK_SIZE(BLOCK_SIZE),
    //             .DCT_OUT_WIDTH(DCT_OUT_WIDTH)
    //         ) compress_block_i (
    //             .clk(clk),
    //             .rst_n(rst_n),
    //             .start_block(start_block),
    //             .block(block),

    //             .quantized_coeffs(quantized_coeffs),
    //             .block_done(block_done[i])
    //         );
    //     end
    // endgenerate

    generate
        for (i = 0; i < (NUM_BLOCKS_IN_ROW); i = i + 1) begin
            for (j = 0; j < (NUM_BLOCKS_IN_COL); j = j + 1) begin

                wire signed [8:0] block [BLOCK_SIZE-1:0][BLOCK_SIZE-1:0]; // Q9.0
                wire signed [DCT_OUT_WIDTH-1:0] quantized_coeffs [BLOCK_SIZE-1:0][BLOCK_SIZE-1:0]; // Q18.16 + Q1.8 + Q1.8 = Q20.32

                for (ii = 0; ii < BLOCK_SIZE; ii = ii + 1) begin
                    for (jj = 0; jj < BLOCK_SIZE; jj = jj + 1) begin
                        assign block[ii][jj] = image[(i*BLOCK_SIZE) + ii][(j*BLOCK_SIZE)+jj];
                        assign quantized_coeffs_out[(i*BLOCK_SIZE) + ii][(j*BLOCK_SIZE)+jj] = quantized_coeffs[ii][jj];
                    end
                end

                compress_block #(
                    .BLOCK_SIZE(BLOCK_SIZE),
                    .DCT_OUT_WIDTH(DCT_OUT_WIDTH)
                ) compress_block_i (
                    .clk(clk),
                    .rst_n(rst_n),
                    .start_block(start_blocks),
                    .block(block),

                    .quantized_coeffs(quantized_coeffs),
                    .block_done(block_done[i][j])
                );
            end
        end
    endgenerate

    // counter #(
    //     .WIDTH(ROW_CTR_WIDTH),
    //     .MAX_COUNT(NUM_BLOCKS_IN_COL)
    // ) row_counter_i (
    //     .clk(clk),
    //     .rst_n(rst_n),
    //     .restart(row_ctr_restart),
    //     .go(row_ctr_go),

    //     .count(row_ctr_count),
    //     .done(row_ctr_done)
    // );

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