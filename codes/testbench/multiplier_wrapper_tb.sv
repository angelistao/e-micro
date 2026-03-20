module multiplier_wrapper_tb;

    // Troquem esse parâmetro para alterar o número de testes
    localparam TESTS_NUM = 1000;
    localparam CLOCK_PERIOD = 50; //ns

    logic clk, rst;
    logic [15:0] A_tb, B_tb;
    logic [31:0] S_tb;
    int i, errors, tests;

    // troquem "multiplier" pelo nome da entity de vocês
    multiplier_wrapper DUT (
        .clk_i    ( clk  ),
        .rst_i    ( rst  ),
        .opA_i    ( A_tb ),
        .opB_i    ( B_tb ),
        .result_o ( S_tb )
    );


    task SetAB (
        input logic[15:0] A,
        input logic[15:0] B
    );
        A_tb = A;
        B_tb = B;
    endtask

    task TestResult();
        logic [31:0] S;

        S = {16'h0000, A_tb} * {16'h0000, B_tb};
        errors = (S_tb==S) ? errors : errors + 1; 

        // Se quiserem ver os números no terminal em binário altere %d para %h e para binário %b
        $display(  "|  %05d  |  %05d  |  %010d  |  %s  |%0d", A_tb, B_tb, S_tb, (S_tb==S ? "   ": "SIM") ,$time);


    endtask

    always #(CLOCK_PERIOD/2) clk <= ~clk;

    initial begin

        // Esse arquivo é para carregar no GTK Wave se estiverem usando
        $dumpfile("dump.vcd");
        $dumpvars(0, DUT);

        errors = 0;

        $display("\n+---------+---------+--------------+-------+--------");
        $display(  "|   A     |   b     |      S       | ERRO? | Time");
        $display(  "+---------+---------+--------------+-------+--------");

        A_tb = 16'h0000;
        B_tb = 16'h0000;

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
        

        
        for (i=0 ; i<TESTS_NUM ; i=i+1) begin
            #(2*CLOCK_PERIOD/10)
            SetAB($urandom, $urandom);
            #(8*CLOCK_PERIOD/10 + 2*CLOCK_PERIOD)
            TestResult();
        end

        #CLOCK_PERIOD

        $display(  "+---------+---------+--------------+-------+--------");
        $display(  "| Numero de Testes : %0d", TESTS_NUM+tests);
        $display(  "| Numero de Erros  : %0d", errors);
        $display(  "+---------------------------------------------------\n");
        $finish;


    end



endmodule