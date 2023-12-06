`include "ff.sv"

module double_counter (
    input wire clk,
    input wire rst,
    input wire restart,
    input wire go,

    output wire [2:0] u,
    output wire [2:0] v,
    output wire done
);

reg [2:0] u_r;
reg [2:0] v_r;

wire [2:0] next_u;
wire [2:0] next_v;

assign next_u = restart ? '0 : ((v_r === 3'b111) ? (u_r + 1) : u_r);
assign next_v = restart ? '0 : (v_r + 1);
assign done = (u === 3'b111) & (v === 3'b111);

ffen u_ff (
    .clk(clk),
    .rst(rst),
    .en(go),
    .rst_val('0),
    .D(next_u),

    .Q(u_r)
);

ffen v_ff (
    .clk(clk),
    .rst(rst),
    .en(go | restart),
    .rst_val('0),
    .D(next_v),

    .Q(v_r)
);

    
endmodule