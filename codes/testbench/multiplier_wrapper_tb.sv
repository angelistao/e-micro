module multiplier_wrapper_tb;

    // Troquem esse parâmetro para alterar o número de testes

    // Troquem esse parâmetro para alterar o número de testes
    `ifdef TESTS_NUM
        localparam TESTS_NUM_h = `TESTS_NUM;
    `else
        localparam TESTS_NUM_h = 100;
    `endif

    `ifdef WIDTH
        localparam DATA_WIDTH = `WIDTH;
    `else
        localparam DATA_WIDTH = 16;
    `endif

    localparam CLOCK_PERIOD = 2000; //ms

    logic clk, rst;
    logic [DATA_WIDTH-1:0] A_tb, B_tb;
    logic [ DATA_WIDTH*2-1:0] S_tb;
    int i, errors, tests;

    // troquem "multiplier" pelo nome da entity de vocês
    `ifdef POS_SYNTH
    multiplier_wrapper_N512 DUT (
        .clk_i    ( clk  ),
        .rst_i    ( rst  ),
        .opA_i    ( A_tb ),
        .opB_i    ( B_tb ),
        .result_o ( S_tb )
    );
    `else
        multiplier_wrapper #(
        .N(DATA_WIDTH)
    ) DUT (
        .clk_i    ( clk  ),
        .rst_i    ( rst  ),
        .opA_i    ( A_tb ),
        .opB_i    ( B_tb ),
        .result_o ( S_tb )
    );
    `endif


    task SetAB (
        input logic[DATA_WIDTH-1:0] A,
        input logic[DATA_WIDTH-1:0] B
    );
        A_tb = A;
        B_tb = B;
    endtask

    task TestResult();
        logic [DATA_WIDTH*2-1:0] S;

        S = {{DATA_WIDTH{1'b0}}, A_tb} * {{DATA_WIDTH{1'b0}}, B_tb};
        errors = (S_tb==S) ? errors : errors + 1; 

        // Se quiserem ver os números no terminal em binário altere %d para %h e para binário %b
        $display(  "|  %05d  |  %05d  |  %010d  |  %s  |%0d", A_tb, B_tb, S_tb, (S_tb==S ? "   ": "SIM") ,$time);


    endtask

    always #(CLOCK_PERIOD/2) clk <= ~clk;

    initial begin

        // Esse arquivo é para carregar no GTK Wave se estiverem usando
        $dumpfile("multiplier_wrapper.vcd");
        $dumpvars(0, DUT);

        errors = 0;

        $display("\n+---------+---------+--------------+-------+--------");
        $display(  "|   A     |   b     |      S       | ERRO? | Time");
        $display(  "+---------+---------+--------------+-------+--------");

        A_tb = {DATA_WIDTH{1'b0}};
        B_tb = {DATA_WIDTH{1'b0}};

        clk=0;
        rst=0;
        #(CLOCK_PERIOD/10)     // CLOCK_PERIOD * 1/10
        rst=1;
        #(CLOCK_PERIOD/10)     // CLOCK_PERIOD * 2/10
        rst=0;

        // CLOCK_PERIOD * 5/10 = BORDA DE SUBIDA

        #(2*CLOCK_PERIOD/10)     // CLOCK_PERIOD * 4/10

        // Se quiserem usar alguma combinação específica usem as 5 linhas abaixo:
        // #(2*CLOCK_PERIOD/10)
        // SetAB(16'hXXXX, 16'hXXXX);  // SetAB(operandA, operandB), Troquem XXXX pelo valor em hexadecimal
        // #(8*CLOCK_PERIOD/10 + 2*CLOCK_PERIOD)
        // tests = tests+1;
        // TestResult();
        //COPIEM AS 5 LINHAS ACIMA E COLEM AQUI DE NOVO PAR OUTRO PADRÃO
        

        
        for (i=0 ; i<TESTS_NUM_h ; i=i+1) begin
            #(2*CLOCK_PERIOD/10)
            SetAB($urandom, $urandom);
            #(8*CLOCK_PERIOD/10 + 2*CLOCK_PERIOD)
            TestResult();
        end

        #CLOCK_PERIOD

        $display(  "+---------+---------+--------------+-------+--------");
        $display(  "| Numero de Testes : %0d", TESTS_NUM_h+tests);
        $display(  "| Numero de Erros  : %0d", errors);
        $display(  "+---------------------------------------------------\n");
        $finish;


    end



endmodule