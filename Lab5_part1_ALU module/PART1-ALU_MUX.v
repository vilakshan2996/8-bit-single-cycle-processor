// MUX module (8x3 MUX)
module MUX(ForwardOut,AddOut,AndOut,OrOut,e,f,g,h, SELECT, out);
    
    input [7:0] ForwardOut,AddOut,AndOut,OrOut,e,f,g,h;                 // Eight 8-bit inputs to the MUX
    input [2:0] SELECT;                                                 // 3-bit select input
    output reg [7:0] out;                                               // 8-bit output of the mux (connected to the result port of the ALU)

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