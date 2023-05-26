// AND module
module AND(DATA1, DATA2, out);

    input [7:0] DATA1, DATA2;                   // Two 8-bit inputs
    output [7:0] out;                           // 8-bit output

    // Perform the AND operation on every bit of the two inputs
    assign #1 out = DATA1 & DATA2;

endmodule