module riscv_mult_wrapper #(
    parameter N = 32   // 32 para RV32, 64 para RV64
) (
    input  wire             signed_A_i,   // decoder.signed_A_o
    input  wire             signed_B_i,   // decoder.signed_B_o
    input  wire             upper_i,      // decoder.upper_rem_o
    input  wire [N-1:0]     A_i,
    input  wire [N-1:0]     B_i,
    output wire [N-1:0]     result_o
);

    // ------------------------------------------------------------------
    // 1) Pré-processamento: extrai o sinal e converte para módulo (magnitude)
    // ------------------------------------------------------------------
    wire neg_a = signed_A_i & A_i[N-1];
    wire neg_b = signed_B_i & B_i[N-1];

    wire [N-1:0] abs_a = neg_a ? (~A_i + {{(N-1){1'b0}}, 1'b1}) : A_i;
    wire [N-1:0] abs_b = neg_b ? (~B_i + {{(N-1){1'b0}}, 1'b1}) : B_i;

    // ------------------------------------------------------------------
    // 2) Núcleo Karatsuba (VHDL, sem sinal) — instanciado a partir do Verilog
    //    Mixed-language: entidade VHDL vista como módulo pelo simulador/síntese
    // ------------------------------------------------------------------
    wire [2*N-1:0] prod_mag;

    karatsuba_mult #(
        .N(N)
    ) u_karatsuba (
        .A(abs_a),
        .B(abs_b),
        .P(prod_mag)
    );

    // ------------------------------------------------------------------
    // 3) Pós-processamento: corrige o sinal do resultado (XOR dos sinais)
    // ------------------------------------------------------------------
    wire sign_result = neg_a ^ neg_b;

    wire [2*N-1:0] prod_final = sign_result
                                 ? (~prod_mag + {{(2*N-1){1'b0}}, 1'b1})
                                 : prod_mag;

    // ------------------------------------------------------------------
    // 4) Seleção da saída: bits baixos (MUL) ou bits altos (MULH/MULHU/MULHSU)
    // ------------------------------------------------------------------
    assign result_o =  upper_i ? prod_final[2*N-1:N] : prod_final[N-1:0];

endmodule