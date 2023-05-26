// ALU- TESTBENCH

module testbench;

    reg [7:0] OPERAND1, OPERAND2;                              // Two register inputs of 8-bit
    reg [2:0] ALUOP;                                           // A 3-bit select input
    wire [7:0] ALURESULT;                                      // An 8-bit wire to propagate the output  

    alu ALU(OPERAND1, OPERAND2, ALURESULT, ALUOP);             // Instatiate an alu module

    // Print the outputs when ever the inputs change
    initial
    begin
        
        $monitor($time, "  DATA1: %b           DATA2: %b              SELECT: %b             RESULT: %b", OPERAND1, OPERAND2, ALUOP, ALURESULT);
    end

    // To observe the timing on gtkwave
    initial
    begin
        $dumpfile("wavedata.vcd");
        $dumpvars(0,testbench);
    end

    // Assign the inputs
    initial
    begin
        
        // Forward
        OPERAND1 = 8'b00001111;
        OPERAND2 = 8'b11110000;
        ALUOP = 3'b000;                         // -> xxxxxxxx (Monitor will give an unknown value as it will take #1 delay for forward to give a result.)

        #2

        // ADD
        OPERAND1 = 8'b00001111;
        OPERAND2 = 8'b11110000;
        ALUOP = 3'b001;                         

        #3

        // AND
        OPERAND1 = 8'b00001111;
        OPERAND2 = 8'b11110000;
        ALUOP = 3'b010;

        #3

        // OR
        OPERAND1 = 8'b10001111;
        OPERAND2 = 8'b10110000;
        ALUOP = 3'b011;

        #20
        $finish;

    end
    

endmodule