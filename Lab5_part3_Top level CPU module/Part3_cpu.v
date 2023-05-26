// // Lab5 Part3
// // Group 6 : E/18/147
// //           E/18/379

/* ************************************************************************************************************* */
module cpu(PC, INSTRUCTION, CLK, RESET);

/*****Declaration of reg/wires*****/

//inputs and outputs to the CPU 
    input [31:0]INSTRUCTION;                    //inputs Instruction
    input CLK, RESET;                           //input clock an reset
    output reg [31:0] PC;                       //outputs the next instruciton to be executed(PC) 

//PC register
    reg [31:0] PCregister;

//extracted OPCODE, Read registeer1, readregister2, writing register and immediate value
    reg [2:0] READREG1, READREG2, INADDRESS;    //registers to store registers to read and write
    reg [7:0] OPCODE;
    reg signed[7:0] IMMEDIATE;          //registers to store opcode and immediatee values

//Control signal outputs of the Control Unit
    wire WRITEENABLE;                           // Input signal to the register file
    wire SUB_ADD, IMM;                          // Select signals to the two muxs
    wire [2:0] ALUOP;                           // Select signal for the ALU

//register file output wire connections
    wire signed [7:0] OUT1, OUT2;   

//outputs of muxs and ALU
    wire signed[7:0] OUT2_1, OUT2_2, RESULT;

//for getting 2s Complement
    reg signed[7:0] OUT2_2s;

/***BEGIN OPERATIONS***/

//synchronous always block for PC update
    always @(posedge CLK) begin
        #1                              // Unit time delay
        if (RESET) PC = 0;              //for reseting CPU and Register
        else PC = PCregister;           //else move to next instruction
    end    

//always block to increment the pc register value
    always @(PC) begin
        #1                              // Unit time delay
        PCregister = PC + 4;
    end

//always block to extract instruction parts. Trigger when an instruciton is recieved.
    always @(INSTRUCTION) begin

    OPCODE = INSTRUCTION[31:24];            //extract  opcode from instruction
    INADDRESS = INSTRUCTION[23:16];         //extract writing register
    READREG1 = INSTRUCTION[15:8];           //extract Read register 1 from instruction
    READREG2 = INSTRUCTION[7:0];            //Read register 2 from instruction
    IMMEDIATE = INSTRUCTION[7:0];           //extract immediate value from instruction

    end

//initiating control unit
    ControlUnit CU( WRITEENABLE, ALUOP, SUB_ADD, IMM, OPCODE);

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
    alu ALU(OUT1, OUT2_2, RESULT, ALUOP);               //delay of #2 maximum

endmodule

//module for Control unit
module ControlUnit (WRITEENABLE, ALUOP, SUB_ADD, IMM, OPCODE);

//Output control signals   
    output reg SUB_ADD,IMM, WRITEENABLE;
    output reg [2:0] ALUOP;

//Input signal
    input [7:0] OPCODE;

//always block to set ALUOP
    always @(OPCODE) begin
        WRITEENABLE = 0;
        #1                          //delay of 1 time unit
        case(OPCODE)
        8'b00000010: ALUOP = 3'b001;        //add instruction
        8'b00000011: ALUOP = 3'b001;        //sub instruction
        8'b00000100: ALUOP = 3'b010;        //and instruction
        8'b00000101: ALUOP = 3'b011;        //or instruction
        8'b00000000: ALUOP = 3'b000;        //loadi instruction
        8'b00000001: ALUOP = 3'b000;        //mov instruction
        default:  ALUOP = 3'bxxx;           //default

        endcase

//for sub instruction SUB_ADD=1 for add SUB_ADD=0
    if (OPCODE==8'b00000011) SUB_ADD=1;
    else SUB_ADD=0;

//for loadi IMM=1 else IMM=0
    if(OPCODE==8'b00000000) IMM=1;
    else IMM=0;

//ready to write to register at next positive clock edge
    WRITEENABLE = 1;
    end
endmodule


//2x1 MUX module 
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