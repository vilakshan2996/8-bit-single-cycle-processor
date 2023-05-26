// FORWARD module
module FORWARD(DATA2, out);

    input [7:0] DATA2;                          // 8-bit input
    output [7:0] out;                           // 8-bit output

    assign #1 out = DATA2;                      // Assign DATA2 to the output with a 1 unit delay

endmodule