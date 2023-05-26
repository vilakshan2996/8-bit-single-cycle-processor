module testbench;

    reg [7:0] DATA1, DATA2;
    reg [2:0] SELECT;
    wire [7:0] RESULT;

    alu ALU(DATA1, DATA2, SELECT, RESULT);

    initial
    begin
        $monitor($time,  "  DATA1: %b           DATA2: %b              SELECT: %b             RESULT: %b", DATA1, DATA2, SELECT, RESULT);
    end

    initial
    begin
        DATA1 <= 8'b00001111;
        DATA2 <= 8'b11110000;
        SELECT <= 3'b000;

        #1

        DATA1 <= 8'b00001111;
        DATA2 <= 8'b11110000;
        SELECT <= 3'b001;

        #1

        DATA1 <= 8'b00001111;
        DATA2 <= 8'b11110000;
        SELECT <= 3'b010;

        #1

        DATA1 <= 8'b00001111;
        DATA2 <= 8'b11110000;
        SELECT <= 3'b011;
    end

endmodule


module alu(DATA1, DATA2, SELECT, RESULT);

    input [7:0] DATA1, DATA2;                     // Two inputs of 8 bit length
    input [2:0] SELECT;                           // An input of 3 bit length
    output [7:0] RESULT;                          // The output of 8 bit length

    wire [7:0] a,b,c,d,e,f,g,h;
    wire [7:0] out;

    // Instantiate the functional unit modules
    FORWARD F1 (DATA2, a);
    ADD A1 (DATA1, DATA2, b);
    AND A2 (DATA1, DATA2, c);
    OR O1 (DATA1, DATA2, d);

    // Instantiate the MUX to choose the right output
    MUX M1 (a,b,c,d,e,f,g,h,SELECT, out);

    // Assign the selected output to RESULT according to "SELECT"
    assign RESULT = out;

endmodule


module FORWARD(DATA2, out);

    input [7:0] DATA2;
    output [7:0] out;

    assign out = DATA2;

endmodule

module ADD(DATA1, DATA2, out);

    input [7:0] DATA1, DATA2;
    output [7:0] out;
    wire [7:0] carry;
    
    assign {carry, out} = DATA1 + DATA2;

endmodule

module AND(DATA1, DATA2, out);

    input [7:0] DATA1, DATA2;
    output [7:0] out;

    and(out[0], DATA1[0], DATA2[0]);
    and(out[1], DATA1[1], DATA2[1]);
    and(out[2], DATA1[2], DATA2[2]);
    and(out[3], DATA1[3], DATA2[3]);
    and(out[4], DATA1[4], DATA2[4]);
    and(out[5], DATA1[5], DATA2[5]);
    and(out[6], DATA1[6], DATA2[6]);
    and(out[7], DATA1[7], DATA2[7]);

endmodule

module OR(DATA1, DATA2, out);

    input [7:0] DATA1, DATA2;
    output [7:0] out;

    or(out[0], DATA1[0], DATA2[0]);
    or(out[1], DATA1[1], DATA2[1]);
    or(out[2], DATA1[2], DATA2[2]);
    or(out[3], DATA1[3], DATA2[3]);
    or(out[4], DATA1[4], DATA2[4]);
    or(out[5], DATA1[5], DATA2[5]);
    or(out[6], DATA1[6], DATA2[6]);
    or(out[7], DATA1[7], DATA2[7]);

endmodule

module MUX(a,b,c,d,e,f,g,h, SELECT, out);
    
    input [7:0] a,b,c,d,e,f,g,h;
    input [2:0] SELECT;
    output reg [7:0] out;

    always @(a,b,c,d,e,f,g,h,SELECT)
    
    begin
        case(SELECT)

            3'b000: out = a;
            3'b001: out = b;
            3'b010: out = c;
            3'b011: out = d;
            3'b000: out = e;
            3'b000: out = f;
            3'b000: out = g;
            3'b000: out = h;

        endcase
    end
    
endmodule