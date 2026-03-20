module multiplier_wrapper (
    input  wire clk_i,
    input  wire rst_i,
    input  wire [15:0] opA_i,
    input  wire [15:0] opB_i,

    output wire [31:0] result_o
);

    // Sinais internos
    reg  [15:0] reg_opA_s;
    reg  [15:0] reg_opB_s;
    reg  [31:0] reg_result_s;
    wire [31:0] result_s;

    // Registra as entradas A e B
    always@(posedge clk_i, posedge rst_i) begin
        if(rst_i)begin
            reg_opA_s <= 16'h0000;
            reg_opB_s <= 16'h0000;
        end
        else begin
            reg_opA_s <= opA_i;
            reg_opB_s <= opB_i;
        end
    end

    // Instancia o Multiplicador
    multiplier multiplier_inst (
        .A(reg_opA_s),
        .B(reg_opB_s),
        .P(result_s)
    );

    // Registra a saida S
    always@(posedge clk_i, posedge rst_i) begin
        if(rst_i)begin
            reg_result_s <= 32'h00000000;
        end
        else begin
            reg_result_s <= result_s;
        end
    end

    // Atribui a saida do circuito a saida do registrador
    assign result_o = reg_result_s;

endmodule