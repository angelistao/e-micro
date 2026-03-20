module multiplier (
    input wire [15:0] A,
    input wire [15:0] B,

    output wire [31:0] P
);

    assign P = {16'h0000, A} * {16'h0000, B};

endmodule