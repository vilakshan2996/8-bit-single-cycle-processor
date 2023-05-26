// ALU MODULE
module alu(DATA1, DATA2, RESULT, SELECT, left_right, ZERO);

    input  signed [7:0] DATA1, DATA2;                     // Two inputs of 8 bit length
    input signed [2:0] SELECT;                           // An input of 3 bit length
    input left_right;
    output signed [7:0] RESULT;                          // Output of 8 bit length with the arithmetic calcultion
    output  ZERO;                                        // Output with the beq condition for data1 and data2 being equal or not

    wire signed [7:0] ForwardOut,AddOut,AndOut,OrOut,SllOut,SraOut,RorOut,MultOut;                   // Eight 8-bit wires to store the outputs of the modules
    wire signed [7:0] out;                                                      // A wire output to hold the output of the MUX

    // Instantiate the functional unit modules
    // These modules are run whenever any one of the parameters in the module sensitivity list changes.

    FORWARD F1 (DATA2, ForwardOut);                             // #1 delay
    ADD A1 (DATA1, DATA2, AddOut);                              // #2 delay
    AND A2 (DATA1, DATA2, AndOut);                              // #1 delay
    OR O1 (DATA1, DATA2, OrOut);                                // #1 delay
    sll_srl S1 (DATA1, DATA2, left_right,SllOut);               // #1 delay
    sra S2 (DATA1, DATA2, SraOut);                              // #1 delay
    ror R1(DATA1, DATA2, RorOut);                               // #1 delay
    mult MMM1(DATA1, DATA2, MultOut);                           // #3 delay                         

    // Instantiate the MUX to choose the right output
    // The MUX module is triggered when any one of the parameters in the module list is changed
    MUX_8X3 M1 (ForwardOut,AddOut,AndOut,OrOut,SllOut,SraOut,RorOut,MultOut,SELECT, out);

    // Assign the selected output to RESULT according to "SELECT"
    assign RESULT = out;

    // The branch if equal module which sets the value of the output zero to 1/0
    beq BEQ(ZERO, RESULT, SELECT);

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
module MUX_8X3(ForwardOut,AddOut,AndOut,OrOut,SllOut,SraOut,RorOut,MultOut, SELECT, out);

    input signed [7:0] ForwardOut,AddOut,AndOut,OrOut,SllOut,SraOut,RorOut,MultOut;                 // Eight 8-bit inputs to the MUX
    input signed[2:0] SELECT;                                                 // 3-bit select input
    output reg signed [7:0] out;                                               // 8-bit output of the mux (connected to the result port of the ALU)

    // An always block for the switch case
    always @(ForwardOut,AddOut,AndOut,OrOut,SllOut,SraOut,RorOut,MultOut,SELECT)
    begin
        // The case structure
        case(SELECT)
            3'b000: out = ForwardOut;               // Forward result
            3'b001: out = AddOut;                   // ADD result
            3'b010: out = AndOut;                   // AND result
            3'b011: out = OrOut;                    // OR result
            // Reserved for future operations
            3'b100: out = SllOut;
            3'b101: out = SraOut;
            3'b110: out = RorOut;
            3'b111: out = MultOut;
            default: out = 8'bxxxxxxxx;
        endcase
    end

endmodule

//Module for beq zero setting
module beq(ZERO, RESULT, SELECT);

    input signed [7:0] RESULT;                  // Get the output of the mux as an input
    input [2:0] SELECT;                         // Get the ALUOP as an input to determine if it is a subtraction                         
    output reg ZERO;                            // The output

    // An always block triggered everytime SELECT/RESULT changes
    always @(RESULT, SELECT)
    begin
        // If the subtraction is 0
        if(RESULT == 8'd0 && SELECT == 3'b001) ZERO = 1'b1;
        // For any other time
        else  ZERO = 1'b0;
    end

endmodule

module sll_srl(DATA1, DATA2,left_right, out);

    input [7:0] DATA1, DATA2;           // DATA1: Value to be shifted
                                        // DATA2: Shift amount
    input left_right;
    output [7:0] out;                   // Output of the shifter

    wire [7:0] out1,out2, out3, out4, out5, out6, out7, out8;
    wire [7:0] out11, out22, out33, out44, out55, out66, out77, out88, out_mux;

    wire orOutLeft, orOutRight;

    //Left shift
    //By 1
    oneBitShiftLeft O1 (DATA1[0], 1'b0, DATA2[0], out1[0]);
    oneBitShiftLeft O2 (DATA1[1], DATA1[0], DATA2[0], out1[1]);
    oneBitShiftLeft O3 (DATA1[2], DATA1[1], DATA2[0], out1[2]);
    oneBitShiftLeft O4 (DATA1[3], DATA1[2], DATA2[0], out1[3]);
    oneBitShiftLeft O5 (DATA1[4], DATA1[3], DATA2[0], out1[4]);
    oneBitShiftLeft O6 (DATA1[5], DATA1[4], DATA2[0], out1[5]);
    oneBitShiftLeft O7 (DATA1[6], DATA1[5], DATA2[0], out1[6]);
    oneBitShiftLeft O8 (DATA1[7], DATA1[6], DATA2[0], out1[7]);

    //By 2
    oneBitShiftLeft P1 (out1[0], 1'b0, DATA2[1], out2[0]);
    oneBitShiftLeft P2 (out1[1], 1'b0, DATA2[1], out2[1]);
    oneBitShiftLeft P3 (out1[2], out1[0], DATA2[1], out2[2]);
    oneBitShiftLeft P4 (out1[3], out1[1], DATA2[1], out2[3]);
    oneBitShiftLeft P5 (out1[4], out1[2], DATA2[1], out2[4]);
    oneBitShiftLeft P6 (out1[5], out1[3], DATA2[1], out2[5]);
    oneBitShiftLeft P7 (out1[6], out1[4], DATA2[1], out2[6]);
    oneBitShiftLeft P8 (out1[7], out1[5], DATA2[1], out2[7]);

    //By 4
    oneBitShiftLeft Q1 (out2[0], 1'b0, DATA2[2], out3[0]);
    oneBitShiftLeft Q2 (out2[1], 1'b0, DATA2[2], out3[1]);
    oneBitShiftLeft Q3 (out2[2], 1'b0, DATA2[2], out3[2]);
    oneBitShiftLeft Q4 (out2[3], 1'b0, DATA2[2], out3[3]);
    oneBitShiftLeft Q5 (out2[4], out2[0], DATA2[2], out3[4]);
    oneBitShiftLeft q6 (out2[5], out2[1], DATA2[2], out3[5]);
    oneBitShiftLeft q7 (out2[6], out2[2], DATA2[2], out3[6]);
    oneBitShiftLeft q8 (out2[7], out2[3], DATA2[2], out3[7]);

    //By 8 or more shifts
    or AAA1 (orOutLeft, DATA2[3], DATA2[4], DATA2[5], DATA2[6], DATA2[7]);

  
    oneBitShiftLeft R1 (out3[0], 1'b0, orOutLeft, out4[0]);
    oneBitShiftLeft R2 (out3[1], 1'b0, orOutLeft, out4[1]);
    oneBitShiftLeft R3 (out3[2], 1'b0, orOutLeft, out4[2]);
    oneBitShiftLeft R4 (out3[3], 1'b0, orOutLeft, out4[3]);
    oneBitShiftLeft R5 (out3[4], 1'b0, orOutLeft, out4[4]);
    oneBitShiftLeft R6 (out3[5], 1'b0, orOutLeft, out4[5]);
    oneBitShiftLeft R7 (out3[6], 1'b0, orOutLeft, out4[6]);
    oneBitShiftLeft R8 (out3[7], 1'b0, orOutLeft, out4[7]);


    //Right shift
    //By 1 
    oneBitShiftRight OO1 (1'b0, DATA1[7], DATA2[0], out11[7]);
    oneBitShiftRight OO2 (DATA1[7], DATA1[6], DATA2[0], out11[6]);
    oneBitShiftRight OO3 (DATA1[6], DATA1[5], DATA2[0], out11[5]);
    oneBitShiftRight OO4 (DATA1[5], DATA1[4], DATA2[0], out11[4]);
    oneBitShiftRight OO5 (DATA1[4], DATA1[3], DATA2[0], out11[3]);
    oneBitShiftRight OO6 (DATA1[3], DATA1[2], DATA2[0], out11[2]);
    oneBitShiftRight OO7 (DATA1[2], DATA1[1], DATA2[0], out11[1]);
    oneBitShiftRight OO8 (DATA1[1], DATA1[0], DATA2[0], out11[0]);

    //By 2
    oneBitShiftRight PP1 (1'b0, out11[7], DATA2[1], out22[7]);
    oneBitShiftRight PP2 (1'b0, out11[6], DATA2[1], out22[6]);
    oneBitShiftRight PP3 (out11[7], out11[5], DATA2[1], out22[5]);
    oneBitShiftRight PP4 (out11[6], out11[4], DATA2[1], out22[4]);
    oneBitShiftRight PP5 (out11[5], out11[3], DATA2[1], out22[3]);
    oneBitShiftRight PP6 (out11[4], out11[2], DATA2[1], out22[2]);
    oneBitShiftRight PP7 (out11[3], out11[1], DATA2[1], out22[1]);
    oneBitShiftRight PP8 (out11[2], out11[0], DATA2[1], out22[0]);

    //By 4
    oneBitShiftRight QQ1 ( 1'b0, out22[7], DATA2[2], out33[7]);
    oneBitShiftRight QQ2 ( 1'b0, out22[6], DATA2[2], out33[6]);
    oneBitShiftRight QQ3 ( 1'b0, out22[5], DATA2[2], out33[5]);
    oneBitShiftRight QQ4 ( 1'b0, out22[4], DATA2[2], out33[4]);
    oneBitShiftRight QQ5 (out22[7], out22[3], DATA2[2], out33[3]);
    oneBitShiftRight qQ6 (out22[6], out22[2], DATA2[2], out33[2]);
    oneBitShiftRight qQ7 (out22[5], out22[1], DATA2[2], out33[1]);
    oneBitShiftRight qQ8 (out22[4], out22[0], DATA2[2], out33[0]);

    //By 8 or more
    or AA (orOutRight, DATA2[3], DATA2[4], DATA2[5], DATA2[6], DATA2[7]);

    oneBitShiftRight RR1 (1'b0, out33[7], orOutRight, out44[7]);
    oneBitShiftRight RR2 (1'b0, out33[6], orOutRight, out44[6]);
    oneBitShiftRight RR3 (1'b0, out33[5], orOutRight, out44[5]);
    oneBitShiftRight RR4 (1'b0, out33[4], orOutRight, out44[4]);
    oneBitShiftRight RR5 (1'b0, out33[3], orOutRight, out44[3]);
    oneBitShiftRight RR6 (1'b0, out33[2], orOutRight, out44[2]);
    oneBitShiftRight RR7 (1'b0, out33[1], orOutRight, out44[1]);
    oneBitShiftRight RR8 (1'b0, out33[0], orOutRight, out44[0]);

    //MUX to choose between left or right shift
    mux2X1  MM (out44, out4, left_right, out_mux);

    //Assign the value to the output 
    assign #2 out = out_mux;

endmodule

//Arithmetic shift right
module sra(DATA1, DATA2, out);

    input [7:0] DATA1, DATA2;
    output [7:0] out;

    wire [7:0] out11, out22, out33, out44, out55, out66, out77, out88;
    wire orOutRight;

    //Right shift
    //By 1 
    oneBitShiftRight OO1 (DATA1[7], DATA1[7], DATA2[0], out11[7]);
    oneBitShiftRight OO2 (DATA1[7], DATA1[6], DATA2[0], out11[6]);
    oneBitShiftRight OO3 (DATA1[6], DATA1[5], DATA2[0], out11[5]);
    oneBitShiftRight OO4 (DATA1[5], DATA1[4], DATA2[0], out11[4]);
    oneBitShiftRight OO5 (DATA1[4], DATA1[3], DATA2[0], out11[3]);
    oneBitShiftRight OO6 (DATA1[3], DATA1[2], DATA2[0], out11[2]);
    oneBitShiftRight OO7 (DATA1[2], DATA1[1], DATA2[0], out11[1]);
    oneBitShiftRight OO8 (DATA1[1], DATA1[0], DATA2[0], out11[0]);

    //By 2
    oneBitShiftRight PP1 (DATA1[7], out11[7], DATA2[1], out22[7]);
    oneBitShiftRight PP2 (DATA1[7], out11[6], DATA2[1], out22[6]);
    oneBitShiftRight PP3 (out11[7], out11[5], DATA2[1], out22[5]);
    oneBitShiftRight PP4 (out11[6], out11[4], DATA2[1], out22[4]);
    oneBitShiftRight PP5 (out11[5], out11[3], DATA2[1], out22[3]);
    oneBitShiftRight PP6 (out11[4], out11[2], DATA2[1], out22[2]);
    oneBitShiftRight PP7 (out11[3], out11[1], DATA2[1], out22[1]);
    oneBitShiftRight PP8 (out11[2], out11[0], DATA2[1], out22[0]);

    //By 4
    oneBitShiftRight QQ1 (DATA1[7], out22[7], DATA2[2], out33[7]);
    oneBitShiftRight QQ2 (DATA1[7], out22[6], DATA2[2], out33[6]);
    oneBitShiftRight QQ3 (DATA1[7], out22[5], DATA2[2], out33[5]);
    oneBitShiftRight QQ4 (DATA1[7], out22[4], DATA2[2], out33[4]);
    oneBitShiftRight QQ5 (out22[7], out22[3], DATA2[2], out33[3]);
    oneBitShiftRight qQ6 (out22[6], out22[2], DATA2[2], out33[2]);
    oneBitShiftRight qQ7 (out22[5], out22[1], DATA2[2], out33[1]);
    oneBitShiftRight qQ8 (out22[4], out22[0], DATA2[2], out33[0]);

    or AA (orOutRight, DATA2[3], DATA2[4], DATA2[5], DATA2[6], DATA2[7]);
    

    //By 8 or more
    oneBitShiftRight RR1 (DATA1[7], out33[7], orOutRight, out44[7]);
    oneBitShiftRight RR2 (DATA1[7], out33[6], orOutRight, out44[6]);
    oneBitShiftRight RR3 (DATA1[7], out33[5], orOutRight, out44[5]);
    oneBitShiftRight RR4 (DATA1[7], out33[4], orOutRight, out44[4]);
    oneBitShiftRight RR5 (DATA1[7], out33[3], orOutRight, out44[3]);
    oneBitShiftRight RR6 (DATA1[7], out33[2], orOutRight, out44[2]);
    oneBitShiftRight RR7 (DATA1[7], out33[1], orOutRight, out44[1]);
    oneBitShiftRight RR8 (DATA1[7], out33[0], orOutRight, out44[0]);

    //1 time unit delay
    assign #2 out = out44;

endmodule 

//Rotate
module ror (DATA1, DATA2, out);

    input [7:0] DATA1, DATA2;
    output [7:0] out;

    wire [7:0] out11, out22, out33, out44, out55, out66, out77, out88;
    wire orOutRight;

    //Right shift
    //0
    oneBitShiftRight OO1 (DATA1[0], DATA1[7], DATA2[0], out11[7]);
    oneBitShiftRight OO2 (DATA1[7], DATA1[6], DATA2[0], out11[6]);
    oneBitShiftRight OO3 (DATA1[6], DATA1[5], DATA2[0], out11[5]);
    oneBitShiftRight OO4 (DATA1[5], DATA1[4], DATA2[0], out11[4]);
    oneBitShiftRight OO5 (DATA1[4], DATA1[3], DATA2[0], out11[3]);
    oneBitShiftRight OO6 (DATA1[3], DATA1[2], DATA2[0], out11[2]);
    oneBitShiftRight OO7 (DATA1[2], DATA1[1], DATA2[0], out11[1]);
    oneBitShiftRight OO8 (DATA1[1], DATA1[0], DATA2[0], out11[0]);

    //1
    oneBitShiftRight PP1 (out11[1], out11[7], DATA2[1], out22[7]);
    oneBitShiftRight PP2 (out11[0], out11[6], DATA2[1], out22[6]);
    oneBitShiftRight PP3 (out11[7], out11[5], DATA2[1], out22[5]);
    oneBitShiftRight PP4 (out11[6], out11[4], DATA2[1], out22[4]);
    oneBitShiftRight PP5 (out11[5], out11[3], DATA2[1], out22[3]);
    oneBitShiftRight PP6 (out11[4], out11[2], DATA2[1], out22[2]);
    oneBitShiftRight PP7 (out11[3], out11[1], DATA2[1], out22[1]);
    oneBitShiftRight PP8 (out11[2], out11[0], DATA2[1], out22[0]);

    //2
    oneBitShiftRight QQ1 (out22[3],out22[7], DATA2[2], out33[7]);
    oneBitShiftRight QQ2 (out22[2], out22[6], DATA2[2], out33[6]);
    oneBitShiftRight QQ3 (out22[1], out22[5], DATA2[2], out33[5]);
    oneBitShiftRight QQ4 (out22[0], out22[4], DATA2[2], out33[4]);
    oneBitShiftRight QQ5 (out22[7], out22[3], DATA2[2], out33[3]);
    oneBitShiftRight qQ6 (out22[6], out22[2], DATA2[2], out33[2]);
    oneBitShiftRight qQ7 (out22[5], out22[1], DATA2[2], out33[1]);
    oneBitShiftRight qQ8 (out22[4], out22[0], DATA2[2], out33[0]);

    or AA (orOutRight, DATA2[3], DATA2[4], DATA2[5], DATA2[6], DATA2[7]);

    //By 8 or more
    oneBitShiftRight RR1 (out33[7], out33[7], orOutRight, out44[7]);
    oneBitShiftRight RR2 (out33[6], out33[6], orOutRight, out44[6]);
    oneBitShiftRight RR3 (out33[5], out33[5], orOutRight, out44[5]);
    oneBitShiftRight RR4 (out33[4], out33[4], orOutRight, out44[4]);
    oneBitShiftRight RR5 (out33[3], out33[3], orOutRight, out44[3]);
    oneBitShiftRight RR6 (out33[2], out33[2], orOutRight, out44[2]);
    oneBitShiftRight RR7 (out33[1], out33[1], orOutRight, out44[1]);
    oneBitShiftRight RR8 (out33[0], out33[0], orOutRight, out44[0]);

    assign #2 out = out44;

endmodule 

// One bit left shift module
module oneBitShiftLeft(IN0, IN1,SHIFT, OUT);

    input IN0, IN1, SHIFT;
    output OUT;

    wire not1, leftAnd, rightAnd;

    not N1(not1, SHIFT);
    and A1(leftAnd, not1, IN0);
    and A2(rightAnd, SHIFT, IN1);

    or O1 (OUT, leftAnd, rightAnd);

endmodule 

// One bit right shift module
module oneBitShiftRight (IN0, IN1, SHIFT, OUT);

    input IN0, IN1, SHIFT;
    output OUT;

    wire not1, leftAnd, rightAnd;

    not N1(not1, SHIFT);
    and A1(leftAnd, IN0, SHIFT);
    and A2 (rightAnd , IN1, not1);

    or O1 (OUT, leftAnd, rightAnd);

endmodule 

module mux2X1(IN0, IN1, SEL, OUT);

    input signed [7:0] IN0, IN1;
    input SEL;
    output [7:0] OUT;

    reg [7:0] SELECT;

    wire [7:0] topAnd, bottomAnd;
                 
    and A1 [7:0] (topAnd, IN0, ~SEL);                    //When select is 0 -> srl
    and A2 [7:0] (bottomAnd, IN1, SEL);                  //When select is 1 -> sll
    or O1 [7:0] (OUT, topAnd, bottomAnd);

endmodule 

//Multiplication module
module mult (DATA1, DATA2, outFinal);

    input [7:0] DATA1, DATA2;                                   //Data input     
    output [7:0] outFinal;                 
    wire [7:0] out;                                           //Output

    //out[0]
    and AA1 (out[0], DATA1[0], DATA2[0]);

    //Wires for the and and nand gates to hold the partial product
    wire [2:0] temp1;
    wire [3:0] temp2;


    and AAZ1 (temp1[0], DATA1[1], DATA2[0]);
    and AA2 (temp1[1], DATA1[2], DATA2[0]);
    nand AA3 (temp1[2], DATA1[3], DATA2[0]);

    and AA4 (temp2[0], DATA1[0], DATA2[1]);
    and AA5 (temp2[1], DATA1[1], DATA2[1]);
    and AA6 (temp2[2], DATA1[2], DATA2[1]);
    nand AA7 (temp2[3], DATA1[3], DATA2[1]);

    //Wires for the carry out
    wire c1,c2,c3,c4;

    //Wire for the adder
    wire [2:0] adderOut1;

    //out[1]
    HalfAdder HH1 (out[1], c1, temp1[0], temp2[0]);
    FullAddder FF1 (adderOut1[0], c2, temp1[1], temp2[1], c1);
    FullAddder FF2 (adderOut1[1], c3, temp1[2], temp2[2], c2);
    FullAddder FF3 (adderOut1[2], c4, 1'b1, temp2[3], c3);

    //Wire for and and nand gates to hold the partial product
    wire [3:0] temp3;

    and BB1 (temp3[0], DATA1[0], DATA2[2]);
    and BB2 (temp3[1], DATA1[1], DATA2[2]);
    and BB3 (temp3[2], DATA1[2], DATA2[2]);
    nand BB4 (temp3[3], DATA1[3], DATA2[2]);

    //Wires for the carry out
    wire c5,c6,c7,c8;

    //Wire for the adder
    wire [2:0] adderOut2;

    //out[2]
    HalfAdder HH2 (out[2], c5, temp3[0], adderOut1[0]);
    FullAddder FF4 (adderOut2[0], c6, temp3[1], adderOut1[1], c5);
    FullAddder FF5 (adderOut2[1], c7, temp3[2], adderOut1[2], c6);
    FullAddder FF6 (adderOut2[2], c8, temp3[3], c4, c7);

    //Wire for and and nand gates to hold the partial product
    wire [3:0] temp4;

    //Wires for the carry out signals
    wire c9,c10,c11,c12, c13, c14;

    
    nand NNX1 (temp4[0], DATA1[0], DATA2[3]);
    nand NNY1 (temp4[1], DATA1[1], DATA2[3]);
    nand NNZ1 (temp4[2], DATA1[2], DATA2[3]);
    and NNP1 (temp4[3], DATA1[3], DATA2[3]);

    //out[3]
    HalfAdder HH3 (out[3], c9, temp4[0], adderOut2[0]);
    //out[4]
    FullAddder FF7 (out[4], c10, temp4[1], adderOut2[1], c9);
    //out[5]
    FullAddder FF8 (out[5], c11, temp4[2], adderOut2[2], c10);
    //out[6]
    FullAddder FF9 (out[6], c12, temp4[3], c8, c11);
    //out[7]
    HalfAdder HH4 (out[7], c14, 1'b1, c12);

    assign #3 outFinal = out;

endmodule 

//One bit full adder
module FullAddder (SUM, Cout, A, B, Cin);
    
    output SUM, Cout;                       // SUM: sum
                                            // Cout: carry out
    input A, B, Cin;                        // Three 1 bit inputs

    wire sum1, carry1, carry2;              //Wires to carry intermediate values

    //Implement a full adder with two half adders
    HalfAdder HH1 (sum1, carry1, A,B);              
    HalfAdder HH2 (SUM, carry2, sum1, Cin);

    //Or gate to get the carry out of the full adder
    or OO1 (Cout, carry2, carry1);

endmodule

//One bit half adder
module HalfAdder (S, C, A, B);
    
    output S, C;                            // S: sum
                                            // C: carry out
    input A, B;                             //Two 1 bit inputs

    //Sum out
    xor ab(S, A, B);
    //Carry out
    and ab1(C, A, B);

endmodule

