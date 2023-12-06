module double_counter_sv();
    reg clk;
    reg rst;
    reg restart;
    reg go;

    wire [2:0] u;
    wire [2:0] v;
    wire done;

    always #5 clock = ~clock;

    double_counter double_counter_i (
        .clk(clk),
        .rst(rst),
        .restart(restart),
        .go(go),

        .u(u),
        .v(v),
        .done(done)
    );


    initial begin
        clk <= 0;
        rst = 1;
        restart <= 0;
        go <= 0;
        #30
        go <= 1
        #200
        restart <= 0;
        #700
        $display("Test finished");
        $finish();
    end
endmodule