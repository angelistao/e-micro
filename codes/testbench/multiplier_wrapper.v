module multiplier_wrapper(

    // Inputs
    input wire clk_i,
    input wire rst_i,
    input wire mult_en_i,
    input wire [31:0] op_A_i,
    input wire [31:0] op_B_i,
    input wire signed_A_i,
    input wire signed_B_i,
    input wire upper_i,

    // Outputs
    output wire [31:0] result_o,
    output wire stall_o
);

    wire [31:0] 


    karatsuba_mult #(
        .N ( 32 )
    ) mult_inst (
        .A (),
        .B (),
        .P ()
    );




endmodule