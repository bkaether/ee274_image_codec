`include "ff_en.sv"
`include "double_counter.sv"

module dct_2d #(
    parameter BLOCK_SIZE = 8
) (
    input  wire clk,
    input  wire rst,
    input  wire start_block,
    input  wire [15:0] block     [BLOCK_SIZE][BLOCK_SIZE],

    output reg  [31:0] dct_block [BLOCK_SIZE][BLOCK_SIZE]
    output wire block_done;
);

// define states
`define STATE_IDLE        2'b00
`define STATE_CALCULATING 2'b01
`define STATE_DONE        2'b10

// define values to be used for alpha_u and alpha_v from gold software model ( 8.8 fixed point)
wire [15:0] root_one_over_n;
wire [15:0] root_two_over_n;
assign root_one_over_n = 16'h00_5b; // = ~0.3536
assign root_two_over_n = 16'h00_80; // = 0.5

// state signals
wire [1:0] next_state;
reg  [1:0] state;

// double counter signals
// inputs

// outputs
wire done;
wire [2:0] u;
wire [2:0] v;

assign next_state = (state === STATE_IDLE)        ? (start_block ? STATE_CALCULATING : STATE_IDLE) :
                    (state === STATE_CALCULATING) ? (done        ? STATE_DONE : STATE_CALCULATING) :
                    (state === STATE_DONE)        ?  STATE_IDLE

reg [15:0] alpha_u;
reg [15:0] alpha_v;

// FIXED point cosine values
reg [31:0] cosine_vals [BLOCK_SIZE][BLOCK_SIZE];
reg [31:0] sum_values  [BLOCK_SIZE][BLOCK_SIZE];



double_counter double_counter_i (
    .clk(clk),
    .rst(rst),
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
    .rst(rst),
    .en(1'b1),
    .rst_val(STATE_IDLE),
    .D(next_state),

    .Q(state)
);

initial begin
    $readmemh("../memfiles/cosine_vals.mem", cosine_vals)
end
    
endmodule