module ff_en #(
    parameter WIDTH = 3
) (
    input wire clk,
    input wire rst_n,
    input wire en,
    input wire [WIDTH-1:0] rst_val,
    input wire [WIDTH-1:0] D,

    output reg [WIDTH-1:0] Q
);

always_ff @(posedge clk) begin
    if (!rst_n) begin
        Q <= rst_val;
    end else if (en) begin
        Q <= D;
    end else begin
        Q <= Q;
    end
end
    
endmodule