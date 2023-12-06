module dct_2d #(
    parameter BLOCK_SIZE = 8
) (
    input  wire [15:0] block     [BLOCK_SIZE][BLOCK_SIZE],
    output reg  [31:0] dct_block [BLOCK_SIZE][BLOCK_SIZE]
);

// define values to be used for alpha_u and alpha_v from gold software model ( 8.8 fixed point)
wire [15:0] root_one_over_n;
wire [15:0] root_two_over_n;

assign root_one_over_n = 16'h00_5b // = ~0.3536
assign root_two_over_n = 16'h00_80 // = 0.5

reg [15:0] alpha_u;
reg [15:0] alpha_v;

reg [31:0] cosine_vals [BLOCK_SIZE][BLOCK_SIZE];
reg [31:0] sum_values  [BLOCK_SIZE][BLOCK_SIZE];

initial begin
    $readmemh("../memfiles/cosine_vals.mem", cosine_vals)
end
    
endmodule