`include "ff_en.sv"
`include "double_counter.sv"

module dct_2d #(
    parameter BLOCK_SIZE = 8,
    parameter DCT_OUT_WIDTH = 54
) (
    input  wire clk,
    input  wire rst_n,
    input  wire start_block,
    input  wire signed [8:0]  block     [BLOCK_SIZE-1:0][BLOCK_SIZE-1:0], // Q9.0

    output reg  signed [DCT_OUT_WIDTH-1:0] dct_block_out [BLOCK_SIZE-1:0][BLOCK_SIZE-1:0], // Q20.16 + Q1.8 + Q1.8 = Q22.32
    output wire block_done
);

// define states
`define STATE_IDLE        2'b00
`define STATE_CALCULATING 2'b01
`define STATE_DONE        2'b10

// define values to be used for alpha_u and alpha_v from gold software model ( 8.8 fixed point)
wire [8:0] root_one_over_n;
wire [8:0] root_two_over_n;
assign root_one_over_n = 9'b0_01011011; // = ~0.3536
assign root_two_over_n = 9'b0_10000000; // = 0.5

// state signals
wire [1:0] next_state;
reg  [1:0] state;

// double counter inputs
wire restart;
wire go;

assign restart = (state === `STATE_IDLE);
assign go = (state === `STATE_CALCULATING);

// double counter outputs
wire done;
wire [2:0] u;
wire [2:0] v;

assign next_state = (state === `STATE_IDLE)        ? (start_block ? `STATE_CALCULATING : `STATE_IDLE) :
                    (state === `STATE_CALCULATING) ? (done        ? `STATE_DONE : `STATE_CALCULATING) :
                    (state === `STATE_DONE)        ?  `STATE_IDLE : `STATE_IDLE;

assign block_done = (state === `STATE_DONE);

// alpha values for dct calculation
wire signed [8:0] alpha_u; // Q1.8
wire signed [8:0] alpha_v; // Q1.8

assign alpha_u = (u === 3'b000) ? root_one_over_n : root_two_over_n;
assign alpha_v = (v === 3'b000) ? root_one_over_n : root_two_over_n;

// fixed point cosine values
reg signed [9:0] cosine_vals [BLOCK_SIZE-1:0][BLOCK_SIZE-1:0]; // Q2.8

reg signed [26:0] sum_values  [BLOCK_SIZE-1:0][BLOCK_SIZE-1:0]; // Q2.8 * Q2.8 * Q9.0 = Q13.16

// add integer bits to accumulate values - Q20.16
reg signed [35:0] sum;

wire signed [DCT_OUT_WIDTH-1:0] nxt_dct_block [BLOCK_SIZE-1:0][BLOCK_SIZE-1:0]; // Q20.16 + Q1.8 + Q1.8 = Q22.32
reg  signed [DCT_OUT_WIDTH-1:0] dct_block     [BLOCK_SIZE-1:0][BLOCK_SIZE-1:0]; // Q20.16 + Q1.8 + Q1.8 = Q22.32

always_comb begin
    for (int x = 0; x < BLOCK_SIZE; x = x + 1) begin
        for (int y = 0; y < BLOCK_SIZE; y = y + 1) begin
            sum_values[x][y] = block[x][y] * cosine_vals[x][u] * cosine_vals[y][v]; // TODO: check fixed point bit width reqs
        end
    end

    sum = sum_values[0][0] + sum_values[0][1] + sum_values[0][2] + sum_values[0][3] +
          sum_values[0][4] + sum_values[0][5] + sum_values[0][6] + sum_values[0][7] +
          sum_values[1][0] + sum_values[1][1] + sum_values[1][2] + sum_values[1][3] +
          sum_values[1][4] + sum_values[1][5] + sum_values[1][6] + sum_values[1][7] +
          sum_values[2][0] + sum_values[2][1] + sum_values[2][2] + sum_values[2][3] +
          sum_values[2][4] + sum_values[2][5] + sum_values[2][6] + sum_values[2][7] +
          sum_values[3][0] + sum_values[3][1] + sum_values[3][2] + sum_values[3][3] +
          sum_values[3][4] + sum_values[3][5] + sum_values[3][6] + sum_values[3][7] +
          sum_values[4][0] + sum_values[4][1] + sum_values[4][2] + sum_values[4][3] +
          sum_values[4][4] + sum_values[4][5] + sum_values[4][6] + sum_values[4][7] +
          sum_values[5][0] + sum_values[5][1] + sum_values[5][2] + sum_values[5][3] +
          sum_values[5][4] + sum_values[5][5] + sum_values[5][6] + sum_values[5][7] +
          sum_values[6][0] + sum_values[6][1] + sum_values[6][2] + sum_values[6][3] +
          sum_values[6][4] + sum_values[6][5] + sum_values[6][6] + sum_values[6][7] +
          sum_values[7][0] + sum_values[7][1] + sum_values[7][2] + sum_values[7][3] +
          sum_values[7][4] + sum_values[7][5] + sum_values[7][6] + sum_values[7][7];
          
    dct_block[u][v] = alpha_u * alpha_v * sum;
end

generate
    genvar i, j;
    for (i = 0; i < BLOCK_SIZE; i = i + 1) begin
        for (j = 0; j < BLOCK_SIZE; j = j + 1) begin
            assign nxt_dct_block[i][j] = dct_block[i][j];

            ff_en #(
                .WIDTH(DCT_OUT_WIDTH)
            ) dct_ff (
                .clk(clk),
                .rst_n(rst_n),
                .en((u === i) & (v === j)),
                .rst_val('0),
                .D(nxt_dct_block[i][j]),

                .Q(dct_block_out[i][j])
            );
        end
    end
endgenerate

double_counter double_counter_i (
    .clk(clk),
    .rst_n(rst_n),
    .restart(restart),
    .go(go),

    .u(u),
    .v(v),
    .done(done)
);

ff_en #(
    .WIDTH(2)
) state_ff (
    .clk(clk),
    .rst_n(rst_n),
    .en(1'b1),
    .rst_val(`STATE_IDLE),
    .D(next_state),

    .Q(state)
);

initial begin
    $readmemb("cosine_vals.mem", cosine_vals);
end
    
endmodule