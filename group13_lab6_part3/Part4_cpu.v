// // Lab5 Part3
// // Group 6 : E/18/147
// //           E/18/379
`timescale 1ns/100ps
/* ************************************************************************************************************* */
module cpu(PC, INSTRUCTION, CLK, RESET, WRITEDATA, READDATA, ADDRESS, WRITE, READ, BUSYWAIT, iBUSYWAIT, INST_READ);

/*****Declaration of reg/wires*****/

//inputs and outputs to the CPU 
    input [31:0]INSTRUCTION;                    //inputs Instruction
    input CLK, RESET;
    input BUSYWAIT, iBUSYWAIT;                             //input clock an reset
    output reg [31:0] PC;                       //outputs the next instruciton to be executed(PC)

    //inputs/outputs to the data memory
    output [7:0] WRITEDATA, ADDRESS;            //outputs to the data memory 
    output WRITE, READ;
    output reg INST_READ;

    input [7:0]  READDATA;                      //input reada data from data memory

//PC register afetr +4
    reg [31:0] PCregister;

//PC register after the branch/jump
    reg [31:0] PCregister_JB;

//Output of the branch mux 
    wire [31:0] PCvalue;

//extracted OPCODE, Read registeer1, readregister2, writing register and immediate value
    reg [2:0] READREG1, READREG2, INADDRESS;    //registers to store registers to read and write
    reg [7:0] OPCODE;
    reg signed[7:0] IMMEDIATE;
    reg signed[31:0] IMMEDIATE_JB;              //register to store an immediatee value for branch/jump instructions

//Control signal outputs of the Control Unit
    wire WRITEENABLE;                           // Input signal to the register file
    wire SUB_ADD, IMM;                          // Select signals to the two muxs
    wire JUMP, BRANCH;                          // Used in the jump/branch selection muxs                                                
    wire [2:0] ALUOP;                           // Select signal for the ALU
    wire left_right;                            // Select bit for left or right shift

// The output of the AND gate which determines whether beq is taken or not    
    wire JUMP_TAKEN, BEQ_TAKEN;

// The output of the AND gate which determines whether bne is taken or not
    wire BNE_TAKEN;

// The output of the OR gate to be used as the select bit of the mux
    wire SEL;                       

//register file output wire connections
    wire signed [7:0] OUT1, OUT2;   

//outputs of muxs and ALU
    wire signed[7:0] OUT2_1, OUT2_2, ALURESULT;
    wire ZERO;                                  // A wire to the input of the and gate
                                                // Carries a value of 1 if the subtraction is 0 (register values are equal)

//for getting 2s Complement
    reg signed[7:0] OUT2_2s;

//control  signals/wires for choosing result  over memory read
    wire[7:0] RESULT;
    wire AluOrMemRead;

/***BEGIN OPERATIONS***/

/***********************************************PC MODULE BEGIN****************************************************/
//synchronous always block for PC update
    always @(posedge CLK) begin

            if(!BUSYWAIT) begin                     //if busywait is not asserted move to next instruction else stall     
                #1                                      // Unit time delay
                if (RESET) PC = 0;                  //for reseting CPU and Register
                else if (iBUSYWAIT) PC = PC;           
                else PC = PCvalue;                  //else move to next instruction
                
                INST_READ = 1'b1;
            end

            // if(iBUSYWAIT) begin
            //     #1
            //     PC = PC;
            // end 

    end    

//always block to increment the pc register value
    always @(PC) begin
        #1                              // Unit time delay
        PCregister = PC + 4;
    end

//An adder to calculate the branch/jump addresses
    always @(PCregister)
    #1
    begin
        #2 PCregister_JB = PCregister + (4*IMMEDIATE_JB);
    end 

//instantiate the beq mux
    MUX2x1PC mux_branch(PCvalue, PCregister, PCregister_JB, SEL);


/**********************************************END OF PC MODULE***************************************************/

//always block to extract instruction parts. Trigger when an instruciton is recieved.
    always @(INSTRUCTION) begin
    
    OPCODE = INSTRUCTION[31:24];            //extract  opcode from instruction
    INADDRESS = INSTRUCTION[23:16];         //extract writing register
    READREG1 = INSTRUCTION[15:8];           //extract Read register 1 from instruction
    READREG2 = INSTRUCTION[7:0];            //Read register 2 from instruction
    IMMEDIATE = INSTRUCTION[7:0];           //extract immediate value from instruction
    IMMEDIATE_JB = $signed(INSTRUCTION[23:16]);      //extract the immediate value for j/beq instructions if any and sign extend it
    
    end
//initiating control unit
    ControlUnit CU(INSTRUCTION, WRITEENABLE, ALUOP, SUB_ADD, IMM, JUMP, BRANCH, left_right, OPCODE, BUSYWAIT, iBUSYWAIT, READ, WRITE,AluOrMemRead);

//selecting result or memory output
    MUX2x1 memOrResult(RESULT, ALURESULT, READDATA, AluOrMemRead);

//creating register file object
    reg_file register(RESULT, OUT1, OUT2, INADDRESS, READREG1, READREG2, WRITEENABLE, CLK, RESET);

//always block to get 2s Complement. The always block is triggered whenever the OUT2 changes
    always @(OUT2) begin
        #1                                      //delay 1 seconds
        OUT2_2s = ~OUT2 + 8'd1;                 //increment by 1 to get 2s complement
    end

//choosing 2s complement
    MUX2x1 Mux1(OUT2_1, OUT2, OUT2_2s, SUB_ADD);

//chosing immediate value or  register value
    MUX2x1 Mux2(OUT2_2, OUT2_1, IMMEDIATE, IMM);

//feeding result to ALU. Create an alu object
    alu ALU(OUT1, OUT2_2, ALURESULT, ALUOP, left_right,ZERO);               //delay of #2 maximum

//And gate for the jump instruction
    and A3 (JUMP_TAKEN,  JUMP, ~BRANCH);

//And gate for the beq instruction
    and A1(BEQ_TAKEN, BRANCH, ~JUMP, ZERO);

//And gate for the bne instruction
    and A2(BNE_TAKEN, BRANCH, JUMP, ~ZERO);

// Or gate to see for a jump, beq or bne
    or O1 (SEL, JUMP_TAKEN, BEQ_TAKEN, BNE_TAKEN);

//inputs  for data memory
    assign WRITEDATA = OUT1;
    assign ADDRESS = ALURESULT;

endmodule

//module for Control unit
module ControlUnit (INSTRUCTION,WRITEENABLE, ALUOP, SUB_ADD, IMM, JUMP, BRANCH, left_right, OPCODE, BUSYWAIT, iBUSYWAIT, READ, WRITE,AluOrMemRead);

//Output control signals   
    output reg SUB_ADD,IMM, WRITEENABLE, JUMP, BRANCH, left_right, READ, WRITE, AluOrMemRead;
    output reg [2:0] ALUOP;

//Input signal
    input [7:0] OPCODE;
    input BUSYWAIT, iBUSYWAIT;
    input [31:0]INSTRUCTION;   

//always block to set ALUOP
    always @(INSTRUCTION) begin

        WRITEENABLE = 0;
        #1                          //delay of 1 time unit
        case(OPCODE)

        8'd0: {ALUOP, SUB_ADD, IMM, WRITEENABLE, JUMP, BRANCH, READ, WRITE,AluOrMemRead} <= 11'b000_0_1_1_0_0_0_0_0;         //loadi
        8'd1: {ALUOP, SUB_ADD, IMM, WRITEENABLE, JUMP, BRANCH, READ, WRITE,AluOrMemRead} <= 11'b000_0_0_1_0_0_0_0_0;         //mov
        8'd2: {ALUOP, SUB_ADD, IMM, WRITEENABLE, JUMP, BRANCH, READ, WRITE,AluOrMemRead} <= 11'b001_0_0_1_0_0_0_0_0;         //add
        8'd3: {ALUOP, SUB_ADD, IMM, WRITEENABLE, JUMP, BRANCH, READ, WRITE,AluOrMemRead} <= 11'b001_1_0_1_0_0_0_0_0;         //sub
        8'd4: {ALUOP, SUB_ADD, IMM, WRITEENABLE, JUMP, BRANCH, READ, WRITE,AluOrMemRead} <= 11'b010_0_0_1_0_0_0_0_0;         //and
        8'd5: {ALUOP, SUB_ADD, IMM, WRITEENABLE, JUMP, BRANCH, READ, WRITE,AluOrMemRead} <= 11'b011_0_0_1_0_0_0_0_0;         //or
        8'd6: {SUB_ADD, IMM, WRITEENABLE, JUMP, BRANCH, READ, WRITE,AluOrMemRead} <= 8'b0_0_0_1_0_0_0_0;                    //jump
        8'd7: {ALUOP, SUB_ADD, IMM, WRITEENABLE, JUMP, BRANCH, READ, WRITE,AluOrMemRead} <= 11'b001_1_0_0_0_1_0_0_0;         //beq

        8'd8: {ALUOP, SUB_ADD, IMM, WRITEENABLE, JUMP, BRANCH, READ, WRITE,AluOrMemRead} <= 11'b000_0_0_1_0_0_1_0_1;         //lwd
        8'd9: {ALUOP, SUB_ADD, IMM, WRITEENABLE, JUMP, BRANCH, READ, WRITE,AluOrMemRead} <= 11'b000_0_1_1_0_0_1_0_1;         //lwi
        8'd10: {ALUOP, SUB_ADD, IMM, WRITEENABLE, JUMP, BRANCH, READ, WRITE, AluOrMemRead} <= 11'b000_0_0_0_0_0_0_1_0;        //swd
        8'd11: {ALUOP, SUB_ADD, IMM, WRITEENABLE, JUMP, BRANCH, READ, WRITE, AluOrMemRead} <= 11'b000_0_1_0_0_0_0_1_0;        //swi

        8'd12: {ALUOP, SUB_ADD, IMM, WRITEENABLE, JUMP, BRANCH, READ, WRITE,AluOrMemRead} <= 11'b001_1_0_0_1_1_0_0_0;        //bne
        8'd13: {ALUOP, SUB_ADD, IMM, WRITEENABLE, JUMP, BRANCH, left_right, READ, WRITE,AluOrMemRead} <= 12'b100_0_1_1_0_0_1_0_0_0;        //sll
        8'd14: {ALUOP, SUB_ADD, IMM, WRITEENABLE, JUMP, BRANCH, left_right, READ, WRITE,AluOrMemRead} <= 12'b100_0_1_1_0_0_0_0_0_0;        //sr1 
        8'd15: {ALUOP, SUB_ADD, IMM, WRITEENABLE, JUMP, BRANCH, READ, WRITE,AluOrMemRead} <= 11'b101_0_1_1_0_0_0_0_0;                      //sra
        8'd16: {ALUOP, SUB_ADD, IMM, WRITEENABLE, JUMP, BRANCH, READ, WRITE,AluOrMemRead} <= 11'b110_0_1_1_0_0_0_0_0;        //ror
        8'd17: {ALUOP, SUB_ADD, IMM, WRITEENABLE, JUMP, BRANCH, READ, WRITE,AluOrMemRead} <= 11'b111_0_0_1_0_0_0_0_0;        //mult

        endcase
        
    end

//for lwd/lwi instructions make WRITENABLE 1 only after data is loaded from the memory to prevent unknown values
//when BUSYWAIT signal is asserted wait for data to be loaded from the memory (40 time units) and make WRITEENABLE 1

    always @(BUSYWAIT) begin

        if(BUSYWAIT) begin
            WRITEENABLE=1'b0;
        end
        
        else if(!BUSYWAIT) begin
            if(READ) WRITEENABLE=1'b1;
            READ = 1'b0;
            WRITE = 1'b0;
        end
    end

endmodule


//2x1 MUX module- for 8 bit inputs and outputs
module MUX2x1(output1, input1, input2, select);
    
    //inputs - select bit and two inputs
    input [7:0]input1, input2;
    input select;        

    output reg [7:0]output1;                     //chosen input to be sent as the output

    //case block to implement the MUX
    always @(input1, input2, select) begin
      case (select)
        1'b0: output1 = input1;          //first choice  
        1'b1: output1 = input2;          //second choice
        
    endcase  
    end

endmodule

//2x1 MUX module- for 32 bit inputs and outputs
module MUX2x1PC(output1, input1, input2, select);
    
    //inputs - select bit and two inputs
    input [31:0]input1, input2;
    input select;        

    output reg [31:0]output1;                     //chosen input to be sent as the output

    //case block to implement the MUX
    always @(input1, input2, select) begin
      case (select)
        1'b0: output1 = input1;          //first choice  
        1'b1: output1 = input2;          //second choice
        
    endcase  
    end

endmodule