// Computer Architecture (CO224) - Lab 05
// Design: Testbench of Integrated CPU of Simple Processor
// Author: Isuru Nawinne
`timescale 1ns/100ps
module cpu_tb;

    reg CLK, RESET;
    wire [31:0] PC;
    wire I_READ;
    reg [31:0] INSTRUCTION;

    //wires to facilitate cache read/write
    wire [7:0] READDATA, WRITEDATA, ADDRESS;    
    wire WRITE, READ, BUSYWAIT, iBUSYWAIT;


    //wires to facilitate memory read/write
    wire [31:0] mem_READDATA, mem_WRITEDATA;
    wire [5:0] mem_ADDRESS;    
    wire mem_WRITE, mem_READ, mem_BUSYWAIT;

    wire [31:0] readinst;
    wire [5:0] imem_ADDRESS;
    wire imem_READ, imem_BUSYWAIT;
    wire [127:0] imem_READDATA;

    //integer i;
    /* 
    ------------------------
     SIMPLE INSTRUCTION MEM
    ------------------------
    */
    
    // TODO: Initialize an array of registers (8x1024) named 'instr_mem' to be used as instruction memory

    reg [7:0] instr_mem [0:1023];                   // Memory allocated for 1024 words
                                                    // 256 Instructions (256 instructions * 4 words per instruction = 1024 words)

    // TODO: Create combinational logic to support CPU instruction fetching, given the Program Counter(PC) value 
    //       (make sure you include the delay for instruction fetching here)
    
    // Intsruction fetching is done when ever the PC register is updated
    // always @(PC) begin
    //     #2                                          // Instruction fetching delay
    //     // Concatenate 4 words to form an instruction
    //     //INSTRUCTION = {instr_mem[PC],instr_mem[PC+1],instr_mem[PC+2],instr_mem[PC+3]};
    //     INSTRUCTION = {instr_mem[PC+3],instr_mem[PC+2],instr_mem[PC+1],instr_mem[PC]};

    // end

    // initial
    // begin
    //     // Initialize instruction memory with the set of instructions you need execute on CPU
        
    //     // METHOD 1: manually loading instructions to instr_mem
    //     // {instr_mem[10'd3], instr_mem[10'd2], instr_mem[10'd1], instr_mem[10'd0]} = 32'b00000010000000000000001000000000;
    //     // {instr_mem[10'd7], instr_mem[10'd6], instr_mem[10'd5], instr_mem[10'd4]} = 32'b00000000000000000000011000000000;
    //     // {instr_mem[10'd11], instr_mem[10'd10], instr_mem[10'd9], instr_mem[10'd8]} = 32'b00001010000000000000000100000000;
    //     // {instr_mem[10'd15], instr_mem[10'd14], instr_mem[10'd13], instr_mem[10'd12]} = 32'b00000010000001100000011000000010;
    //     // {instr_mem[10'd19], instr_mem[10'd18], instr_mem[10'd17], instr_mem[10'd16]} = 32'b00000001000001100000000100000111;
    //     // {instr_mem[10'd23], instr_mem[10'd22], instr_mem[10'd21], instr_mem[10'd20]} = 32'b00000000000000001111110100000110;
    //     // {instr_mem[10'd27], instr_mem[10'd26], instr_mem[10'd25], instr_mem[10'd24]} = 32'b01100011000000000000011100000000;
        
    //     // METHOD 2: loading instr_mem content from instr_mem.mem file
    //     $readmemb("instr_mem.mem", instr_mem);
    
    // end
    
    /* 
    -----
     CPU
    -----
    */
    //cpu mycpu(PC, INSTRUCTION, CLK, RESET, WRITEDATA, READDATA, ADDRESS, WRITE, READ, BUSYWAIT, I_READ);
    cpu mycpu(PC, readinst, CLK, RESET, WRITEDATA, READDATA, ADDRESS, WRITE, READ, BUSYWAIT, iBUSYWAIT, I_READ);

    //cache memory
    data_cache data_cach(BUSYWAIT, READDATA, mem_READ, mem_WRITE, mem_WRITEDATA, mem_ADDRESS, READ, WRITE, WRITEDATA, ADDRESS, mem_BUSYWAIT, mem_READDATA, CLK, RESET);

    //data memory
    data_memory data_mem(CLK, RESET,mem_READ, mem_WRITE, mem_ADDRESS, mem_WRITEDATA, mem_READDATA, mem_BUSYWAIT);

    //instruction cache
    instruction_cache inst_cache (iBUSYWAIT, readinst, imem_READ, imem_ADDRESS, I_READ, PC[9:0], imem_BUSYWAIT, imem_READDATA, CLK, RESET);

    //instruction memory
    instruction_memory inst_memory (CLK, imem_READ, imem_ADDRESS,imem_READDATA, imem_BUSYWAIT);

    initial
    begin
    
        // generate files needed to plot the waveform using GTKWave
        $dumpfile("cpu_wavedata.vcd");
		$dumpvars(0, cpu_tb);
        
        CLK = 1'b0;
        RESET = 1'b0;
        
        // TODO: Reset the CPU (by giving a pulse to RESET signal) to start the program execution
        #2
        RESET = 1'b1;

        #5
        RESET = 1'b0;

        // #43                                                     // 50th time unit: Another reset signal to restart the program
        // RESET = 1'b1;

        // #4
        // RESET = 1'b0;
        
        // finish simulation after some time
        #20000
        $finish;

        
    end
    
    // clock signal generation
    always
        #4 CLK = ~CLK;
    
endmodule