// ALU MODULE

module alu(DATA1, DATA2, RESULT, SELECT);

    input [7:0] DATA1, DATA2;                     // Two inputs of 8 bit length
    input [2:0] SELECT;                           // An input of 3 bit length
    output [7:0] RESULT;                          // The output of 8 bit length

    wire [7:0] ForwardOut,AddOut,AndOut,OrOut,e,f,g,h;                   // Eight 8-bit wires to store the outputs of the modules
    wire [7:0] out;                                                      // A wire output to hold the output of the MUX

    // Instantiate the functional unit modules
    // These modules are run whenever any one of the parameters in the module sensitivity list changes.

    FORWARD F1 (DATA2, ForwardOut);                             // #1 delay
    ADD A1 (DATA1, DATA2, AddOut);                              // #2 delay
    AND A2 (DATA1, DATA2, AndOut);                              // #1 delay
    OR O1 (DATA1, DATA2, OrOut);                                // #1 delay

    // Instantiate the MUX to choose the right output
    // The MUX module is triggered when any one of the parameters in the module list is changed
    MUX M1 (ForwardOut,AddOut,AndOut,OrOut,e,f,g,h,SELECT, out);

    // Assign the selected output to RESULT according to "SELECT"
    assign RESULT = out;

endmodule