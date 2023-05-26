// ALU MODULE
module alu(DATA1, DATA2, RESULT, SELECT);

    input signed [7:0] DATA1, DATA2;                     // Two inputs of 8 bit length
    input signed [2:0] SELECT;                           // An input of 3 bit length
    output signed [7:0] RESULT;                          // The output of 8 bit length

    wire signed [7:0] ForwardOut,AddOut,AndOut,OrOut,e,f,g,h;                   // Eight 8-bit wires to store the outputs of the modules
    wire signed [7:0] out;                                                      // A wire output to hold the output of the MUX

    // Instantiate the functional unit modules
    // These modules are run whenever any one of the parameters in the module sensitivity list changes.

    FORWARD F1 (DATA2, ForwardOut);                             // #1 delay
    ADD A1 (DATA1, DATA2, AddOut);                              // #2 delay
    AND A2 (DATA1, DATA2, AndOut);                              // #1 delay
    OR O1 (DATA1, DATA2, OrOut);                                // #1 delay

    // Instantiate the MUX to choose the right output
    // The MUX module is triggered when any one of the parameters in the module list is changed
    MUX_8X3 M1 (ForwardOut,AddOut,AndOut,OrOut,e,f,g,h,SELECT, out);

    // Assign the selected output to RESULT according to "SELECT"
    assign RESULT = out;

endmodule

// FORWARD module
module FORWARD(DATA2, out);

    input signed [7:0] DATA2;                          // 8-bit input
    output signed [7:0] out;                           // 8-bit output

    assign #1 out = DATA2;                      // Assign DATA2 to the output with a 1 unit delay

endmodule

// ADD module
module ADD(DATA1, DATA2, out);

    input signed [7:0] DATA1, DATA2;                   // Two 8-bit inputs
    output signed [7:0] out;                           // 8-bit output
    wire signed [7:0] carry;                           // A wire to store the carry-out of the sum

    assign #2 {carry, out} = DATA1 + DATA2;        // Perform addition and assign the carry-out and sum accordingly with a 2 unit delay

endmodule

// AND module
module AND(DATA1, DATA2, out);

    input signed [7:0] DATA1, DATA2;                   // Two 8-bit inputs
    output signed [7:0] out;                           // 8-bit output

    // Perform the AND operation on every bit of the two inputs
    assign #1 out = DATA1 & DATA2;

endmodule

// OR module
module OR(DATA1, DATA2, out);

    input signed [7:0] DATA1, DATA2;                   // Two 8-bit inputs
    output signed [7:0] out;                           // 8-bit output

    // Perform the OR operation on every bit of the two inputs
    assign #1 out = DATA1 | DATA2;


endmodule

// MUX module (8x3 MUX)
module MUX_8X3(ForwardOut,AddOut,AndOut,OrOut,e,f,g,h, SELECT, out);

    input signed [7:0] ForwardOut,AddOut,AndOut,OrOut,e,f,g,h;                 // Eight 8-bit inputs to the MUX
    input signed[2:0] SELECT;                                                 // 3-bit select input
    output reg signed [7:0] out;                                               // 8-bit output of the mux (connected to the result port of the ALU)

    // An always block for the switch case
    always @(ForwardOut,AddOut,AndOut,OrOut,e,f,g,h,SELECT)
    begin
        // The case structure
        case(SELECT)
            3'b000: out = ForwardOut;               // Forward result
            3'b001: out = AddOut;                   // ADD result
            3'b010: out = AndOut;                   // AND result
            3'b011: out = OrOut;                    // OR result
            // Reserved for future operations
            3'b100: out = e;
            3'b101: out = f;
            3'b110: out = g;
            3'b111: out = h;
            default: out = 8'bxxxxxxxx;
        endcase
    end

endmodule
