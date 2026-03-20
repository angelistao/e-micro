module multiplier_tb;

    // Troquem esse parâmetro para alterar o número de testes
    localparam TESTS_NUM = 10000;

    logic [15:0] A_tb, B_tb;
    logic [31:0] P_tb;
    int i, errors;

    // troquem "multiplier" pelo nome da entity de vocês
    multiplier DUT (
        .A( A_tb ),
        .B( B_tb ),
        .P( P_tb )
    );

    task TestResult(
        input logic[15:0] A,
        input logic[15:0] B
    );
        logic [31:0] S;

        
        S = {16'h0000, A} * {16'h0000, B};
        errors = (P_tb==S) ? errors : errors + 1; 

        // Se quiserem ver os números no terminal em binário altere %d para %h e para binário %b
        $display(  "|  %h  |  %h  |  %h  |  %s  |%0d", A_tb, B_tb, P_tb, (P_tb==S ? "   ": "SIM") ,$time);
        $fdisplay(log_file,  "|  %h  |  %h  |  %h  |  %s  |%0d", A_tb, B_tb, P_tb, (P_tb==S ? "   ": "SIM") ,$time);


    endtask

    int log_file;

    initial begin

        // Esse arquivo é para carregar no GTK Wave se estiverem usando
        $dumpfile("dump.vcd");
        $dumpvars(0, DUT);
        log_file = $fopen("multiplier_tb.log", "w");
        errors = 0;

        $display("\n+--------+--------+------------+-------+--------");
        $display(  "|   A    |   b    |      S     | ERRO? | Time");
        $display(  "+--------+--------+------------+-------+--------");

        $fdisplay(log_file, "\n+--------+--------+------------+-------+--------");
        $fdisplay(log_file,   "|   A    |   b    |      S     | ERRO? | Time");
        $fdisplay(log_file,   "+--------+--------+------------+-------+--------");
        

         #1

            // Se quiserem usar alguma combinação específica usem as 3 linhas abaixo:
            //A_tb = 16'hXXXX; // Troquem XXXX pelo valor em hexadecimal
            // B_tb = 16'hXXXX; 
            //#1 // #1 adiciona um delay de 1 seg na forma de onda

        A_tb = 16'h000A;
        B_tb = 16'h0005;
        #1
        TestResult(A_tb, B_tb);
        #1

        A_tb = 16'h0002;
        B_tb = 16'h0003;
        #1
        TestResult(A_tb, B_tb);
        #1

        A_tb = 16'hFFFF;
        B_tb = 16'h0002;
        #1
        TestResult(A_tb, B_tb);
        #1
        
        for (i=0 ; i<TESTS_NUM ; i=i+1) begin
            #1
            A_tb = $urandom; //Cria números aleatórios
            B_tb = $urandom;
            #1
            TestResult(A_tb, B_tb);
        end

        #1

        $display(  "+--------+--------+------------+-------+--------");
        $display(  "| Numero de Testes : %0d", TESTS_NUM);
        $display(  "| Numero de Erros  : %0d", errors);
        $display(  "+-----------------------------------------------\n");

        $fdisplay(log_file,  "+--------+--------+------------+-------+--------");
        $fdisplay(log_file,  "| Numero de Testes : %0d", TESTS_NUM);
        $fdisplay(log_file,  "| Numero de Erros  : %0d", errors);
        $fdisplay(log_file,  "+-----------------------------------------------\n");
        $finish;


    end



endmodule