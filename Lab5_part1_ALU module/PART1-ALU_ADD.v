// ADD module
module ADD(DATA1, DATA2, out);

    input [7:0] DATA1, DATA2;                   // Two 8-bit inputs 
    output [7:0] out;                           // 8-bit output
    wire [7:0] carry;                           // A wire to store the carry-out of the sum
    
    assign #2 {carry, out} = DATA1 + DATA2;        // Perform addition and assign the carry-out and sum accordingly with a 2 unit delay

endmodule