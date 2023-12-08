module compressor_top #(
    parameter IMG_ROWS = 480,
    parameter IMG_COLS = 640,
    parameter BLOCK_SIZE = 8;
    parameter LOG2_BLOCK_SIZE = 3,
    parameter DCT_OUT_WIDTH = 52,
    parameter ROW_CTR_WIDTH = 9
) (
    input  wire clk,
    input  wire rst_n,
    input  wire start_img,
    input  wire signed [8:0] image [IMG_ROWS-1:0][IMG_COLS-1:0], // Q9.0

    output wire signed [51:0] quantized_coeffs [IMG_ROWS-1:0][IMG_COLS-1:0]
    output wire img_done;
);

    `define STATE_IDLE        2'b00
    `define STATE_CALCULATING 2'b01
    `define STATE_DONE        2'b10

    localparam NUM_BLOCKS_IN_ROW = (IMG_COLS >> BLOCK_SIZE);

    // state signals
    wire [1:0] nxt_state;
    reg  [1:0] state;

    // row counter signals
    wire row_ctr_restart;
    wire row_ctr_go;
    wire [ROW_CTR_WIDTH-1:0] row_ctr_count;
    wire row_ctr_done;

    assign row_ctr_restart = (state === `STATE_IDLE);
    assign row_ctr_go =      (state === `STATE_CALCULATING);

    assign nxt_state = (state === `STATE_CALCULATING) ? (row_ctr_done ? `STATE_DONE : `STATE_CALCULATING) :
                       (state === `STATE_IDLE)        ? (start_img    ? `STATE_CALCULATING : `STATE_IDLE) :
                       (state === `STATE_DONE)        ? `STATE_IDLE : `STATE_IDLE;


    assign img_done = (state === `STATE_DONE);

    generate
        genvar i;
        for (i = 0; i < (NUM_BLOCKS_IN_ROW); i = i + 1) begin

            wire start_block;
            wire signed [8:0] block [BLOCK_SIZE-1:0][BLOCK_SIZE-1:0], // Q9.0
            reg signed [DCT_OUT_WIDTH-1:0] dct_block_out [BLOCK_SIZE-1:0][BLOCK_SIZE-1:0]; // Q18.16 + Q1.8 + Q1.8 = Q20.32

            compress_block #(
                .BLOCK_SIZE(BLOCK_SIZE),
                .DCT_OUT_WIDTH(DCT_OUT_WIDTH)
            ) compress_block_i (
                .clk(clk),
                .rst_n(rst_n),
                .start_block(start_block),
                .block(block),

                .dct_block_out(dct_block_out),
                .block_done(block_done)
            );
        end
    endgenerate

    counter #(
        .WIDTH(ROW_CTR_WIDTH)
    ) row_counter_i (
        .clk(clk),
        .rst_n(rst_n),
        .restart(row_ctr_restart),
        .go(row_ctr_go),

        .count(row_ctr_count),
        .done(row_ctr_done)
    );

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