module counter #(
    parameter WIDTH = 8,
    parameter MAX_COUNT = 60
) (
    input wire clk,
    input wire rst_n,
    input wire restart,
    input wire go,

    output wire [WIDTH-1:0] count,
    output wire done
);

    reg  [WIDTH-1:0] count_r;
    wire [WIDTH-1:0] nxt_count;

    assign nxt_count = restart ? '0 : (count_r + 1);
    assign done = (count === MAX_COUNT);

    assign count = count_r;

    ff_en #(
        .WIDTH(WIDTH)
    ) count_ff (
        .clk(clk),
        .rst_n(rst_n),
        .en(go | restart),
        .rst_val('0),
        .D(nxt_count),

        .Q(count_r)
    );

endmodule