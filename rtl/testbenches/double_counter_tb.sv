module double_counter_tb();
    reg clk;
    reg rst_n;
    reg restart;
    reg go;

    wire [2:0] u;
    wire [2:0] v;
    wire done;

    always #5 clk = ~clk;

    double_counter double_counter_i (
        .clk(clk),
        .rst_n(rst_n),
        .restart(restart),
        .go(go),

        .u(u),
        .v(v),
        .done(done)
    );


    initial begin
        clk <= 0;
        rst_n = 1;
        restart <= 0;
        go <= 0;
        #20
        rst_n = 0;
        #20
        rst_n = 1;
        #10
        go <= 1;
        #200
        go <= 0;
        #50
        restart <= 1;
        #50
        go <= 1;
        #10
        restart <= 0;
        #700
        $display("Test finished");
        $finish();
    end
endmodule